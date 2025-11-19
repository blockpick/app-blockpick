/// 트랜잭션 의도 상세 정보
class TxIntentDetail {
  final String intentId;
  final String status;
  final String? txHash;
  final String? errorCode;
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime updatedAt;

  TxIntentDetail({
    required this.intentId,
    required this.status,
    this.txHash,
    this.errorCode,
    this.errorMessage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TxIntentDetail.fromJson(Map<String, dynamic> json) {
    return TxIntentDetail(
      intentId: json['intentId'] as String,
      status: json['status'] as String,
      txHash: json['txHash'] as String?,
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() {
    return 'TxIntentDetail(intentId: $intentId, status: $status, txHash: $txHash)';
  }
}

/// 게임 참여 상태
class EntryStatus {
  final bool success;
  final String entryId;
  final String status; // PENDING, PROCESSING, CONFIRMED, FAILED
  final List<TxIntentDetail> txIntents;
  final String? errorMessage;

  EntryStatus({
    required this.success,
    required this.entryId,
    required this.status,
    required this.txIntents,
    this.errorMessage,
  });

  factory EntryStatus.fromJson(Map<String, dynamic> json) {
    final txIntentsJson = json['txIntents'] as List?;
    final txIntents = txIntentsJson
            ?.map((item) => TxIntentDetail.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    return EntryStatus(
      success: json['success'] as bool,
      entryId: json['entryId'] as String,
      status: json['status'] as String,
      txIntents: txIntents,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  bool get isConfirmed => status == 'CONFIRMED';
  bool get isFailed => status == 'FAILED';
  bool get isProcessing => status == 'PROCESSING' || status == 'PENDING';

  @override
  String toString() {
    return 'EntryStatus(entryId: $entryId, status: $status, txIntents: ${txIntents.length})';
  }
}
