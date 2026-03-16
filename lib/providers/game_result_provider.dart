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
  // TODO: 백엔드에서 좌표 복호화 후 추가 예정
  // final int? coordX;
  // final int? coordY;

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

/// 게임 결과 조회 쿼리 (닉네임 포함)
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
    }
  }
''';

/// 게임 결과 아이템 (참가자 + 유저 정보 병합)
class GameResultItem {
  final String id;
  final String? nickname;
  final String? profileImageUrl;
  final int? rank;
  final int? reward;
  final bool isWinner;
  final String? txHash;
  final String joinedAt;
  // TODO: 백엔드에서 좌표 복호화 API 추가 시 활성화
  // final int? coordX;
  // final int? coordY;

  const GameResultItem({
    required this.id,
    this.nickname,
    this.profileImageUrl,
    this.rank,
    this.reward,
    this.isWinner = false,
    this.txHash,
    required this.joinedAt,
  });
}

/// 게임 결과 목록 Provider (참가자 + 결과 병합)
@riverpod
Future<List<GameResultItem>> gameResults(
  GameResultsRef ref,
  String gameId,
) async {
  try {
    final client = ref.watch(publicGraphqlClientProvider);

    // 참가자 + 결과를 병렬 조회
    final participantsResult = await client.query(
      QueryOptions(
        document: gql(_getGameParticipantsQuery),
        variables: {'gameId': gameId, 'page': 0, 'size': 50},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    final resultsResult = await client.query(
      QueryOptions(
        document: gql(_getGameResultsQuery),
        variables: {'gameId': gameId, 'page': 0, 'size': 50},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    // 참가자 파싱
    final participantsData = participantsResult.data?['getGameParticipants'];
    final participants = <GameParticipant>[];
    if (participantsData != null && participantsData['success'] == true) {
      final list = participantsData['participants'] as List?;
      if (list != null) {
        for (final item in list) {
          try {
            participants.add(GameParticipant.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            print('❌ 참가자 파싱 에러: $e');
          }
        }
      }
      print('✅ 게임 참가자 ${participants.length}명 조회');
    } else {
      print('⚠️ 참가자 조회 실패: ${participantsData?['message']}');
    }

    // 결과 파싱 (닉네임 매칭용)
    final resultsData = resultsResult.data?['getGameResults'];
    final nicknameMap = <String, Map<String, String?>>{}; // id -> {nickname, profileImageUrl}
    if (resultsData != null && resultsData['success'] == true) {
      final list = resultsData['results'] as List?;
      if (list != null) {
        for (final item in list) {
          final id = item['id'] as String;
          final user = item['user'] as Map<String, dynamic>?;
          nicknameMap[id] = {
            'nickname': user?['nickname'] as String?,
            'profileImageUrl': user?['profileImageUrl'] as String?,
          };
        }
      }
      print('✅ 게임 결과 ${nicknameMap.length}건 조회 (닉네임 매칭용)');
    }

    // 병합: 참가자 데이터 + 닉네임
    final results = participants.map((p) {
      final userInfo = nicknameMap[p.id];
      return GameResultItem(
        id: p.id,
        nickname: userInfo?['nickname'],
        profileImageUrl: userInfo?['profileImageUrl'],
        rank: p.rank,
        reward: p.reward,
        isWinner: p.isWinner,
        txHash: p.txHash,
        joinedAt: p.joinedAt,
      );
    }).toList();

    // 당첨자 우선, 순위순 정렬
    results.sort((a, b) {
      if (a.isWinner != b.isWinner) return a.isWinner ? -1 : 1;
      return (a.rank ?? 999).compareTo(b.rank ?? 999);
    });

    print('📊 게임 결과 병합 완료: ${results.length}건');
    for (final r in results) {
      print('   • rank: ${r.rank}, winner: ${r.isWinner}, nickname: ${r.nickname ?? "미확인"}, txHash: ${r.txHash?.substring(0, 10) ?? "없음"}...');
    }
    // TODO: 백엔드에서 좌표 복호화 API가 추가되면
    // participants에 coordX/coordY 필드를 추가하고 여기서 로그 출력
    print('ℹ️ 좌표 데이터: 백엔드에서 복호화 API 추가 필요 (현재 on-chain 암호문만 존재)');

    return results;
  } catch (e) {
    print('❌ gameResults provider 에러: $e');
    return [];
  }
}
