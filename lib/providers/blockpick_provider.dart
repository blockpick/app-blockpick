import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/blockpick/blockpick_models.dart';
import '../data/blockpick/blockpick_remote_datasource.dart';
import '../data/blockpick/blockpick_to_game_adapter.dart';
import '../models/game_round_model.dart';

/// BlockpickRemoteDataSource provider
/// 인증 토큰 자동 첨부 위해 graphqlClientProvider 사용. 비로그인도 호출 가능.
final blockpickRemoteDataSourceProvider =
    FutureProvider<BlockpickRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return BlockpickRemoteDataSource(client);
});

/// 블록픽 목록 (필터 기반)
final blockpickListProvider = FutureProvider.autoDispose
    .family<BlockpickListPage, BlockpickFilterInput?>((ref, filter) async {
  final ds = await ref.watch(blockpickRemoteDataSourceProvider.future);
  return ds.fetchBlockpicks(filter: filter);
});

/// 블록픽 상세 — NOT_FOUND이면 null
final blockpickDetailProvider = FutureProvider.autoDispose
    .family<BlockpickDetail?, String>((ref, id) async {
  final ds = await ref.watch(blockpickRemoteDataSourceProvider.future);
  return ds.fetchBlockpick(id: id);
});

/// 블록픽 카테고리 목록
final blockpickCategoriesProvider =
    FutureProvider.autoDispose<List<Category>>((ref) async {
  final ds = await ref.watch(blockpickRemoteDataSourceProvider.future);
  return ds.fetchCategories();
});

// =============================================================================
// game_provider 마이그레이션용 어댑터 provider
//
// 구 gamesByTypeProvider(GameType) → 신 blockpicksByGameTypeProvider(GameType)
//
// TODO (백엔드 정합 후 재검증):
//   BlockpickSummary에 gameType 필드 추가 후 클라이언트 Mock 분기 제거하고
//   실제 서버 필터 파라미터로 교체. docs/blockpick_summary_field_request.md 참조.
// =============================================================================

/// GameType 기반 블록픽 목록 → GameRound 목록 변환 provider
///
/// - 현재 BlockpickSummary에 gameType 필드 없음 → 전체 목록 조회 후 mockGameType을 그대로 적용.
/// - 백엔드에 gameType 추가 후: fetchBlockpicks(filter: BlockpickFilterInput(gameType: ...)) 로 교체.
final blockpicksByGameTypeProvider =
    FutureProvider.autoDispose.family<List<GameRound>, GameType>(
  (ref, gameType) async {
    final ds = await ref.watch(blockpickRemoteDataSourceProvider.future);
    // TODO: 백엔드 gameType 필터 지원 후 filter 파라미터 추가
    final page = await ds.fetchBlockpicks(
      filter: const BlockpickFilterInput(onlyOngoing: true),
    );
    return BlockpickToGameAdapter.fromSummaryList(
      page.items,
      mockGameType: gameType,
    );
  },
);

/// 전체 블록픽 목록 → GameRound 목록 (gameType 무관, gamesProvider 대체용)
final allBlockpicksAsGameRoundsProvider =
    FutureProvider.autoDispose<List<GameRound>>((ref) async {
  final ds = await ref.watch(blockpickRemoteDataSourceProvider.future);
  final page = await ds.fetchBlockpicks();
  return BlockpickToGameAdapter.fromSummaryList(page.items);
});
