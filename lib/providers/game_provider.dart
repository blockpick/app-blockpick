import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/graphql/graphql_client.dart';
import '../models/game_model.dart';
import '../models/game_round_model.dart';
import '../data/mock_game_data.dart';

part 'game_provider.g.dart';

/// 게임 목록 조회 쿼리
const String _getGamesQuery = r'''
  query GetGames {
    getGames {
      success
      code
      message
      games {
        id
        title
        description
        mainProductName
        gameType
        category
        status
        entryFee
        currency
        minEntries
        maxEntries
        maxEntriesPerUser
        rewardPoint
        gridRows
        gridCols
        visibleFrom
        startTime
        endTime
        allowDuplicate
        enableNotification
        isRecommended
        hasInstantPrize
        customRules
        autoEndOnMax
        autoEndOnTime
        onchainTxHash
        onchainContractAddr
        createdAt
        updatedAt
        gameProducts {
          id
          sequence
          active
          isGrandPrize
          product {
            id
            name
            description
            brand
            category
            sku
            defaultImage
            imageUrl
            thumbnailUrl
            price
            originalPrice
            countryCode
            active
          }
          createdAt
          updatedAt
        }
      }
    }
  }
''';

/// 진행중인 게임 조회 쿼리
const String _getActiveGamesQuery = r'''
  query GetActiveGames {
    getActiveGames {
      success
      code
      message
      games {
        id
        title
        description
        mainProductName
        gameType
        category
        status
        entryFee
        currency
        minEntries
        maxEntries
        maxEntriesPerUser
        rewardPoint
        gridRows
        gridCols
        startTime
        endTime
        isRecommended
        hasInstantPrize
        onchainTxHash
        onchainContractAddr
        createdAt
        gameProducts {
          id
          sequence
          isGrandPrize
          product {
            id
            name
            brand
            description
            defaultImage
            price
            originalPrice
          }
        }
      }
    }
  }
''';

/// 게임 상세 조회 쿼리
const String _getGameQuery = r'''
  query GetGame($id: String!) {
    getGame(id: $id) {
      success
      code
      message
      game {
        id
        title
        description
        mainProductName
        gameType
        category
        status
        entryFee
        currency
        minEntries
        maxEntries
        maxEntriesPerUser
        rewardPoint
        gridRows
        gridCols
        visibleFrom
        startTime
        endTime
        allowDuplicate
        enableNotification
        isRecommended
        hasInstantPrize
        customRules
        autoEndOnMax
        autoEndOnTime
        onchainTxHash
        onchainContractAddr
        createdAt
        updatedAt
        gameProducts {
          id
          sequence
          active
          isGrandPrize
          product {
            id
            name
            description
            brand
            category
            sku
            defaultImage
            imageUrl
            thumbnailUrl
            price
            originalPrice
            countryCode
            active
          }
          createdAt
          updatedAt
        }
      }
    }
  }
''';

/// 모든 게임 목록 Provider
@riverpod
Future<List<Game>> games(Ref ref) async {
  try {
    // 게임 목록은 공개 API이므로 인증 없는 클라이언트 사용
    final client = ref.watch(publicGraphqlClientProvider);

    final result = await client.query(
      QueryOptions(
        document: gql(_getGamesQuery),
        fetchPolicy: FetchPolicy.noCache, // 캐시 완전 비활성화
      ),
    );

    if (result.hasException) {
      print('❌ 게임 목록 조회 에러: ${result.exception}');
      // 에러가 있어도 데이터가 있으면 사용
      if (result.data != null) {
        print('⚠️  에러가 있지만 데이터는 존재함, 파싱 시도');
      } else {
        return [];
      }
    }

    final data = result.data?['getGames'];
    if (data == null) {
      print('⚠️  getGames 데이터가 null');
      return [];
    }

    if (data['success'] != true) {
      print('⚠️  게임 목록 조회 실패: ${data['message']}');
      return [];
    }

    final gamesData = data['games'] as List?;
    if (gamesData == null || gamesData.isEmpty) {
      print('ℹ️  게임 목록이 비어있음');
      return [];
    }

    print('✅ 게임 ${gamesData.length}개 파싱 시작');
    final games = <Game>[];
    for (var i = 0; i < gamesData.length; i++) {
      try {
        final game = Game.fromJson(gamesData[i] as Map<String, dynamic>);
        games.add(game);
      } catch (e) {
        print('❌ 게임 #$i 파싱 에러: $e');
        // 개별 게임 파싱 실패는 무시하고 계속
      }
    }

    print('✅ 총 ${games.length}개 게임 로드 완료');
    return games;
  } catch (e) {
    print('❌ games provider 에러: $e');
    return [];
  }
}

/// 진행중인 게임 목록 Provider
@riverpod
Future<List<Game>> activeGames(Ref ref) async {
  try {
    final client = await ref.watch(graphqlClientProvider.future);

    final result = await client.query(
      QueryOptions(
        document: gql(_getActiveGamesQuery),
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      print('❌ 진행중 게임 조회 에러: ${result.exception}');
      if (result.data == null) return [];
    }

    final data = result.data?['getActiveGames'];
    if (data == null || data['success'] != true) {
      print('⚠️  진행중 게임 조회 실패: ${data?['message']}');
      return [];
    }

    final gamesData = data['games'] as List?;
    if (gamesData == null) return [];

    final games = <Game>[];
    for (var gameJson in gamesData) {
      try {
        games.add(Game.fromJson(gameJson as Map<String, dynamic>));
      } catch (e) {
        print('❌ 게임 파싱 에러: $e');
      }
    }

    return games;
  } catch (e) {
    print('❌ activeGames provider 에러: $e');
    return [];
  }
}

/// 게임 타입별 필터링 Provider
@riverpod
Future<List<GameRound>> gamesByType(
  Ref ref,
  GameType gameType,
) async {
  try {
    final allGames = await ref.watch(gamesProvider.future);

    // gameType에 따라 필터링
    String typeString;
    switch (gameType) {
      case GameType.daily:
        typeString = 'DAILY';
        break;
      case GameType.select:
        typeString = 'SELECT';
        break;
      case GameType.vibe:
        typeString = 'VIBE';
        break;
      case GameType.prime:
        typeString = 'PRIME';
        break;
    }

    // gameType이 null이거나 일치하는 게임 필터링
    final filteredGames = allGames.where((game) {
      // gameType이 null이면 DAILY로 간주 (임시)
      if (game.gameType == null) {
        return gameType == GameType.daily;
      }
      return game.gameType?.toUpperCase() == typeString;
    }).toList();

    // GameRound로 변환
    final gameRounds = filteredGames.map((game) => game.toGameRound()).toList();

    // 데이터가 없으면 목 데이터 사용
    if (gameRounds.isEmpty) {
      print('🔄 API 데이터 없음, Mock 데이터 사용: $typeString');
      return MockGameData.getGamesByType(gameType);
    }

    return gameRounds;
  } catch (e) {
    print('❌ gamesByType 에러: $e');
    print('🔄 에러 발생, Mock 데이터로 fallback');
    // 에러 발생 시 목 데이터 반환
    return MockGameData.getGamesByType(gameType);
  }
}

/// 특정 게임 상세 조회 Provider
@riverpod
Future<Game?> game(Ref ref, String gameId) async {
  try {
    final client = await ref.watch(graphqlClientProvider.future);

    final result = await client.query(
      QueryOptions(
        document: gql(_getGameQuery),
        variables: {'id': gameId},
        fetchPolicy: FetchPolicy.noCache,
      ),
    );

    if (result.hasException) {
      print('❌ 게임 상세 조회 에러: ${result.exception}');
      print('🔄 Mock 데이터로 fallback (gameId: $gameId)');
      final mockGameRound = MockGameData.getGameById(gameId);
      if (mockGameRound != null) {
        // GameRound를 Game 형식으로 변환
        return _convertGameRoundToGame(mockGameRound);
      }
      // 기본 목 게임 반환 (첫 번째 daily 게임)
      if (MockGameData.dailyGames.isNotEmpty) {
        return _convertGameRoundToGame(MockGameData.dailyGames.first);
      }
      return null;
    }

    final data = result.data?['getGame'];
    if (data == null || data['success'] != true) {
      print('⚠️  게임 상세 조회 실패: ${data?['message']}');
      print('🔄 Mock 데이터로 fallback (gameId: $gameId)');
      final mockGameRound = MockGameData.getGameById(gameId);
      if (mockGameRound != null) {
        return _convertGameRoundToGame(mockGameRound);
      }
      if (MockGameData.dailyGames.isNotEmpty) {
        return _convertGameRoundToGame(MockGameData.dailyGames.first);
      }
      return null;
    }

    final gameData = data['game'];
    if (gameData == null) {
      print('🔄 Mock 데이터로 fallback (gameId: $gameId)');
      final mockGameRound = MockGameData.getGameById(gameId);
      if (mockGameRound != null) {
        return _convertGameRoundToGame(mockGameRound);
      }
      if (MockGameData.dailyGames.isNotEmpty) {
        return _convertGameRoundToGame(MockGameData.dailyGames.first);
      }
      return null;
    }

    return Game.fromJson(gameData as Map<String, dynamic>);
  } catch (e) {
    print('❌ game provider 에러: $e');
    print('🔄 Mock 데이터로 fallback (gameId: $gameId)');
    final mockGameRound = MockGameData.getGameById(gameId);
    if (mockGameRound != null) {
      return _convertGameRoundToGame(mockGameRound);
    }
    if (MockGameData.dailyGames.isNotEmpty) {
      return _convertGameRoundToGame(MockGameData.dailyGames.first);
    }
    return null;
  }
}

/// GameRound를 Game으로 변환하는 헬퍼 함수
Game _convertGameRoundToGame(GameRound gameRound) {
  return Game(
    id: gameRound.id,
    title: gameRound.title,
    description: gameRound.description,
    gameType: gameRound.type.toString().split('.').last.toUpperCase(),
    category: gameRound.category,
    status: 'IN_PROGRESS',
    maxEntries: gameRound.maxParticipants,
    minEntries: 1,
    entryFee: gameRound.currentPrice,
    rewardPoint: 0,
    gridRows: gameRound.gridHeight,
    gridCols: gameRound.gridWidth,
    startTime: DateTime.now().toIso8601String(),
    endTime: DateTime.now().add(const Duration(hours: 24)).toIso8601String(),
    customRules: null,
    onchainTxHash: null,
    onchainContractAddr: null,
    createdAt: DateTime.now().toIso8601String(),
    updatedAt: DateTime.now().toIso8601String(),
    gameProducts: [
      GameProduct(
        id: 'product-1',
        sequence: 1,
        active: true,
        isGrandPrize: true,
        product: Product(
          id: 'p-1',
          name: gameRound.title,
          description: gameRound.description,
          brand: 'Mock Brand',
          category: gameRound.category,
          sku: 'MOCK-SKU',
          defaultImage: gameRound.imageUrl,
          imageUrl: gameRound.imageUrl,
          thumbnailUrl: gameRound.imageUrl,
          price: gameRound.currentPrice,
          originalPrice: gameRound.originalPrice,
          countryCode: 'KR',
          active: true,
        ),
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      ),
    ],
  );
}

/// 카테고리별 게임 필터링 Provider
@riverpod
Future<List<GameRound>> gamesByCategory(
  Ref ref,
  GameType gameType,
  String category,
) async {
  try {
    final games = await ref.watch(gamesByTypeProvider(gameType).future);

    if (category == 'ALL') {
      return games;
    }

    return games.where((game) => game.category == category).toList();
  } catch (e) {
    print('❌ gamesByCategory provider 에러: $e');
    return [];
  }
}

/// 게임 정렬 Provider
@riverpod
List<GameRound> sortedGames(
  SortedGamesRef ref,
  List<GameRound> games,
  String sortBy,
) {
  try {
    final sorted = List<GameRound>.from(games);

    switch (sortBy) {
      case 'popular':
        sorted.sort((a, b) => b.participants.compareTo(a.participants));
        break;
      case 'newest':
        // createdAt으로 정렬 (GameRound에 createdAt 없으므로 id로 대체)
        sorted.sort((a, b) => b.id.compareTo(a.id));
        break;
      case 'ending_soon':
        sorted.sort((a, b) {
          // timeLeft가 짧은 순서로
          if (a.timeLeft == 'Ended') return 1;
          if (b.timeLeft == 'Ended') return -1;
          return a.timeLeft.compareTo(b.timeLeft);
        });
        break;
      case 'price_low':
        sorted.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
    }

    return sorted;
  } catch (e) {
    print('❌ sortedGames provider 에러: $e');
    return games;
  }
}
