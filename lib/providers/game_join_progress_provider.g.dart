// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_join_progress_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameJoinProgressNotifierHash() =>
    r'3a6f8b340398484775b06f301060a2a48d62b9fc';

/// 게임 참여 진행 상태 관리
///
/// Copied from [GameJoinProgressNotifier].
@ProviderFor(GameJoinProgressNotifier)
final gameJoinProgressNotifierProvider =
    AutoDisposeNotifierProvider<
      GameJoinProgressNotifier,
      GameJoinProgress?
    >.internal(
      GameJoinProgressNotifier.new,
      name: r'gameJoinProgressNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameJoinProgressNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameJoinProgressNotifier = AutoDisposeNotifier<GameJoinProgress?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
