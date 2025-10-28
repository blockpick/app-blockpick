import '../models/optimal_game_model.dart';

/// 목 데이터: 최적가 게임
class MockOptimalGameData {
  /// 최적가 게임 목록
  static final List<OptimalGame> optimalGames = [
    OptimalGame(
      id: 'optimal-001',
      title: 'iPhone 16 Pro Max 256GB',
      description: '최적가를 선택하여 아이폰을 획득하세요!',
      imageUrl: 'assets/images/products/iphone-16-pro.webp',
      participants: 1234,
      maxParticipants: 5000,
      winners: 1,
      originalPrice: 1590000,
      timeLeft: '2시간 30분',
      category: 'Digital',
      minPrice: 1000000,
      maxPrice: 1590000,
      priceStep: 1000,
    ),
    OptimalGame(
      id: 'optimal-002',
      title: 'AirPods Pro 2세대',
      description: '프리미엄 무선 이어폰',
      imageUrl: 'assets/images/products/airpods-pro-2.jpeg',
      participants: 567,
      maxParticipants: 2000,
      winners: 1,
      originalPrice: 359000,
      timeLeft: '5시간 12분',
      category: 'Digital',
      minPrice: 250000,
      maxPrice: 359000,
      priceStep: 500,
    ),
    OptimalGame(
      id: 'optimal-003',
      title: 'MacBook Air M4',
      description: '최고 성능의 맥북',
      imageUrl: 'assets/images/products/macbook-air-m4.jpeg',
      participants: 890,
      maxParticipants: 3000,
      winners: 1,
      originalPrice: 1690000,
      timeLeft: '1일 3시간',
      category: 'Digital',
      minPrice: 1200000,
      maxPrice: 1690000,
      priceStep: 1000,
    ),
    OptimalGame(
      id: 'optimal-004',
      title: '스타벅스 기프트카드 10만원',
      description: '스타벅스 상품권',
      imageUrl: 'assets/images/products/starbucks-giftcard.jpeg',
      participants: 2345,
      maxParticipants: 10000,
      winners: 5,
      originalPrice: 100000,
      timeLeft: '30분',
      category: 'Gift',
      minPrice: 50000,
      maxPrice: 100000,
      priceStep: 100,
    ),
    OptimalGame(
      id: 'optimal-005',
      title: 'Luxury Brand 명품 가방',
      description: '샤넬, 에르메스, 구찌 중 선택',
      imageUrl: 'assets/images/products/chanel-bag.webp',
      participants: 456,
      maxParticipants: 1000,
      winners: 1,
      originalPrice: 5000000,
      timeLeft: '6시간',
      category: 'Fashion',
      minPrice: 3000000,
      maxPrice: 5000000,
      priceStep: 5000,
    ),
  ];

  /// ID로 게임 찾기
  static OptimalGame? getGameById(String id) {
    try {
      return optimalGames.firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 모든 게임 가져오기
  static List<OptimalGame> getAllGames() {
    return optimalGames;
  }
}
