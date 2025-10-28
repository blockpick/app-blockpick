// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$GameImpl _$$GameImplFromJson(Map<String, dynamic> json) => _$GameImpl(
  id: json['id'] as String,
  title: json['title'] as String,
  description: json['description'] as String?,
  gameType: json['gameType'] as String?,
  status: json['status'] as String?,
  maxPlayers: (json['maxPlayers'] as num?)?.toInt(),
  currentPlayers: (json['currentPlayers'] as num?)?.toInt(),
  entryFee: (json['entryFee'] as num?)?.toDouble(),
  prizePool: (json['prizePool'] as num?)?.toDouble(),
  startTime: json['startTime'] as String?,
  endTime: json['endTime'] as String?,
  rules: json['rules'] as String?,
  onchainTxHash: json['onchainTxHash'] as String?,
  onchainContractAddr: json['onchainContractAddr'] as String?,
  createdAt: json['createdAt'] as String?,
  updatedAt: json['updatedAt'] as String?,
  gameProducts:
      (json['gameProducts'] as List<dynamic>?)
          ?.map((e) => GameProduct.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$$GameImplToJson(_$GameImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'gameType': instance.gameType,
      'status': instance.status,
      'maxPlayers': instance.maxPlayers,
      'currentPlayers': instance.currentPlayers,
      'entryFee': instance.entryFee,
      'prizePool': instance.prizePool,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'rules': instance.rules,
      'onchainTxHash': instance.onchainTxHash,
      'onchainContractAddr': instance.onchainContractAddr,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'gameProducts': instance.gameProducts,
    };

_$GameProductImpl _$$GameProductImplFromJson(Map<String, dynamic> json) =>
    _$GameProductImpl(
      id: json['id'] as String,
      sequence: (json['sequence'] as num?)?.toInt(),
      active: json['active'] as bool?,
      isGrandPrize: json['isGrandPrize'] as bool?,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );

Map<String, dynamic> _$$GameProductImplToJson(_$GameProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sequence': instance.sequence,
      'active': instance.active,
      'isGrandPrize': instance.isGrandPrize,
      'product': instance.product,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      sku: json['sku'] as String?,
      defaultImage: json['defaultImage'] as String?,
      imageUrl: json['imageUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      price: (json['price'] as num?)?.toInt(),
      originalPrice: (json['originalPrice'] as num?)?.toInt(),
      countryCode: json['countryCode'] as String?,
      active: json['active'] as bool?,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'brand': instance.brand,
      'category': instance.category,
      'sku': instance.sku,
      'defaultImage': instance.defaultImage,
      'imageUrl': instance.imageUrl,
      'thumbnailUrl': instance.thumbnailUrl,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'countryCode': instance.countryCode,
      'active': instance.active,
    };

_$GameItemImpl _$$GameItemImplFromJson(Map<String, dynamic> json) =>
    _$GameItemImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      category: json['category'] as String,
      status: json['status'] as String,
      entryFee: (json['entryFee'] as num).toInt(),
      currency: json['currency'] as String,
      minEntries: (json['minEntries'] as num).toInt(),
      maxEntries: (json['maxEntries'] as num).toInt(),
      currentEntries: (json['currentEntries'] as num?)?.toInt(),
      maxEntriesPerUser: (json['maxEntriesPerUser'] as num).toInt(),
      rewardPoint: (json['rewardPoint'] as num).toInt(),
      gridRows: (json['gridRows'] as num).toInt(),
      gridCols: (json['gridCols'] as num).toInt(),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      isRecommended: json['isRecommended'] as bool,
      onchainTxHash: json['onchainTxHash'] as String?,
      onchainContractAddr: json['onchainContractAddr'] as String?,
      createdAt: json['createdAt'] as String,
      gameProducts:
          (json['gameProducts'] as List<dynamic>?)
              ?.map((e) => GameProductItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GameItemImplToJson(_$GameItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'type': instance.type,
      'category': instance.category,
      'status': instance.status,
      'entryFee': instance.entryFee,
      'currency': instance.currency,
      'minEntries': instance.minEntries,
      'maxEntries': instance.maxEntries,
      'currentEntries': instance.currentEntries,
      'maxEntriesPerUser': instance.maxEntriesPerUser,
      'rewardPoint': instance.rewardPoint,
      'gridRows': instance.gridRows,
      'gridCols': instance.gridCols,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'isRecommended': instance.isRecommended,
      'onchainTxHash': instance.onchainTxHash,
      'onchainContractAddr': instance.onchainContractAddr,
      'createdAt': instance.createdAt,
      'gameProducts': instance.gameProducts,
    };

_$GameProductItemImpl _$$GameProductItemImplFromJson(
  Map<String, dynamic> json,
) => _$GameProductItemImpl(
  id: json['id'] as String,
  position: (json['position'] as num?)?.toInt(),
  sequence: (json['sequence'] as num?)?.toInt(),
  isGrandPrize: json['isGrandPrize'] as bool,
  product: ProductItem.fromJson(json['product'] as Map<String, dynamic>),
);

Map<String, dynamic> _$$GameProductItemImplToJson(
  _$GameProductItemImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'position': instance.position,
  'sequence': instance.sequence,
  'isGrandPrize': instance.isGrandPrize,
  'product': instance.product,
};

_$ProductItemImpl _$$ProductItemImplFromJson(Map<String, dynamic> json) =>
    _$ProductItemImpl(
      id: json['id'] as String,
      sku: json['sku'] as String,
      brand: json['brand'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      defaultImage: json['defaultImage'] as String?,
    );

Map<String, dynamic> _$$ProductItemImplToJson(_$ProductItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sku': instance.sku,
      'brand': instance.brand,
      'name': instance.name,
      'description': instance.description,
      'defaultImage': instance.defaultImage,
    };

_$GamesResponseImpl _$$GamesResponseImplFromJson(Map<String, dynamic> json) =>
    _$GamesResponseImpl(
      success: json['success'] as bool,
      code: json['code'] as String,
      message: json['message'] as String,
      games:
          (json['games'] as List<dynamic>?)
              ?.map((e) => Game.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$GamesResponseImplToJson(_$GamesResponseImpl instance) =>
    <String, dynamic>{
      'success': instance.success,
      'code': instance.code,
      'message': instance.message,
      'games': instance.games,
    };
