import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/graphql/graphql_client.dart';
import '../features/game/models/event_prize.dart';

part 'instant_prize_provider.g.dart';

/// 즉석경품 목록 조회 쿼리
const String _getGameInstantPrizesQuery = r'''
  query GetGameInstantPrizes($gameId: String!) {
    getGameInstantPrizes(gameId: $gameId) {
      success
      message
      prizes {
        id
        gameId
        instantPrize {
          id
          name
          description
          imageUrl
          thumbnailUrl
          limitType
          isActive
          metadata
        }
        gridX
        gridY
        isClaimed
        claimedByUserId
        claimedAt
        giftshowCouponUrl
        customImageUrl
        customThumbnailUrl
      }
    }
  }
''';

/// 즉석경품 수령 뮤테이션
const String _claimInstantPrizeMutation = r'''
  mutation ClaimInstantPrize($gameId: String!, $gridX: Int!, $gridY: Int!) {
    claimInstantPrize(gameId: $gameId, gridX: $gridX, gridY: $gridY) {
      success
      message
      prize {
        id
        name
        description
        imageUrl
        thumbnailUrl
      }
      giftshowCouponUrl
    }
  }
''';

/// 즉석경품 수령 결과
class ClaimPrizeResult {
  final bool success;
  final String? message;
  final EventPrize? prize;
  final String? giftshowCouponUrl;

  ClaimPrizeResult({
    required this.success,
    this.message,
    this.prize,
    this.giftshowCouponUrl,
  });
}

/// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
@riverpod
Future<List<EventTarget>> gameInstantPrizes(Ref ref, String gameId) async {
  try {
    final client = await ref.watch(graphqlClientProvider.future);

    final result = await client.query(
      QueryOptions(
        document: gql(_getGameInstantPrizesQuery),
        variables: {'gameId': gameId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      print('❌ 즉석경품 목록 조회 에러: ${result.exception}');
      if (result.data == null) return [];
    }

    final data = result.data?['getGameInstantPrizes'];
    if (data == null || data['success'] != true) {
      print('⚠️  즉석경품 목록 조회 실패: ${data?['message']}');
      return [];
    }

    final prizesData = data['prizes'] as List?;
    if (prizesData == null || prizesData.isEmpty) {
      print('ℹ️  즉석경품이 없음');
      return [];
    }

    final targets = <EventTarget>[];
    for (final prizeJson in prizesData) {
      try {
        final target = EventTarget.fromGameInstantPrizeDto(
          prizeJson as Map<String, dynamic>,
        );
        // 이미 수령된 경품은 제외
        if (!target.isClaimed) {
          targets.add(target);
        }
      } catch (e) {
        print('❌ 즉석경품 파싱 에러: $e');
      }
    }

    print('✅ 즉석경품 ${targets.length}개 로드 완료 (미수령)');
    return targets;
  } catch (e) {
    print('❌ gameInstantPrizes provider 에러: $e');
    return [];
  }
}

/// 즉석경품 수령 Provider
@riverpod
class InstantPrizeClaim extends _$InstantPrizeClaim {
  @override
  AsyncValue<ClaimPrizeResult?> build() {
    return const AsyncData(null);
  }

  /// 즉석경품 수령 요청
  Future<ClaimPrizeResult> claimPrize(
    String gameId,
    int gridX,
    int gridY,
  ) async {
    state = const AsyncLoading();

    try {
      final client = await ref.read(graphqlClientProvider.future);

      final result = await client.mutate(
        MutationOptions(
          document: gql(_claimInstantPrizeMutation),
          variables: {
            'gameId': gameId,
            'gridX': gridX,
            'gridY': gridY,
          },
        ),
      );

      if (result.hasException) {
        print('❌ 즉석경품 수령 에러: ${result.exception}');
        final claimResult = ClaimPrizeResult(
          success: false,
          message: '서버 오류가 발생했습니다.',
        );
        state = AsyncData(claimResult);
        return claimResult;
      }

      final data = result.data?['claimInstantPrize'];
      if (data == null) {
        final claimResult = ClaimPrizeResult(
          success: false,
          message: '응답 데이터가 없습니다.',
        );
        state = AsyncData(claimResult);
        return claimResult;
      }

      final success = data['success'] == true;
      EventPrize? prize;

      if (success && data['prize'] != null) {
        prize = EventPrize.fromInstantPrizeDto(
          data['prize'] as Map<String, dynamic>,
        );
        if (data['giftshowCouponUrl'] != null) {
          prize = prize.copyWith(
            giftshowCouponUrl: data['giftshowCouponUrl'] as String?,
          );
        }
      }

      final claimResult = ClaimPrizeResult(
        success: success,
        message: data['message'] as String?,
        prize: prize,
        giftshowCouponUrl: data['giftshowCouponUrl'] as String?,
      );

      state = AsyncData(claimResult);

      // 성공 시 경품 목록 갱신
      if (success) {
        ref.invalidate(gameInstantPrizesProvider(gameId));
      }

      return claimResult;
    } catch (e) {
      print('❌ claimPrize 에러: $e');
      final claimResult = ClaimPrizeResult(
        success: false,
        message: '네트워크 오류가 발생했습니다.',
      );
      state = AsyncData(claimResult);
      return claimResult;
    }
  }
}
