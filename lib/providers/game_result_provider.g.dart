// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_result_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameResultsHash() => r'9b441be9149fd162ff76b6699d83399203dbec0d';

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

/// 게임 결과 목록 Provider (참가자 + 결과 병합)
///
/// Copied from [gameResults].
@ProviderFor(gameResults)
const gameResultsProvider = GameResultsFamily();

/// 게임 결과 목록 Provider (참가자 + 결과 병합)
///
/// Copied from [gameResults].
class GameResultsFamily extends Family<AsyncValue<List<GameResultItem>>> {
  /// 게임 결과 목록 Provider (참가자 + 결과 병합)
  ///
  /// Copied from [gameResults].
  const GameResultsFamily();

  /// 게임 결과 목록 Provider (참가자 + 결과 병합)
  ///
  /// Copied from [gameResults].
  GameResultsProvider call(String gameId) {
    return GameResultsProvider(gameId);
  }

  @override
  GameResultsProvider getProviderOverride(
    covariant GameResultsProvider provider,
  ) {
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
  String? get name => r'gameResultsProvider';
}

/// 게임 결과 목록 Provider (참가자 + 결과 병합)
///
/// Copied from [gameResults].
class GameResultsProvider
    extends AutoDisposeFutureProvider<List<GameResultItem>> {
  /// 게임 결과 목록 Provider (참가자 + 결과 병합)
  ///
  /// Copied from [gameResults].
  GameResultsProvider(String gameId)
    : this._internal(
        (ref) => gameResults(ref as GameResultsRef, gameId),
        from: gameResultsProvider,
        name: r'gameResultsProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameResultsHash,
        dependencies: GameResultsFamily._dependencies,
        allTransitiveDependencies: GameResultsFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  GameResultsProvider._internal(
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
  Override overrideWith(
    FutureOr<List<GameResultItem>> Function(GameResultsRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameResultsProvider._internal(
        (ref) => create(ref as GameResultsRef),
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
  AutoDisposeFutureProviderElement<List<GameResultItem>> createElement() {
    return _GameResultsProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameResultsProvider && other.gameId == gameId;
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
mixin GameResultsRef on AutoDisposeFutureProviderRef<List<GameResultItem>> {
  /// The parameter `gameId` of this provider.
  String get gameId;
}

class _GameResultsProviderElement
    extends AutoDisposeFutureProviderElement<List<GameResultItem>>
    with GameResultsRef {
  _GameResultsProviderElement(super.provider);

  @override
  String get gameId => (origin as GameResultsProvider).gameId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
