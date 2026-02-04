// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_transaction_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pendingTransactionNotifierHash() =>
    r'26a54d4911b028855bbdd8ad4bbf92c8e6e99839';

/// 진행 중인 트랜잭션 상태 관리 (keepAlive: 화면 전환 후에도 유지)
///
/// Copied from [PendingTransactionNotifier].
@ProviderFor(PendingTransactionNotifier)
final pendingTransactionNotifierProvider =
    NotifierProvider<PendingTransactionNotifier, PendingTransaction?>.internal(
      PendingTransactionNotifier.new,
      name: r'pendingTransactionNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$pendingTransactionNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$PendingTransactionNotifier = Notifier<PendingTransaction?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
