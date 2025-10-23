// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'platform_mode_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$platformModeNotifierHash() =>
    r'fcf7735c570a070e6781d5f65ac676743f8bc6b6';

/// 현재 선택된 플랫폼 모드 상태 관리
///
/// Copied from [PlatformModeNotifier].
@ProviderFor(PlatformModeNotifier)
final platformModeNotifierProvider =
    AutoDisposeNotifierProvider<PlatformModeNotifier, PlatformMode>.internal(
      PlatformModeNotifier.new,
      name: r'platformModeNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$platformModeNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PlatformModeNotifier = AutoDisposeNotifier<PlatformMode>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
