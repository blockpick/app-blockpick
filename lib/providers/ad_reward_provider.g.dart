// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ad_reward_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$adMobServiceHash() => r'ab79f8c17627b3d8c8c95c7465e38f86845bd0f4';

/// AdMob 서비스 Provider
///
/// Copied from [adMobService].
@ProviderFor(adMobService)
final adMobServiceProvider = AutoDisposeProvider<AdMobService>.internal(
  adMobService,
  name: r'adMobServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$adMobServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdMobServiceRef = AutoDisposeProviderRef<AdMobService>;
String _$adRewardServiceHash() => r'eddaf54d527ce83f576a84ef6f5ebe5ea6d824da';

/// 광고 보상 서비스 Provider
///
/// Copied from [adRewardService].
@ProviderFor(adRewardService)
final adRewardServiceProvider =
    AutoDisposeFutureProvider<AdRewardService>.internal(
      adRewardService,
      name: r'adRewardServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adRewardServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AdRewardServiceRef = AutoDisposeFutureProviderRef<AdRewardService>;
String _$adRewardPolicyHash() => r'78b9abacf326c74f2f4fdaa53c8377d21a9c12ef';

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

/// 광고 보상 정책 조회 Provider
///
/// Copied from [adRewardPolicy].
@ProviderFor(adRewardPolicy)
const adRewardPolicyProvider = AdRewardPolicyFamily();

/// 광고 보상 정책 조회 Provider
///
/// Copied from [adRewardPolicy].
class AdRewardPolicyFamily extends Family<AsyncValue<AdRewardPolicy?>> {
  /// 광고 보상 정책 조회 Provider
  ///
  /// Copied from [adRewardPolicy].
  const AdRewardPolicyFamily();

  /// 광고 보상 정책 조회 Provider
  ///
  /// Copied from [adRewardPolicy].
  AdRewardPolicyProvider call(AdContextType contextType) {
    return AdRewardPolicyProvider(contextType);
  }

  @override
  AdRewardPolicyProvider getProviderOverride(
    covariant AdRewardPolicyProvider provider,
  ) {
    return call(provider.contextType);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'adRewardPolicyProvider';
}

/// 광고 보상 정책 조회 Provider
///
/// Copied from [adRewardPolicy].
class AdRewardPolicyProvider
    extends AutoDisposeFutureProvider<AdRewardPolicy?> {
  /// 광고 보상 정책 조회 Provider
  ///
  /// Copied from [adRewardPolicy].
  AdRewardPolicyProvider(AdContextType contextType)
    : this._internal(
        (ref) => adRewardPolicy(ref as AdRewardPolicyRef, contextType),
        from: adRewardPolicyProvider,
        name: r'adRewardPolicyProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$adRewardPolicyHash,
        dependencies: AdRewardPolicyFamily._dependencies,
        allTransitiveDependencies:
            AdRewardPolicyFamily._allTransitiveDependencies,
        contextType: contextType,
      );

  AdRewardPolicyProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.contextType,
  }) : super.internal();

  final AdContextType contextType;

  @override
  Override overrideWith(
    FutureOr<AdRewardPolicy?> Function(AdRewardPolicyRef provider) create,
  ) {
    return ProviderOverride(
      origin: this,
      override: AdRewardPolicyProvider._internal(
        (ref) => create(ref as AdRewardPolicyRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        contextType: contextType,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<AdRewardPolicy?> createElement() {
    return _AdRewardPolicyProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is AdRewardPolicyProvider && other.contextType == contextType;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, contextType.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin AdRewardPolicyRef on AutoDisposeFutureProviderRef<AdRewardPolicy?> {
  /// The parameter `contextType` of this provider.
  AdContextType get contextType;
}

class _AdRewardPolicyProviderElement
    extends AutoDisposeFutureProviderElement<AdRewardPolicy?>
    with AdRewardPolicyRef {
  _AdRewardPolicyProviderElement(super.provider);

  @override
  AdContextType get contextType =>
      (origin as AdRewardPolicyProvider).contextType;
}

String _$adLoadStateHash() => r'ece739161c603a2874b11762b010b84b07a47ec7';

/// 광고 로드 상태
///
/// Copied from [AdLoadState].
@ProviderFor(AdLoadState)
final adLoadStateProvider =
    AutoDisposeNotifierProvider<AdLoadState, bool>.internal(
      AdLoadState.new,
      name: r'adLoadStateProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adLoadStateHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdLoadState = AutoDisposeNotifier<bool>;
String _$adRewardNotifierHash() => r'e9e3bbdaa85ff3a0a76a9b70fd09f6113511a8da';

/// 광고 보상 상태 Provider
///
/// Copied from [AdRewardNotifier].
@ProviderFor(AdRewardNotifier)
final adRewardNotifierProvider =
    AutoDisposeNotifierProvider<AdRewardNotifier, AdRewardState>.internal(
      AdRewardNotifier.new,
      name: r'adRewardNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$adRewardNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$AdRewardNotifier = AutoDisposeNotifier<AdRewardState>;
String _$myAdRewardLedgersHash() => r'd9fccfc6020412bb4f80083f1a34303514eed737';

abstract class _$MyAdRewardLedgers
    extends BuildlessAutoDisposeAsyncNotifier<AdRewardLedgerPage> {
  late final int page;
  late final int size;

  FutureOr<AdRewardLedgerPage> build({int page = 0, int size = 20});
}

/// 내 광고 보상 기록 Provider
///
/// Copied from [MyAdRewardLedgers].
@ProviderFor(MyAdRewardLedgers)
const myAdRewardLedgersProvider = MyAdRewardLedgersFamily();

/// 내 광고 보상 기록 Provider
///
/// Copied from [MyAdRewardLedgers].
class MyAdRewardLedgersFamily extends Family<AsyncValue<AdRewardLedgerPage>> {
  /// 내 광고 보상 기록 Provider
  ///
  /// Copied from [MyAdRewardLedgers].
  const MyAdRewardLedgersFamily();

  /// 내 광고 보상 기록 Provider
  ///
  /// Copied from [MyAdRewardLedgers].
  MyAdRewardLedgersProvider call({int page = 0, int size = 20}) {
    return MyAdRewardLedgersProvider(page: page, size: size);
  }

  @override
  MyAdRewardLedgersProvider getProviderOverride(
    covariant MyAdRewardLedgersProvider provider,
  ) {
    return call(page: provider.page, size: provider.size);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'myAdRewardLedgersProvider';
}

/// 내 광고 보상 기록 Provider
///
/// Copied from [MyAdRewardLedgers].
class MyAdRewardLedgersProvider
    extends
        AutoDisposeAsyncNotifierProviderImpl<
          MyAdRewardLedgers,
          AdRewardLedgerPage
        > {
  /// 내 광고 보상 기록 Provider
  ///
  /// Copied from [MyAdRewardLedgers].
  MyAdRewardLedgersProvider({int page = 0, int size = 20})
    : this._internal(
        () => MyAdRewardLedgers()
          ..page = page
          ..size = size,
        from: myAdRewardLedgersProvider,
        name: r'myAdRewardLedgersProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$myAdRewardLedgersHash,
        dependencies: MyAdRewardLedgersFamily._dependencies,
        allTransitiveDependencies:
            MyAdRewardLedgersFamily._allTransitiveDependencies,
        page: page,
        size: size,
      );

  MyAdRewardLedgersProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.page,
    required this.size,
  }) : super.internal();

  final int page;
  final int size;

  @override
  FutureOr<AdRewardLedgerPage> runNotifierBuild(
    covariant MyAdRewardLedgers notifier,
  ) {
    return notifier.build(page: page, size: size);
  }

  @override
  Override overrideWith(MyAdRewardLedgers Function() create) {
    return ProviderOverride(
      origin: this,
      override: MyAdRewardLedgersProvider._internal(
        () => create()
          ..page = page
          ..size = size,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        page: page,
        size: size,
      ),
    );
  }

  @override
  AutoDisposeAsyncNotifierProviderElement<MyAdRewardLedgers, AdRewardLedgerPage>
  createElement() {
    return _MyAdRewardLedgersProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is MyAdRewardLedgersProvider &&
        other.page == page &&
        other.size == size;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, page.hashCode);
    hash = _SystemHash.combine(hash, size.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin MyAdRewardLedgersRef
    on AutoDisposeAsyncNotifierProviderRef<AdRewardLedgerPage> {
  /// The parameter `page` of this provider.
  int get page;

  /// The parameter `size` of this provider.
  int get size;
}

class _MyAdRewardLedgersProviderElement
    extends
        AutoDisposeAsyncNotifierProviderElement<
          MyAdRewardLedgers,
          AdRewardLedgerPage
        >
    with MyAdRewardLedgersRef {
  _MyAdRewardLedgersProviderElement(super.provider);

  @override
  int get page => (origin as MyAdRewardLedgersProvider).page;
  @override
  int get size => (origin as MyAdRewardLedgersProvider).size;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
