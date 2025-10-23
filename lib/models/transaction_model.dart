/// 거래 내역 모델
class Transaction {
  final String id;
  final String userId;
  final TransactionType type;
  final int amount;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.description,
    this.metadata,
    required this.createdAt,
  });

  /// 금액이 증가하는 거래인지
  bool get isIncrease {
    return type == TransactionType.deposit ||
        type == TransactionType.refund ||
        type == TransactionType.gameReward;
  }

  /// 금액이 감소하는 거래인지
  bool get isDecrease {
    return type == TransactionType.gameEntry ||
        type == TransactionType.shoppingPurchase;
  }

  Transaction copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    int? amount,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'description': description,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.deposit,
      ),
      amount: json['amount'] as int,
      description: json['description'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// 거래 유형
enum TransactionType {
  deposit, // 충전
  refund, // 환불
  gameEntry, // 게임 참가
  gameReward, // 게임 상금
  shoppingPurchase; // 쇼핑 구매

  String get displayName {
    switch (this) {
      case TransactionType.deposit:
        return '캐시 충전';
      case TransactionType.refund:
        return '환불';
      case TransactionType.gameEntry:
        return '게임 참가';
      case TransactionType.gameReward:
        return '게임 상금';
      case TransactionType.shoppingPurchase:
        return '쇼핑 구매';
    }
  }

  String get emoji {
    switch (this) {
      case TransactionType.deposit:
        return '💰';
      case TransactionType.refund:
        return '💸';
      case TransactionType.gameEntry:
        return '🎮';
      case TransactionType.gameReward:
        return '🏆';
      case TransactionType.shoppingPurchase:
        return '🛒';
    }
  }
}
