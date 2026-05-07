import 'offerwall_adapter.dart';
import 'tapjoy_adapter.dart';
import 'adgem_adapter.dart';
import 'web_offerwall_adapter.dart';

/// 활성화할 오퍼월 어댑터 타입
///
/// --dart-define=OFFERWALL_ADAPTER=[value] 로 빌드 시 주입:
///   tapjoy  → TapjoyAdapter
///   adgem   → AdGemAdapter
///   web     → WebOfferwallAdapter (기본값)
enum OfferwallAdapterType { tapjoy, adGem, web }

/// 오퍼월 어댑터 팩토리
///
/// 사업자 선정 후 --dart-define=OFFERWALL_ADAPTER=tapjoy (또는 adgem) 로
/// 빌드하면 자동으로 해당 어댑터가 활성화됩니다.
///
/// 사용 예:
///   final adapter = OfferwallFactory.create();
///   adapter.onCompletion(({offerId, pointsEarned}) { ... });
///   await adapter.showOfferwall(url: url, title: '오퍼월');
class OfferwallFactory {
  OfferwallFactory._();

  /// dart-define 키
  static const String _adapterKey = String.fromEnvironment(
    'OFFERWALL_ADAPTER',
    defaultValue: 'web',
  );

  static OfferwallAdapterType get activeType {
    switch (_adapterKey.toLowerCase()) {
      case 'tapjoy':
        return OfferwallAdapterType.tapjoy;
      case 'adgem':
        return OfferwallAdapterType.adGem;
      default:
        return OfferwallAdapterType.web;
    }
  }

  /// 활성 어댑터 인스턴스를 생성합니다.
  static OfferwallAdapter create() {
    switch (activeType) {
      case OfferwallAdapterType.tapjoy:
        return TapjoyAdapter();
      case OfferwallAdapterType.adGem:
        return AdGemAdapter();
      case OfferwallAdapterType.web:
        return WebOfferwallAdapter();
    }
  }
}
