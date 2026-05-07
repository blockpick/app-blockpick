import 'package:graphql_flutter/graphql_flutter.dart';
import 'mission_models.dart';

class MissionRemoteDataSource {
  final GraphQLClient _client;

  MissionRemoteDataSource(this._client);

  static const String myMissionsQuery = r'''
    query MyMissions($input: MyMissionsInput) {
      myMissions(input: $input) {
        success
        code
        message
        items {
          id missionType title description rewardTickets externalUrl
          blockpickId status completionStatus completedAt
        }
      }
    }
  ''';

  static const String completeMissionMutation = r'''
    mutation CompleteMission($input: CompleteMissionInput!) {
      completeMission(input: $input) {
        success
        code
        message
        mission {
          id missionType title description rewardTickets externalUrl
          blockpickId status completionStatus completedAt
        }
        ticketsIssued
      }
    }
  ''';

  Future<List<Mission>> fetchMyMissions({String? blockpickId}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myMissionsQuery),
        variables: {
          'input': {
            if (blockpickId != null) 'blockpickId': blockpickId,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myMissions'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myMissions');
    }
    return ((data['items'] as List?) ?? const [])
        .map((e) => Mission.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<({Mission mission, int ticketsIssued})> completeMission({
    required String missionId,
    String? verificationPayload,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(completeMissionMutation),
        variables: {
          'input': {
            'missionId': missionId,
            if (verificationPayload != null)
              'verificationPayload': verificationPayload,
          },
        },
      ),
    );

    final data = result.data?['completeMission'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: completeMission');
    }

    final missionJson = data['mission'];
    if (missionJson == null) {
      throw Exception('Failed: completeMission (mission null)');
    }

    return (
      mission: Mission.fromJson(missionJson as Map<String, dynamic>),
      ticketsIssued: (data['ticketsIssued'] as num?)?.toInt() ?? 0,
    );
  }
}
