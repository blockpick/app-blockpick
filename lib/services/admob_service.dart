import 'package:flutter/foundation.dart';
// dart:io 는 웹에서 지원하지 않으므로 조건부 import
import 'dart:io' if (dart.library.html) 'package:blockpick_flutter/utils/platform_stub.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 서비스 — 보상형 광고 로드·표시·콜백 관리
///
/// 광고 단위 ID 우선순위:
///   1) dart-define `ADMOB_REWARDED_UNIT_ID` (프로덕션 배포 시 주입)
///   2) Google 공식 테스트 ID (fallback — 시뮬레이터/디버그 환경)
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  // 로드 대기 콜백 큐
  final List<VoidCallback> _pendingLoadCallbacks = [];
  final List<void Function(String)> _pendingFailCallbacks = [];

  // ── 플랫폼 지원 여부 ─────────────────────────────────────────────────────────

  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  // ── SDK 초기화 ───────────────────────────────────────────────────────────────

  /// AdMob SDK 초기화. main() 에서 한 번만 호출.
  static Future<void> initialize() async {
    if (!isSupported) {
      debugPrint('[AdMob] 이 플랫폼에서는 지원하지 않습니다.');
      return;
    }
    await MobileAds.instance.initialize();
    debugPrint('[AdMob] SDK 초기화 완료');
  }

  // ── 광고 단위 ID ─────────────────────────────────────────────────────────────

  /// dart-define 으로 주입된 ID, 없으면 Google 공식 테스트 ID 사용
  String get _rewardedAdUnitId {
    if (kIsWeb) throw UnsupportedError('웹에서는 지원하지 않습니다.');

    // dart-define 주입 값 (빌드 시: --dart-define=ADMOB_REWARDED_UNIT_ID=ca-app-pub-XXX/YYY)
    const injected = String.fromEnvironment('ADMOB_REWARDED_UNIT_ID');
    if (injected.isNotEmpty) return injected;

    // fallback: Google 공식 테스트 ID
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('지원하지 않는 플랫폼입니다.');
  }

  // ── 상태 조회 ────────────────────────────────────────────────────────────────

  /// 광고가 로드되어 표시 준비가 된 상태인지 확인
  bool get isReady => _rewardedAd != null;

  /// 광고 로딩 중 여부
  bool get isLoading => _isLoading;

  // ── 광고 미리 로드 ───────────────────────────────────────────────────────────

  /// 보상형 광고를 미리 로드합니다. 화면 진입 시 호출하세요.
  ///
  /// - 이미 로드된 경우: [onAdLoaded] 즉시 호출
  /// - 로딩 중인 경우: 완료 후 콜백 호출 (큐 방식)
  Future<void> preloadRewardedAd({
    VoidCallback? onAdLoaded,
    void Function(String error)? onAdFailedToLoad,
  }) async {
    if (!isSupported) {
      debugPrint('[AdMob] 이 플랫폼에서는 광고를 지원하지 않습니다.');
      onAdFailedToLoad?.call('지원하지 않는 플랫폼');
      return;
    }

    if (_rewardedAd != null) {
      debugPrint('[AdMob] 광고가 이미 로드되어 있습니다.');
      onAdLoaded?.call();
      return;
    }

    if (_isLoading) {
      debugPrint('[AdMob] 광고 로드 중 — 콜백 큐에 추가');
      if (onAdLoaded != null) _pendingLoadCallbacks.add(onAdLoaded);
      if (onAdFailedToLoad != null) _pendingFailCallbacks.add(onAdFailedToLoad);
      return;
    }

    _isLoading = true;
    debugPrint('[AdMob] 보상형 광고 로드 시작: $_rewardedAdUnitId');

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('[AdMob] 광고 로드 완료');
          _rewardedAd = ad;
          _isLoading = false;
          onAdLoaded?.call();
          for (final cb in _pendingLoadCallbacks) {
            cb();
          }
          _pendingLoadCallbacks.clear();
          _pendingFailCallbacks.clear();
        },
        onAdFailedToLoad: (error) {
          debugPrint('[AdMob] 광고 로드 실패: ${error.message}');
          _isLoading = false;
          onAdFailedToLoad?.call(error.message);
          for (final cb in _pendingFailCallbacks) {
            cb(error.message);
          }
          _pendingLoadCallbacks.clear();
          _pendingFailCallbacks.clear();
        },
      ),
    );
  }

  // ── 광고 표시 ────────────────────────────────────────────────────────────────

  /// 보상형 광고를 표시합니다.
  ///
  /// [onUserEarned]  — 사용자가 광고를 끝까지 시청하여 보상을 획득했을 때 호출
  /// [onClosed]      — 광고가 닫혔을 때 호출 (보상 획득 여부와 무관)
  /// [onFailed]      — 광고 표시 실패 시 호출
  ///
  /// 광고 닫힘/실패 후 자동으로 다음 광고를 미리 로드합니다.
  Future<void> showRewardedAd({
    required VoidCallback onUserEarned,
    VoidCallback? onClosed,
    void Function(String error)? onFailed,
  }) async {
    if (!isSupported) {
      debugPrint('[AdMob] 이 플랫폼에서는 광고를 지원하지 않습니다.');
      onFailed?.call('지원하지 않는 플랫폼');
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('[AdMob] 표시할 광고 없음 — preloadRewardedAd() 먼저 호출 필요');
      onFailed?.call('광고가 아직 준비되지 않았습니다. 잠시 후 다시 시도하세요.');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[AdMob] 광고 전체 화면 표시됨');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[AdMob] 광고 닫힘');
        ad.dispose();
        _rewardedAd = null;
        onClosed?.call();
        // 다음 광고 미리 로드 (fire-and-forget)
        preloadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[AdMob] 광고 표시 실패: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        onFailed?.call(error.message);
        // 다음 광고 미리 로드
        preloadRewardedAd();
      },
      onAdImpression: (ad) {
        debugPrint('[AdMob] 광고 노출 기록됨 (impression)');
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('[AdMob] 보상 획득: ${reward.amount} ${reward.type}');
        onUserEarned();
      },
    );
  }

  // ── 리소스 해제 ──────────────────────────────────────────────────────────────

  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
