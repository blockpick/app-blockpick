// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'game_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Game _$GameFromJson(Map<String, dynamic> json) {
  return _Game.fromJson(json);
}

/// @nodoc
mixin _$Game {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get mainProductName => throw _privateConstructorUsedError;
  String? get gameType =>
      throw _privateConstructorUsedError; // DAILY, SELECT, VIBE
  String? get category => throw _privateConstructorUsedError;
  String? get status =>
      throw _privateConstructorUsedError; // SCHEDULED, IN_PROGRESS, PAUSED, SETTLING, ENDED, FAILED
  int? get entryFee => throw _privateConstructorUsedError;
  String? get currency => throw _privateConstructorUsedError;
  int? get minEntries => throw _privateConstructorUsedError;
  int? get maxEntries => throw _privateConstructorUsedError;
  int? get maxEntriesPerUser => throw _privateConstructorUsedError;
  int? get rewardPoint => throw _privateConstructorUsedError;
  int? get gridRows => throw _privateConstructorUsedError;
  int? get gridCols => throw _privateConstructorUsedError;
  String? get visibleFrom => throw _privateConstructorUsedError;
  String? get startTime => throw _privateConstructorUsedError;
  String? get endTime => throw _privateConstructorUsedError;
  bool get allowDuplicate => throw _privateConstructorUsedError;
  bool get enableNotification => throw _privateConstructorUsedError;
  bool get isRecommended => throw _privateConstructorUsedError;
  bool get hasInstantPrize => throw _privateConstructorUsedError;
  String? get customRules => throw _privateConstructorUsedError;
  bool get autoEndOnMax => throw _privateConstructorUsedError;
  bool get autoEndOnTime => throw _privateConstructorUsedError;
  String? get onchainTxHash => throw _privateConstructorUsedError;
  String? get onchainContractAddr => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;
  List<GameProduct>? get gameProducts => throw _privateConstructorUsedError;

  /// Serializes this Game to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameCopyWith<Game> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameCopyWith<$Res> {
  factory $GameCopyWith(Game value, $Res Function(Game) then) =
      _$GameCopyWithImpl<$Res, Game>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? mainProductName,
    String? gameType,
    String? category,
    String? status,
    int? entryFee,
    String? currency,
    int? minEntries,
    int? maxEntries,
    int? maxEntriesPerUser,
    int? rewardPoint,
    int? gridRows,
    int? gridCols,
    String? visibleFrom,
    String? startTime,
    String? endTime,
    bool allowDuplicate,
    bool enableNotification,
    bool isRecommended,
    bool hasInstantPrize,
    String? customRules,
    bool autoEndOnMax,
    bool autoEndOnTime,
    String? onchainTxHash,
    String? onchainContractAddr,
    String? createdAt,
    String? updatedAt,
    List<GameProduct>? gameProducts,
  });
}

/// @nodoc
class _$GameCopyWithImpl<$Res, $Val extends Game>
    implements $GameCopyWith<$Res> {
  _$GameCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? mainProductName = freezed,
    Object? gameType = freezed,
    Object? category = freezed,
    Object? status = freezed,
    Object? entryFee = freezed,
    Object? currency = freezed,
    Object? minEntries = freezed,
    Object? maxEntries = freezed,
    Object? maxEntriesPerUser = freezed,
    Object? rewardPoint = freezed,
    Object? gridRows = freezed,
    Object? gridCols = freezed,
    Object? visibleFrom = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? allowDuplicate = null,
    Object? enableNotification = null,
    Object? isRecommended = null,
    Object? hasInstantPrize = null,
    Object? customRules = freezed,
    Object? autoEndOnMax = null,
    Object? autoEndOnTime = null,
    Object? onchainTxHash = freezed,
    Object? onchainContractAddr = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? gameProducts = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            mainProductName: freezed == mainProductName
                ? _value.mainProductName
                : mainProductName // ignore: cast_nullable_to_non_nullable
                      as String?,
            gameType: freezed == gameType
                ? _value.gameType
                : gameType // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            status: freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String?,
            entryFee: freezed == entryFee
                ? _value.entryFee
                : entryFee // ignore: cast_nullable_to_non_nullable
                      as int?,
            currency: freezed == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String?,
            minEntries: freezed == minEntries
                ? _value.minEntries
                : minEntries // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxEntries: freezed == maxEntries
                ? _value.maxEntries
                : maxEntries // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxEntriesPerUser: freezed == maxEntriesPerUser
                ? _value.maxEntriesPerUser
                : maxEntriesPerUser // ignore: cast_nullable_to_non_nullable
                      as int?,
            rewardPoint: freezed == rewardPoint
                ? _value.rewardPoint
                : rewardPoint // ignore: cast_nullable_to_non_nullable
                      as int?,
            gridRows: freezed == gridRows
                ? _value.gridRows
                : gridRows // ignore: cast_nullable_to_non_nullable
                      as int?,
            gridCols: freezed == gridCols
                ? _value.gridCols
                : gridCols // ignore: cast_nullable_to_non_nullable
                      as int?,
            visibleFrom: freezed == visibleFrom
                ? _value.visibleFrom
                : visibleFrom // ignore: cast_nullable_to_non_nullable
                      as String?,
            startTime: freezed == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            endTime: freezed == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String?,
            allowDuplicate: null == allowDuplicate
                ? _value.allowDuplicate
                : allowDuplicate // ignore: cast_nullable_to_non_nullable
                      as bool,
            enableNotification: null == enableNotification
                ? _value.enableNotification
                : enableNotification // ignore: cast_nullable_to_non_nullable
                      as bool,
            isRecommended: null == isRecommended
                ? _value.isRecommended
                : isRecommended // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasInstantPrize: null == hasInstantPrize
                ? _value.hasInstantPrize
                : hasInstantPrize // ignore: cast_nullable_to_non_nullable
                      as bool,
            customRules: freezed == customRules
                ? _value.customRules
                : customRules // ignore: cast_nullable_to_non_nullable
                      as String?,
            autoEndOnMax: null == autoEndOnMax
                ? _value.autoEndOnMax
                : autoEndOnMax // ignore: cast_nullable_to_non_nullable
                      as bool,
            autoEndOnTime: null == autoEndOnTime
                ? _value.autoEndOnTime
                : autoEndOnTime // ignore: cast_nullable_to_non_nullable
                      as bool,
            onchainTxHash: freezed == onchainTxHash
                ? _value.onchainTxHash
                : onchainTxHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            onchainContractAddr: freezed == onchainContractAddr
                ? _value.onchainContractAddr
                : onchainContractAddr // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            gameProducts: freezed == gameProducts
                ? _value.gameProducts
                : gameProducts // ignore: cast_nullable_to_non_nullable
                      as List<GameProduct>?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameImplCopyWith<$Res> implements $GameCopyWith<$Res> {
  factory _$$GameImplCopyWith(
    _$GameImpl value,
    $Res Function(_$GameImpl) then,
  ) = __$$GameImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String? mainProductName,
    String? gameType,
    String? category,
    String? status,
    int? entryFee,
    String? currency,
    int? minEntries,
    int? maxEntries,
    int? maxEntriesPerUser,
    int? rewardPoint,
    int? gridRows,
    int? gridCols,
    String? visibleFrom,
    String? startTime,
    String? endTime,
    bool allowDuplicate,
    bool enableNotification,
    bool isRecommended,
    bool hasInstantPrize,
    String? customRules,
    bool autoEndOnMax,
    bool autoEndOnTime,
    String? onchainTxHash,
    String? onchainContractAddr,
    String? createdAt,
    String? updatedAt,
    List<GameProduct>? gameProducts,
  });
}

/// @nodoc
class __$$GameImplCopyWithImpl<$Res>
    extends _$GameCopyWithImpl<$Res, _$GameImpl>
    implements _$$GameImplCopyWith<$Res> {
  __$$GameImplCopyWithImpl(_$GameImpl _value, $Res Function(_$GameImpl) _then)
    : super(_value, _then);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? mainProductName = freezed,
    Object? gameType = freezed,
    Object? category = freezed,
    Object? status = freezed,
    Object? entryFee = freezed,
    Object? currency = freezed,
    Object? minEntries = freezed,
    Object? maxEntries = freezed,
    Object? maxEntriesPerUser = freezed,
    Object? rewardPoint = freezed,
    Object? gridRows = freezed,
    Object? gridCols = freezed,
    Object? visibleFrom = freezed,
    Object? startTime = freezed,
    Object? endTime = freezed,
    Object? allowDuplicate = null,
    Object? enableNotification = null,
    Object? isRecommended = null,
    Object? hasInstantPrize = null,
    Object? customRules = freezed,
    Object? autoEndOnMax = null,
    Object? autoEndOnTime = null,
    Object? onchainTxHash = freezed,
    Object? onchainContractAddr = freezed,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
    Object? gameProducts = freezed,
  }) {
    return _then(
      _$GameImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        mainProductName: freezed == mainProductName
            ? _value.mainProductName
            : mainProductName // ignore: cast_nullable_to_non_nullable
                  as String?,
        gameType: freezed == gameType
            ? _value.gameType
            : gameType // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        status: freezed == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String?,
        entryFee: freezed == entryFee
            ? _value.entryFee
            : entryFee // ignore: cast_nullable_to_non_nullable
                  as int?,
        currency: freezed == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String?,
        minEntries: freezed == minEntries
            ? _value.minEntries
            : minEntries // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxEntries: freezed == maxEntries
            ? _value.maxEntries
            : maxEntries // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxEntriesPerUser: freezed == maxEntriesPerUser
            ? _value.maxEntriesPerUser
            : maxEntriesPerUser // ignore: cast_nullable_to_non_nullable
                  as int?,
        rewardPoint: freezed == rewardPoint
            ? _value.rewardPoint
            : rewardPoint // ignore: cast_nullable_to_non_nullable
                  as int?,
        gridRows: freezed == gridRows
            ? _value.gridRows
            : gridRows // ignore: cast_nullable_to_non_nullable
                  as int?,
        gridCols: freezed == gridCols
            ? _value.gridCols
            : gridCols // ignore: cast_nullable_to_non_nullable
                  as int?,
        visibleFrom: freezed == visibleFrom
            ? _value.visibleFrom
            : visibleFrom // ignore: cast_nullable_to_non_nullable
                  as String?,
        startTime: freezed == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        endTime: freezed == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String?,
        allowDuplicate: null == allowDuplicate
            ? _value.allowDuplicate
            : allowDuplicate // ignore: cast_nullable_to_non_nullable
                  as bool,
        enableNotification: null == enableNotification
            ? _value.enableNotification
            : enableNotification // ignore: cast_nullable_to_non_nullable
                  as bool,
        isRecommended: null == isRecommended
            ? _value.isRecommended
            : isRecommended // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasInstantPrize: null == hasInstantPrize
            ? _value.hasInstantPrize
            : hasInstantPrize // ignore: cast_nullable_to_non_nullable
                  as bool,
        customRules: freezed == customRules
            ? _value.customRules
            : customRules // ignore: cast_nullable_to_non_nullable
                  as String?,
        autoEndOnMax: null == autoEndOnMax
            ? _value.autoEndOnMax
            : autoEndOnMax // ignore: cast_nullable_to_non_nullable
                  as bool,
        autoEndOnTime: null == autoEndOnTime
            ? _value.autoEndOnTime
            : autoEndOnTime // ignore: cast_nullable_to_non_nullable
                  as bool,
        onchainTxHash: freezed == onchainTxHash
            ? _value.onchainTxHash
            : onchainTxHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        onchainContractAddr: freezed == onchainContractAddr
            ? _value.onchainContractAddr
            : onchainContractAddr // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        gameProducts: freezed == gameProducts
            ? _value._gameProducts
            : gameProducts // ignore: cast_nullable_to_non_nullable
                  as List<GameProduct>?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameImpl implements _Game {
  const _$GameImpl({
    required this.id,
    required this.title,
    this.description,
    this.mainProductName,
    this.gameType,
    this.category,
    this.status,
    this.entryFee,
    this.currency,
    this.minEntries,
    this.maxEntries,
    this.maxEntriesPerUser,
    this.rewardPoint,
    this.gridRows,
    this.gridCols,
    this.visibleFrom,
    this.startTime,
    this.endTime,
    this.allowDuplicate = false,
    this.enableNotification = false,
    this.isRecommended = false,
    this.hasInstantPrize = false,
    this.customRules,
    this.autoEndOnMax = false,
    this.autoEndOnTime = false,
    this.onchainTxHash,
    this.onchainContractAddr,
    this.createdAt,
    this.updatedAt,
    final List<GameProduct>? gameProducts = const [],
  }) : _gameProducts = gameProducts;

  factory _$GameImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String? mainProductName;
  @override
  final String? gameType;
  // DAILY, SELECT, VIBE
  @override
  final String? category;
  @override
  final String? status;
  // SCHEDULED, IN_PROGRESS, PAUSED, SETTLING, ENDED, FAILED
  @override
  final int? entryFee;
  @override
  final String? currency;
  @override
  final int? minEntries;
  @override
  final int? maxEntries;
  @override
  final int? maxEntriesPerUser;
  @override
  final int? rewardPoint;
  @override
  final int? gridRows;
  @override
  final int? gridCols;
  @override
  final String? visibleFrom;
  @override
  final String? startTime;
  @override
  final String? endTime;
  @override
  @JsonKey()
  final bool allowDuplicate;
  @override
  @JsonKey()
  final bool enableNotification;
  @override
  @JsonKey()
  final bool isRecommended;
  @override
  @JsonKey()
  final bool hasInstantPrize;
  @override
  final String? customRules;
  @override
  @JsonKey()
  final bool autoEndOnMax;
  @override
  @JsonKey()
  final bool autoEndOnTime;
  @override
  final String? onchainTxHash;
  @override
  final String? onchainContractAddr;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;
  final List<GameProduct>? _gameProducts;
  @override
  @JsonKey()
  List<GameProduct>? get gameProducts {
    final value = _gameProducts;
    if (value == null) return null;
    if (_gameProducts is EqualUnmodifiableListView) return _gameProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'Game(id: $id, title: $title, description: $description, mainProductName: $mainProductName, gameType: $gameType, category: $category, status: $status, entryFee: $entryFee, currency: $currency, minEntries: $minEntries, maxEntries: $maxEntries, maxEntriesPerUser: $maxEntriesPerUser, rewardPoint: $rewardPoint, gridRows: $gridRows, gridCols: $gridCols, visibleFrom: $visibleFrom, startTime: $startTime, endTime: $endTime, allowDuplicate: $allowDuplicate, enableNotification: $enableNotification, isRecommended: $isRecommended, hasInstantPrize: $hasInstantPrize, customRules: $customRules, autoEndOnMax: $autoEndOnMax, autoEndOnTime: $autoEndOnTime, onchainTxHash: $onchainTxHash, onchainContractAddr: $onchainContractAddr, createdAt: $createdAt, updatedAt: $updatedAt, gameProducts: $gameProducts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.mainProductName, mainProductName) ||
                other.mainProductName == mainProductName) &&
            (identical(other.gameType, gameType) ||
                other.gameType == gameType) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.entryFee, entryFee) ||
                other.entryFee == entryFee) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.minEntries, minEntries) ||
                other.minEntries == minEntries) &&
            (identical(other.maxEntries, maxEntries) ||
                other.maxEntries == maxEntries) &&
            (identical(other.maxEntriesPerUser, maxEntriesPerUser) ||
                other.maxEntriesPerUser == maxEntriesPerUser) &&
            (identical(other.rewardPoint, rewardPoint) ||
                other.rewardPoint == rewardPoint) &&
            (identical(other.gridRows, gridRows) ||
                other.gridRows == gridRows) &&
            (identical(other.gridCols, gridCols) ||
                other.gridCols == gridCols) &&
            (identical(other.visibleFrom, visibleFrom) ||
                other.visibleFrom == visibleFrom) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.allowDuplicate, allowDuplicate) ||
                other.allowDuplicate == allowDuplicate) &&
            (identical(other.enableNotification, enableNotification) ||
                other.enableNotification == enableNotification) &&
            (identical(other.isRecommended, isRecommended) ||
                other.isRecommended == isRecommended) &&
            (identical(other.hasInstantPrize, hasInstantPrize) ||
                other.hasInstantPrize == hasInstantPrize) &&
            (identical(other.customRules, customRules) ||
                other.customRules == customRules) &&
            (identical(other.autoEndOnMax, autoEndOnMax) ||
                other.autoEndOnMax == autoEndOnMax) &&
            (identical(other.autoEndOnTime, autoEndOnTime) ||
                other.autoEndOnTime == autoEndOnTime) &&
            (identical(other.onchainTxHash, onchainTxHash) ||
                other.onchainTxHash == onchainTxHash) &&
            (identical(other.onchainContractAddr, onchainContractAddr) ||
                other.onchainContractAddr == onchainContractAddr) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            const DeepCollectionEquality().equals(
              other._gameProducts,
              _gameProducts,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    mainProductName,
    gameType,
    category,
    status,
    entryFee,
    currency,
    minEntries,
    maxEntries,
    maxEntriesPerUser,
    rewardPoint,
    gridRows,
    gridCols,
    visibleFrom,
    startTime,
    endTime,
    allowDuplicate,
    enableNotification,
    isRecommended,
    hasInstantPrize,
    customRules,
    autoEndOnMax,
    autoEndOnTime,
    onchainTxHash,
    onchainContractAddr,
    createdAt,
    updatedAt,
    const DeepCollectionEquality().hash(_gameProducts),
  ]);

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      __$$GameImplCopyWithImpl<_$GameImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameImplToJson(this);
  }
}

abstract class _Game implements Game {
  const factory _Game({
    required final String id,
    required final String title,
    final String? description,
    final String? mainProductName,
    final String? gameType,
    final String? category,
    final String? status,
    final int? entryFee,
    final String? currency,
    final int? minEntries,
    final int? maxEntries,
    final int? maxEntriesPerUser,
    final int? rewardPoint,
    final int? gridRows,
    final int? gridCols,
    final String? visibleFrom,
    final String? startTime,
    final String? endTime,
    final bool allowDuplicate,
    final bool enableNotification,
    final bool isRecommended,
    final bool hasInstantPrize,
    final String? customRules,
    final bool autoEndOnMax,
    final bool autoEndOnTime,
    final String? onchainTxHash,
    final String? onchainContractAddr,
    final String? createdAt,
    final String? updatedAt,
    final List<GameProduct>? gameProducts,
  }) = _$GameImpl;

  factory _Game.fromJson(Map<String, dynamic> json) = _$GameImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String? get mainProductName;
  @override
  String? get gameType; // DAILY, SELECT, VIBE
  @override
  String? get category;
  @override
  String? get status; // SCHEDULED, IN_PROGRESS, PAUSED, SETTLING, ENDED, FAILED
  @override
  int? get entryFee;
  @override
  String? get currency;
  @override
  int? get minEntries;
  @override
  int? get maxEntries;
  @override
  int? get maxEntriesPerUser;
  @override
  int? get rewardPoint;
  @override
  int? get gridRows;
  @override
  int? get gridCols;
  @override
  String? get visibleFrom;
  @override
  String? get startTime;
  @override
  String? get endTime;
  @override
  bool get allowDuplicate;
  @override
  bool get enableNotification;
  @override
  bool get isRecommended;
  @override
  bool get hasInstantPrize;
  @override
  String? get customRules;
  @override
  bool get autoEndOnMax;
  @override
  bool get autoEndOnTime;
  @override
  String? get onchainTxHash;
  @override
  String? get onchainContractAddr;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;
  @override
  List<GameProduct>? get gameProducts;

  /// Create a copy of Game
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameImplCopyWith<_$GameImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameProduct _$GameProductFromJson(Map<String, dynamic> json) {
  return _GameProduct.fromJson(json);
}

/// @nodoc
mixin _$GameProduct {
  String get id => throw _privateConstructorUsedError;
  int? get sequence => throw _privateConstructorUsedError;
  bool? get active => throw _privateConstructorUsedError;
  bool? get isGrandPrize => throw _privateConstructorUsedError;
  Product get product => throw _privateConstructorUsedError;
  String? get createdAt => throw _privateConstructorUsedError;
  String? get updatedAt => throw _privateConstructorUsedError;

  /// Serializes this GameProduct to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameProductCopyWith<GameProduct> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameProductCopyWith<$Res> {
  factory $GameProductCopyWith(
    GameProduct value,
    $Res Function(GameProduct) then,
  ) = _$GameProductCopyWithImpl<$Res, GameProduct>;
  @useResult
  $Res call({
    String id,
    int? sequence,
    bool? active,
    bool? isGrandPrize,
    Product product,
    String? createdAt,
    String? updatedAt,
  });

  $ProductCopyWith<$Res> get product;
}

/// @nodoc
class _$GameProductCopyWithImpl<$Res, $Val extends GameProduct>
    implements $GameProductCopyWith<$Res> {
  _$GameProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sequence = freezed,
    Object? active = freezed,
    Object? isGrandPrize = freezed,
    Object? product = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sequence: freezed == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int?,
            active: freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool?,
            isGrandPrize: freezed == isGrandPrize
                ? _value.isGrandPrize
                : isGrandPrize // ignore: cast_nullable_to_non_nullable
                      as bool?,
            product: null == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as Product,
            createdAt: freezed == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String?,
            updatedAt: freezed == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }

  /// Create a copy of GameProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductCopyWith<$Res> get product {
    return $ProductCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameProductImplCopyWith<$Res>
    implements $GameProductCopyWith<$Res> {
  factory _$$GameProductImplCopyWith(
    _$GameProductImpl value,
    $Res Function(_$GameProductImpl) then,
  ) = __$$GameProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int? sequence,
    bool? active,
    bool? isGrandPrize,
    Product product,
    String? createdAt,
    String? updatedAt,
  });

  @override
  $ProductCopyWith<$Res> get product;
}

/// @nodoc
class __$$GameProductImplCopyWithImpl<$Res>
    extends _$GameProductCopyWithImpl<$Res, _$GameProductImpl>
    implements _$$GameProductImplCopyWith<$Res> {
  __$$GameProductImplCopyWithImpl(
    _$GameProductImpl _value,
    $Res Function(_$GameProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameProduct
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sequence = freezed,
    Object? active = freezed,
    Object? isGrandPrize = freezed,
    Object? product = null,
    Object? createdAt = freezed,
    Object? updatedAt = freezed,
  }) {
    return _then(
      _$GameProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sequence: freezed == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int?,
        active: freezed == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool?,
        isGrandPrize: freezed == isGrandPrize
            ? _value.isGrandPrize
            : isGrandPrize // ignore: cast_nullable_to_non_nullable
                  as bool?,
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as Product,
        createdAt: freezed == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String?,
        updatedAt: freezed == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameProductImpl implements _GameProduct {
  const _$GameProductImpl({
    required this.id,
    this.sequence,
    this.active,
    this.isGrandPrize,
    required this.product,
    this.createdAt,
    this.updatedAt,
  });

  factory _$GameProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameProductImplFromJson(json);

  @override
  final String id;
  @override
  final int? sequence;
  @override
  final bool? active;
  @override
  final bool? isGrandPrize;
  @override
  final Product product;
  @override
  final String? createdAt;
  @override
  final String? updatedAt;

  @override
  String toString() {
    return 'GameProduct(id: $id, sequence: $sequence, active: $active, isGrandPrize: $isGrandPrize, product: $product, createdAt: $createdAt, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.active, active) || other.active == active) &&
            (identical(other.isGrandPrize, isGrandPrize) ||
                other.isGrandPrize == isGrandPrize) &&
            (identical(other.product, product) || other.product == product) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    sequence,
    active,
    isGrandPrize,
    product,
    createdAt,
    updatedAt,
  );

  /// Create a copy of GameProduct
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameProductImplCopyWith<_$GameProductImpl> get copyWith =>
      __$$GameProductImplCopyWithImpl<_$GameProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameProductImplToJson(this);
  }
}

abstract class _GameProduct implements GameProduct {
  const factory _GameProduct({
    required final String id,
    final int? sequence,
    final bool? active,
    final bool? isGrandPrize,
    required final Product product,
    final String? createdAt,
    final String? updatedAt,
  }) = _$GameProductImpl;

  factory _GameProduct.fromJson(Map<String, dynamic> json) =
      _$GameProductImpl.fromJson;

  @override
  String get id;
  @override
  int? get sequence;
  @override
  bool? get active;
  @override
  bool? get isGrandPrize;
  @override
  Product get product;
  @override
  String? get createdAt;
  @override
  String? get updatedAt;

  /// Create a copy of GameProduct
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameProductImplCopyWith<_$GameProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Product _$ProductFromJson(Map<String, dynamic> json) {
  return _Product.fromJson(json);
}

/// @nodoc
mixin _$Product {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get brand => throw _privateConstructorUsedError;
  String? get category => throw _privateConstructorUsedError;
  String? get sku => throw _privateConstructorUsedError;
  String? get defaultImage => throw _privateConstructorUsedError;
  String? get imageUrl => throw _privateConstructorUsedError;
  String? get thumbnailUrl => throw _privateConstructorUsedError;
  int? get price => throw _privateConstructorUsedError;
  int? get originalPrice => throw _privateConstructorUsedError;
  String? get countryCode => throw _privateConstructorUsedError;
  bool? get active => throw _privateConstructorUsedError;

  /// Serializes this Product to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductCopyWith<Product> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductCopyWith<$Res> {
  factory $ProductCopyWith(Product value, $Res Function(Product) then) =
      _$ProductCopyWithImpl<$Res, Product>;
  @useResult
  $Res call({
    String id,
    String name,
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
  });
}

/// @nodoc
class _$ProductCopyWithImpl<$Res, $Val extends Product>
    implements $ProductCopyWith<$Res> {
  _$ProductCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? brand = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? defaultImage = freezed,
    Object? imageUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? price = freezed,
    Object? originalPrice = freezed,
    Object? countryCode = freezed,
    Object? active = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            brand: freezed == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String?,
            category: freezed == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String?,
            sku: freezed == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultImage: freezed == defaultImage
                ? _value.defaultImage
                : defaultImage // ignore: cast_nullable_to_non_nullable
                      as String?,
            imageUrl: freezed == imageUrl
                ? _value.imageUrl
                : imageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            thumbnailUrl: freezed == thumbnailUrl
                ? _value.thumbnailUrl
                : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            price: freezed == price
                ? _value.price
                : price // ignore: cast_nullable_to_non_nullable
                      as int?,
            originalPrice: freezed == originalPrice
                ? _value.originalPrice
                : originalPrice // ignore: cast_nullable_to_non_nullable
                      as int?,
            countryCode: freezed == countryCode
                ? _value.countryCode
                : countryCode // ignore: cast_nullable_to_non_nullable
                      as String?,
            active: freezed == active
                ? _value.active
                : active // ignore: cast_nullable_to_non_nullable
                      as bool?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductImplCopyWith<$Res> implements $ProductCopyWith<$Res> {
  factory _$$ProductImplCopyWith(
    _$ProductImpl value,
    $Res Function(_$ProductImpl) then,
  ) = __$$ProductImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
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
  });
}

/// @nodoc
class __$$ProductImplCopyWithImpl<$Res>
    extends _$ProductCopyWithImpl<$Res, _$ProductImpl>
    implements _$$ProductImplCopyWith<$Res> {
  __$$ProductImplCopyWithImpl(
    _$ProductImpl _value,
    $Res Function(_$ProductImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = freezed,
    Object? brand = freezed,
    Object? category = freezed,
    Object? sku = freezed,
    Object? defaultImage = freezed,
    Object? imageUrl = freezed,
    Object? thumbnailUrl = freezed,
    Object? price = freezed,
    Object? originalPrice = freezed,
    Object? countryCode = freezed,
    Object? active = freezed,
  }) {
    return _then(
      _$ProductImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        brand: freezed == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String?,
        category: freezed == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String?,
        sku: freezed == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultImage: freezed == defaultImage
            ? _value.defaultImage
            : defaultImage // ignore: cast_nullable_to_non_nullable
                  as String?,
        imageUrl: freezed == imageUrl
            ? _value.imageUrl
            : imageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        thumbnailUrl: freezed == thumbnailUrl
            ? _value.thumbnailUrl
            : thumbnailUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        price: freezed == price
            ? _value.price
            : price // ignore: cast_nullable_to_non_nullable
                  as int?,
        originalPrice: freezed == originalPrice
            ? _value.originalPrice
            : originalPrice // ignore: cast_nullable_to_non_nullable
                  as int?,
        countryCode: freezed == countryCode
            ? _value.countryCode
            : countryCode // ignore: cast_nullable_to_non_nullable
                  as String?,
        active: freezed == active
            ? _value.active
            : active // ignore: cast_nullable_to_non_nullable
                  as bool?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductImpl implements _Product {
  const _$ProductImpl({
    required this.id,
    required this.name,
    this.description,
    this.brand,
    this.category,
    this.sku,
    this.defaultImage,
    this.imageUrl,
    this.thumbnailUrl,
    this.price,
    this.originalPrice,
    this.countryCode,
    this.active,
  });

  factory _$ProductImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? brand;
  @override
  final String? category;
  @override
  final String? sku;
  @override
  final String? defaultImage;
  @override
  final String? imageUrl;
  @override
  final String? thumbnailUrl;
  @override
  final int? price;
  @override
  final int? originalPrice;
  @override
  final String? countryCode;
  @override
  final bool? active;

  @override
  String toString() {
    return 'Product(id: $id, name: $name, description: $description, brand: $brand, category: $category, sku: $sku, defaultImage: $defaultImage, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, price: $price, originalPrice: $originalPrice, countryCode: $countryCode, active: $active)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.defaultImage, defaultImage) ||
                other.defaultImage == defaultImage) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.thumbnailUrl, thumbnailUrl) ||
                other.thumbnailUrl == thumbnailUrl) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.originalPrice, originalPrice) ||
                other.originalPrice == originalPrice) &&
            (identical(other.countryCode, countryCode) ||
                other.countryCode == countryCode) &&
            (identical(other.active, active) || other.active == active));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    description,
    brand,
    category,
    sku,
    defaultImage,
    imageUrl,
    thumbnailUrl,
    price,
    originalPrice,
    countryCode,
    active,
  );

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      __$$ProductImplCopyWithImpl<_$ProductImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductImplToJson(this);
  }
}

abstract class _Product implements Product {
  const factory _Product({
    required final String id,
    required final String name,
    final String? description,
    final String? brand,
    final String? category,
    final String? sku,
    final String? defaultImage,
    final String? imageUrl,
    final String? thumbnailUrl,
    final int? price,
    final int? originalPrice,
    final String? countryCode,
    final bool? active,
  }) = _$ProductImpl;

  factory _Product.fromJson(Map<String, dynamic> json) = _$ProductImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get brand;
  @override
  String? get category;
  @override
  String? get sku;
  @override
  String? get defaultImage;
  @override
  String? get imageUrl;
  @override
  String? get thumbnailUrl;
  @override
  int? get price;
  @override
  int? get originalPrice;
  @override
  String? get countryCode;
  @override
  bool? get active;

  /// Create a copy of Product
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductImplCopyWith<_$ProductImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameItem _$GameItemFromJson(Map<String, dynamic> json) {
  return _GameItem.fromJson(json);
}

/// @nodoc
mixin _$GameItem {
  String get id => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String get type => throw _privateConstructorUsedError;
  String get category => throw _privateConstructorUsedError;
  String get status => throw _privateConstructorUsedError;
  int get entryFee => throw _privateConstructorUsedError;
  String get currency => throw _privateConstructorUsedError;
  int get minEntries => throw _privateConstructorUsedError;
  int get maxEntries => throw _privateConstructorUsedError;
  int? get currentEntries =>
      throw _privateConstructorUsedError; // nullable로 변경 (백엔드 이슈)
  int get maxEntriesPerUser => throw _privateConstructorUsedError;
  int get rewardPoint => throw _privateConstructorUsedError;
  int get gridRows => throw _privateConstructorUsedError;
  int get gridCols => throw _privateConstructorUsedError;
  String get startTime => throw _privateConstructorUsedError;
  String get endTime => throw _privateConstructorUsedError;
  bool get isRecommended => throw _privateConstructorUsedError;
  bool get hasInstantPrize => throw _privateConstructorUsedError;
  String? get onchainTxHash => throw _privateConstructorUsedError;
  String? get onchainContractAddr => throw _privateConstructorUsedError;
  String get createdAt => throw _privateConstructorUsedError;
  List<GameProductItem> get gameProducts => throw _privateConstructorUsedError;

  /// Serializes this GameItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameItemCopyWith<GameItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameItemCopyWith<$Res> {
  factory $GameItemCopyWith(GameItem value, $Res Function(GameItem) then) =
      _$GameItemCopyWithImpl<$Res, GameItem>;
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String type,
    String category,
    String status,
    int entryFee,
    String currency,
    int minEntries,
    int maxEntries,
    int? currentEntries,
    int maxEntriesPerUser,
    int rewardPoint,
    int gridRows,
    int gridCols,
    String startTime,
    String endTime,
    bool isRecommended,
    bool hasInstantPrize,
    String? onchainTxHash,
    String? onchainContractAddr,
    String createdAt,
    List<GameProductItem> gameProducts,
  });
}

/// @nodoc
class _$GameItemCopyWithImpl<$Res, $Val extends GameItem>
    implements $GameItemCopyWith<$Res> {
  _$GameItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = null,
    Object? category = null,
    Object? status = null,
    Object? entryFee = null,
    Object? currency = null,
    Object? minEntries = null,
    Object? maxEntries = null,
    Object? currentEntries = freezed,
    Object? maxEntriesPerUser = null,
    Object? rewardPoint = null,
    Object? gridRows = null,
    Object? gridCols = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isRecommended = null,
    Object? hasInstantPrize = null,
    Object? onchainTxHash = freezed,
    Object? onchainContractAddr = freezed,
    Object? createdAt = null,
    Object? gameProducts = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            title: null == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as String,
            category: null == category
                ? _value.category
                : category // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as String,
            entryFee: null == entryFee
                ? _value.entryFee
                : entryFee // ignore: cast_nullable_to_non_nullable
                      as int,
            currency: null == currency
                ? _value.currency
                : currency // ignore: cast_nullable_to_non_nullable
                      as String,
            minEntries: null == minEntries
                ? _value.minEntries
                : minEntries // ignore: cast_nullable_to_non_nullable
                      as int,
            maxEntries: null == maxEntries
                ? _value.maxEntries
                : maxEntries // ignore: cast_nullable_to_non_nullable
                      as int,
            currentEntries: freezed == currentEntries
                ? _value.currentEntries
                : currentEntries // ignore: cast_nullable_to_non_nullable
                      as int?,
            maxEntriesPerUser: null == maxEntriesPerUser
                ? _value.maxEntriesPerUser
                : maxEntriesPerUser // ignore: cast_nullable_to_non_nullable
                      as int,
            rewardPoint: null == rewardPoint
                ? _value.rewardPoint
                : rewardPoint // ignore: cast_nullable_to_non_nullable
                      as int,
            gridRows: null == gridRows
                ? _value.gridRows
                : gridRows // ignore: cast_nullable_to_non_nullable
                      as int,
            gridCols: null == gridCols
                ? _value.gridCols
                : gridCols // ignore: cast_nullable_to_non_nullable
                      as int,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as String,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as String,
            isRecommended: null == isRecommended
                ? _value.isRecommended
                : isRecommended // ignore: cast_nullable_to_non_nullable
                      as bool,
            hasInstantPrize: null == hasInstantPrize
                ? _value.hasInstantPrize
                : hasInstantPrize // ignore: cast_nullable_to_non_nullable
                      as bool,
            onchainTxHash: freezed == onchainTxHash
                ? _value.onchainTxHash
                : onchainTxHash // ignore: cast_nullable_to_non_nullable
                      as String?,
            onchainContractAddr: freezed == onchainContractAddr
                ? _value.onchainContractAddr
                : onchainContractAddr // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            gameProducts: null == gameProducts
                ? _value.gameProducts
                : gameProducts // ignore: cast_nullable_to_non_nullable
                      as List<GameProductItem>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GameItemImplCopyWith<$Res>
    implements $GameItemCopyWith<$Res> {
  factory _$$GameItemImplCopyWith(
    _$GameItemImpl value,
    $Res Function(_$GameItemImpl) then,
  ) = __$$GameItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String title,
    String? description,
    String type,
    String category,
    String status,
    int entryFee,
    String currency,
    int minEntries,
    int maxEntries,
    int? currentEntries,
    int maxEntriesPerUser,
    int rewardPoint,
    int gridRows,
    int gridCols,
    String startTime,
    String endTime,
    bool isRecommended,
    bool hasInstantPrize,
    String? onchainTxHash,
    String? onchainContractAddr,
    String createdAt,
    List<GameProductItem> gameProducts,
  });
}

/// @nodoc
class __$$GameItemImplCopyWithImpl<$Res>
    extends _$GameItemCopyWithImpl<$Res, _$GameItemImpl>
    implements _$$GameItemImplCopyWith<$Res> {
  __$$GameItemImplCopyWithImpl(
    _$GameItemImpl _value,
    $Res Function(_$GameItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? title = null,
    Object? description = freezed,
    Object? type = null,
    Object? category = null,
    Object? status = null,
    Object? entryFee = null,
    Object? currency = null,
    Object? minEntries = null,
    Object? maxEntries = null,
    Object? currentEntries = freezed,
    Object? maxEntriesPerUser = null,
    Object? rewardPoint = null,
    Object? gridRows = null,
    Object? gridCols = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? isRecommended = null,
    Object? hasInstantPrize = null,
    Object? onchainTxHash = freezed,
    Object? onchainContractAddr = freezed,
    Object? createdAt = null,
    Object? gameProducts = null,
  }) {
    return _then(
      _$GameItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        title: null == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as String,
        category: null == category
            ? _value.category
            : category // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as String,
        entryFee: null == entryFee
            ? _value.entryFee
            : entryFee // ignore: cast_nullable_to_non_nullable
                  as int,
        currency: null == currency
            ? _value.currency
            : currency // ignore: cast_nullable_to_non_nullable
                  as String,
        minEntries: null == minEntries
            ? _value.minEntries
            : minEntries // ignore: cast_nullable_to_non_nullable
                  as int,
        maxEntries: null == maxEntries
            ? _value.maxEntries
            : maxEntries // ignore: cast_nullable_to_non_nullable
                  as int,
        currentEntries: freezed == currentEntries
            ? _value.currentEntries
            : currentEntries // ignore: cast_nullable_to_non_nullable
                  as int?,
        maxEntriesPerUser: null == maxEntriesPerUser
            ? _value.maxEntriesPerUser
            : maxEntriesPerUser // ignore: cast_nullable_to_non_nullable
                  as int,
        rewardPoint: null == rewardPoint
            ? _value.rewardPoint
            : rewardPoint // ignore: cast_nullable_to_non_nullable
                  as int,
        gridRows: null == gridRows
            ? _value.gridRows
            : gridRows // ignore: cast_nullable_to_non_nullable
                  as int,
        gridCols: null == gridCols
            ? _value.gridCols
            : gridCols // ignore: cast_nullable_to_non_nullable
                  as int,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as String,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as String,
        isRecommended: null == isRecommended
            ? _value.isRecommended
            : isRecommended // ignore: cast_nullable_to_non_nullable
                  as bool,
        hasInstantPrize: null == hasInstantPrize
            ? _value.hasInstantPrize
            : hasInstantPrize // ignore: cast_nullable_to_non_nullable
                  as bool,
        onchainTxHash: freezed == onchainTxHash
            ? _value.onchainTxHash
            : onchainTxHash // ignore: cast_nullable_to_non_nullable
                  as String?,
        onchainContractAddr: freezed == onchainContractAddr
            ? _value.onchainContractAddr
            : onchainContractAddr // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        gameProducts: null == gameProducts
            ? _value._gameProducts
            : gameProducts // ignore: cast_nullable_to_non_nullable
                  as List<GameProductItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameItemImpl implements _GameItem {
  const _$GameItemImpl({
    required this.id,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.status,
    required this.entryFee,
    required this.currency,
    required this.minEntries,
    required this.maxEntries,
    this.currentEntries,
    required this.maxEntriesPerUser,
    required this.rewardPoint,
    required this.gridRows,
    required this.gridCols,
    required this.startTime,
    required this.endTime,
    required this.isRecommended,
    this.hasInstantPrize = false,
    this.onchainTxHash,
    this.onchainContractAddr,
    required this.createdAt,
    final List<GameProductItem> gameProducts = const [],
  }) : _gameProducts = gameProducts;

  factory _$GameItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameItemImplFromJson(json);

  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String type;
  @override
  final String category;
  @override
  final String status;
  @override
  final int entryFee;
  @override
  final String currency;
  @override
  final int minEntries;
  @override
  final int maxEntries;
  @override
  final int? currentEntries;
  // nullable로 변경 (백엔드 이슈)
  @override
  final int maxEntriesPerUser;
  @override
  final int rewardPoint;
  @override
  final int gridRows;
  @override
  final int gridCols;
  @override
  final String startTime;
  @override
  final String endTime;
  @override
  final bool isRecommended;
  @override
  @JsonKey()
  final bool hasInstantPrize;
  @override
  final String? onchainTxHash;
  @override
  final String? onchainContractAddr;
  @override
  final String createdAt;
  final List<GameProductItem> _gameProducts;
  @override
  @JsonKey()
  List<GameProductItem> get gameProducts {
    if (_gameProducts is EqualUnmodifiableListView) return _gameProducts;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_gameProducts);
  }

  @override
  String toString() {
    return 'GameItem(id: $id, title: $title, description: $description, type: $type, category: $category, status: $status, entryFee: $entryFee, currency: $currency, minEntries: $minEntries, maxEntries: $maxEntries, currentEntries: $currentEntries, maxEntriesPerUser: $maxEntriesPerUser, rewardPoint: $rewardPoint, gridRows: $gridRows, gridCols: $gridCols, startTime: $startTime, endTime: $endTime, isRecommended: $isRecommended, hasInstantPrize: $hasInstantPrize, onchainTxHash: $onchainTxHash, onchainContractAddr: $onchainContractAddr, createdAt: $createdAt, gameProducts: $gameProducts)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.entryFee, entryFee) ||
                other.entryFee == entryFee) &&
            (identical(other.currency, currency) ||
                other.currency == currency) &&
            (identical(other.minEntries, minEntries) ||
                other.minEntries == minEntries) &&
            (identical(other.maxEntries, maxEntries) ||
                other.maxEntries == maxEntries) &&
            (identical(other.currentEntries, currentEntries) ||
                other.currentEntries == currentEntries) &&
            (identical(other.maxEntriesPerUser, maxEntriesPerUser) ||
                other.maxEntriesPerUser == maxEntriesPerUser) &&
            (identical(other.rewardPoint, rewardPoint) ||
                other.rewardPoint == rewardPoint) &&
            (identical(other.gridRows, gridRows) ||
                other.gridRows == gridRows) &&
            (identical(other.gridCols, gridCols) ||
                other.gridCols == gridCols) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.isRecommended, isRecommended) ||
                other.isRecommended == isRecommended) &&
            (identical(other.hasInstantPrize, hasInstantPrize) ||
                other.hasInstantPrize == hasInstantPrize) &&
            (identical(other.onchainTxHash, onchainTxHash) ||
                other.onchainTxHash == onchainTxHash) &&
            (identical(other.onchainContractAddr, onchainContractAddr) ||
                other.onchainContractAddr == onchainContractAddr) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            const DeepCollectionEquality().equals(
              other._gameProducts,
              _gameProducts,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hashAll([
    runtimeType,
    id,
    title,
    description,
    type,
    category,
    status,
    entryFee,
    currency,
    minEntries,
    maxEntries,
    currentEntries,
    maxEntriesPerUser,
    rewardPoint,
    gridRows,
    gridCols,
    startTime,
    endTime,
    isRecommended,
    hasInstantPrize,
    onchainTxHash,
    onchainContractAddr,
    createdAt,
    const DeepCollectionEquality().hash(_gameProducts),
  ]);

  /// Create a copy of GameItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameItemImplCopyWith<_$GameItemImpl> get copyWith =>
      __$$GameItemImplCopyWithImpl<_$GameItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GameItemImplToJson(this);
  }
}

abstract class _GameItem implements GameItem {
  const factory _GameItem({
    required final String id,
    required final String title,
    final String? description,
    required final String type,
    required final String category,
    required final String status,
    required final int entryFee,
    required final String currency,
    required final int minEntries,
    required final int maxEntries,
    final int? currentEntries,
    required final int maxEntriesPerUser,
    required final int rewardPoint,
    required final int gridRows,
    required final int gridCols,
    required final String startTime,
    required final String endTime,
    required final bool isRecommended,
    final bool hasInstantPrize,
    final String? onchainTxHash,
    final String? onchainContractAddr,
    required final String createdAt,
    final List<GameProductItem> gameProducts,
  }) = _$GameItemImpl;

  factory _GameItem.fromJson(Map<String, dynamic> json) =
      _$GameItemImpl.fromJson;

  @override
  String get id;
  @override
  String get title;
  @override
  String? get description;
  @override
  String get type;
  @override
  String get category;
  @override
  String get status;
  @override
  int get entryFee;
  @override
  String get currency;
  @override
  int get minEntries;
  @override
  int get maxEntries;
  @override
  int? get currentEntries; // nullable로 변경 (백엔드 이슈)
  @override
  int get maxEntriesPerUser;
  @override
  int get rewardPoint;
  @override
  int get gridRows;
  @override
  int get gridCols;
  @override
  String get startTime;
  @override
  String get endTime;
  @override
  bool get isRecommended;
  @override
  bool get hasInstantPrize;
  @override
  String? get onchainTxHash;
  @override
  String? get onchainContractAddr;
  @override
  String get createdAt;
  @override
  List<GameProductItem> get gameProducts;

  /// Create a copy of GameItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameItemImplCopyWith<_$GameItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GameProductItem _$GameProductItemFromJson(Map<String, dynamic> json) {
  return _GameProductItem.fromJson(json);
}

/// @nodoc
mixin _$GameProductItem {
  String get id => throw _privateConstructorUsedError;
  int? get position => throw _privateConstructorUsedError;
  int? get sequence => throw _privateConstructorUsedError;
  bool get isGrandPrize => throw _privateConstructorUsedError;
  ProductItem get product => throw _privateConstructorUsedError;

  /// Serializes this GameProductItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GameProductItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GameProductItemCopyWith<GameProductItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GameProductItemCopyWith<$Res> {
  factory $GameProductItemCopyWith(
    GameProductItem value,
    $Res Function(GameProductItem) then,
  ) = _$GameProductItemCopyWithImpl<$Res, GameProductItem>;
  @useResult
  $Res call({
    String id,
    int? position,
    int? sequence,
    bool isGrandPrize,
    ProductItem product,
  });

  $ProductItemCopyWith<$Res> get product;
}

/// @nodoc
class _$GameProductItemCopyWithImpl<$Res, $Val extends GameProductItem>
    implements $GameProductItemCopyWith<$Res> {
  _$GameProductItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GameProductItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? position = freezed,
    Object? sequence = freezed,
    Object? isGrandPrize = null,
    Object? product = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            position: freezed == position
                ? _value.position
                : position // ignore: cast_nullable_to_non_nullable
                      as int?,
            sequence: freezed == sequence
                ? _value.sequence
                : sequence // ignore: cast_nullable_to_non_nullable
                      as int?,
            isGrandPrize: null == isGrandPrize
                ? _value.isGrandPrize
                : isGrandPrize // ignore: cast_nullable_to_non_nullable
                      as bool,
            product: null == product
                ? _value.product
                : product // ignore: cast_nullable_to_non_nullable
                      as ProductItem,
          )
          as $Val,
    );
  }

  /// Create a copy of GameProductItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $ProductItemCopyWith<$Res> get product {
    return $ProductItemCopyWith<$Res>(_value.product, (value) {
      return _then(_value.copyWith(product: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$GameProductItemImplCopyWith<$Res>
    implements $GameProductItemCopyWith<$Res> {
  factory _$$GameProductItemImplCopyWith(
    _$GameProductItemImpl value,
    $Res Function(_$GameProductItemImpl) then,
  ) = __$$GameProductItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    int? position,
    int? sequence,
    bool isGrandPrize,
    ProductItem product,
  });

  @override
  $ProductItemCopyWith<$Res> get product;
}

/// @nodoc
class __$$GameProductItemImplCopyWithImpl<$Res>
    extends _$GameProductItemCopyWithImpl<$Res, _$GameProductItemImpl>
    implements _$$GameProductItemImplCopyWith<$Res> {
  __$$GameProductItemImplCopyWithImpl(
    _$GameProductItemImpl _value,
    $Res Function(_$GameProductItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GameProductItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? position = freezed,
    Object? sequence = freezed,
    Object? isGrandPrize = null,
    Object? product = null,
  }) {
    return _then(
      _$GameProductItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        position: freezed == position
            ? _value.position
            : position // ignore: cast_nullable_to_non_nullable
                  as int?,
        sequence: freezed == sequence
            ? _value.sequence
            : sequence // ignore: cast_nullable_to_non_nullable
                  as int?,
        isGrandPrize: null == isGrandPrize
            ? _value.isGrandPrize
            : isGrandPrize // ignore: cast_nullable_to_non_nullable
                  as bool,
        product: null == product
            ? _value.product
            : product // ignore: cast_nullable_to_non_nullable
                  as ProductItem,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GameProductItemImpl implements _GameProductItem {
  const _$GameProductItemImpl({
    required this.id,
    this.position,
    this.sequence,
    required this.isGrandPrize,
    required this.product,
  });

  factory _$GameProductItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$GameProductItemImplFromJson(json);

  @override
  final String id;
  @override
  final int? position;
  @override
  final int? sequence;
  @override
  final bool isGrandPrize;
  @override
  final ProductItem product;

  @override
  String toString() {
    return 'GameProductItem(id: $id, position: $position, sequence: $sequence, isGrandPrize: $isGrandPrize, product: $product)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GameProductItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.position, position) ||
                other.position == position) &&
            (identical(other.sequence, sequence) ||
                other.sequence == sequence) &&
            (identical(other.isGrandPrize, isGrandPrize) ||
                other.isGrandPrize == isGrandPrize) &&
            (identical(other.product, product) || other.product == product));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, position, sequence, isGrandPrize, product);

  /// Create a copy of GameProductItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GameProductItemImplCopyWith<_$GameProductItemImpl> get copyWith =>
      __$$GameProductItemImplCopyWithImpl<_$GameProductItemImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$GameProductItemImplToJson(this);
  }
}

abstract class _GameProductItem implements GameProductItem {
  const factory _GameProductItem({
    required final String id,
    final int? position,
    final int? sequence,
    required final bool isGrandPrize,
    required final ProductItem product,
  }) = _$GameProductItemImpl;

  factory _GameProductItem.fromJson(Map<String, dynamic> json) =
      _$GameProductItemImpl.fromJson;

  @override
  String get id;
  @override
  int? get position;
  @override
  int? get sequence;
  @override
  bool get isGrandPrize;
  @override
  ProductItem get product;

  /// Create a copy of GameProductItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GameProductItemImplCopyWith<_$GameProductItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ProductItem _$ProductItemFromJson(Map<String, dynamic> json) {
  return _ProductItem.fromJson(json);
}

/// @nodoc
mixin _$ProductItem {
  String get id => throw _privateConstructorUsedError;
  String get sku => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  String? get defaultImage => throw _privateConstructorUsedError;

  /// Serializes this ProductItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProductItemCopyWith<ProductItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProductItemCopyWith<$Res> {
  factory $ProductItemCopyWith(
    ProductItem value,
    $Res Function(ProductItem) then,
  ) = _$ProductItemCopyWithImpl<$Res, ProductItem>;
  @useResult
  $Res call({
    String id,
    String sku,
    String brand,
    String name,
    String? description,
    String? defaultImage,
  });
}

/// @nodoc
class _$ProductItemCopyWithImpl<$Res, $Val extends ProductItem>
    implements $ProductItemCopyWith<$Res> {
  _$ProductItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = null,
    Object? brand = null,
    Object? name = null,
    Object? description = freezed,
    Object? defaultImage = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sku: null == sku
                ? _value.sku
                : sku // ignore: cast_nullable_to_non_nullable
                      as String,
            brand: null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            description: freezed == description
                ? _value.description
                : description // ignore: cast_nullable_to_non_nullable
                      as String?,
            defaultImage: freezed == defaultImage
                ? _value.defaultImage
                : defaultImage // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProductItemImplCopyWith<$Res>
    implements $ProductItemCopyWith<$Res> {
  factory _$$ProductItemImplCopyWith(
    _$ProductItemImpl value,
    $Res Function(_$ProductItemImpl) then,
  ) = __$$ProductItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String sku,
    String brand,
    String name,
    String? description,
    String? defaultImage,
  });
}

/// @nodoc
class __$$ProductItemImplCopyWithImpl<$Res>
    extends _$ProductItemCopyWithImpl<$Res, _$ProductItemImpl>
    implements _$$ProductItemImplCopyWith<$Res> {
  __$$ProductItemImplCopyWithImpl(
    _$ProductItemImpl _value,
    $Res Function(_$ProductItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sku = null,
    Object? brand = null,
    Object? name = null,
    Object? description = freezed,
    Object? defaultImage = freezed,
  }) {
    return _then(
      _$ProductItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sku: null == sku
            ? _value.sku
            : sku // ignore: cast_nullable_to_non_nullable
                  as String,
        brand: null == brand
            ? _value.brand
            : brand // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        description: freezed == description
            ? _value.description
            : description // ignore: cast_nullable_to_non_nullable
                  as String?,
        defaultImage: freezed == defaultImage
            ? _value.defaultImage
            : defaultImage // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ProductItemImpl implements _ProductItem {
  const _$ProductItemImpl({
    required this.id,
    required this.sku,
    required this.brand,
    required this.name,
    this.description,
    this.defaultImage,
  });

  factory _$ProductItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ProductItemImplFromJson(json);

  @override
  final String id;
  @override
  final String sku;
  @override
  final String brand;
  @override
  final String name;
  @override
  final String? description;
  @override
  final String? defaultImage;

  @override
  String toString() {
    return 'ProductItem(id: $id, sku: $sku, brand: $brand, name: $name, description: $description, defaultImage: $defaultImage)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProductItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sku, sku) || other.sku == sku) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.defaultImage, defaultImage) ||
                other.defaultImage == defaultImage));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, sku, brand, name, description, defaultImage);

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProductItemImplCopyWith<_$ProductItemImpl> get copyWith =>
      __$$ProductItemImplCopyWithImpl<_$ProductItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ProductItemImplToJson(this);
  }
}

abstract class _ProductItem implements ProductItem {
  const factory _ProductItem({
    required final String id,
    required final String sku,
    required final String brand,
    required final String name,
    final String? description,
    final String? defaultImage,
  }) = _$ProductItemImpl;

  factory _ProductItem.fromJson(Map<String, dynamic> json) =
      _$ProductItemImpl.fromJson;

  @override
  String get id;
  @override
  String get sku;
  @override
  String get brand;
  @override
  String get name;
  @override
  String? get description;
  @override
  String? get defaultImage;

  /// Create a copy of ProductItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProductItemImplCopyWith<_$ProductItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

GamesResponse _$GamesResponseFromJson(Map<String, dynamic> json) {
  return _GamesResponse.fromJson(json);
}

/// @nodoc
mixin _$GamesResponse {
  bool get success => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  List<Game> get games => throw _privateConstructorUsedError;

  /// Serializes this GamesResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of GamesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $GamesResponseCopyWith<GamesResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $GamesResponseCopyWith<$Res> {
  factory $GamesResponseCopyWith(
    GamesResponse value,
    $Res Function(GamesResponse) then,
  ) = _$GamesResponseCopyWithImpl<$Res, GamesResponse>;
  @useResult
  $Res call({bool success, String code, String message, List<Game> games});
}

/// @nodoc
class _$GamesResponseCopyWithImpl<$Res, $Val extends GamesResponse>
    implements $GamesResponseCopyWith<$Res> {
  _$GamesResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of GamesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? code = null,
    Object? message = null,
    Object? games = null,
  }) {
    return _then(
      _value.copyWith(
            success: null == success
                ? _value.success
                : success // ignore: cast_nullable_to_non_nullable
                      as bool,
            code: null == code
                ? _value.code
                : code // ignore: cast_nullable_to_non_nullable
                      as String,
            message: null == message
                ? _value.message
                : message // ignore: cast_nullable_to_non_nullable
                      as String,
            games: null == games
                ? _value.games
                : games // ignore: cast_nullable_to_non_nullable
                      as List<Game>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$GamesResponseImplCopyWith<$Res>
    implements $GamesResponseCopyWith<$Res> {
  factory _$$GamesResponseImplCopyWith(
    _$GamesResponseImpl value,
    $Res Function(_$GamesResponseImpl) then,
  ) = __$$GamesResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool success, String code, String message, List<Game> games});
}

/// @nodoc
class __$$GamesResponseImplCopyWithImpl<$Res>
    extends _$GamesResponseCopyWithImpl<$Res, _$GamesResponseImpl>
    implements _$$GamesResponseImplCopyWith<$Res> {
  __$$GamesResponseImplCopyWithImpl(
    _$GamesResponseImpl _value,
    $Res Function(_$GamesResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of GamesResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? code = null,
    Object? message = null,
    Object? games = null,
  }) {
    return _then(
      _$GamesResponseImpl(
        success: null == success
            ? _value.success
            : success // ignore: cast_nullable_to_non_nullable
                  as bool,
        code: null == code
            ? _value.code
            : code // ignore: cast_nullable_to_non_nullable
                  as String,
        message: null == message
            ? _value.message
            : message // ignore: cast_nullable_to_non_nullable
                  as String,
        games: null == games
            ? _value._games
            : games // ignore: cast_nullable_to_non_nullable
                  as List<Game>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$GamesResponseImpl implements _GamesResponse {
  const _$GamesResponseImpl({
    required this.success,
    required this.code,
    required this.message,
    final List<Game> games = const [],
  }) : _games = games;

  factory _$GamesResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$GamesResponseImplFromJson(json);

  @override
  final bool success;
  @override
  final String code;
  @override
  final String message;
  final List<Game> _games;
  @override
  @JsonKey()
  List<Game> get games {
    if (_games is EqualUnmodifiableListView) return _games;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_games);
  }

  @override
  String toString() {
    return 'GamesResponse(success: $success, code: $code, message: $message, games: $games)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$GamesResponseImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.code, code) || other.code == code) &&
            (identical(other.message, message) || other.message == message) &&
            const DeepCollectionEquality().equals(other._games, _games));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    success,
    code,
    message,
    const DeepCollectionEquality().hash(_games),
  );

  /// Create a copy of GamesResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$GamesResponseImplCopyWith<_$GamesResponseImpl> get copyWith =>
      __$$GamesResponseImplCopyWithImpl<_$GamesResponseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$GamesResponseImplToJson(this);
  }
}

abstract class _GamesResponse implements GamesResponse {
  const factory _GamesResponse({
    required final bool success,
    required final String code,
    required final String message,
    final List<Game> games,
  }) = _$GamesResponseImpl;

  factory _GamesResponse.fromJson(Map<String, dynamic> json) =
      _$GamesResponseImpl.fromJson;

  @override
  bool get success;
  @override
  String get code;
  @override
  String get message;
  @override
  List<Game> get games;

  /// Create a copy of GamesResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$GamesResponseImplCopyWith<_$GamesResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
