import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/analytics/analytics_service.dart';
import '../core/graphql/graphql_client.dart';
import '../data/ad_reward/ad_reward_models.dart';
import '../data/ad_reward/ad_reward_remote_datasource.dart';
import '../services/admob_service.dart';

/// 신규 AdRewardRemoteDataSource provider — claimAdReward / myAdRewards 새 스키마용.
/// 기존 ad_reward_provider.dart 는 옛 ad_reward_service 를 감싸는 deprecated 버전.
final adRewardRemoteDataSourceProvider =
    FutureProvider<AdRewardRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return AdRewardRemoteDataSource(client);
});

/// 특정 블록픽의 내 광고 시청 로그 목록
final myAdRewardsProvider = FutureProvider.autoDispose
    .family<List<AdRewardLog>, String>((ref, blockpickId) async {
  final ds = await ref.watch(adRewardRemoteDataSourceProvider.future);
  return ds.fetchMyAdRewards(blockpickId: blockpickId);
});

// ── 광고 + 보상 청구 통합 흐름 ──────────────────────────────────────────────────

/// 광고 표시 + 백엔드 보상 청구를 한 흐름으로 처리하는 결과 타입
sealed class AdClaimResult {
  const AdClaimResult();
}

/// 성공: 광고 시청 완료 + 보상 청구 성공
class AdClaimSuccess extends AdClaimResult {
  const AdClaimSuccess({required this.log, this.ticketId});
  final AdRewardLog log;
  final String? ticketId;
}

/// 실패: 광고 미준비 또는 표시 실패
class AdClaimAdFailed extends AdClaimResult {
  const AdClaimAdFailed({required this.reason});
  final String reason;
}

/// 실패: 광고는 시청했지만 백엔드 청구 실패
class AdClaimBackendFailed extends AdClaimResult {
  const AdClaimBackendFailed({required this.error});
  final Object error;
}

/// 취소: 사용자가 광고를 보상 획득 전에 닫음
class AdClaimCancelled extends AdClaimResult {
  const AdClaimCancelled();
}

/// 광고 표시 + 백엔드 보상 청구를 한 흐름으로 처리합니다.
///
/// 사용법:
/// ```dart
/// final result = await ref.read(adRewardControllerProvider).showAdAndClaim(
///   blockpickId: widget.blockpickId,
///   contextType: 'blockpick',
/// );
/// ```
class AdRewardController {
  const AdRewardController(this._ref);

  final Ref _ref;

  AdMobService get _adMob => AdMobService();

  /// 광고를 표시하고, 시청 완료 시 백엔드 claimAdReward 를 호출합니다.
  ///
  /// [blockpickId]   — 보상 대상 블록픽 ID
  /// [contextType]   — Analytics 이벤트 컨텍스트 (예: 'blockpick', 'daily')
  Future<AdClaimResult> showAdAndClaim({
    required String blockpickId,
    String contextType = 'blockpick',
  }) async {
    // ── 1. 분석 이벤트: 광고 시청 시작 ──────────────────────────────────────
    AnalyticsService.track('ad_reward_started', {
      'context': contextType,
      'blockpickId': blockpickId,
    });

    // ── 2. 광고 표시 ─────────────────────────────────────────────────────────
    bool userEarned = false;
    String? adError;

    // Completer 없이 콜백을 동기화하는 방식: completer 대신 Future + callback
    final result = await _showAdWithCallbacks(
      onUserEarned: () => userEarned = true,
      onClosed: () {},
      onFailed: (err) => adError = err,
    );

    if (!result) {
      // 광고 표시 자체 실패
      final reason = adError ?? '광고를 불러오지 못했습니다.';
      AnalyticsService.track('ad_reward_failed', {
        'context': contextType,
        'blockpickId': blockpickId,
        'reason': reason,
      });
      return AdClaimAdFailed(reason: reason);
    }

    if (!userEarned) {
      // 광고를 끝까지 보지 않고 닫음
      AnalyticsService.track('ad_reward_failed', {
        'context': contextType,
        'blockpickId': blockpickId,
        'reason': 'cancelled_before_reward',
      });
      return const AdClaimCancelled();
    }

    // ── 3. 백엔드 보상 청구 ──────────────────────────────────────────────────
    try {
      final ds = await _ref.read(adRewardRemoteDataSourceProvider.future);

      // externalNetworkRef: 클라이언트 측 고유 참조값 (SSV 연동 시 활용)
      // TODO(SSV): Google AdMob SSV 콜백이 활성화되면 서버에서 직접 검증하므로
      //   이 값은 부가 식별자로만 사용됩니다. 백엔드 /admob/ssv 엔드포인트 신설 필요.
      final externalRef =
          'admob_${blockpickId}_${DateTime.now().millisecondsSinceEpoch}';

      final claimed = await ds.claimAdReward(
        blockpickId: blockpickId,
        externalNetworkRef: externalRef,
      );

      // ── 4. 분석 이벤트: 보상 완료 ────────────────────────────────────────
      AnalyticsService.track('ad_reward_completed', {
        'context': contextType,
        'blockpickId': blockpickId,
        'points': 5,
        'ticketId': claimed.ticketId ?? '',
      });

      return AdClaimSuccess(log: claimed.log, ticketId: claimed.ticketId);
    } catch (e) {
      debugPrint('[AdRewardController] 백엔드 청구 실패: $e');
      AnalyticsService.track('ad_reward_failed', {
        'context': contextType,
        'blockpickId': blockpickId,
        'reason': 'backend_claim_failed',
      });
      return AdClaimBackendFailed(error: e);
    }
  }

  /// 내부: 광고를 표시하고 결과(성공 여부)를 반환합니다.
  /// 콜백은 호출자가 클로저로 캡처한 변수를 수정합니다.
  Future<bool> _showAdWithCallbacks({
    required VoidCallback onUserEarned,
    required VoidCallback onClosed,
    required void Function(String) onFailed,
  }) async {
    if (!_adMob.isReady) {
      onFailed('광고가 아직 준비되지 않았습니다. 잠시 후 다시 시도하세요.');
      return false;
    }

    bool showSucceeded = true;

    // Future를 Completer 없이 처리: show() 자체는 광고가 닫힐 때까지 await
    await _adMob.showRewardedAd(
      onUserEarned: onUserEarned,
      onClosed: onClosed,
      onFailed: (err) {
        showSucceeded = false;
        onFailed(err);
      },
    );

    return showSucceeded;
  }
}

/// AdRewardController provider
final adRewardControllerProvider = Provider<AdRewardController>((ref) {
  return AdRewardController(ref);
});
