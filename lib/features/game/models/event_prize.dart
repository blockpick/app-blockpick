/// 이벤트 상품 등급 (UI 폴백용)
enum PrizeGrade {
  common,    // 일반
  uncommon,  // 고급
  rare,      // 희귀
  epic,      // 에픽
}

/// 이벤트 보너스 상품
class EventPrize {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final PrizeGrade grade;
  final int value; // 원 단위 가치
  final int quantity; // 수량 (-1 = 무제한)
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? giftshowCouponUrl;

  const EventPrize({
    required this.id,
    required this.name,
    this.description = '',
    this.emoji = '🎁',
    this.grade = PrizeGrade.common,
    this.value = 0,
    this.quantity = -1,
    this.imageUrl,
    this.thumbnailUrl,
    this.giftshowCouponUrl,
  });

  /// 이미지가 있는지 여부
  bool get hasImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      (thumbnailUrl != null && thumbnailUrl!.isNotEmpty);

  /// 표시용 이미지 URL (thumbnailUrl 우선)
  String? get displayImageUrl => thumbnailUrl ?? imageUrl;

  /// 서버 instantPrize DTO에서 생성
  factory EventPrize.fromInstantPrizeDto(Map<String, dynamic> json) {
    return EventPrize(
      id: json['id'] ?? '',
      name: json['name'] ?? '경품',
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'],
      thumbnailUrl: json['thumbnailUrl'],
    );
  }

  /// 수량이 있는 복사본 생성
  EventPrize copyWith({
    int? quantity,
    String? giftshowCouponUrl,
  }) {
    return EventPrize(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      grade: grade,
      value: value,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      giftshowCouponUrl: giftshowCouponUrl ?? this.giftshowCouponUrl,
    );
  }

  /// 등급별 색상
  static (int, int, int) getGradeColor(PrizeGrade grade) {
    switch (grade) {
      case PrizeGrade.common:
        return (158, 158, 158); // Gray
      case PrizeGrade.uncommon:
        return (76, 175, 80);   // Green
      case PrizeGrade.rare:
        return (33, 150, 243);  // Blue
      case PrizeGrade.epic:
        return (156, 39, 176);  // Purple
    }
  }

  /// 등급별 이름
  static String getGradeName(PrizeGrade grade) {
    switch (grade) {
      case PrizeGrade.common:
        return '일반';
      case PrizeGrade.uncommon:
        return '고급';
      case PrizeGrade.rare:
        return '희귀';
      case PrizeGrade.epic:
        return '에픽';
    }
  }
}

/// 타겟 좌표와 상품 정보를 함께 담는 클래스
class EventTarget {
  final String id; // 고유 ID (당첨 시 제거용)
  final int row;
  final int col;
  final EventPrize prize;
  final bool isClaimed;

  EventTarget({
    String? id,
    required this.row,
    required this.col,
    required this.prize,
    this.isClaimed = false,
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}_${row}_$col';

  /// 서버 gameInstantPrize DTO에서 생성
  factory EventTarget.fromGameInstantPrizeDto(Map<String, dynamic> json) {
    final instantPrize = json['instantPrize'] as Map<String, dynamic>?;
    final customImageUrl = json['customImageUrl'] as String?;
    final customThumbnailUrl = json['customThumbnailUrl'] as String?;
    final couponUrl = json['giftshowCouponUrl'] as String?;

    // instantPrize 기본 정보로 EventPrize 생성 후 커스텀 이미지/쿠폰 URL 적용
    EventPrize prize;
    if (instantPrize != null) {
      prize = EventPrize.fromInstantPrizeDto(instantPrize);
      // 커스텀 이미지가 있으면 덮어씌움
      if (customImageUrl != null || customThumbnailUrl != null || couponUrl != null) {
        prize = EventPrize(
          id: prize.id,
          name: prize.name,
          description: prize.description,
          imageUrl: customImageUrl ?? prize.imageUrl,
          thumbnailUrl: customThumbnailUrl ?? prize.thumbnailUrl,
          giftshowCouponUrl: couponUrl,
        );
      }
    } else {
      prize = EventPrize(
        id: json['id'] ?? '',
        name: '경품',
        imageUrl: customImageUrl,
        thumbnailUrl: customThumbnailUrl,
        giftshowCouponUrl: couponUrl,
      );
    }

    return EventTarget(
      id: json['id'] ?? '',
      row: json['gridY'] ?? 0,
      col: json['gridX'] ?? 0,
      prize: prize,
      isClaimed: json['isClaimed'] ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTarget && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
