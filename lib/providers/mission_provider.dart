import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/mission/mission_models.dart';
import '../data/mission/mission_remote_datasource.dart';

/// MissionRemoteDataSource provider — 인증 필요
final missionRemoteDataSourceProvider =
    FutureProvider<MissionRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return MissionRemoteDataSource(client);
});

/// 내 미션 목록 (blockpickId 옵셔널)
final myMissionsProvider = FutureProvider.autoDispose
    .family<List<Mission>, String?>((ref, blockpickId) async {
  final ds = await ref.watch(missionRemoteDataSourceProvider.future);
  return ds.fetchMyMissions(blockpickId: blockpickId);
});
