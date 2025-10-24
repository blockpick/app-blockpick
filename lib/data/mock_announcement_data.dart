import '../models/announcement_model.dart';

/// 공지사항 목 데이터
class MockAnnouncementData {
  static List<AnnouncementModel> getAnnouncements() {
    return [
      AnnouncementModel(
        id: '1',
        title: '새로운 럭셔리 카테고리 오픈!',
        content: '명품 시계, 가방 등 럭셔리 상품 카테고리가 새롭게 오픈되었습니다. 다양한 명품을 블록픽으로 만나보세요!',
        createdAt: DateTime(2025, 10, 23, 20, 0),
        isImportant: true,
      ),
      AnnouncementModel(
        id: '2',
        title: '시스템 점검 안내 (12/25 02:00-04:00)',
        content: '안정적인 서비스 제공을 위해 시스템 점검이 진행됩니다. 점검 시간 동안 서비스 이용이 제한될 수 있습니다.',
        createdAt: DateTime(2025, 10, 23, 18, 30),
        isImportant: false,
      ),
      AnnouncementModel(
        id: '3',
        title: '크리스마스 특별 이벤트 진행',
        content: '크리스마스를 맞아 특별 이벤트를 진행합니다. 매일 출석체크하고 보너스 캐시를 받아가세요!',
        createdAt: DateTime(2025, 10, 23, 12, 0),
        isImportant: false,
      ),
      AnnouncementModel(
        id: '4',
        title: '신규 결제 수단 추가 안내',
        content: '카카오페이, 네이버페이 결제 수단이 추가되었습니다. 더욱 편리하게 이용하세요!',
        createdAt: DateTime(2025, 10, 22, 15, 30),
        isImportant: false,
      ),
      AnnouncementModel(
        id: '5',
        title: '10월 당첨자 발표',
        content: '10월 게임 당첨자가 발표되었습니다. 당첨 내역은 마이페이지에서 확인하실 수 있습니다.',
        createdAt: DateTime(2025, 10, 21, 10, 0),
        isImportant: true,
      ),
    ];
  }
}
