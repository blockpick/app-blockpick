// Winning 도메인 DTO + enum

enum WinningStatus {
  pending,
  claimRequired,
  processing,
  delivered,
  completed,
  failed,
}

WinningStatus winningStatusFromString(String? s) {
  if (s == null) return WinningStatus.pending;
  switch (s) {
    case 'PENDING':
      return WinningStatus.pending;
    case 'CLAIM_REQUIRED':
      return WinningStatus.claimRequired;
    case 'PROCESSING':
      return WinningStatus.processing;
    case 'DELIVERED':
      return WinningStatus.delivered;
    case 'COMPLETED':
      return WinningStatus.completed;
    case 'FAILED':
      return WinningStatus.failed;
    default:
      return WinningStatus.pending;
  }
}

class WinningRecord {
  final String id;
  final String entryId;
  final String blockpickPrizeId;
  final String userId;
  final WinningStatus status;
  final String? couponCode;
  final String? codeIssuedAt;
  final String? deliveryAddressId;
  final String issuedAt;
  final String? deliveredAt;

  const WinningRecord({
    required this.id,
    required this.entryId,
    required this.blockpickPrizeId,
    required this.userId,
    required this.status,
    this.couponCode,
    this.codeIssuedAt,
    this.deliveryAddressId,
    required this.issuedAt,
    this.deliveredAt,
  });

  factory WinningRecord.fromJson(Map<String, dynamic> json) => WinningRecord(
        id: json['id'] as String,
        entryId: json['entryId'] as String,
        blockpickPrizeId: json['blockpickPrizeId'] as String,
        userId: json['userId'] as String,
        status: winningStatusFromString(json['status'] as String?),
        couponCode: json['couponCode'] as String?,
        codeIssuedAt: json['codeIssuedAt'] as String?,
        deliveryAddressId: json['deliveryAddressId'] as String?,
        issuedAt: json['issuedAt'] as String,
        deliveredAt: json['deliveredAt'] as String?,
      );
}
