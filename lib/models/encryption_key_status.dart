/// 암호화 키 생성 상태
class EncryptionKeyStatus {
  final bool success;
  final String requestId;
  final String status; // PENDING, PROCESSING, COMPLETED, FAILED
  final String? txHash;
  final String? errorCode;
  final String? errorMessage;

  EncryptionKeyStatus({
    required this.success,
    required this.requestId,
    required this.status,
    this.txHash,
    this.errorCode,
    this.errorMessage,
  });

  factory EncryptionKeyStatus.fromJson(Map<String, dynamic> json) {
    return EncryptionKeyStatus(
      success: json['success'] as bool,
      requestId: json['requestId'] as String,
      status: json['status'] as String,
      txHash: json['txHash'] as String?,
      errorCode: json['errorCode'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  bool get isCompleted => status == 'COMPLETED';
  bool get isFailed => status == 'FAILED';
  bool get isProcessing => status == 'PROCESSING' || status == 'PENDING' || status == 'QUEUED';

  @override
  String toString() {
    return 'EncryptionKeyStatus(requestId: $requestId, status: $status, txHash: $txHash)';
  }
}
