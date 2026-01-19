import 'dart:math';

/// 이벤트 상품 등급
enum PrizeGrade {
  common,    // 일반 (60%)
  uncommon,  // 고급 (25%)
  rare,      // 희귀 (12%)
  epic,      // 에픽 (3%)
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

  const EventPrize({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.grade,
    required this.value,
    this.quantity = -1,
  });

  /// 수량이 있는 복사본 생성
  EventPrize copyWith({int? quantity}) {
    return EventPrize(
      id: id,
      name: name,
      description: description,
      emoji: emoji,
      grade: grade,
      value: value,
      quantity: quantity ?? this.quantity,
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

/// 게임별 상품군 풀 (관리자에서 설정 예정)
class EventPrizePool {
  final String id;
  final String name;
  final List<EventPrize> prizes;
  final int maxPrizeCount; // 최대 배치 가능한 상품 수

  const EventPrizePool({
    required this.id,
    required this.name,
    required this.prizes,
    this.maxPrizeCount = 10,
  });

  /// 등급별 확률에 따라 랜덤 상품 선택
  EventPrize getRandomPrize() {
    if (prizes.isEmpty) return defaultPool.getRandomPrize();

    final random = Random();
    final roll = random.nextDouble() * 100;

    PrizeGrade selectedGrade;
    if (roll < 3) {
      selectedGrade = PrizeGrade.epic;      // 3%
    } else if (roll < 15) {
      selectedGrade = PrizeGrade.rare;      // 12%
    } else if (roll < 40) {
      selectedGrade = PrizeGrade.uncommon;  // 25%
    } else {
      selectedGrade = PrizeGrade.common;    // 60%
    }

    // 해당 등급의 상품 중 랜덤 선택
    final prizesOfGrade = prizes.where((p) => p.grade == selectedGrade).toList();

    // 해당 등급 상품이 없으면 전체에서 랜덤
    if (prizesOfGrade.isEmpty) {
      return prizes[random.nextInt(prizes.length)];
    }

    return prizesOfGrade[random.nextInt(prizesOfGrade.length)];
  }

  /// 기본 상품 풀 (10가지)
  static const EventPrizePool defaultPool = EventPrizePool(
    id: 'default',
    name: '기본 상품군',
    maxPrizeCount: 20,
    prizes: [
      // Common (일반) - 60%
      EventPrize(
        id: 'vita500',
        name: '비타500',
        description: '피로회복에 좋은 비타민 음료',
        emoji: '🍊',
        grade: PrizeGrade.common,
        value: 1000,
      ),
      EventPrize(
        id: 'chocopie',
        name: '초코파이',
        description: '달콤한 초코파이 1박스',
        emoji: '🍫',
        grade: PrizeGrade.common,
        value: 1500,
      ),
      EventPrize(
        id: 'pepero',
        name: '빼빼로',
        description: '바삭바삭 빼빼로',
        emoji: '🥢',
        grade: PrizeGrade.common,
        value: 1200,
      ),
      EventPrize(
        id: 'coffee',
        name: '아메리카노',
        description: '스타벅스 아메리카노 (Tall)',
        emoji: '☕',
        grade: PrizeGrade.common,
        value: 4500,
      ),

      // Uncommon (고급) - 25%
      EventPrize(
        id: 'gift5000',
        name: '기프티콘 5,000원',
        description: 'CU 편의점 상품권',
        emoji: '🎫',
        grade: PrizeGrade.uncommon,
        value: 5000,
      ),
      EventPrize(
        id: 'chicken',
        name: '치킨 할인권',
        description: 'BBQ 3,000원 할인권',
        emoji: '🍗',
        grade: PrizeGrade.uncommon,
        value: 3000,
      ),
      EventPrize(
        id: 'icecream',
        name: '배스킨라빈스',
        description: '파인트 아이스크림',
        emoji: '🍨',
        grade: PrizeGrade.uncommon,
        value: 8900,
      ),

      // Rare (희귀) - 12%
      EventPrize(
        id: 'gift10000',
        name: '기프티콘 10,000원',
        description: '네이버페이 포인트',
        emoji: '💳',
        grade: PrizeGrade.rare,
        value: 10000,
      ),
      EventPrize(
        id: 'movie',
        name: '영화 예매권',
        description: 'CGV 영화 1인 관람권',
        emoji: '🎬',
        grade: PrizeGrade.rare,
        value: 13000,
      ),

      // Epic (에픽) - 3%
      EventPrize(
        id: 'gift30000',
        name: '기프티콘 30,000원',
        description: '배달의민족 상품권',
        emoji: '🎁',
        grade: PrizeGrade.epic,
        value: 30000,
      ),
    ],
  );

  /// 프리미엄 상품 풀 예시 (나중에 관리자에서 추가)
  static const EventPrizePool premiumPool = EventPrizePool(
    id: 'premium',
    name: '프리미엄 상품군',
    maxPrizeCount: 5,
    prizes: [
      EventPrize(
        id: 'airpods',
        name: '에어팟',
        description: 'Apple AirPods 3세대',
        emoji: '🎧',
        grade: PrizeGrade.epic,
        value: 250000,
      ),
      EventPrize(
        id: 'gift50000',
        name: '기프티콘 50,000원',
        description: '신세계 상품권',
        emoji: '💎',
        grade: PrizeGrade.epic,
        value: 50000,
      ),
      EventPrize(
        id: 'starbucks_card',
        name: '스타벅스 카드',
        description: '스타벅스 충전카드 30,000원',
        emoji: '💚',
        grade: PrizeGrade.rare,
        value: 30000,
      ),
      EventPrize(
        id: 'chicken_set',
        name: '치킨 세트',
        description: 'BBQ 황금올리브 + 콜라',
        emoji: '🍗',
        grade: PrizeGrade.uncommon,
        value: 22000,
      ),
      EventPrize(
        id: 'pizza',
        name: '피자',
        description: '도미노 라지 피자',
        emoji: '🍕',
        grade: PrizeGrade.common,
        value: 25000,
      ),
    ],
  );

  /// 사용 가능한 모든 상품 풀 (나중에 API에서 가져올 예정)
  static List<EventPrizePool> get availablePools => [
    defaultPool,
    premiumPool,
  ];
}

/// 타겟 좌표와 상품 정보를 함께 담는 클래스
class EventTarget {
  final String id; // 고유 ID (당첨 시 제거용)
  final int row;
  final int col;
  final EventPrize prize;

  EventTarget({
    String? id,
    required this.row,
    required this.col,
    required this.prize,
  }) : id = id ?? '${DateTime.now().millisecondsSinceEpoch}_${row}_$col';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventTarget && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
