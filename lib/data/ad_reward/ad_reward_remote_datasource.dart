import 'package:graphql_flutter/graphql_flutter.dart';
import 'ad_reward_models.dart';

class AdRewardRemoteDataSource {
  final GraphQLClient _client;

  AdRewardRemoteDataSource(this._client);

  static const String claimAdRewardMutation = r'''
    mutation ClaimAdReward($input: ClaimAdRewardInput!) {
      claimAdReward(input: $input) {
        success
        code
        message
        log {
          id
          blockpickId
          watchedAt
          ticketIssued
          ticketId
          externalNetworkRef
        }
        ticketId
      }
    }
  ''';

  static const String myAdRewardsQuery = r'''
    query MyAdRewards($blockpickId: String!) {
      myAdRewards(blockpickId: $blockpickId) {
        success
        code
        message
        items {
          id
          blockpickId
          watchedAt
          ticketIssued
          ticketId
          externalNetworkRef
        }
      }
    }
  ''';

  Future<({AdRewardLog log, String? ticketId})> claimAdReward({
    required String blockpickId,
    String? externalNetworkRef,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(claimAdRewardMutation),
        variables: {
          'input': {
            'blockpickId': blockpickId,
            if (externalNetworkRef != null)
              'externalNetworkRef': externalNetworkRef,
          },
        },
      ),
    );

    final data = result.data?['claimAdReward'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: claimAdReward');
    }
    final log = data['log'];
    if (log == null) {
      throw Exception('Failed: claimAdReward (log null)');
    }
    return (
      log: AdRewardLog.fromJson(log as Map<String, dynamic>),
      ticketId: data['ticketId'] as String?,
    );
  }

  Future<List<AdRewardLog>> fetchMyAdRewards({
    required String blockpickId,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myAdRewardsQuery),
        variables: {'blockpickId': blockpickId},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myAdRewards'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myAdRewards');
    }
    return ((data['items'] as List?) ?? const [])
        .map((e) => AdRewardLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
