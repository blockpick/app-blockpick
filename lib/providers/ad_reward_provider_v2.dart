import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/ad_reward/ad_reward_models.dart';
import '../data/ad_reward/ad_reward_remote_datasource.dart';

/// 신규 AdRewardRemoteDataSource provider — claimAdReward / myAdRewards 새 스키마용.
/// 기존 ad_reward_provider.dart 는 옛 ad_reward_service 를 감싸는 deprecated 버전.
final adRewardRemoteDataSourceProvider =
    FutureProvider<AdRewardRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return AdRewardRemoteDataSource(client);
});

/// 특정 블록픽의 내 광고 시청 로그 목록
final myAdRewardsProvider = FutureProvider.autoDispose
    .family<List<AdRewardLog>, String>((ref, blockpickId) async {
  final ds = await ref.watch(adRewardRemoteDataSourceProvider.future);
  return ds.fetchMyAdRewards(blockpickId: blockpickId);
});
