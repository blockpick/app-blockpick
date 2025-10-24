import '../models/event_banner_model.dart';

/// 이벤트 배너 목 데이터
class MockEventBannerData {
  static List<EventBannerModel> getBanners() {
    return [
      EventBannerModel(
        id: '1',
        title: '신규 가입 10,000 캐시 지급!',
        subtitle: '지금 가입하고 바로 게임 참여하세요',
        backgroundColor: '#5B6FED',
        textColor: '#FFFFFF',
      ),
      EventBannerModel(
        id: '2',
        title: '명품 시계 카테고리 오픈',
        subtitle: '럭셔리 워치 게임 오픈 기념 이벤트',
        backgroundColor: '#9D4EDD',
        textColor: '#FFFFFF',
      ),
      EventBannerModel(
        id: '3',
        title: '친구 초대하고 보너스 받기',
        subtitle: '친구 1명당 5,000 캐시 적립',
        backgroundColor: '#FF6B6B',
        textColor: '#FFFFFF',
      ),
      EventBannerModel(
        id: '4',
        title: '블랙프라이데이 특가',
        subtitle: '인기 상품 특가 진행 중',
        backgroundColor: '#20C997',
        textColor: '#FFFFFF',
      ),
      EventBannerModel(
        id: '5',
        title: '매일 출석체크',
        subtitle: '출석만 해도 캐시가 쌓여요',
        backgroundColor: '#FFA94D',
        textColor: '#FFFFFF',
      ),
    ];
  }
}
