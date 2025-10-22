/// 게임 라운드 타입
enum GameType {
  daily, // Stage -> Daily로 명칭 변경
  select,
  vibe,
}

/// 게임 상태
enum GameStatus {
  active,
  drawing,
  ended,
}

/// 게임 라운드 모델
class GameRound {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final int maxParticipants;
  final int totalBlocks;
  final int requiredPicks;
  final int winners;
  final int originalPrice;
  final int currentPrice;
  final String timeLeft;
  final GameType type;
  final GameStatus status;
  final String category; // Digital, Fashion, Gift, Coupon, Food
  final int? gridSize; // Vibe의 경우 그리드 크기
  final String? vibeImageUrl; // Vibe의 경우 배경 이미지

  const GameRound({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.maxParticipants,
    required this.totalBlocks,
    required this.requiredPicks,
    required this.winners,
    required this.originalPrice,
    required this.currentPrice,
    required this.timeLeft,
    required this.type,
    required this.status,
    this.category = 'Digital',
    this.gridSize,
    this.vibeImageUrl,
  });

  /// JSON으로부터 생성
  factory GameRound.fromJson(Map<String, dynamic> json) {
    return GameRound(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      participants: json['participants'] as int? ?? 0,
      maxParticipants: json['max_participants'] as int? ?? 0,
      totalBlocks: json['total_blocks'] as int? ?? 0,
      requiredPicks: json['required_picks'] as int? ?? 0,
      winners: json['winners'] as int? ?? 0,
      originalPrice: json['original_price'] as int? ?? 0,
      currentPrice: json['current_price'] as int? ?? 0,
      timeLeft: json['time_left'] as String? ?? '',
      type: _parseGameType(json['type'] as String?),
      status: _parseGameStatus(json['status'] as String?),
      category: json['category'] as String? ?? 'Digital',
      gridSize: json['grid_size'] as int?,
      vibeImageUrl: json['vibe_image_url'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'participants': participants,
      'max_participants': maxParticipants,
      'total_blocks': totalBlocks,
      'required_picks': requiredPicks,
      'winners': winners,
      'original_price': originalPrice,
      'current_price': currentPrice,
      'time_left': timeLeft,
      'type': type.name,
      'status': status.name,
      'category': category,
      'grid_size': gridSize,
      'vibe_image_url': vibeImageUrl,
    };
  }

  /// 게임 타입 파싱
  static GameType _parseGameType(String? type) {
    switch (type?.toLowerCase()) {
      case 'daily':
      case 'stage':
        return GameType.daily;
      case 'select':
        return GameType.select;
      case 'vibe':
        return GameType.vibe;
      default:
        return GameType.daily;
    }
  }

  /// 게임 상태 파싱
  static GameStatus _parseGameStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'active':
        return GameStatus.active;
      case 'drawing':
        return GameStatus.drawing;
      case 'ended':
        return GameStatus.ended;
      default:
        return GameStatus.active;
    }
  }

  /// copyWith 메서드
  GameRound copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? participants,
    int? maxParticipants,
    int? totalBlocks,
    int? requiredPicks,
    int? winners,
    int? originalPrice,
    int? currentPrice,
    String? timeLeft,
    GameType? type,
    GameStatus? status,
    String? category,
    int? gridSize,
    String? vibeImageUrl,
  }) {
    return GameRound(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      totalBlocks: totalBlocks ?? this.totalBlocks,
      requiredPicks: requiredPicks ?? this.requiredPicks,
      winners: winners ?? this.winners,
      originalPrice: originalPrice ?? this.originalPrice,
      currentPrice: currentPrice ?? this.currentPrice,
      timeLeft: timeLeft ?? this.timeLeft,
      type: type ?? this.type,
      status: status ?? this.status,
      category: category ?? this.category,
      gridSize: gridSize ?? this.gridSize,
      vibeImageUrl: vibeImageUrl ?? this.vibeImageUrl,
    );
  }
}
