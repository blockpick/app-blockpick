/// 트랜잭션 진행 단계
enum TransactionPhase {
  /// Phase A: Mutation 전송 중 (steps 1-5)
  submitting,

  /// Phase B: 블록체인 폴링 중 (steps 6-7)
  polling,

  /// 블록체인 확정 완료
  confirmed,

  /// 실패
  failed,
}

/// 진행 중인 트랜잭션 상태
class PendingTransaction {
  final String gameId;
  final String gameTitle;
  final String? entryId;
  final String? txHash;
  final TransactionPhase phase;
  final int currentStep;
  final int totalSteps;
  final String? message;
  final String? errorMessage;
  final int? currentTxCount;
  final int? totalTxCount;
  final DateTime createdAt;

  PendingTransaction({
    required this.gameId,
    required this.gameTitle,
    this.entryId,
    this.txHash,
    required this.phase,
    this.currentStep = 1,
    this.totalSteps = 6,
    this.message,
    this.errorMessage,
    this.currentTxCount,
    this.totalTxCount,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  PendingTransaction copyWith({
    String? gameId,
    String? gameTitle,
    String? entryId,
    String? txHash,
    TransactionPhase? phase,
    int? currentStep,
    int? totalSteps,
    String? message,
    String? errorMessage,
    int? currentTxCount,
    int? totalTxCount,
    DateTime? createdAt,
  }) {
    return PendingTransaction(
      gameId: gameId ?? this.gameId,
      gameTitle: gameTitle ?? this.gameTitle,
      entryId: entryId ?? this.entryId,
      txHash: txHash ?? this.txHash,
      phase: phase ?? this.phase,
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      message: message ?? this.message,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTxCount: currentTxCount ?? this.currentTxCount,
      totalTxCount: totalTxCount ?? this.totalTxCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isInProgress =>
      phase == TransactionPhase.submitting || phase == TransactionPhase.polling;
  bool get isCompleted => phase == TransactionPhase.confirmed;
  bool get isFailed => phase == TransactionPhase.failed;

  String get stepDisplay => '$currentStep/$totalSteps';
}
