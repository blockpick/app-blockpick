import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/winning/winning_models.dart';
import '../data/winning/winning_remote_datasource.dart';

/// WinningRemoteDataSource provider — 인증 필요
final winningRemoteDataSourceProvider =
    FutureProvider<WinningRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return WinningRemoteDataSource(client);
});

/// 내 당첨 내역
final myWinningsProvider =
    FutureProvider.autoDispose<List<WinningRecord>>((ref) async {
  final ds = await ref.watch(winningRemoteDataSourceProvider.future);
  return ds.fetchMyWinnings();
});
