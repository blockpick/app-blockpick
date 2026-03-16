/// 게임 라운드 타입
enum GameType {
  daily, // Stage -> Daily로 명칭 변경
  select,
  vibe,
  prime,
}

/// 게임 상태
enum GameStatus {
  scheduled, // 예정 (SCHEDULED, READY, DRAFT)
  active, // 진행중 (ACTIVE, IN_PROGRESS)
  paused, // 일시중지 (PAUSED)
  settling, // 정산중 (SETTLING)
  ended, // 종료 (ENDED)
  completed, // 완료 (COMPLETED)
  failed, // 실패 (FAILED)
}

/// GameStatus 확장 메서드
extension GameStatusX on GameStatus {
  /// 참여 가능 여부
  bool get isJoinable => this == GameStatus.active;

  /// 종료된 게임 여부
  bool get isEnded =>
      this == GameStatus.ended ||
      this == GameStatus.completed ||
      this == GameStatus.failed;

  /// 예정된 게임 여부
  bool get isUpcoming => this == GameStatus.scheduled;

  /// 상태 뱃지 텍스트 (한국어)
  String get badgeText {
    switch (this) {
      case GameStatus.scheduled:
        return '예정';
      case GameStatus.active:
        return '진행중';
      case GameStatus.paused:
        return '일시중지';
      case GameStatus.settling:
        return '정산중';
      case GameStatus.ended:
        return '종료됨';
      case GameStatus.completed:
        return '완료';
      case GameStatus.failed:
        return '실패';
    }
  }

  /// 상태 안내 문구 (게임 상세 화면용)
  String bannerMessage({String? startTime}) {
    switch (this) {
      case GameStatus.scheduled:
        final timeStr = startTime != null ? ' 시작 시간: $startTime' : '';
        return '게임이 아직 시작되지 않았습니다.$timeStr';
      case GameStatus.active:
        return '';
      case GameStatus.paused:
        return '게임이 일시 중지되었습니다.';
      case GameStatus.settling:
        return '게임이 정산 중입니다. 잠시만 기다려주세요.';
      case GameStatus.ended:
        return '이 게임은 종료되었습니다.';
      case GameStatus.completed:
        return '이 게임은 완료되었습니다. 결과를 확인해보세요.';
      case GameStatus.failed:
        return '이 게임은 진행이 불가합니다.';
    }
  }
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
  final int? gridSize; // 레거시: 정사각형 그리드 크기 (Vibe)
  final int? gridWidth; // 그리드 가로 크기
  final int? gridHeight; // 그리드 세로 크기
  final String? vibeImageUrl; // Vibe의 경우 배경 이미지
  final String? gameMethod; // GACHA, BLOCK_PICK (VIBE 타입에서 관리자 선택)

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
    this.gridWidth,
    this.gridHeight,
    this.vibeImageUrl,
    this.gameMethod,
  });

  /// 실제 그리드 가로 크기 반환
  int get actualGridWidth => gridWidth ?? gridSize ?? 10000;

  /// 실제 그리드 세로 크기 반환
  int get actualGridHeight => gridHeight ?? gridSize ?? 10000;

  /// JSON으로부터 생성
  factory GameRound.fromJson(Map<String, dynamic> json) {
    // grid_dimensions 파싱 (예: "50x50", "100x200")
    int? gridWidth;
    int? gridHeight;

    if (json['grid_dimensions'] != null) {
      final dimensions = _parseGridDimensions(json['grid_dimensions']);
      gridWidth = dimensions.$1;
      gridHeight = dimensions.$2;
    }

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
      gridWidth: gridWidth ?? (json['grid_width'] as int?),
      gridHeight: gridHeight ?? (json['grid_height'] as int?),
      vibeImageUrl: json['vibe_image_url'] as String?,
      gameMethod: json['game_method'] as String?,
    );
  }

  /// 그리드 크기 문자열 파싱 (예: "50x50" -> (50, 50))
  static (int, int) _parseGridDimensions(dynamic dimensions) {
    if (dimensions is String) {
      final parts = dimensions.split('x');
      if (parts.length == 2) {
        final width = int.tryParse(parts[0].trim());
        final height = int.tryParse(parts[1].trim());
        if (width != null && height != null) {
          return (width, height);
        }
      }
    }
    return (10000, 10000); // 기본값
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
      'grid_width': gridWidth,
      'grid_height': gridHeight,
      if (gridWidth != null && gridHeight != null)
        'grid_dimensions': '${gridWidth}x$gridHeight',
      'vibe_image_url': vibeImageUrl,
      'game_method': gameMethod,
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
      case 'prime':
        return GameType.prime;
      default:
        return GameType.daily;
    }
  }

  /// 게임 상태 파싱
  static GameStatus _parseGameStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'ACTIVE':
      case 'IN_PROGRESS':
        return GameStatus.active;
      case 'SCHEDULED':
      case 'READY':
      case 'DRAFT':
        return GameStatus.scheduled;
      case 'PAUSED':
        return GameStatus.paused;
      case 'SETTLING':
        return GameStatus.settling;
      case 'ENDED':
        return GameStatus.ended;
      case 'COMPLETED':
        return GameStatus.completed;
      case 'FAILED':
        return GameStatus.failed;
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
    int? gridWidth,
    int? gridHeight,
    String? vibeImageUrl,
    String? gameMethod,
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
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      vibeImageUrl: vibeImageUrl ?? this.vibeImageUrl,
      gameMethod: gameMethod ?? this.gameMethod,
    );
  }
}
