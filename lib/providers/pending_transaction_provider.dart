import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/pending_transaction.dart';

part 'pending_transaction_provider.g.dart';

/// 진행 중인 트랜잭션 상태 관리 (keepAlive: 화면 전환 후에도 유지)
@Riverpod(keepAlive: true)
class PendingTransactionNotifier extends _$PendingTransactionNotifier {
  @override
  PendingTransaction? build() {
    return null;
  }

  /// Phase A 시작: Mutation 전송 시작
  void startTransaction({
    required String gameId,
    required String gameTitle,
  }) {
    state = PendingTransaction(
      gameId: gameId,
      gameTitle: gameTitle,
      phase: TransactionPhase.submitting,
      currentStep: 1,
      message: '게임 참여를 준비하고 있습니다...',
    );
  }

  /// Phase A 진행 상태 업데이트
  void updateSubmitProgress({
    required int currentStep,
    String? message,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      currentStep: currentStep,
      message: message,
    );
  }

  /// Phase A 완료 → Phase B 시작 (폴링 전환)
  void onMutationSuccess({
    required String entryId,
    String? txHash,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      phase: TransactionPhase.polling,
      entryId: entryId,
      txHash: txHash,
      currentStep: 5,
      message: '블록체인 트랜잭션을 처리하고 있습니다...',
    );
  }

  /// Phase B 폴링 중 업데이트
  void updatePollingProgress({
    required int currentTxCount,
    required int totalTxCount,
    String? txHash,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      currentTxCount: currentTxCount,
      totalTxCount: totalTxCount,
      txHash: txHash ?? state!.txHash,
      currentStep: 6,
      message: '$currentTxCount/$totalTxCount 트랜잭션 처리 중...',
    );
  }

  /// 성공 완료
  void onConfirmed({String? txHash}) {
    if (state == null) return;
    state = state!.copyWith(
      phase: TransactionPhase.confirmed,
      txHash: txHash ?? state!.txHash,
      currentStep: 6,
      message: '트랜잭션이 완료되었습니다!',
    );
  }

  /// 실패
  void onFailed({required String errorMessage}) {
    if (state == null) return;
    state = state!.copyWith(
      phase: TransactionPhase.failed,
      errorMessage: errorMessage,
      message: '트랜잭션 처리에 실패했습니다.',
    );
  }

  /// 상태 초기화
  void clear() {
    state = null;
  }
}
