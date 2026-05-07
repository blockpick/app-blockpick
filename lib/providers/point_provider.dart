import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/point/point_models.dart';
import '../data/point/point_remote_datasource.dart';

/// PointRemoteDataSource provider
final pointRemoteDataSourceProvider =
    FutureProvider<PointRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return PointRemoteDataSource(client);
});

/// 포인트 지갑 provider
final pointWalletProvider =
    FutureProvider.autoDispose<PointWallet>((ref) async {
  final ds = await ref.watch(pointRemoteDataSourceProvider.future);
  return ds.fetchPointWallet();
});

/// 포인트 거래 내역 provider (페이지 번호 기반)
final pointTransactionsProvider = FutureProvider.autoDispose
    .family<PointTransactionPage, int>((ref, page) async {
  final ds = await ref.watch(pointRemoteDataSourceProvider.future);
  return ds.fetchPointTransactions(page: page);
});

// ===== 출석체크 State =====

/// 출석체크 상태
class CheckInState {
  final bool isLoading;
  final CheckInResult? result;
  final String? errorMessage;

  const CheckInState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  CheckInState copyWith({
    bool? isLoading,
    CheckInResult? result,
    String? errorMessage,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 출석체크 Notifier
class CheckInNotifier extends StateNotifier<CheckInState> {
  final Ref _ref;

  CheckInNotifier(this._ref) : super(const CheckInState());

  Future<void> claimCheckIn() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ds = await _ref.read(pointRemoteDataSourceProvider.future);
      final result = await ds.claimDailyCheckIn();
      state = CheckInState(result: result);
      // 지갑 잔액 갱신
      _ref.invalidate(pointWalletProvider);
    } on AlreadyCheckedInException catch (e) {
      state = CheckInState(errorMessage: e.message);
    } catch (e) {
      state = CheckInState(errorMessage: '출석체크 중 오류가 발생했어요. 다시 시도해 주세요.');
    }
  }

  void reset() {
    state = const CheckInState();
  }
}

final checkInProvider =
    StateNotifierProvider.autoDispose<CheckInNotifier, CheckInState>(
  (ref) => CheckInNotifier(ref),
);

// ===== 미니게임 State =====

/// 미니게임 진행 단계
enum MiniGamePhase { idle, playing, result }

/// 미니게임 상태
class MiniGameState {
  final MiniGamePhase phase;
  final bool isLoading;
  final MiniGameResult? result;
  final String? errorMessage;

  const MiniGameState({
    this.phase = MiniGamePhase.idle,
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  MiniGameState copyWith({
    MiniGamePhase? phase,
    bool? isLoading,
    MiniGameResult? result,
    String? errorMessage,
  }) {
    return MiniGameState(
      phase: phase ?? this.phase,
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 미니게임 Notifier
class MiniGameNotifier extends StateNotifier<MiniGameState> {
  final Ref _ref;

  MiniGameNotifier(this._ref) : super(const MiniGameState());

  void startGame() {
    state = const MiniGameState(phase: MiniGamePhase.playing);
  }

  Future<void> submitResult({
    required bool won,
    required bool watchedAd,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ds = await _ref.read(pointRemoteDataSourceProvider.future);
      final result = await ds.playMiniGame(
        PlayMiniGameInput(
          gameType: 'CARD_FLIP',
          won: won,
          watchedAd: watchedAd,
        ),
      );
      state = MiniGameState(phase: MiniGamePhase.result, result: result);
      // 지갑 잔액 갱신
      _ref.invalidate(pointWalletProvider);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: '게임 결과 처리 중 오류가 발생했어요.',
      );
    }
  }

  void reset() {
    state = const MiniGameState();
  }
}

final miniGameProvider =
    StateNotifierProvider.autoDispose<MiniGameNotifier, MiniGameState>(
  (ref) => MiniGameNotifier(ref),
);
