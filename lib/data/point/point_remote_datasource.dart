import 'package:graphql_flutter/graphql_flutter.dart';
import 'point_models.dart';

/// 포인트 도메인 GraphQL 데이터소스
/// blockpick-api S01 (포인트 도메인) 쿼리/뮤테이션 래핑
class PointRemoteDataSource {
  final GraphQLClient _client;

  PointRemoteDataSource(this._client);

  // ===== Queries =====

  /// 포인트 지갑 조회
  static const String pointWalletQuery = r'''
    query PointWallet {
      pointWallet {
        success
        code
        message
        wallet {
          userId
          balance
          totalEarned
          totalConsumed
        }
      }
    }
  ''';

  /// 포인트 거래 내역 조회 (페이징)
  static const String pointTransactionsQuery = r'''
    query PointTransactions($page: Int, $size: Int) {
      pointTransactions(page: $page, size: $size) {
        success
        code
        message
        items {
          id
          type
          reason
          amount
          balanceAfter
          note
          createdAt
        }
        totalCount
        page
        size
        hasNext
      }
    }
  ''';

  // ===== Mutations =====

  /// 일일 출석체크
  static const String claimDailyCheckInMutation = r'''
    mutation ClaimDailyCheckIn {
      claimDailyCheckIn {
        success
        code
        message
        pointsEarned
        currentStreak
        bonusAwarded
      }
    }
  ''';

  /// 미니게임 플레이 결과 전송
  static const String playMiniGameMutation = r'''
    mutation PlayMiniGame($input: PlayMiniGameInput!) {
      playMiniGame(input: $input) {
        success
        code
        message
        won
        pointsEarned
      }
    }
  ''';

  // ===== 메서드 =====

  /// 포인트 지갑 조회
  Future<PointWallet> fetchPointWallet() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(pointWalletQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['pointWallet'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? '포인트 지갑 조회 실패');
    }

    return PointWallet.fromJson(data['wallet'] as Map<String, dynamic>);
  }

  /// 포인트 거래 내역 조회
  Future<PointTransactionPage> fetchPointTransactions({
    int page = 0,
    int size = 20,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(pointTransactionsQuery),
        variables: {'page': page, 'size': size},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['pointTransactions'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? '포인트 내역 조회 실패');
    }

    return PointTransactionPage.fromJson(data as Map<String, dynamic>);
  }

  /// 일일 출석체크 — 중복 시 ALREADY_CHECKED_IN 코드 반환
  Future<CheckInResult> claimDailyCheckIn() async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(claimDailyCheckInMutation),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['claimDailyCheckIn'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null) {
      throw Exception('출석체크 응답 없음');
    }

    // 이미 체크인한 경우 — 친절한 에러로 처리
    if (data['success'] != true) {
      final code = data['code'] as String?;
      final message = data['message'] as String?;
      if (code == 'ALREADY_CHECKED_IN') {
        throw AlreadyCheckedInException(message ?? '오늘은 이미 출석체크를 완료했어요.');
      }
      throw Exception(message ?? '출석체크 실패');
    }

    return CheckInResult.fromJson(data as Map<String, dynamic>);
  }

  /// 미니게임 결과 전송
  Future<MiniGameResult> playMiniGame(PlayMiniGameInput input) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(playMiniGameMutation),
        variables: {'input': input.toJson()},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['playMiniGame'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? '미니게임 처리 실패');
    }

    return MiniGameResult.fromJson(data as Map<String, dynamic>);
  }
}

/// 이미 출석체크를 완료한 경우 예외
class AlreadyCheckedInException implements Exception {
  final String message;
  const AlreadyCheckedInException(this.message);

  @override
  String toString() => message;
}
