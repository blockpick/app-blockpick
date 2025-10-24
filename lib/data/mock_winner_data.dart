import '../models/winner_model.dart';

/// 목 데이터: 당첨자 목록
class MockWinnerData {
  /// 프리미엄 상품 당첨자 (게임 전용)
  static final List<WinnerModel> premiumWinners = [
    WinnerModel(
      id: 'winner-premium-001',
      userName: '김철수',
      userAvatar: 'https://i.pravatar.cc/150?img=1',
      prizeName: 'iPhone 16 Pro Max 256GB',
      prizeImage: 'assets/images/products/iphone-16-pro.webp',
      prizeType: PrizeType.premium,
      winDate: DateTime.now().subtract(const Duration(days: 1)),
      gameId: 'daily-001',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-premium-002',
      userName: '이영희',
      userAvatar: 'https://i.pravatar.cc/150?img=2',
      prizeName: 'MacBook Air M4',
      prizeImage: 'assets/images/products/macbook-air-m4.jpeg',
      prizeType: PrizeType.premium,
      winDate: DateTime.now().subtract(const Duration(days: 2)),
      gameId: 'daily-003',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-premium-003',
      userName: '박민수',
      userAvatar: 'https://i.pravatar.cc/150?img=3',
      prizeName: 'LG OLED TV 65인치',
      prizeImage: 'assets/images/products/lg-oled-tv.jpg',
      prizeType: PrizeType.premium,
      winDate: DateTime.now().subtract(const Duration(days: 3)),
      gameId: 'select-003',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-premium-004',
      userName: '최지원',
      userAvatar: 'https://i.pravatar.cc/150?img=4',
      prizeName: 'Dyson V15 무선청소기',
      prizeImage: 'assets/images/products/dyson-v15.jpg',
      prizeType: PrizeType.premium,
      winDate: DateTime.now().subtract(const Duration(days: 5)),
      gameId: 'vibe-002',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-premium-005',
      userName: '정하늘',
      userAvatar: 'https://i.pravatar.cc/150?img=5',
      prizeName: 'AirPods Pro 2세대',
      prizeImage: 'assets/images/products/airpods-pro-2.jpeg',
      prizeType: PrizeType.premium,
      winDate: DateTime.now().subtract(const Duration(days: 7)),
      gameId: 'daily-002',
      isMyWin: false,
    ),
  ];

  /// 쇼핑몰 상품 당첨자 (숙박권, 항공권, 티켓 등)
  static final List<WinnerModel> shopWinners = [
    WinnerModel(
      id: 'winner-shop-001',
      userName: '강민호',
      userAvatar: 'https://i.pravatar.cc/150?img=6',
      prizeName: '제주도 5성급 호텔 숙박권',
      prizeImage: 'assets/images/products/jeju-hotel.jpg',
      prizeType: PrizeType.shop,
      winDate: DateTime.now().subtract(const Duration(hours: 12)),
      gameId: 'select-001',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-shop-002',
      userName: '윤서영',
      userAvatar: 'https://i.pravatar.cc/150?img=7',
      prizeName: '제주항공 왕복 항공권',
      prizeImage: 'assets/images/products/jeju-air-ticket.jpg',
      prizeType: PrizeType.shop,
      winDate: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      gameId: 'select-002',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-shop-003',
      userName: '임동현',
      userAvatar: 'https://i.pravatar.cc/150?img=8',
      prizeName: '롯데월드 자유이용권',
      prizeImage: 'assets/images/products/lotte-world-ticket.jpg',
      prizeType: PrizeType.shop,
      winDate: DateTime.now().subtract(const Duration(days: 2)),
      gameId: 'vibe-001',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-shop-004',
      userName: '한수진',
      userAvatar: 'https://i.pravatar.cc/150?img=9',
      prizeName: '부산 해운대 호텔 숙박권',
      prizeImage: 'assets/images/products/busan-hotel.jpg',
      prizeType: PrizeType.shop,
      winDate: DateTime.now().subtract(const Duration(days: 4)),
      gameId: 'select-004',
      isMyWin: false,
    ),
    WinnerModel(
      id: 'winner-shop-005',
      userName: '오준영',
      userAvatar: 'https://i.pravatar.cc/150?img=10',
      prizeName: '에버랜드 자유이용권',
      prizeImage: 'assets/images/products/everland-ticket.jpg',
      prizeType: PrizeType.shop,
      winDate: DateTime.now().subtract(const Duration(days: 6)),
      gameId: 'vibe-003',
      isMyWin: false,
    ),
  ];

  /// 내 당첨 목록 (예시)
  static final List<WinnerModel> myWinners = [
    WinnerModel(
      id: 'winner-my-001',
      userName: '나',
      userAvatar: 'https://i.pravatar.cc/150?img=11',
      prizeName: 'AirPods Pro 2세대',
      prizeImage: 'assets/images/products/airpods-pro-2.jpeg',
      prizeType: PrizeType.premium,
      winDate: DateTime.now().subtract(const Duration(days: 3)),
      gameId: 'daily-002',
      isMyWin: true,
    ),
    WinnerModel(
      id: 'winner-my-002',
      userName: '나',
      userAvatar: 'https://i.pravatar.cc/150?img=11',
      prizeName: '롯데월드 자유이용권',
      prizeImage: 'assets/images/products/lotte-world-ticket.jpg',
      prizeType: PrizeType.shop,
      winDate: DateTime.now().subtract(const Duration(days: 10)),
      gameId: 'vibe-001',
      isMyWin: true,
    ),
  ];

  /// 전체 당첨자 목록
  static List<WinnerModel> get allWinners {
    return [...premiumWinners, ...shopWinners]
      ..sort((a, b) => b.winDate.compareTo(a.winDate)); // 최신순 정렬
  }

  /// 타입별 필터링
  static List<WinnerModel> filterByType(PrizeType? type) {
    if (type == null) return allWinners;
    return allWinners.where((w) => w.prizeType == type).toList();
  }

  /// 내 당첨만 필터링
  static List<WinnerModel> filterMyWins(PrizeType? type) {
    if (type == null) return myWinners;
    return myWinners.where((w) => w.prizeType == type).toList();
  }
}
