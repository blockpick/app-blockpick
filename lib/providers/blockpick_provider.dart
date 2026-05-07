import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/blockpick/blockpick_models.dart';
import '../data/blockpick/blockpick_remote_datasource.dart';

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
