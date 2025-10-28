/// 최적가 게임 모델
class OptimalGame {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int participants;
  final int maxParticipants;
  final int winners;
  final int originalPrice;
  final String timeLeft;
  final String category;

  // 최적가 전용 필드
  final int minPrice; // 최저 입찰 가격
  final int maxPrice; // 최고 입찰 가격 (시작가)
  final int priceStep; // 가격 단위 (기본 100원)

  const OptimalGame({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.participants,
    required this.maxParticipants,
    required this.winners,
    required this.originalPrice,
    required this.timeLeft,
    required this.category,
    required this.minPrice,
    required this.maxPrice,
    this.priceStep = 100,
  });

  /// 가능한 모든 가격 목록 생성
  List<int> get availablePrices {
    final prices = <int>[];
    for (int price = maxPrice; price >= minPrice; price -= priceStep) {
      prices.add(price);
    }
    return prices;
  }

  /// JSON으로부터 생성
  factory OptimalGame.fromJson(Map<String, dynamic> json) {
    return OptimalGame(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      participants: json['participants'] as int? ?? 0,
      maxParticipants: json['max_participants'] as int? ?? 0,
      winners: json['winners'] as int? ?? 1,
      originalPrice: json['original_price'] as int? ?? 0,
      timeLeft: json['time_left'] as String? ?? '',
      category: json['category'] as String? ?? 'Digital',
      minPrice: json['min_price'] as int? ?? 0,
      maxPrice: json['max_price'] as int? ?? 0,
      priceStep: json['price_step'] as int? ?? 100,
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
      'winners': winners,
      'original_price': originalPrice,
      'time_left': timeLeft,
      'category': category,
      'min_price': minPrice,
      'max_price': maxPrice,
      'price_step': priceStep,
    };
  }

  /// copyWith 메서드
  OptimalGame copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? participants,
    int? maxParticipants,
    int? winners,
    int? originalPrice,
    String? timeLeft,
    String? category,
    int? minPrice,
    int? maxPrice,
    int? priceStep,
  }) {
    return OptimalGame(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      participants: participants ?? this.participants,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      winners: winners ?? this.winners,
      originalPrice: originalPrice ?? this.originalPrice,
      timeLeft: timeLeft ?? this.timeLeft,
      category: category ?? this.category,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      priceStep: priceStep ?? this.priceStep,
    );
  }
}
