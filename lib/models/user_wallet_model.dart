/// 사용자 지갑 모델
class UserWallet {
  final String userId;

  // 3가지 캐시 유형
  final int fundingCash; // 충전캐시 (환불 대상)
  final int eventCash; // 이벤트 캐시 (게임용)
  final int shoppingCash; // 쇼핑 캐시 (쇼핑용)

  // 누적 사용액 (환불 판단용)
  final int totalEventCashUsed;
  final int totalShoppingCashUsed;

  // 통계
  final int totalDeposit; // 총 충전액
  final int totalRefund; // 총 환불액
  final int totalGameReward; // 총 게임 상금

  final DateTime updatedAt;

  const UserWallet({
    required this.userId,
    required this.fundingCash,
    required this.eventCash,
    required this.shoppingCash,
    required this.totalEventCashUsed,
    required this.totalShoppingCashUsed,
    required this.totalDeposit,
    required this.totalRefund,
    required this.totalGameReward,
    required this.updatedAt,
  });

  /// 총 보유 캐시 (충전 + 이벤트 + 쇼핑)
  int get totalCash => fundingCash + eventCash + shoppingCash;

  /// 환불 가능 여부 (이벤트 AND 쇼핑 캐시 모두 미사용)
  bool get isRefundable =>
      totalEventCashUsed == 0 && totalShoppingCashUsed == 0;

  /// 환불 가능 금액
  int get refundableAmount => isRefundable ? fundingCash : 0;

  /// 오늘의 변동 금액 (임시: 게임 상금으로 계산, 추후 거래 내역 기반으로 변경)
  int get todayChange => totalGameReward;

  /// 오늘의 변동 퍼센트
  double get todayChangePercent {
    if (totalCash == 0) return 0.0;
    return (todayChange / totalCash) * 100;
  }

  UserWallet copyWith({
    String? userId,
    int? fundingCash,
    int? eventCash,
    int? shoppingCash,
    int? totalEventCashUsed,
    int? totalShoppingCashUsed,
    int? totalDeposit,
    int? totalRefund,
    int? totalGameReward,
    DateTime? updatedAt,
  }) {
    return UserWallet(
      userId: userId ?? this.userId,
      fundingCash: fundingCash ?? this.fundingCash,
      eventCash: eventCash ?? this.eventCash,
      shoppingCash: shoppingCash ?? this.shoppingCash,
      totalEventCashUsed: totalEventCashUsed ?? this.totalEventCashUsed,
      totalShoppingCashUsed:
          totalShoppingCashUsed ?? this.totalShoppingCashUsed,
      totalDeposit: totalDeposit ?? this.totalDeposit,
      totalRefund: totalRefund ?? this.totalRefund,
      totalGameReward: totalGameReward ?? this.totalGameReward,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fundingCash': fundingCash,
      'eventCash': eventCash,
      'shoppingCash': shoppingCash,
      'totalEventCashUsed': totalEventCashUsed,
      'totalShoppingCashUsed': totalShoppingCashUsed,
      'totalDeposit': totalDeposit,
      'totalRefund': totalRefund,
      'totalGameReward': totalGameReward,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserWallet.fromJson(Map<String, dynamic> json) {
    return UserWallet(
      userId: json['userId'] as String,
      fundingCash: json['fundingCash'] as int,
      eventCash: json['eventCash'] as int,
      shoppingCash: json['shoppingCash'] as int,
      totalEventCashUsed: json['totalEventCashUsed'] as int,
      totalShoppingCashUsed: json['totalShoppingCashUsed'] as int,
      totalDeposit: json['totalDeposit'] as int,
      totalRefund: json['totalRefund'] as int,
      totalGameReward: json['totalGameReward'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
