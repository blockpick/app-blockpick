import '../models/participation_feed_model.dart';

/// 실시간 참가 이력 목 데이터
class MockParticipationFeedData {
  static List<ParticipationFeedModel> getRecentParticipations() {
    final now = DateTime.now();

    return [
      ParticipationFeedModel(
        id: '1',
        userName: '박**',
        gameName: 'iPhone 15 Pro',
        participatedAt: now.subtract(const Duration(minutes: 2)),
      ),
      ParticipationFeedModel(
        id: '2',
        userName: '최**',
        gameName: 'AirPods Pro',
        participatedAt: now.subtract(const Duration(minutes: 5)),
      ),
      ParticipationFeedModel(
        id: '3',
        userName: '김**',
        gameName: 'Galaxy Watch 6',
        participatedAt: now.subtract(const Duration(minutes: 7)),
      ),
      ParticipationFeedModel(
        id: '4',
        userName: '이**',
        gameName: 'MacBook Air',
        participatedAt: now.subtract(const Duration(minutes: 12)),
      ),
      ParticipationFeedModel(
        id: '5',
        userName: '정**',
        gameName: 'Nike 에어포스',
        participatedAt: now.subtract(const Duration(minutes: 15)),
      ),
      ParticipationFeedModel(
        id: '6',
        userName: '강**',
        gameName: 'PlayStation 5',
        participatedAt: now.subtract(const Duration(minutes: 18)),
      ),
      ParticipationFeedModel(
        id: '7',
        userName: '윤**',
        gameName: 'LG 그램 노트북',
        participatedAt: now.subtract(const Duration(minutes: 22)),
      ),
      ParticipationFeedModel(
        id: '8',
        userName: '조**',
        gameName: 'Dyson 청소기',
        participatedAt: now.subtract(const Duration(minutes: 28)),
      ),
    ];
  }
}
