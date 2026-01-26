import '../models/winner_model.dart';

/// 목 데이터: 당첨자 목록
class MockWinnerData {
  /// Daily 이벤트 당첨자
  static final List<WinnerModel> dailyWinners = [
    WinnerModel(
      id: 'winner-daily-001',
      orderId: 'order-001',
      userId: 'user-001',
      nickName: 'yoyoyo_1632',
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      productName: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
      productImageUrl: 'assets/images/products/galaxy-buds3.webp',
      eventType: EventType.daily,
      winDate: DateTime.now(),
      gameId: 'daily-001',
    ),
    WinnerModel(
      id: 'winner-daily-002',
      orderId: 'order-002',
      userId: 'user-002',
      nickName: 'epiktiger_34',
      profileImageUrl: 'https://i.pravatar.cc/150?img=2',
      productName: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
      productImageUrl: 'assets/images/products/galaxy-buds3.webp',
      eventType: EventType.daily,
      winDate: DateTime.now().subtract(const Duration(minutes: 15)),
      gameId: 'daily-002',
    ),
  ];

  /// Vibe 이벤트 당첨자
  static final List<WinnerModel> vibeWinners = [
    WinnerModel(
      id: 'winner-vibe-001',
      orderId: 'order-003',
      userId: 'user-003',
      nickName: 'kor_cowking238',
      profileImageUrl: 'https://i.pravatar.cc/150?img=3',
      productName: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
      productImageUrl: 'assets/images/products/galaxy-buds3.webp',
      eventType: EventType.vibe,
      winDate: DateTime.now().subtract(const Duration(days: 1)),
      gameId: 'vibe-001',
    ),
  ];

  /// Select 이벤트 당첨자
  static final List<WinnerModel> selectWinners = [
    WinnerModel(
      id: 'winner-select-001',
      orderId: 'order-004',
      userId: 'user-004',
      nickName: 'yoyoyo_1632',
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      productName: '[Samsung] 정품 갤럭시 버즈3 프로 화이트 두줄이...',
      productImageUrl: 'assets/images/products/galaxy-buds3.webp',
      eventType: EventType.select,
      winDate: DateTime.now().subtract(const Duration(days: 60)),
      gameId: 'select-001',
    ),
  ];

  /// Prime 이벤트 당첨자
  static final List<WinnerModel> primeWinners = [
    WinnerModel(
      id: 'winner-prime-001',
      orderId: 'order-005',
      userId: 'user-001',
      nickName: 'yoyoyo_1632',
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      productName: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
      productImageUrl: 'assets/images/products/galaxy-buds3.webp',
      eventType: EventType.prime,
      winDate: DateTime(2024, 4, 24),
      gameId: 'prime-001',
    ),
  ];

  /// 전체 당첨자 목록
  static List<WinnerModel> get allWinners {
    return [...dailyWinners, ...vibeWinners, ...selectWinners, ...primeWinners]
      ..sort((a, b) => b.winDate.compareTo(a.winDate));
  }

  /// 이벤트 타입별 필터링
  static List<WinnerModel> filterByEventType(EventType? type) {
    if (type == null) return allWinners;
    return allWinners.where((w) => w.eventType == type).toList();
  }

  /// 당첨자 상세 정보 (예시)
  static WinnerDetailModel getWinnerDetail(String winnerId) {
    final winner = allWinners.firstWhere(
      (w) => w.id == winnerId,
      orElse: () => allWinners.first,
    );

    return WinnerDetailModel(
      winner: winner,
      totalParticipants: 2356,
      topRankers: [
        WinnerRankModel(
          rank: 1,
          oderId: 'order-001',
          userId: 'user-001',
          nickName: 'yoyoyo_1632',
          selectedTime: DateTime.utc(2025, 12, 23, 6, 55, 3),
          duplicateCount: 1,
        ),
        WinnerRankModel(
          rank: 2,
          oderId: 'order-002',
          userId: 'user-002',
          nickName: 'epiktiger_34',
          selectedTime: DateTime.utc(2025, 12, 23, 15, 34, 12),
          duplicateCount: 1,
        ),
        WinnerRankModel(
          rank: 3,
          oderId: 'order-003',
          userId: 'user-003',
          nickName: 'korea_cowking2',
          selectedTime: DateTime.utc(2025, 12, 23, 15, 33, 12),
          duplicateCount: 4,
        ),
      ],
      lottieAnimationUrl: 'assets/animations/celebration.json',
      blockchainViewUrl: 'https://example.com/blockchain/view',
    );
  }
}
