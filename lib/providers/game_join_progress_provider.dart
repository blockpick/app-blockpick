import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../features/game/widgets/game_join_progress_overlay.dart';

part 'game_join_progress_provider.g.dart';

/// 게임 참여 진행 상태 정보
class GameJoinProgress {
  final GameJoinStep step;
  final String? message;
  final String? txHash;
  final bool isError;
  final String? errorMessage;
  final int? currentTxCount;
  final int? totalTxCount;

  GameJoinProgress({
    required this.step,
    this.message,
    this.txHash,
    this.isError = false,
    this.errorMessage,
    this.currentTxCount,
    this.totalTxCount,
  });

  GameJoinProgress copyWith({
    GameJoinStep? step,
    String? message,
    String? txHash,
    bool? isError,
    String? errorMessage,
    int? currentTxCount,
    int? totalTxCount,
  }) {
    return GameJoinProgress(
      step: step ?? this.step,
      message: message ?? this.message,
      txHash: txHash ?? this.txHash,
      isError: isError ?? this.isError,
      errorMessage: errorMessage ?? this.errorMessage,
      currentTxCount: currentTxCount ?? this.currentTxCount,
      totalTxCount: totalTxCount ?? this.totalTxCount,
    );
  }
}

/// 게임 참여 진행 상태 관리
@riverpod
class GameJoinProgressNotifier extends _$GameJoinProgressNotifier {
  @override
  GameJoinProgress? build() {
    return null;
  }

  void updateProgress({
    required GameJoinStep step,
    String? message,
    String? txHash,
  }) {
    state = GameJoinProgress(
      step: step,
      message: message,
      txHash: txHash,
    );
  }

  void updateError({
    required GameJoinStep step,
    required String errorMessage,
  }) {
    state = GameJoinProgress(
      step: step,
      isError: true,
      errorMessage: errorMessage,
    );
  }

  void updatePollingProgress({
    required String entryId,
    required int currentTxCount,
    required int totalTxCount,
    String? currentTxHash,
  }) {
    state = GameJoinProgress(
      step: GameJoinStep.polling,
      message: '$currentTxCount/$totalTxCount 트랜잭션 처리 중...',
      txHash: currentTxHash,
      currentTxCount: currentTxCount,
      totalTxCount: totalTxCount,
    );
  }

  void reset() {
    state = null;
  }
}
