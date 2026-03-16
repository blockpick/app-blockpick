import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/graphql/graphql_client.dart';

part 'game_result_provider.g.dart';

/// 게임 결과 모델
class GameResultItem {
  final String id;
  final String gameId;
  final String userId;
  final String nickname;
  final String? profileImageUrl;
  final int? score;
  final int? rank;
  final double? reward;
  final bool isWinner;
  final String createdAt;

  const GameResultItem({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.nickname,
    this.profileImageUrl,
    this.score,
    this.rank,
    this.reward,
    this.isWinner = false,
    required this.createdAt,
  });

  factory GameResultItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final game = json['game'] as Map<String, dynamic>?;

    return GameResultItem(
      id: json['id'] as String,
      gameId: game?['id'] as String? ?? '',
      userId: user?['id'] as String? ?? '',
      nickname: user?['nickname'] as String? ?? '익명',
      profileImageUrl: user?['profileImageUrl'] as String?,
      score: json['score'] as int?,
      rank: json['rank'] as int?,
      reward: (json['reward'] as num?)?.toDouble(),
      isWinner: (json['rank'] as int?) == 1,
      createdAt: json['createdAt'] as String,
    );
  }
}

/// 게임 결과 조회 쿼리
const String _getGameResultsQuery = r'''
  query GetGameResults($gameId: String!, $page: Int, $size: Int) {
    getGameResults(gameId: $gameId, page: $page, size: $size) {
      success
      code
      message
      results {
        id
        game {
          id
        }
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
        pageSize
        totalPages
        totalElements
        hasNext
        hasPrevious
      }
    }
  }
''';

/// 게임 결과 목록 Provider
@riverpod
Future<List<GameResultItem>> gameResults(
  GameResultsRef ref,
  String gameId,
) async {
  try {
    final client = ref.watch(publicGraphqlClientProvider);

    final result = await client.query(
      QueryOptions(
        document: gql(_getGameResultsQuery),
        variables: {'gameId': gameId, 'page': 0, 'size': 50},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      print('❌ 게임 결과 조회 에러: ${result.exception}');
      if (result.data == null) return [];
    }

    final data = result.data?['getGameResults'];
    if (data == null || data['success'] != true) {
      print('⚠️ 게임 결과 조회 실패: ${data?['message']}');
      return [];
    }

    final resultsData = data['results'] as List?;
    if (resultsData == null || resultsData.isEmpty) {
      return [];
    }

    final results = <GameResultItem>[];
    for (final item in resultsData) {
      try {
        results.add(GameResultItem.fromJson(item as Map<String, dynamic>));
      } catch (e) {
        print('❌ 게임 결과 파싱 에러: $e');
      }
    }

    // 순위순 정렬
    results.sort((a, b) => (a.rank ?? 999).compareTo(b.rank ?? 999));

    return results;
  } catch (e) {
    print('❌ gameResults provider 에러: $e');
    return [];
  }
}
