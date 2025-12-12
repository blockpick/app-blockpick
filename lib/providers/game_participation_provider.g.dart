// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_participation_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blockchainWalletServiceHash() =>
    r'26479f111f07bcb1f3e1468172754a2dd58d9cf0';

/// 블록체인 지갑 서비스 Provider
///
/// Copied from [blockchainWalletService].
@ProviderFor(blockchainWalletService)
final blockchainWalletServiceProvider =
    AutoDisposeProvider<BlockchainWalletService>.internal(
      blockchainWalletService,
      name: r'blockchainWalletServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$blockchainWalletServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef BlockchainWalletServiceRef =
    AutoDisposeProviderRef<BlockchainWalletService>;
String _$coordinateEncryptionServiceHash() =>
    r'2664df28e5e45ab63128a162ccdade88f7a6f064';

/// 좌표 암호화 서비스 Provider
///
/// Copied from [coordinateEncryptionService].
@ProviderFor(coordinateEncryptionService)
final coordinateEncryptionServiceProvider =
    AutoDisposeProvider<CoordinateEncryptionService>.internal(
      coordinateEncryptionService,
      name: r'coordinateEncryptionServiceProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$coordinateEncryptionServiceHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CoordinateEncryptionServiceRef =
    AutoDisposeProviderRef<CoordinateEncryptionService>;
String _$canJoinGameHash() => r'1129988634a3917a1fbcc3f985c587991d3128ab';

/// 게임 참여 가능 여부 확인
///
/// - 지갑이 있는지 확인
/// - GraphQL 클라이언트 연결 확인
///
/// Copied from [canJoinGame].
@ProviderFor(canJoinGame)
final canJoinGameProvider = AutoDisposeFutureProvider<bool>.internal(
  canJoinGame,
  name: r'canJoinGameProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$canJoinGameHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CanJoinGameRef = AutoDisposeFutureProviderRef<bool>;
String _$userWalletAddressHash() => r'7377a3344e73172846c6476a5f8db33f7ebe7e7c';

/// 사용자 지갑 주소 조회
///
/// Copied from [userWalletAddress].
@ProviderFor(userWalletAddress)
final userWalletAddressProvider = AutoDisposeFutureProvider<String?>.internal(
  userWalletAddress,
  name: r'userWalletAddressProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userWalletAddressHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef UserWalletAddressRef = AutoDisposeFutureProviderRef<String?>;
String _$gameParticipationHash() => r'a030a420b1b251ad36adb5c23c4425c38c4164dd';

/// 게임 참여 통합 서비스 (서버 가스비 대납 방식)
///
/// 문서 참조: docs/게임_참가_프로세스.md
///
/// 전체 프로세스:
/// 0. 게임 정보 조회 (getGame/getGames)
/// 1. 좌표 선택 (UI)
/// 2. 지갑 준비 (SecureStorage/localStorage)
/// 3. 암호화 키 확보 (하이브리드: 온체인 조회 → 서버 생성 → 재조회)
/// 4. 좌표 암호화 (로컬)
/// 5. joinGame Mutation 호출
/// 6. 초기 응답 처리
/// 7. 상태 폴링 (EntryStatusPollingService)
///
/// Copied from [GameParticipation].
@ProviderFor(GameParticipation)
final gameParticipationProvider =
    AutoDisposeAsyncNotifierProvider<
      GameParticipation,
      GameJoinResult?
    >.internal(
      GameParticipation.new,
      name: r'gameParticipationProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$gameParticipationHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$GameParticipation = AutoDisposeAsyncNotifier<GameJoinResult?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
