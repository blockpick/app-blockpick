// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'instant_prize_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameInstantPrizesHash() => r'aa2c7824c2e8d2e082fcf7b09526b017b904f083';

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

/// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
///
/// Copied from [gameInstantPrizes].
@ProviderFor(gameInstantPrizes)
const gameInstantPrizesProvider = GameInstantPrizesFamily();

/// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
///
/// Copied from [gameInstantPrizes].
class GameInstantPrizesFamily extends Family<AsyncValue<List<EventTarget>>> {
  /// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
  ///
  /// Copied from [gameInstantPrizes].
  const GameInstantPrizesFamily();

  /// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
  ///
  /// Copied from [gameInstantPrizes].
  GameInstantPrizesProvider call(String gameId) {
    return GameInstantPrizesProvider(gameId);
  }

  @override
  GameInstantPrizesProvider getProviderOverride(
    covariant GameInstantPrizesProvider provider,
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
  String? get name => r'gameInstantPrizesProvider';
}

/// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
///
/// Copied from [gameInstantPrizes].
class GameInstantPrizesProvider
    extends AutoDisposeFutureProvider<List<EventTarget>> {
  /// 게임별 즉석경품 목록 Provider (미수령 경품만 반환)
  ///
  /// Copied from [gameInstantPrizes].
  GameInstantPrizesProvider(String gameId)
    : this._internal(
        (ref) => gameInstantPrizes(ref as GameInstantPrizesRef, gameId),
        from: gameInstantPrizesProvider,
        name: r'gameInstantPrizesProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameInstantPrizesHash,
        dependencies: GameInstantPrizesFamily._dependencies,
        allTransitiveDependencies:
            GameInstantPrizesFamily._allTransitiveDependencies,
        gameId: gameId,
      );

  GameInstantPrizesProvider._internal(
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
    FutureOr<List<EventTarget>> Function(GameInstantPrizesRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: GameInstantPrizesProvider._internal(
        (ref) => create(ref as GameInstantPrizesRef),
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
  AutoDisposeFutureProviderElement<List<EventTarget>> createElement() {
    return _GameInstantPrizesProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameInstantPrizesProvider && other.gameId == gameId;
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
mixin GameInstantPrizesRef on AutoDisposeFutureProviderRef<List<EventTarget>> {
  /// The parameter `gameId` of this provider.
  String get gameId;
}

class _GameInstantPrizesProviderElement
    extends AutoDisposeFutureProviderElement<List<EventTarget>>
    with GameInstantPrizesRef {
  _GameInstantPrizesProviderElement(super.provider);

  @override
  String get gameId => (origin as GameInstantPrizesProvider).gameId;
}

String _$instantPrizeClaimHash() => r'9424868967451d1d5710a90f50fa2e604bcca2d3';

/// 즉석경품 수령 Provider
///
/// Copied from [InstantPrizeClaim].
@ProviderFor(InstantPrizeClaim)
final instantPrizeClaimProvider =
    AutoDisposeNotifierProvider<
      InstantPrizeClaim,
      AsyncValue<ClaimPrizeResult?>
    >.internal(
      InstantPrizeClaim.new,
      name: r'instantPrizeClaimProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$instantPrizeClaimHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$InstantPrizeClaim =
    AutoDisposeNotifier<AsyncValue<ClaimPrizeResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
