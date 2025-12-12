// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gamesHash() => r'0eb57c58310189aeaa3dc9f24fd7f471d8e80836';

/// 모든 게임 목록 Provider
///
/// Copied from [games].
@ProviderFor(games)
final gamesProvider = AutoDisposeFutureProvider<List<Game>>.internal(
  games,
  name: r'gamesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$gamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GamesRef = AutoDisposeFutureProviderRef<List<Game>>;
String _$activeGamesHash() => r'4048c6457d3904853ba89dcb7c8a0ac788067f02';

/// 진행중인 게임 목록 Provider
///
/// Copied from [activeGames].
@ProviderFor(activeGames)
final activeGamesProvider = AutoDisposeFutureProvider<List<Game>>.internal(
  activeGames,
  name: r'activeGamesProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeGamesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveGamesRef = AutoDisposeFutureProviderRef<List<Game>>;
String _$gamesByTypeHash() => r'd019b6dd7dccd0269894b06fef636091790d0459';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// 게임 타입별 필터링 Provider
///
/// Copied from [gamesByType].
@ProviderFor(gamesByType)
const gamesByTypeProvider = GamesByTypeFamily();

/// 게임 타입별 필터링 Provider
///
/// Copied from [gamesByType].
class GamesByTypeFamily extends Family<AsyncValue<List<GameRound>>> {
  /// 게임 타입별 필터링 Provider
  ///
  /// Copied from [gamesByType].
  const GamesByTypeFamily();

  /// 게임 타입별 필터링 Provider
  ///
  /// Copied from [gamesByType].
  GamesByTypeProvider call(GameType gameType) {
    return GamesByTypeProvider(gameType);
  }

  @override
  GamesByTypeProvider getProviderOverride(
    covariant GamesByTypeProvider provider,
  ) {
    return call(provider.gameType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gamesByTypeProvider';
}

/// 게임 타입별 필터링 Provider
///
/// Copied from [gamesByType].
class GamesByTypeProvider extends AutoDisposeFutureProvider<List<GameRound>> {
  /// 게임 타입별 필터링 Provider
  ///
  /// Copied from [gamesByType].
  GamesByTypeProvider(GameType gameType)
    : this._internal(
        (ref) => gamesByType(ref as GamesByTypeRef, gameType),
        from: gamesByTypeProvider,
        name: r'gamesByTypeProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gamesByTypeHash,
        dependencies: GamesByTypeFamily._dependencies,
        allTransitiveDependencies: GamesByTypeFamily._allTransitiveDependencies,
        gameType: gameType,
      );

  GamesByTypeProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameType,
  }) : super.internal();

  final GameType gameType;

  @override
  Override overrideWith(
    FutureOr<List<GameRound>> Function(GamesByTypeRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GamesByTypeProvider._internal(
        (ref) => create(ref as GamesByTypeRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameType: gameType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GameRound>> createElement() {
    return _GamesByTypeProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GamesByTypeProvider && other.gameType == gameType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GamesByTypeRef on AutoDisposeFutureProviderRef<List<GameRound>> {
  /// The parameter `gameType` of this provider.
  GameType get gameType;
}

class _GamesByTypeProviderElement
    extends AutoDisposeFutureProviderElement<List<GameRound>>
    with GamesByTypeRef {
  _GamesByTypeProviderElement(super.provider);

  @override
  GameType get gameType => (origin as GamesByTypeProvider).gameType;
}

String _$gameHash() => r'0d45ff37252a2bd0d3be7f118f8e38728102884c';

/// 특정 게임 상세 조회 Provider
///
/// Copied from [game].
@ProviderFor(game)
const gameProvider = GameFamily();

/// 특정 게임 상세 조회 Provider
///
/// Copied from [game].
class GameFamily extends Family<AsyncValue<Game?>> {
  /// 특정 게임 상세 조회 Provider
  ///
  /// Copied from [game].
  const GameFamily();

  /// 특정 게임 상세 조회 Provider
  ///
  /// Copied from [game].
  GameProvider call(String gameId) {
    return GameProvider(gameId);
  }

  @override
  GameProvider getProviderOverride(covariant GameProvider provider) {
    return call(provider.gameId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameProvider';
}

/// 특정 게임 상세 조회 Provider
///
/// Copied from [game].
class GameProvider extends AutoDisposeFutureProvider<Game?> {
  /// 특정 게임 상세 조회 Provider
  ///
  /// Copied from [game].
  GameProvider(String gameId)
    : this._internal(
        (ref) => game(ref as GameRef, gameId),
        from: gameProvider,
        name: r'gameProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameHash,
        dependencies: GameFamily._dependencies,
        allTransitiveDependencies: GameFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  GameProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameId,
  }) : super.internal();

  final String gameId;

  @override
  Override overrideWith(FutureOr<Game?> Function(GameRef provider) create) {
    return ProviderOverride(
      origin: this,
      override: GameProvider._internal(
        (ref) => create(ref as GameRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameId: gameId,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<Game?> createElement() {
    return _GameProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameProvider && other.gameId == gameId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameRef on AutoDisposeFutureProviderRef<Game?> {
  /// The parameter `gameId` of this provider.
  String get gameId;
}

class _GameProviderElement extends AutoDisposeFutureProviderElement<Game?>
    with GameRef {
  _GameProviderElement(super.provider);

  @override
  String get gameId => (origin as GameProvider).gameId;
}

String _$gamesByCategoryHash() => r'9e761e67dcb933f6536c60c583de1ccf6087b4b9';

/// 카테고리별 게임 필터링 Provider
///
/// Copied from [gamesByCategory].
@ProviderFor(gamesByCategory)
const gamesByCategoryProvider = GamesByCategoryFamily();

/// 카테고리별 게임 필터링 Provider
///
/// Copied from [gamesByCategory].
class GamesByCategoryFamily extends Family<AsyncValue<List<GameRound>>> {
  /// 카테고리별 게임 필터링 Provider
  ///
  /// Copied from [gamesByCategory].
  const GamesByCategoryFamily();

  /// 카테고리별 게임 필터링 Provider
  ///
  /// Copied from [gamesByCategory].
  GamesByCategoryProvider call(GameType gameType, String category) {
    return GamesByCategoryProvider(gameType, category);
  }

  @override
  GamesByCategoryProvider getProviderOverride(
    covariant GamesByCategoryProvider provider,
  ) {
    return call(provider.gameType, provider.category);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gamesByCategoryProvider';
}

/// 카테고리별 게임 필터링 Provider
///
/// Copied from [gamesByCategory].
class GamesByCategoryProvider
    extends AutoDisposeFutureProvider<List<GameRound>> {
  /// 카테고리별 게임 필터링 Provider
  ///
  /// Copied from [gamesByCategory].
  GamesByCategoryProvider(GameType gameType, String category)
    : this._internal(
        (ref) => gamesByCategory(ref as GamesByCategoryRef, gameType, category),
        from: gamesByCategoryProvider,
        name: r'gamesByCategoryProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gamesByCategoryHash,
        dependencies: GamesByCategoryFamily._dependencies,
        allTransitiveDependencies:
            GamesByCategoryFamily._allTransitiveDependencies,
        gameType: gameType,
        category: category,
      );

  GamesByCategoryProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.gameType,
    required this.category,
  }) : super.internal();

  final GameType gameType;
  final String category;

  @override
  Override overrideWith(
    FutureOr<List<GameRound>> Function(GamesByCategoryRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GamesByCategoryProvider._internal(
        (ref) => create(ref as GamesByCategoryRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        gameType: gameType,
        category: category,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<GameRound>> createElement() {
    return _GamesByCategoryProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GamesByCategoryProvider &&
        other.gameType == gameType &&
        other.category == category;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, gameType.hashCode);
    hash = _SystemHash.combine(hash, category.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GamesByCategoryRef on AutoDisposeFutureProviderRef<List<GameRound>> {
  /// The parameter `gameType` of this provider.
  GameType get gameType;

  /// The parameter `category` of this provider.
  String get category;
}

class _GamesByCategoryProviderElement
    extends AutoDisposeFutureProviderElement<List<GameRound>>
    with GamesByCategoryRef {
  _GamesByCategoryProviderElement(super.provider);

  @override
  GameType get gameType => (origin as GamesByCategoryProvider).gameType;
  @override
  String get category => (origin as GamesByCategoryProvider).category;
}

String _$sortedGamesHash() => r'e41fa48315f105e81b6ebc85a4d90c88782d45cb';

/// 게임 정렬 Provider
///
/// Copied from [sortedGames].
@ProviderFor(sortedGames)
const sortedGamesProvider = SortedGamesFamily();

/// 게임 정렬 Provider
///
/// Copied from [sortedGames].
class SortedGamesFamily extends Family<List<GameRound>> {
  /// 게임 정렬 Provider
  ///
  /// Copied from [sortedGames].
  const SortedGamesFamily();

  /// 게임 정렬 Provider
  ///
  /// Copied from [sortedGames].
  SortedGamesProvider call(List<GameRound> games, String sortBy) {
    return SortedGamesProvider(games, sortBy);
  }

  @override
  SortedGamesProvider getProviderOverride(
    covariant SortedGamesProvider provider,
  ) {
    return call(provider.games, provider.sortBy);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'sortedGamesProvider';
}

/// 게임 정렬 Provider
///
/// Copied from [sortedGames].
class SortedGamesProvider extends AutoDisposeProvider<List<GameRound>> {
  /// 게임 정렬 Provider
  ///
  /// Copied from [sortedGames].
  SortedGamesProvider(List<GameRound> games, String sortBy)
    : this._internal(
        (ref) => sortedGames(ref as SortedGamesRef, games, sortBy),
        from: sortedGamesProvider,
        name: r'sortedGamesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$sortedGamesHash,
        dependencies: SortedGamesFamily._dependencies,
        allTransitiveDependencies: SortedGamesFamily._allTransitiveDependencies,
        games: games,
        sortBy: sortBy,
      );

  SortedGamesProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.games,
    required this.sortBy,
  }) : super.internal();

  final List<GameRound> games;
  final String sortBy;

  @override
  Override overrideWith(
    List<GameRound> Function(SortedGamesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: SortedGamesProvider._internal(
        (ref) => create(ref as SortedGamesRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        games: games,
        sortBy: sortBy,
      ),
    );
  }

  @override
  AutoDisposeProviderElement<List<GameRound>> createElement() {
    return _SortedGamesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is SortedGamesProvider &&
        other.games == games &&
        other.sortBy == sortBy;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, games.hashCode);
    hash = _SystemHash.combine(hash, sortBy.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin SortedGamesRef on AutoDisposeProviderRef<List<GameRound>> {
  /// The parameter `games` of this provider.
  List<GameRound> get games;

  /// The parameter `sortBy` of this provider.
  String get sortBy;
}

class _SortedGamesProviderElement
    extends AutoDisposeProviderElement<List<GameRound>>
    with SortedGamesRef {
  _SortedGamesProviderElement(super.provider);

  @override
  List<GameRound> get games => (origin as SortedGamesProvider).games;
  @override
  String get sortBy => (origin as SortedGamesProvider).sortBy;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
