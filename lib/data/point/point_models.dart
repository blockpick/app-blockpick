// 포인트 도메인 DTO 모델 + enum
// blockpick-api S01 schema 기준 매핑.

// ===== Enums =====

/// 포인트 적립/사용 사유
enum PointReason {
  adReward,
  miniGame,
  checkIn,
  offerwall,
  blockpickJoin,
  referral,
  adminGrant,
}

PointReason pointReasonFromString(String? s) {
  if (s == null) return PointReason.adminGrant;
  switch (s) {
    case 'AD_REWARD':
      return PointReason.adReward;
    case 'MINI_GAME':
      return PointReason.miniGame;
    case 'CHECK_IN':
      return PointReason.checkIn;
    case 'OFFERWALL':
      return PointReason.offerwall;
    case 'BLOCKPICK_JOIN':
      return PointReason.blockpickJoin;
    case 'REFERRAL':
      return PointReason.referral;
    case 'ADMIN_GRANT':
      return PointReason.adminGrant;
    default:
      return PointReason.adminGrant;
  }
}

/// 사유 한글 라벨
String pointReasonLabel(PointReason r) {
  switch (r) {
    case PointReason.adReward:
      return '광고 보상';
    case PointReason.miniGame:
      return '미니게임';
    case PointReason.checkIn:
      return '출석체크';
    case PointReason.offerwall:
      return '오퍼월';
    case PointReason.blockpickJoin:
      return '블록픽 참여';
    case PointReason.referral:
      return '친구초대';
    case PointReason.adminGrant:
      return '관리자 지급';
  }
}

/// 포인트 거래 유형
enum PointType { grant, consume }

PointType pointTypeFromString(String? s) {
  if (s == null) return PointType.grant;
  switch (s) {
    case 'GRANT':
      return PointType.grant;
    case 'CONSUME':
      return PointType.consume;
    default:
      return PointType.grant;
  }
}

// ===== DTO =====

/// 포인트 지갑 요약
class PointWallet {
  final String userId;
  final int balance;
  final int totalEarned;
  final int totalConsumed;

  const PointWallet({
    required this.userId,
    required this.balance,
    required this.totalEarned,
    required this.totalConsumed,
  });

  factory PointWallet.fromJson(Map<String, dynamic> json) {
    return PointWallet(
      userId: json['userId'] as String? ?? '',
      balance: (json['balance'] as num?)?.toInt() ?? 0,
      totalEarned: (json['totalEarned'] as num?)?.toInt() ?? 0,
      totalConsumed: (json['totalConsumed'] as num?)?.toInt() ?? 0,
    );
  }
}

/// 포인트 거래 내역 항목
class PointTransaction {
  final String id;
  final PointType type;
  final PointReason reason;
  final int amount;
  final int balanceAfter;
  final String? note;
  final DateTime createdAt;

  const PointTransaction({
    required this.id,
    required this.type,
    required this.reason,
    required this.amount,
    required this.balanceAfter,
    this.note,
    required this.createdAt,
  });

  factory PointTransaction.fromJson(Map<String, dynamic> json) {
    return PointTransaction(
      id: json['id'] as String? ?? '',
      type: pointTypeFromString(json['type'] as String?),
      reason: pointReasonFromString(json['reason'] as String?),
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
      note: json['note'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// 포인트 거래 내역 페이지
class PointTransactionPage {
  final List<PointTransaction> items;
  final int totalCount;
  final int page;
  final int size;
  final bool hasNext;

  const PointTransactionPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  factory PointTransactionPage.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return PointTransactionPage(
      items: rawItems
          .map((e) => PointTransaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? 20,
      hasNext: json['hasNext'] as bool? ?? false,
    );
  }
}

/// 출석체크 결과
class CheckInResult {
  final bool success;
  final int pointsEarned;
  final int currentStreak;
  final bool bonusAwarded; // 7일 연속 보너스 여부
  final String? message;

  const CheckInResult({
    required this.success,
    required this.pointsEarned,
    required this.currentStreak,
    required this.bonusAwarded,
    this.message,
  });

  factory CheckInResult.fromJson(Map<String, dynamic> json) {
    return CheckInResult(
      success: json['success'] as bool? ?? false,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      bonusAwarded: json['bonusAwarded'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }
}

/// 미니게임 결과
class MiniGameResult {
  final bool success;
  final bool won;
  final int pointsEarned;
  final String? message;

  const MiniGameResult({
    required this.success,
    required this.won,
    required this.pointsEarned,
    this.message,
  });

  factory MiniGameResult.fromJson(Map<String, dynamic> json) {
    return MiniGameResult(
      success: json['success'] as bool? ?? false,
      won: json['won'] as bool? ?? false,
      pointsEarned: (json['pointsEarned'] as num?)?.toInt() ?? 0,
      message: json['message'] as String?,
    );
  }
}

/// 미니게임 입력 파라미터
class PlayMiniGameInput {
  final String gameType; // CARD_FLIP, ROULETTE 등
  final bool won;
  final bool watchedAd;

  const PlayMiniGameInput({
    required this.gameType,
    required this.won,
    required this.watchedAd,
  });

  Map<String, dynamic> toJson() => {
        'gameType': gameType,
        'won': won,
        'watchedAd': watchedAd,
      };
}
