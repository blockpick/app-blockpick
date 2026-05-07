import 'package:graphql_flutter/graphql_flutter.dart';
import 'referral_models.dart';

class ReferralRemoteDataSource {
  final GraphQLClient _client;

  ReferralRemoteDataSource(this._client);

  static const String myInviteCodeQuery = r'''
    query MyInviteCode {
      myInviteCode {
        success
        code
        message
        inviteCode
        totalInvitees
      }
    }
  ''';

  static const String myReferralsQuery = r'''
    query MyReferrals {
      myReferrals {
        success
        code
        message
        items {
          id
          inviterId
          inviteeId
          inviteCode
          status
          signedUpAt
          rewardedAt
          createdAt
        }
      }
    }
  ''';

  static const String applyInviteCodeMutation = r'''
    mutation ApplyInviteCode($input: ApplyInviteCodeInput!) {
      applyInviteCode(input: $input) {
        success
        code
        message
        referral {
          id
          inviterId
          inviteeId
          inviteCode
          status
          signedUpAt
          rewardedAt
          createdAt
        }
      }
    }
  ''';

  Future<MyInviteCodeInfo> fetchMyInviteCode() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myInviteCodeQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myInviteCode'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myInviteCode');
    }
    return MyInviteCodeInfo.fromJson(data as Map<String, dynamic>);
  }

  Future<List<Referral>> fetchMyReferrals() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myReferralsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myReferrals'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myReferrals');
    }

    return ((data['items'] as List?) ?? const [])
        .map((e) => Referral.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Referral> applyInviteCode({required String inviteCode}) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(applyInviteCodeMutation),
        variables: {
          'input': {'inviteCode': inviteCode},
        },
      ),
    );

    final data = result.data?['applyInviteCode'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: applyInviteCode');
    }
    final referral = data['referral'];
    if (referral == null) {
      throw Exception('Failed: applyInviteCode (referral null)');
    }
    return Referral.fromJson(referral as Map<String, dynamic>);
  }
}
