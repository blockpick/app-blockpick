// 책임: AdMob RewardedAd SDK 통합 + 백엔드 보상 청구 통합 흐름 (showAdAndGetReward).
// ad_reward_provider_v2는 백엔드 claimAdReward Mutation만 추상화하므로 본 provider와 보완 관계임 (대체 아님).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/graphql/graphql_client.dart';
import '../services/ad_reward_service.dart';
import '../services/admob_service.dart';

part 'ad_reward_provider.g.dart';

/// AdMob 서비스 Provider
@riverpod
AdMobService adMobService(Ref ref) {
  return AdMobService();
}

/// 광고 보상 서비스 Provider
@riverpod
Future<AdRewardService> adRewardService(Ref ref) async {
  final graphqlClient = await ref.watch(graphqlClientProvider.future);
  final adMobService = ref.watch(adMobServiceProvider);

  final service = AdRewardService(
    client: graphqlClient,
    adMobService: adMobService,
  );

  // 광고 미리 로드
  await service.preloadAd();

  ref.onDispose(() {
    service.dispose();
  });

  return service;
}

/// 광고 로드 상태
@riverpod
class AdLoadState extends _$AdLoadState {
  @override
  bool build() {
    final adMobService = ref.watch(adMobServiceProvider);
    return adMobService.isAdLoaded;
  }

  void setLoaded(bool loaded) {
    state = loaded;
  }

  Future<void> loadAd() async {
    final adMobService = ref.read(adMobServiceProvider);

    await adMobService.loadRewardedAd(
      onAdLoaded: () {
        state = true;
      },
      onAdFailedToLoad: (error) {
        state = false;
      },
    );
  }
}

/// 광고 보상 상태
class AdRewardState {
  final bool isLoading;
  final bool isShowingAd;
  final AdRewardResult? lastResult;
  final String? error;

  const AdRewardState({
    this.isLoading = false,
    this.isShowingAd = false,
    this.lastResult,
    this.error,
  });

  AdRewardState copyWith({
    bool? isLoading,
    bool? isShowingAd,
    AdRewardResult? lastResult,
    String? error,
  }) {
    return AdRewardState(
      isLoading: isLoading ?? this.isLoading,
      isShowingAd: isShowingAd ?? this.isShowingAd,
      lastResult: lastResult ?? this.lastResult,
      error: error,
    );
  }
}

/// 광고 보상 상태 Provider
@riverpod
class AdRewardNotifier extends _$AdRewardNotifier {
  @override
  AdRewardState build() {
    return AdRewardState();
  }

  /// 광고 시청 및 보상 받기
  Future<AdRewardResult?> showAdAndGetReward({
    required AdContextType contextType,
    required String userId,
    String? gameId,
    String? entryId,
  }) async {
    if (state.isLoading || state.isShowingAd) {
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final service = await ref.read(adRewardServiceProvider.future);

      final result = await service.showRewardedAdWithReward(
        contextType: contextType,
        userId: userId,
        gameId: gameId,
        entryId: entryId,
        onSessionStarted: (previewAmount) {
          // 세션 시작됨
        },
        onAdShowing: () {
          state = state.copyWith(isShowingAd: true);
        },
        onError: (error) {
          state = state.copyWith(error: error);
        },
      );

      state = state.copyWith(
        isLoading: false,
        isShowingAd: false,
        lastResult: result,
      );

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isShowingAd: false,
        error: e.toString(),
      );
      return null;
    }
  }

  /// 에러 초기화
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// 광고 보상 정책 조회 Provider
@riverpod
Future<AdRewardPolicy?> adRewardPolicy(
  Ref ref,
  AdContextType contextType,
) async {
  final service = await ref.watch(adRewardServiceProvider.future);
  return service.getAdRewardPolicy(contextType);
}

/// 내 광고 보상 기록 Provider
@riverpod
class MyAdRewardLedgers extends _$MyAdRewardLedgers {
  @override
  Future<AdRewardLedgerPage> build({int page = 0, int size = 20}) async {
    final service = await ref.watch(adRewardServiceProvider.future);
    return service.getMyAdRewardLedgers(page: page, size: size);
  }

  /// 새로고침
  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  /// 다음 페이지 로드
  Future<AdRewardLedgerPage?> loadNextPage() async {
    final currentState = state.valueOrNull;
    if (currentState == null || !currentState.hasMore) return null;

    final service = await ref.read(adRewardServiceProvider.future);
    return service.getMyAdRewardLedgers(
      page: currentState.currentPage + 1,
      size: currentState.pageSize,
    );
  }
}
