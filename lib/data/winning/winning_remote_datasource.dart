import 'package:graphql_flutter/graphql_flutter.dart';
import 'winning_models.dart';

class WinningRemoteDataSource {
  final GraphQLClient _client;

  WinningRemoteDataSource(this._client);

  static const String myWinningsQuery = r'''
    query MyWinnings {
      myWinnings {
        success
        code
        message
        items {
          id
          entryId
          blockpickPrizeId
          userId
          status
          couponCode
          codeIssuedAt
          deliveryAddressId
          issuedAt
          deliveredAt
        }
      }
    }
  ''';

  static const String claimWinningMutation = r'''
    mutation ClaimWinning($input: ClaimWinningInput!) {
      claimWinning(input: $input) {
        success
        code
        message
        winning {
          id
          entryId
          blockpickPrizeId
          userId
          status
          couponCode
          codeIssuedAt
          deliveryAddressId
          issuedAt
          deliveredAt
        }
      }
    }
  ''';

  Future<List<WinningRecord>> fetchMyWinnings() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myWinningsQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myWinnings'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myWinnings');
    }
    return ((data['items'] as List?) ?? const [])
        .map((e) => WinningRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<WinningRecord> claimWinning({
    required String winningId,
    String? deliveryAddressId,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(claimWinningMutation),
        variables: {
          'input': {
            'winningId': winningId,
            if (deliveryAddressId != null)
              'deliveryAddressId': deliveryAddressId,
          },
        },
      ),
    );

    final data = result.data?['claimWinning'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: claimWinning');
    }
    final w = data['winning'];
    if (w == null) {
      throw Exception('Failed: claimWinning (winning null)');
    }
    return WinningRecord.fromJson(w as Map<String, dynamic>);
  }
}
