import 'package:flutter/foundation.dart';
import 'offerwall_adapter.dart';

/// Tapjoy SDK 어댑터 (placeholder)
///
/// TODO: Tapjoy SDK 통합 시 아래 단계를 따르세요.
///
/// 1. pubspec.yaml에 Tapjoy Flutter SDK 추가:
///    tapjoy_flutter: ^x.x.x  (또는 native binding 패키지)
///
/// 2. iOS: Podfile에 pod 'Tapjoy' 추가 후 pod install
///    Android: build.gradle에 Tapjoy dependency 추가
///
/// 3. TapjoyAdapter.showOfferwall() 내부를 실제 SDK 호출로 교체:
///    - Tapjoy.connect(apiKey)  (앱 초기화 시 1회)
///    - TJPlacement.showOfferwall()
///
/// 4. OfferwallFactory에서 OfferwallAdapterType.tapjoy 선택하도록 설정:
///    --dart-define=OFFERWALL_ADAPTER=tapjoy
///
/// Tapjoy 개발자 콘솔: https://ltv.tapjoy.com/
class TapjoyAdapter implements OfferwallAdapter {
  // ignore: unused_field — SDK 통합 후 사용됨
  OfferwallCompletionCallback? _completionCallback;

  @override
  Future<void> showOfferwall({required String url, String? title}) async {
    // TODO: Tapjoy SDK 연동 후 실제 구현으로 교체
    if (kDebugMode) {
      debugPrint('[TapjoyAdapter] showOfferwall() — 미구현 (placeholder)');
      debugPrint('[TapjoyAdapter] URL: $url');
    }
    throw UnimplementedError(
      'TapjoyAdapter는 아직 구현되지 않았습니다. '
      'Tapjoy SDK 통합 후 이 메서드를 구현하세요.',
    );
  }

  @override
  void onCompletion(OfferwallCompletionCallback callback) {
    _completionCallback = callback;
    // TODO: Tapjoy SDK 콜백 등록
    if (kDebugMode) {
      debugPrint('[TapjoyAdapter] onCompletion 등록 — SDK 연동 후 활성화됨');
    }
  }

  @override
  void dispose() {
    _completionCallback = null;
    // TODO: Tapjoy SDK 리소스 해제
  }
}
