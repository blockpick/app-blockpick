import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/offerwall/offerwall_models.dart';
import '../data/offerwall/offerwall_remote_datasource.dart';

/// OfferwallRemoteDataSource provider
final offerwallRemoteDataSourceProvider =
    FutureProvider<OfferwallRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return OfferwallRemoteDataSource(client);
});

/// 오퍼 목록 provider (카테고리 필터 기반)
/// null = 전체, 그 외 = 해당 카테고리만
final offerwallOffersProvider = FutureProvider.autoDispose
    .family<List<OfferwallOffer>, OfferwallCategory?>((ref, category) async {
  final ds = await ref.watch(offerwallRemoteDataSourceProvider.future);
  return ds.fetchOfferwallOffers(
    filter: OfferwallFilter(category: category),
  );
});

// ===== 오퍼 시작 State =====

/// 오퍼 시작 상태 (클릭 트래킹 + URL 획득)
class StartOfferwallOfferState {
  final bool isLoading;
  final StartOfferwallOfferResult? result;
  final String? errorMessage;

  const StartOfferwallOfferState({
    this.isLoading = false,
    this.result,
    this.errorMessage,
  });

  StartOfferwallOfferState copyWith({
    bool? isLoading,
    StartOfferwallOfferResult? result,
    String? errorMessage,
  }) {
    return StartOfferwallOfferState(
      isLoading: isLoading ?? this.isLoading,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// 오퍼 시작 Notifier
class StartOfferwallOfferNotifier
    extends StateNotifier<StartOfferwallOfferState> {
  final Ref _ref;

  StartOfferwallOfferNotifier(this._ref)
      : super(const StartOfferwallOfferState());

  Future<StartOfferwallOfferResult?> startOffer(String offerId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final ds = await _ref.read(offerwallRemoteDataSourceProvider.future);
      final result = await ds.startOfferwallOffer(offerId);
      state = StartOfferwallOfferState(result: result);
      return result;
    } catch (e) {
      state = StartOfferwallOfferState(
        errorMessage: '오퍼를 시작하는 중 오류가 발생했어요. 다시 시도해 주세요.',
      );
      return null;
    }
  }

  void reset() {
    state = const StartOfferwallOfferState();
  }
}

final startOfferwallOfferProvider = StateNotifierProvider.autoDispose<
    StartOfferwallOfferNotifier, StartOfferwallOfferState>(
  (ref) => StartOfferwallOfferNotifier(ref),
);
