import 'package:flutter/foundation.dart';
import 'offerwall_adapter.dart';

/// AdGem SDK 어댑터 (placeholder)
///
/// TODO: AdGem SDK 통합 시 아래 단계를 따르세요.
///
/// 1. pubspec.yaml에 AdGem Flutter SDK 추가:
///    adgem_flutter: ^x.x.x  (또는 native binding 패키지)
///
/// 2. iOS/Android 각 플랫폼별 SDK 초기화 설정
///    - iOS: AppDelegate에 AdGem.initialize(appKey:) 추가
///    - Android: Application.onCreate()에 AdGem.initialize() 추가
///
/// 3. AdGemAdapter.showOfferwall() 내부를 실제 SDK 호출로 교체:
///    - AdGem.showOfferwall(appId, userId)
///
/// 4. OfferwallFactory에서 OfferwallAdapterType.adGem 선택하도록 설정:
///    --dart-define=OFFERWALL_ADAPTER=adgem
///
/// AdGem 개발자 콘솔: https://adgem.com/publishers/
class AdGemAdapter implements OfferwallAdapter {
  // ignore: unused_field — SDK 통합 후 사용됨
  OfferwallCompletionCallback? _completionCallback;

  @override
  Future<void> showOfferwall({required String url, String? title}) async {
    // TODO: AdGem SDK 연동 후 실제 구현으로 교체
    if (kDebugMode) {
      debugPrint('[AdGemAdapter] showOfferwall() — 미구현 (placeholder)');
      debugPrint('[AdGemAdapter] URL: $url');
    }
    throw UnimplementedError(
      'AdGemAdapter는 아직 구현되지 않았습니다. '
      'AdGem SDK 통합 후 이 메서드를 구현하세요.',
    );
  }

  @override
  void onCompletion(OfferwallCompletionCallback callback) {
    _completionCallback = callback;
    // TODO: AdGem SDK 콜백 등록
    if (kDebugMode) {
      debugPrint('[AdGemAdapter] onCompletion 등록 — SDK 연동 후 활성화됨');
    }
  }

  @override
  void dispose() {
    _completionCallback = null;
    // TODO: AdGem SDK 리소스 해제
  }
}
