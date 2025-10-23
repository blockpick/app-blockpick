import '../models/game_round_model.dart';

/// 목 데이터: 게임 라운드
class MockGameData {
  /// Daily (Stage) 게임 목록
  static final List<GameRound> dailyGames = [
    GameRound(
      id: 'daily-001',
      title: 'iPhone 16 Pro Max 256GB',
      description: '최신 아이폰 16 Pro Max를 획득하세요!',
      imageUrl: 'assets/images/products/iphone-16-pro.webp',
      participants: 1234,
      maxParticipants: 5000,
      totalBlocks: 100000000, // 10000x10000
      requiredPicks: 1,
      winners: 1,
      originalPrice: 1590000,
      currentPrice: 1000,
      timeLeft: '2시간 30분',
      type: GameType.daily,
      status: GameStatus.active,
      category: 'Digital',
      gridWidth: 10000,
      gridHeight: 10000,
    ),
    GameRound(
      id: 'daily-002',
      title: 'AirPods Pro 2세대',
      description: '프리미엄 무선 이어폰',
      imageUrl: 'assets/images/products/airpods-pro-2.jpeg',
      participants: 567,
      maxParticipants: 2000,
      totalBlocks: 1000000, // 1000x1000
      requiredPicks: 1,
      winners: 1,
      originalPrice: 359000,
      currentPrice: 500,
      timeLeft: '5시간 12분',
      type: GameType.daily,
      status: GameStatus.active,
      category: 'Digital',
      gridWidth: 1000,
      gridHeight: 1000,
    ),
    GameRound(
      id: 'daily-003',
      title: 'MacBook Air M4',
      description: '최고 성능의 맥북',
      imageUrl: 'assets/images/products/macbook-air-m4.jpeg',
      participants: 890,
      maxParticipants: 3000,
      totalBlocks: 40000, // 200x200
      requiredPicks: 1,
      winners: 1,
      originalPrice: 1690000,
      currentPrice: 1500,
      timeLeft: '1일 3시간',
      type: GameType.daily,
      status: GameStatus.active,
      category: 'Digital',
      gridWidth: 10000,
      gridHeight: 10000,
    ),
    GameRound(
      id: 'daily-004',
      title: '스타벅스 기프트카드 10만원',
      description: '스타벅스 상품권',
      imageUrl: 'assets/images/products/starbucks-giftcard.jpeg',
      participants: 2345,
      maxParticipants: 10000,
      totalBlocks: 2500, // 50x50
      requiredPicks: 1,
      winners: 5,
      originalPrice: 100000,
      currentPrice: 100,
      timeLeft: '30분',
      type: GameType.daily,
      status: GameStatus.active,
      category: 'Gift',
      gridWidth: 10000,
      gridHeight: 10000,
    ),
  ];

  /// Select 게임 목록
  static final List<GameRound> selectGames = [
    GameRound(
      id: 'select-001',
      title: 'Luxury Brand 럭셔리 패키지',
      description: '샤넬, 에르메스, 구찌 중 선택',
      imageUrl: 'assets/images/products/chanel-bag.webp',
      participants: 456,
      maxParticipants: 1000,
      totalBlocks: 100000000, // 10000x10000
      requiredPicks: 3,
      winners: 1,
      originalPrice: 5000000,
      currentPrice: 3000,
      timeLeft: '6시간',
      type: GameType.select,
      status: GameStatus.active,
      category: 'Fashion',
      gridWidth: 10000,
      gridHeight: 10000,
    ),
    GameRound(
      id: 'select-002',
      title: '명품 가방 셀렉션',
      description: '루이비통, 구찌, 프라다 중 선택',
      imageUrl: 'assets/images/products/louis-vuitton-bag.jpeg',
      participants: 678,
      maxParticipants: 2000,
      totalBlocks: 25000000, // 5000x5000
      requiredPicks: 5,
      winners: 2,
      originalPrice: 3500000,
      currentPrice: 2500,
      timeLeft: '12시간',
      type: GameType.select,
      status: GameStatus.active,
      category: 'Fashion',
      gridWidth: 5000,
      gridHeight: 5000,
    ),
    GameRound(
      id: 'select-003',
      title: '애플 제품 패키지',
      description: 'iPhone, iPad, MacBook 중 선택',
      imageUrl: 'assets/images/products/ipad-air.webp',
      participants: 1890,
      maxParticipants: 5000,
      totalBlocks: 4000000, // 2000x2000
      requiredPicks: 10,
      winners: 3,
      originalPrice: 2000000,
      currentPrice: 1000,
      timeLeft: '1일',
      type: GameType.select,
      status: GameStatus.active,
      category: 'Digital',
      gridWidth: 2000,
      gridHeight: 2000,
    ),
  ];

  /// Vibe 게임 목록
  static final List<GameRound> vibeGames = [
    GameRound(
      id: 'vibe-001',
      title: '스니커즈 컬렉션 Vibe',
      description: '나이키, 아디다스 한정판',
      imageUrl: 'assets/images/products/nike-air-jordan.avif',
      participants: 234,
      maxParticipants: 1000,
      totalBlocks: 10000, // 100x100
      requiredPicks: 5,
      winners: 10,
      originalPrice: 500000,
      currentPrice: 500,
      timeLeft: '3시간',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Fashion',
      gridWidth: 100,
      gridHeight: 100,
      vibeImageUrl: 'assets/images/vibe/01/test.png',
    ),
    GameRound(
      id: 'vibe-002',
      title: '디지털 가젯 Vibe',
      description: '최신 IT 기기 컬렉션',
      imageUrl: 'assets/images/products/airpods-pro-2.jpeg',
      participants: 567,
      maxParticipants: 2000,
      totalBlocks: 40000, // 200x200
      requiredPicks: 10,
      winners: 15,
      originalPrice: 1000000,
      currentPrice: 800,
      timeLeft: '8시간',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Digital',
      gridWidth: 200,
      gridHeight: 200,
      vibeImageUrl: 'assets/images/vibe/02/test.png',
    ),
    GameRound(
      id: 'vibe-003',
      title: 'F&B 쿠폰 Vibe',
      description: '스타벅스, 배스킨라빈스',
      imageUrl: 'assets/images/products/starbucks-giftcard.jpeg',
      participants: 890,
      maxParticipants: 3000,
      totalBlocks: 2500, // 50x50
      requiredPicks: 3,
      winners: 20,
      originalPrice: 50000,
      currentPrice: 100,
      timeLeft: '2시간',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Food',
      gridWidth: 50,
      gridHeight: 50,
      vibeImageUrl: 'assets/images/vibe/03/test.png',
    ),
  ];

  /// 타입별 게임 가져오기
  static List<GameRound> getGamesByType(GameType type) {
    switch (type) {
      case GameType.daily:
        return dailyGames;
      case GameType.select:
        return selectGames;
      case GameType.vibe:
        return vibeGames;
    }
  }

  /// 모든 게임 가져오기
  static List<GameRound> getAllGames() {
    return [...dailyGames, ...selectGames, ...vibeGames];
  }

  /// ID로 게임 찾기
  static GameRound? getGameById(String id) {
    try {
      return getAllGames().firstWhere((game) => game.id == id);
    } catch (e) {
      return null;
    }
  }
}
