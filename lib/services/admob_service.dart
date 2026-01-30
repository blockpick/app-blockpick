import 'package:flutter/foundation.dart';
// dart:io는 웹에서 지원하지 않으므로 조건부로 사용
import 'dart:io' if (dart.library.html) 'package:blockpick_flutter/utils/platform_stub.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 광고 서비스
/// 보상형 광고의 로딩, 표시, 콜백 관리를 담당합니다.
class AdMobService {
  static final AdMobService _instance = AdMobService._internal();
  factory AdMobService() => _instance;
  AdMobService._internal();

  RewardedAd? _rewardedAd;
  bool _isLoading = false;

  /// 로드 중일 때 대기하는 콜백들
  final List<VoidCallback> _pendingLoadCallbacks = [];
  final List<void Function(String)> _pendingFailCallbacks = [];

  /// 플랫폼 지원 여부
  static bool get isSupported {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  /// AdMob SDK 초기화
  static Future<void> initialize() async {
    if (!isSupported) {
      debugPrint('⚠️ AdMob은 이 플랫폼에서 지원되지 않습니다.');
      return;
    }
    await MobileAds.instance.initialize();
    debugPrint('✅ AdMob SDK 초기화 완료');
  }

  /// 보상형 광고 Unit ID (테스트 ID)
  String get _rewardedAdUnitId {
    if (kIsWeb) {
      throw UnsupportedError('웹에서는 지원하지 않습니다.');
    }
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917';
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313';
    }
    throw UnsupportedError('지원하지 않는 플랫폼입니다.');
  }

  /// 광고 로드 여부
  bool get isAdLoaded => _rewardedAd != null;

  /// 광고 로딩 중 여부
  bool get isLoading => _isLoading;

  /// 보상형 광고 미리 로드
  Future<void> loadRewardedAd({
    VoidCallback? onAdLoaded,
    void Function(String error)? onAdFailedToLoad,
  }) async {
    if (!isSupported) {
      debugPrint('⚠️ AdMob은 이 플랫폼에서 지원되지 않습니다.');
      onAdFailedToLoad?.call('이 플랫폼에서는 광고를 지원하지 않습니다.');
      return;
    }

    // 광고가 이미 로드되어 있으면 즉시 콜백 호출
    if (_rewardedAd != null) {
      debugPrint('✅ 광고가 이미 로드되어 있습니다.');
      onAdLoaded?.call();
      return;
    }

    // 광고가 로드 중이면 콜백을 대기열에 추가
    if (_isLoading) {
      debugPrint('⏳ 광고가 로드 중입니다. 콜백을 대기열에 추가합니다.');
      if (onAdLoaded != null) _pendingLoadCallbacks.add(onAdLoaded);
      if (onAdFailedToLoad != null) _pendingFailCallbacks.add(onAdFailedToLoad);
      return;
    }

    _isLoading = true;
    debugPrint('📥 보상형 광고 로드 시작: $_rewardedAdUnitId');

    await RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('✅ 보상형 광고 로드 완료');
          _rewardedAd = ad;
          _isLoading = false;
          onAdLoaded?.call();
          // 대기 중인 콜백들도 호출
          for (final callback in _pendingLoadCallbacks) {
            callback();
          }
          _pendingLoadCallbacks.clear();
          _pendingFailCallbacks.clear();
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ 보상형 광고 로드 실패: ${error.message}');
          _isLoading = false;
          onAdFailedToLoad?.call(error.message);
          // 대기 중인 실패 콜백들도 호출
          for (final callback in _pendingFailCallbacks) {
            callback(error.message);
          }
          _pendingLoadCallbacks.clear();
          _pendingFailCallbacks.clear();
        },
      ),
    );
  }

  /// 보상형 광고 표시
  ///
  /// [onUserEarnedReward] - 사용자가 보상을 획득했을 때 호출 (광고 시청 완료)
  /// [onAdDismissed] - 광고가 닫혔을 때 호출
  /// [onAdFailedToShow] - 광고 표시 실패 시 호출
  Future<void> showRewardedAd({
    required void Function(RewardItem reward) onUserEarnedReward,
    VoidCallback? onAdDismissed,
    void Function(String error)? onAdFailedToShow,
  }) async {
    if (!isSupported) {
      debugPrint('⚠️ AdMob은 이 플랫폼에서 지원되지 않습니다.');
      onAdFailedToShow?.call('이 플랫폼에서는 광고를 지원하지 않습니다.');
      return;
    }

    if (_rewardedAd == null) {
      debugPrint('❌ 표시할 광고가 없습니다. 먼저 loadRewardedAd()를 호출하세요.');
      onAdFailedToShow?.call('광고가 로드되지 않았습니다.');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('📺 광고가 전체 화면으로 표시됨');
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('🚪 광고가 닫힘');
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed?.call();
        // 다음 광고 미리 로드
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ 광고 표시 실패: ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        onAdFailedToShow?.call(error.message);
        // 다음 광고 미리 로드
        loadRewardedAd();
      },
      onAdImpression: (ad) {
        debugPrint('👁️ 광고 노출 기록됨');
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        debugPrint('🎉 보상 획득: ${reward.amount} ${reward.type}');
        onUserEarnedReward(reward);
      },
    );
  }

  /// 광고 리소스 해제
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }
}
