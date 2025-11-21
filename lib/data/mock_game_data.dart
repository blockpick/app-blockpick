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
      title: '따뜻한 나눔의 하루',
      description: '당신의 선택이 누군가에게 따뜻한 하루를 선물합니다. 이번 기부는 지역 아동센터 아이들에게 겨울 의류와 도서를 전달합니다.',
      imageUrl: 'https://images.unsplash.com/photo-1488521787991-ed7bbaae773c?w=800',
      participants: 1234,
      maxParticipants: 5000,
      totalBlocks: 10000,
      requiredPicks: 5,
      winners: 10,
      originalPrice: 50000,
      currentPrice: 500,
      timeLeft: '2일 남음',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Charity',
      gridWidth: 100,
      gridHeight: 100,
      vibeImageUrl: 'assets/images/vibe/01/test.png',
    ),
    GameRound(
      id: 'vibe-002',
      title: '예술가의 꿈을 응원합니다',
      description: '신진 작가들의 작품을 소개하고 후원합니다. 당신의 참여가 예술가의 다음 작품을 만드는 원동력이 됩니다.',
      imageUrl: 'https://images.unsplash.com/photo-1460661419201-fd4cecdf8a8b?w=800',
      participants: 567,
      maxParticipants: 2000,
      totalBlocks: 40000,
      requiredPicks: 3,
      winners: 5,
      originalPrice: 100000,
      currentPrice: 1000,
      timeLeft: '5시간 남음',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Art',
      gridWidth: 200,
      gridHeight: 200,
      vibeImageUrl: 'assets/images/vibe/02/test.png',
    ),
    GameRound(
      id: 'vibe-003',
      title: '선생님께 감사의 마음을',
      description: '스승의 날을 맞아 선생님들께 감사를 전하는 특별한 프로젝트입니다. 작은 정성이 모여 큰 감동이 됩니다.',
      imageUrl: 'https://images.unsplash.com/photo-1472162072942-cd5147eb3902?w=800',
      participants: 890,
      maxParticipants: 3000,
      totalBlocks: 2500,
      requiredPicks: 1,
      winners: 20,
      originalPrice: 30000,
      currentPrice: 300,
      timeLeft: '1일 남음',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Tribute',
      gridWidth: 50,
      gridHeight: 50,
      vibeImageUrl: 'assets/images/vibe/03/test.png',
    ),
    GameRound(
      id: 'vibe-004',
      title: '노을빛 감성 갤러리',
      description: '아름다운 석양을 담은 사진전을 함께 만들어갑니다. 자연의 아름다움을 나누고 보존하는 의미 있는 시간.',
      imageUrl: 'https://images.unsplash.com/photo-1495616811223-4d98c6e9c869?w=800',
      participants: 345,
      maxParticipants: 1500,
      totalBlocks: 10000,
      requiredPicks: 3,
      winners: 8,
      originalPrice: 75000,
      currentPrice: 750,
      timeLeft: '12시간 남음',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Art',
      gridWidth: 100,
      gridHeight: 100,
      vibeImageUrl: 'assets/images/vibe/04/test.png',
    ),
    GameRound(
      id: 'vibe-005',
      title: '어르신께 건강과 행복을',
      description: '독거 어르신들께 영양식과 건강용품을 전달하는 프로젝트입니다. 당신의 작은 관심이 큰 위로가 됩니다.',
      imageUrl: 'https://images.unsplash.com/photo-1531983412922-8b1aba602f2f?w=800',
      participants: 2100,
      maxParticipants: 8000,
      totalBlocks: 25000,
      requiredPicks: 5,
      winners: 15,
      originalPrice: 80000,
      currentPrice: 800,
      timeLeft: '3일 남음',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Charity',
      gridWidth: 150,
      gridHeight: 150,
      vibeImageUrl: 'assets/images/vibe/05/test.png',
    ),
    GameRound(
      id: 'vibe-006',
      title: '음악으로 하나 되는 순간',
      description: '젊은 음악가들의 공연을 후원하고, 함께 음악의 감동을 나눕니다. 예술은 우리를 하나로 연결합니다.',
      imageUrl: 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=800',
      participants: 678,
      maxParticipants: 2500,
      totalBlocks: 16000,
      requiredPicks: 3,
      winners: 12,
      originalPrice: 60000,
      currentPrice: 600,
      timeLeft: '8시간 남음',
      type: GameType.vibe,
      status: GameStatus.active,
      category: 'Art',
      gridWidth: 120,
      gridHeight: 120,
      vibeImageUrl: 'assets/images/vibe/06/test.png',
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
