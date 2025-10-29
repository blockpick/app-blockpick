import 'package:freezed_annotation/freezed_annotation.dart';
import 'game_round_model.dart';

part 'game_model.freezed.dart';
part 'game_model.g.dart';

/// GraphQL Game 타입
@freezed
class Game with _$Game {
  const factory Game({
    required String id,
    required String title,
    String? description,
    String? gameType, // DAILY, SELECT, VIBE
    String? status, // SCHEDULED, IN_PROGRESS, PAUSED, SETTLING, ENDED, FAILED
    int? maxEntries,
    int? minEntries,
    int? entryFee,
    int? rewardPoint,
    int? gridRows,
    int? gridCols,
    String? startTime,
    String? endTime,
    String? customRules,
    String? onchainTxHash,
    String? onchainContractAddr,
    String? createdAt,
    String? updatedAt,
    @Default([]) List<GameProduct>? gameProducts,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);
}

/// Game 확장 메서드
extension GameX on Game {
  /// GameRound로 변환 (기존 UI 호환)
  GameRound toGameRound() {
    // 게임 타입 변환
    GameType type = GameType.daily;
    if (gameType != null) {
      switch (gameType!.toUpperCase()) {
        case 'DAILY':
          type = GameType.daily;
          break;
        case 'SELECT':
          type = GameType.select;
          break;
        case 'VIBE':
          type = GameType.vibe;
          break;
      }
    }

    // 게임 상태 변환
    GameStatus gameStatus = GameStatus.active;
    if (status != null) {
      switch (status!.toUpperCase()) {
        case 'IN_PROGRESS':
        case 'SCHEDULED':
          gameStatus = GameStatus.active;
          break;
        case 'SETTLING':
          gameStatus = GameStatus.drawing;
          break;
        case 'ENDED':
        case 'FAILED':
          gameStatus = GameStatus.ended;
          break;
      }
    }

    // 첫 번째 상품의 이미지 사용
    String imageUrl = '';
    String category = 'Digital';
    int originalPrice = 0;

    if (gameProducts != null && gameProducts!.isNotEmpty) {
      final product = gameProducts!.first.product;
      imageUrl = product.defaultImage ?? product.imageUrl ?? '';
      category = product.category ?? 'Digital';
      originalPrice = product.originalPrice ?? product.price ?? 0;

      // 이미지 URL 디버깅
      print('🖼️ Game.toGameRound():');
      print('   - gameId: $id');
      print('   - product.defaultImage: ${product.defaultImage}');
      print('   - product.imageUrl: ${product.imageUrl}');
      print('   - product.thumbnailUrl: ${product.thumbnailUrl}');
      print('   - 최종 imageUrl: $imageUrl');
    }

    // 시간 계산
    String timeLeft = '0h 0m';
    if (endTime != null) {
      try {
        final end = DateTime.parse(endTime!);
        final now = DateTime.now();
        final difference = end.difference(now);

        if (difference.isNegative) {
          timeLeft = 'Ended';
        } else {
          final hours = difference.inHours;
          final minutes = difference.inMinutes % 60;
          timeLeft = '${hours}h ${minutes}m';
        }
      } catch (e) {
        timeLeft = '0h 0m';
      }
    }

    return GameRound(
      id: id,
      title: title,
      description: description ?? '',
      imageUrl: imageUrl,
      participants: minEntries ?? 0, // 현재 참가자 수는 별도 API에서 가져와야 함
      maxParticipants: maxEntries ?? 0,
      totalBlocks: (gridRows ?? 0) * (gridCols ?? 0),
      requiredPicks: 1, // 기본값
      winners: 1, // 기본값
      originalPrice: originalPrice,
      currentPrice: entryFee ?? 0,
      timeLeft: timeLeft,
      type: type,
      status: gameStatus,
      category: category,
      gridSize: null, // 정사각형이 아니므로 null
      gridWidth: gridCols,
      gridHeight: gridRows,
      vibeImageUrl: null,
    );
  }

  /// 남은 시간 계산
  Duration? get remainingTime {
    if (endTime == null) return null;
    try {
      final end = DateTime.parse(endTime!);
      return end.difference(DateTime.now());
    } catch (e) {
      return null;
    }
  }

  /// 진행중 여부
  bool get isActive {
    return status == 'IN_PROGRESS' || status == 'SCHEDULED';
  }

  /// 종료 여부
  bool get isEnded {
    return status == 'ENDED' || status == 'FAILED';
  }
}

/// GameProduct 타입
@freezed
class GameProduct with _$GameProduct {
  const factory GameProduct({
    required String id,
    int? sequence,
    bool? active,
    bool? isGrandPrize,
    required Product product,
    String? createdAt,
    String? updatedAt,
  }) = _GameProduct;

  factory GameProduct.fromJson(Map<String, dynamic> json) =>
      _$GameProductFromJson(json);
}

/// Product 타입
@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    String? description,
    String? brand,
    String? category,
    String? sku,
    String? defaultImage,
    String? imageUrl,
    String? thumbnailUrl,
    int? price,
    int? originalPrice,
    String? countryCode,
    bool? active,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) =>
      _$ProductFromJson(json);
}

/// GraphQL gameList 응답 타입 (GameItem)
@freezed
class GameItem with _$GameItem {
  const factory GameItem({
    required String id,
    required String title,
    String? description,
    required String type,
    required String category,
    required String status,
    required int entryFee,
    required String currency,
    required int minEntries,
    required int maxEntries,
    int? currentEntries, // nullable로 변경 (백엔드 이슈)
    required int maxEntriesPerUser,
    required int rewardPoint,
    required int gridRows,
    required int gridCols,
    required String startTime,
    required String endTime,
    required bool isRecommended,
    String? onchainTxHash,
    String? onchainContractAddr,
    required String createdAt,
    @Default([]) List<GameProductItem> gameProducts,
  }) = _GameItem;

  factory GameItem.fromJson(Map<String, dynamic> json) =>
      _$GameItemFromJson(json);
}

extension GameItemX on GameItem {
  /// GameRound로 변환
  GameRound toGameRound() {
    GameType gameType = GameType.daily;
    switch (type.toUpperCase()) {
      case 'DAILY':
        gameType = GameType.daily;
        break;
      case 'SELECT':
        gameType = GameType.select;
        break;
      case 'VIBE':
        gameType = GameType.vibe;
        break;
    }

    GameStatus gameStatus = GameStatus.active;
    switch (status.toUpperCase()) {
      case 'IN_PROGRESS':
      case 'SCHEDULED':
        gameStatus = GameStatus.active;
        break;
      case 'SETTLING':
        gameStatus = GameStatus.drawing;
        break;
      case 'ENDED':
      case 'FAILED':
        gameStatus = GameStatus.ended;
        break;
    }

    String imageUrl = '';
    if (gameProducts.isNotEmpty) {
      imageUrl = gameProducts.first.product.defaultImage ?? '';
    }

    String timeLeft = '0h 0m';
    try {
      final end = DateTime.parse(endTime);
      final now = DateTime.now();
      final difference = end.difference(now);

      if (difference.isNegative) {
        timeLeft = 'Ended';
      } else {
        final hours = difference.inHours;
        final minutes = difference.inMinutes % 60;
        timeLeft = '${hours}h ${minutes}m';
      }
    } catch (e) {
      timeLeft = '0h 0m';
    }

    return GameRound(
      id: id,
      title: title,
      description: description ?? '',
      imageUrl: imageUrl,
      participants: currentEntries ?? 0,
      maxParticipants: maxEntries,
      totalBlocks: gridRows * gridCols,
      requiredPicks: 1,
      winners: 1,
      originalPrice: rewardPoint,
      currentPrice: entryFee,
      timeLeft: timeLeft,
      type: gameType,
      status: gameStatus,
      category: category,
      gridSize: null,
      gridWidth: gridCols,
      gridHeight: gridRows,
      vibeImageUrl: null,
    );
  }
}

/// GameProductItem 타입
@freezed
class GameProductItem with _$GameProductItem {
  const factory GameProductItem({
    required String id,
    int? position,
    int? sequence,
    required bool isGrandPrize,
    required ProductItem product,
  }) = _GameProductItem;

  factory GameProductItem.fromJson(Map<String, dynamic> json) =>
      _$GameProductItemFromJson(json);
}

/// ProductItem 타입 (간소화된 상품 정보)
@freezed
class ProductItem with _$ProductItem {
  const factory ProductItem({
    required String id,
    required String sku,
    required String brand,
    required String name,
    String? description,
    String? defaultImage,
  }) = _ProductItem;

  factory ProductItem.fromJson(Map<String, dynamic> json) =>
      _$ProductItemFromJson(json);
}

/// GamesResponse 타입
@freezed
class GamesResponse with _$GamesResponse {
  const factory GamesResponse({
    required bool success,
    required String code,
    required String message,
    @Default([]) List<Game> games,
  }) = _GamesResponse;

  factory GamesResponse.fromJson(Map<String, dynamic> json) =>
      _$GamesResponseFromJson(json);
}
