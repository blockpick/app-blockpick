import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/graphql/graphql_client.dart';

part 'game_result_provider.g.dart';

/// 게임 참가자/결과 모델
class GameParticipant {
  final String id;
  final String gameId;
  final String? gameTitle;
  final String joinedAt;
  final String status;
  final bool isWinner;
  final int? rank;
  final int? reward;
  final String? txHash;

  const GameParticipant({
    required this.id,
    required this.gameId,
    this.gameTitle,
    required this.joinedAt,
    required this.status,
    this.isWinner = false,
    this.rank,
    this.reward,
    this.txHash,
  });

  factory GameParticipant.fromJson(Map<String, dynamic> json) {
    return GameParticipant(
      id: json['id'] as String,
      gameId: json['gameId'] as String,
      gameTitle: json['gameTitle'] as String?,
      joinedAt: json['joinedAt'] as String,
      status: json['status'] as String,
      isWinner: json['isWinner'] as bool? ?? false,
      rank: json['rank'] as int?,
      reward: json['reward'] as int?,
      txHash: json['txHash'] as String?,
    );
  }
}

/// 게임 참가자 조회 쿼리
const String _getGameParticipantsQuery = r'''
  query GetGameParticipants($gameId: String!, $page: Int, $size: Int) {
    getGameParticipants(gameId: $gameId, page: $page, size: $size) {
      success
      code
      message
      participants {
        id
        gameId
        gameTitle
        joinedAt
        status
        isWinner
        rank
        reward
        txHash
      }
      pageInfo {
        currentPage
        pageSize
        totalPages
        totalElements
        hasNext
        hasPrevious
      }
    }
  }
''';

/// 게임 결과 조회 쿼리 (닉네임 + 점수 + 참여시각 포함)
const String _getGameResultsQuery = r'''
  query GetGameResults($gameId: String!, $page: Int, $size: Int) {
    getGameResults(gameId: $gameId, page: $page, size: $size) {
      success
      code
      message
      results {
        id
        user {
          id
          nickname
          profileImageUrl
        }
        score
        rank
        reward
        createdAt
      }
      pageInfo {
        currentPage
        totalElements
        totalPages
        hasNext
      }
    }
  }
''';

/// 게임 결과 아이템 (참가자 + 유저 정보 병합)
class GameResultItem {
  final String id;
  final String? nickname;
  final String? profileImageUrl;
  final int? rank;
  final int? score;
  final double? reward;
  final bool isWinner;
  final String? txHash;
  final String joinedAt;

  const GameResultItem({
    required this.id,
    this.nickname,
    this.profileImageUrl,
    this.rank,
    this.score,
    this.reward,
    this.isWinner = false,
    this.txHash,
    required this.joinedAt,
  });
}

/// 게임 결과 응답 (결과 목록 + 총 참여 건수)
class GameResultsData {
  final List<GameResultItem> results;
  final int totalElements;

  const GameResultsData({
    required this.results,
    required this.totalElements,
  });
}

/// 게임 결과 목록 Provider (참가자 + 결과 병합, 총 참여 건수 포함)
@riverpod
Future<GameResultsData> gameResults(
  GameResultsRef ref,
  String gameId,
) async {
  try {
    final client = ref.watch(publicGraphqlClientProvider);

    // 참가자 + 결과를 병렬 조회
    final futures = await Future.wait([
      client.query(
        QueryOptions(
          document: gql(_getGameParticipantsQuery),
          variables: {'gameId': gameId, 'page': 0, 'size': 50},
          fetchPolicy: FetchPolicy.noCache,
        ),
      ),
      client.query(
        QueryOptions(
          document: gql(_getGameResultsQuery),
          variables: {'gameId': gameId, 'page': 0, 'size': 50},
          fetchPolicy: FetchPolicy.noCache,
        ),
      ),
    ]);

    final participantsResult = futures[0];
    final resultsResult = futures[1];

    // 참가자 파싱 (txHash, isWinner 정보)
    final participantsData = participantsResult.data?['getGameParticipants'];
    final participantMap = <String, GameParticipant>{};
    if (participantsData != null && participantsData['success'] == true) {
      final list = participantsData['participants'] as List?;
      if (list != null) {
        for (final item in list) {
          try {
            final p = GameParticipant.fromJson(item as Map<String, dynamic>);
            participantMap[p.id] = p;
          } catch (e) {
            print('❌ 참가자 파싱 에러: $e');
          }
        }
      }
      print('✅ 게임 참가자 ${participantMap.length}명 조회');
    }

    // 결과 파싱 (getGameResults 기반 — 닉네임, 프로필, 점수, 참여시각 포함)
    final resultsData = resultsResult.data?['getGameResults'];
    int totalElements = 0;
    final results = <GameResultItem>[];

    if (resultsData != null && resultsData['success'] == true) {
      // pageInfo에서 총 참여 건수 추출
      final pageInfo = resultsData['pageInfo'] as Map<String, dynamic>?;
      totalElements = pageInfo?['totalElements'] as int? ?? 0;

      final list = resultsData['results'] as List?;
      if (list != null) {
        for (final item in list) {
          final id = item['id'] as String;
          final user = item['user'] as Map<String, dynamic>?;
          final participant = participantMap[id];

          results.add(GameResultItem(
            id: id,
            nickname: user?['nickname'] as String?,
            profileImageUrl: user?['profileImageUrl'] as String?,
            rank: item['rank'] as int?,
            score: item['score'] as int?,
            reward: (item['reward'] as num?)?.toDouble(),
            isWinner: participant?.isWinner ?? false,
            txHash: participant?.txHash,
            joinedAt: item['createdAt'] as String? ??
                participant?.joinedAt ??
                '',
          ));
        }
      }
      print('✅ 게임 결과 ${results.length}건 조회 (totalElements: $totalElements)');
    } else {
      // getGameResults 실패 시 참가자 데이터로 폴백
      totalElements = participantMap.length;
      for (final p in participantMap.values) {
        results.add(GameResultItem(
          id: p.id,
          nickname: null,
          profileImageUrl: null,
          rank: p.rank,
          score: null,
          reward: p.reward?.toDouble(),
          isWinner: p.isWinner,
          txHash: p.txHash,
          joinedAt: p.joinedAt,
        ));
      }
      print('⚠️ 결과 조회 실패, 참가자 데이터로 폴백: ${results.length}건');
    }

    // 당첨자 우선, 순위순 정렬
    results.sort((a, b) {
      if (a.isWinner != b.isWinner) return a.isWinner ? -1 : 1;
      return (a.rank ?? 999).compareTo(b.rank ?? 999);
    });

    print('📊 게임 결과 병합 완료: ${results.length}건 (총 참여: $totalElements건)');

    return GameResultsData(
      results: results,
      totalElements: totalElements,
    );
  } catch (e) {
    print('❌ gameResults provider 에러: $e');
    return const GameResultsData(results: [], totalElements: 0);
  }
}
