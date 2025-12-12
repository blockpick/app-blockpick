import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/graphql/graphql_client.dart';
import '../services/blockchain_wallet_service.dart';
import '../services/coordinate_encryption_service.dart';
import '../services/smart_contract_service.dart';
import '../services/entry_status_polling_service.dart';
import '../services/encryption_key_polling_service.dart';
import '../models/entry_status.dart';
import '../features/game/widgets/game_join_progress_overlay.dart';
import 'game_join_progress_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../core/auth/domain/providers/auth_provider.dart';

part 'game_participation_provider.g.dart';

/// requestEncryptionKey Mutation (서버 가스비 대납 방식)
///
/// 문서 참조: docs/게임_참가_프로세스.md
/// - 현재는 폴링 없이 즉시 응답 처리
/// - 향후 requestId를 받으면 EncryptionKeyPollingService 사용 가능
const String _requestEncryptionKeyMutation = r'''
  mutation RequestEncryptionKey($input: RequestEncryptionKeyInput!) {
    requestEncryptionKey(input: $input) {
      success
      code
      message
      encryptionKey
      contractAddress
      txHash
      userAddress
      index
    }
  }
''';

/// joinGame Mutation
const String _joinGameMutation = r'''
  mutation JoinGame($input: JoinGameInput!) {
    joinGame(input: $input) {
      success
      code
      message
      entryId
      status
      txHash
      errorCode
    }
  }
''';

/// 게임 참여 결과
class GameJoinResult {
  final bool success;
  final String message;
  final String? entryId;
  final String? status;
  final String? txHash;
  final String? errorCode;

  GameJoinResult({
    required this.success,
    required this.message,
    this.entryId,
    this.status,
    this.txHash,
    this.errorCode,
  });

  factory GameJoinResult.fromJson(Map<String, dynamic> json) {
    return GameJoinResult(
      success: json['success'] as bool,
      message: json['message'] as String,
      entryId: json['entryId'] as String?,
      status: json['status'] as String?,
      txHash: json['txHash'] as String?,
      errorCode: json['errorCode'] as String?,
    );
  }
}

/// 블록체인 지갑 서비스 Provider
@riverpod
BlockchainWalletService blockchainWalletService(Ref ref) {
  return BlockchainWalletService();
}

/// 좌표 암호화 서비스 Provider
@riverpod
CoordinateEncryptionService coordinateEncryptionService(Ref ref) {
  return CoordinateEncryptionService();
}

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
@riverpod
class GameParticipation extends _$GameParticipation {
  @override
  FutureOr<GameJoinResult?> build() {
    return null;
  }

  /// 게임 참여하기 (전체 프로세스)
  ///
  /// [gameId]: 게임 ID
  /// [selectedGameProductId]: 선택한 게임 상품 ID
  /// [row]: 선택한 행 좌표
  /// [col]: 선택한 열 좌표
  /// [contractAddress]: 게임의 스마트 컨트랙트 주소
  Future<GameJoinResult> joinGame({
    required String gameId,
    required String selectedGameProductId,
    required int row,
    required int col,
    required String contractAddress,
  }) async {
    try {
      final startTime = DateTime.now();
      print('');
      print('╔═══════════════════════════════════════════════════════════════════════════╗');
      print('║  🎮 게임 참여 프로세스 시작                                                ║');
      print('║  ⏰ ${startTime.toIso8601String()}                                        ║');
      print('╚═══════════════════════════════════════════════════════════════════════════╝');
      print('');
      print('┌─────────────────────────────────────────────────────────────────────────────┐');
      print('│ 📋 [1/7] 입력 파라미터 확인                                                 │');
      print('├─────────────────────────────────────────────────────────────────────────────┤');
      print('│ • 게임 ID: $gameId');
      print('│ • 상품 ID: $selectedGameProductId');
      print('│ • 선택 좌표: row=$row, col=$col');
      print('│ • 컨트랙트 주소: $contractAddress');
      print('│');
      print('│ 🔗 PolygonScan 컨트랙트 확인:');
      print('│    https://amoy.polygonscan.com/address/$contractAddress');
      print('└─────────────────────────────────────────────────────────────────────────────┘');
      print('');

      // 2. 지갑 준비 (문서: docs/게임_참가_프로세스.md 4.1 단계 2)
      print('┌─────────────────────────────────────────────────────────────────────────────┐');
      print('│ 🔐 [2/7] 지갑 준비                                                          │');
      print('├─────────────────────────────────────────────────────────────────────────────┤');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.walletCheck,
        message: '블록체인 지갑을 확인하고 있습니다...',
      );

      final walletService = ref.read(blockchainWalletServiceProvider);

      final credentials = await walletService.getOrCreateWallet();
      final walletAddress = credentials.address.hex;

      print('│ ✅ 지갑 준비 완료');
      print('│ • 지갑 주소: $walletAddress');
      print('│');
      print('│ 🔗 PolygonScan 지갑 확인:');
      print('│    https://amoy.polygonscan.com/address/$walletAddress');
      print('└─────────────────────────────────────────────────────────────────────────────┘');
      print('');

      // 3. 암호화 키 확보 (하이브리드 전략) (문서: docs/게임_참가_프로세스.md 3.2)
      print('┌─────────────────────────────────────────────────────────────────────────────┐');
      print('│ 🔑 [3/7] 암호화 키 확보 (하이브리드 전략)                                    │');
      print('├─────────────────────────────────────────────────────────────────────────────┤');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.encryptionKey,
        message: '암호화 키를 생성하고 있습니다...',
      );

      // userIndex 생성: (userId + gameId)의 SHA256 해시 (백엔드와 동일한 방식)
      // 쉘 스크립트: USER_INDEX=$(echo -n "${USER_ID}${GAME_ID}" | shasum -a 256 | awk '{print $1}')
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null || currentUser.id == null) {
        throw Exception('로그인이 필요합니다. 사용자 정보를 찾을 수 없습니다.');
      }
      final userId = currentUser.id!;
      final userIndexSource = '$userId$gameId';  // userId + gameId 결합
      final userIndexBytes = utf8.encode(userIndexSource);
      final userIndex = sha256.convert(userIndexBytes).toString();
      print('│ ✅ UserIndex 생성 완료');
      print('│ • userId: $userId');
      print('│ • gameId: $gameId');
      print('│ • userIndex 원본: SHA256("$userId$gameId")');
      print('│ • userIndex (SHA256): $userIndex');
      print('│ • 형식: SHA256(userId + gameId) - 64자 hex');
      print('│');

      final contractService = SmartContractService();
      String encryptionKey;

      // 하이브리드 암호화 키 전략 (문서: docs/게임_참가_프로세스.md 3.2)
      // Step 1: 온체인 View 조회 (가스비 없음)
      print('│ ─────────────────────────────────────────────────────────────────────────');
      print('│ 📡 [Step 3-1] 온체인 View 조회: getEncryptionKey()');
      print('│ ─────────────────────────────────────────────────────────────────────────');
      print('│ • RPC: https://rpc-amoy.polygon.technology/');
      print('│ • 컨트랙트: $contractAddress');
      print('│ • userIndex: $userIndex');
      print('│ • userAddress: $walletAddress');
      print('│ • 목적: 기존 키 재사용 (가스비 절약)');
      print('│');
      print('│ 🔗 PolygonScan Read Contract에서 직접 확인:');
      print('│    https://amoy.polygonscan.com/address/$contractAddress#readContract');
      print('│    → getEncryptionKey(_index: "$userIndex", _owner: "$walletAddress")');
      print('│');

      try {
        encryptionKey = await contractService.getEncryptionKey(
          contractAddress: contractAddress,
          userIndex: userIndex,
          userAddress: walletAddress,
        );

        print('│ ✅ [Step 3-1 성공] 기존 키 발견! 재사용 (가스비 절약)');
        print('│ • 암호화 키: $encryptionKey');
        print('│ • 키 길이: ${encryptionKey.length} 문자');
        print('│ ℹ️  서버 호출 없이 즉시 사용 가능');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        print('');
      } catch (e) {
        // Step 2: 서버 가스 대납 생성 (문서: docs/게임_참가_프로세스.md 3.2)
        print('│ ❌ [Step 3-1 실패] 기존 키 없음');
        print('│ • 에러: $e');
        print('│');
        print('│ ─────────────────────────────────────────────────────────────────────────');
        print('│ 📤 [Step 3-2] 서버 가스 대납 생성: requestEncryptionKey Mutation');
        print('│ ─────────────────────────────────────────────────────────────────────────');
        print('│ • 서버가 블록체인 트랜잭션 실행 및 가스비 지불');
        print('│');

        final client = await ref.read(graphqlClientProvider.future);

        print('│ 📤 Mutation 요청 파라미터:');
        print('│    • gameId: $gameId');
        print('│    • userAddress: $walletAddress');
        print('│    • index: $userIndex');
        print('│');

        final keyResult = await client.mutate(
          MutationOptions(
            document: gql(_requestEncryptionKeyMutation),
            variables: {
              'input': {
                'gameId': gameId,
                'userAddress': walletAddress,
                'index': userIndex,
              },
            },
            fetchPolicy: FetchPolicy.noCache, // 캐시 에러 방지
          ),
        );

        if (keyResult.hasException) {
          print('│ ❌ requestEncryptionKey Mutation 에러');
          print('│    ${keyResult.exception}');
          print('└─────────────────────────────────────────────────────────────────────────────┘');
          // 문서 8장: 실패 시 즉시 에러 처리 (폴링 없음)
          throw Exception('암호화 키 생성 실패: ${keyResult.exception}');
        }

        final keyData = keyResult.data?['requestEncryptionKey'];
        if (keyData == null) {
          print('│ ❌ 암호화 키 응답 데이터 없음');
          print('└─────────────────────────────────────────────────────────────────────────────┘');
          throw Exception('암호화 키를 받지 못했습니다');
        }

        if (keyData['success'] != true) {
          print('│ ❌ 암호화 키 생성 실패');
          print('│    • Code: ${keyData['code']}');
          print('│    • Message: ${keyData['message']}');
          print('└─────────────────────────────────────────────────────────────────────────────┘');
          // 문서 8장: KEY_REQUEST_PROCESSING_FAILED 등 실패 케이스 처리
          throw Exception(keyData['message'] ?? '암호화 키 생성 실패');
        }

        final blockchainTxHash = keyData['txHash'] as String?;
        final contractAddr = keyData['contractAddress'] as String?;
        final serverEncryptionKey = keyData['encryptionKey'] as String?;
        final serverIndex = keyData['index'] as String?;
        final serverUserAddress = keyData['userAddress'] as String?;

        print('│');
        print('│ 📥 서버 응답:');
        print('│    • success: ${keyData['success']}');
        print('│    • code: ${keyData['code']}');
        print('│    • message: ${keyData['message']}');
        print('│    • encryptionKey: ${serverEncryptionKey ?? "null (서버가 키를 반환하지 않음)"}');
        print('│    • contractAddress: $contractAddr');
        print('│    • txHash: $blockchainTxHash');
        print('│    • userAddress: $serverUserAddress');
        print('│    • index: $serverIndex');
        print('│');

        // txHash 형식 검증
        if (blockchainTxHash != null) {
          final isValidTxHash = blockchainTxHash.startsWith('0x') && blockchainTxHash.length == 66;
          if (isValidTxHash) {
            print('│ ✅ txHash 형식 검증: 정상 (블록체인 트랜잭션 해시)');
            print('│ 🔗 PolygonScan TX 확인:');
            print('│    https://amoy.polygonscan.com/tx/$blockchainTxHash');
          } else {
            print('│ ⚠️  txHash 형식 검증: 비정상!');
            print('│    • 예상 형식: 0x + 64자 hex (총 66자)');
            print('│    • 실제 값: $blockchainTxHash (${blockchainTxHash.length}자)');
            print('│    • 판단: 내부 요청 ID로 보임 (실제 블록체인 TX 아님)');
            print('│    ⚠️  백엔드가 실제 블록체인 트랜잭션을 전송하지 않았을 수 있음!');
          }
        }
        print('│');

        // Step 3: 후속 조회 (SQS 비동기 처리 방식)
        // 서버는 항상 encryptionKey: null 반환 → encryptionKeyStatus 폴링 → 스마트 컨트랙트 조회
        // 참고: docs/FRONTEND_ENCRYPTION_KEY_TEST_RESULT.md
        if (keyData['encryptionKey'] != null && keyData['encryptionKey'] != '') {
          // 드물게 서버가 키를 직접 반환하는 경우 (레거시 호환)
          encryptionKey = keyData['encryptionKey'] as String;
          print('│ ✅ [Step 3-2 성공] 서버 응답에서 키 수신 완료 (레거시 방식)');
          print('│ • 암호화 키: $encryptionKey');
          print('│ • 키 길이: ${encryptionKey.length} 문자');
          print('└─────────────────────────────────────────────────────────────────────────────┘');
          print('');
        } else {
          // SQS 비동기 처리 방식 (현재 표준)
          // txHash는 실제 블록체인 TX가 아니라 서버 내부 요청 ID (UUID)
          final requestId = blockchainTxHash;

          if (requestId == null || requestId.isEmpty) {
            throw Exception('암호화 키 요청 ID를 받지 못했습니다');
          }

          print('│');
          print('│ ─────────────────────────────────────────────────────────────────────────');
          print('│ 🔄 [Step 3-3] encryptionKeyStatus 폴링 (SQS 비동기 처리)');
          print('│ ─────────────────────────────────────────────────────────────────────────');
          print('│ • 서버 응답에 encryptionKey가 null → SQS 워커 처리 대기');
          print('│ • 요청 ID (UUID): $requestId');
          print('│ • 폴링 설정: 최대 60회, 간격 2초 (총 2분)');
          print('│');

          // UI 상태 업데이트
          ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
            step: GameJoinStep.encryptionKey,
            message: '블록체인 트랜잭션 처리 대기 중...',
          );

          // encryptionKeyStatus 폴링
          final pollingService = EncryptionKeyPollingService(client: client);

          try {
            await for (final status in pollingService.pollEncryptionKeyStatus(
              requestId,
              interval: const Duration(seconds: 2),
              maxAttempts: 60, // 2분 타임아웃
            )) {
              print('│ 🔄 상태: ${status.status}');
              if (status.txHash != null) {
                print('│    TX Hash: ${status.txHash}');
                print('│    🔗 https://amoy.polygonscan.com/tx/${status.txHash}');
              }

              // UI 상태 업데이트
              ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
                step: GameJoinStep.encryptionKey,
                message: '블록체인 트랜잭션 ${status.status}...',
              );

              if (status.isCompleted) {
                print('│ ✅ 블록체인 트랜잭션 완료!');
                break;
              }
            }
          } catch (pollingError) {
            print('│ ❌ encryptionKeyStatus 폴링 실패: $pollingError');
            print('│');
            print('│ ⚠️  SQS 워커 문제 가능성:');
            print('│    1. SQS 워커가 작동하지 않음');
            print('│    2. 서버 지갑에 가스비(POL)가 부족');
            print('│    3. 네트워크 문제');
            print('└─────────────────────────────────────────────────────────────────────────────┘');
            throw Exception('암호화 키 생성 실패: $pollingError');
          }

          print('│');
          print('│ ─────────────────────────────────────────────────────────────────────────');
          print('│ 📡 [Step 3-4] 스마트 컨트랙트에서 암호화 키 조회');
          print('│ ─────────────────────────────────────────────────────────────────────────');
          print('│ • 블록체인 트랜잭션 완료 → 온체인에서 키 조회');
          print('│ • 조회 파라미터:');
          print('│    - contractAddress: ${contractAddr ?? contractAddress}');
          print('│    - userIndex: $userIndex');
          print('│    - userAddress: $walletAddress');
          print('│');

          // UI 상태 업데이트
          ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
            step: GameJoinStep.encryptionKey,
            message: '스마트 컨트랙트에서 암호화 키 조회 중...',
          );

          // 스마트 컨트랙트에서 키 조회 (몇 번 재시도)
          const maxKeyAttempts = 5;
          const keyPollInterval = Duration(seconds: 2);
          String? polledKey;

          for (int attempts = 1; attempts <= maxKeyAttempts; attempts++) {
            try {
              polledKey = await contractService.getEncryptionKey(
                contractAddress: contractAddr ?? contractAddress,
                userIndex: userIndex,
                userAddress: walletAddress,
              );

              if (polledKey.isNotEmpty) {
                print('│ ✅ 키 조회 성공! (시도 $attempts/$maxKeyAttempts)');
                break;
              }
            } catch (e) {
              print('│ ⏳ 키 조회 시도 $attempts/$maxKeyAttempts: $e');
              if (attempts < maxKeyAttempts) {
                await Future.delayed(keyPollInterval);
              }
            }
          }

          if (polledKey == null || polledKey.isEmpty) {
            print('│ ❌ 스마트 컨트랙트에서 키를 조회할 수 없습니다');
            print('│');
            print('│ 🔗 PolygonScan에서 컨트랙트 확인:');
            print('│    https://amoy.polygonscan.com/address/${contractAddr ?? contractAddress}#readContract');
            print('└─────────────────────────────────────────────────────────────────────────────┘');
            throw Exception('스마트 컨트랙트에서 암호화 키를 조회할 수 없습니다');
          }

          encryptionKey = polledKey;
          print('│');
          print('│ ✅ [Step 3-4 성공] 스마트 컨트랙트 키 조회 완료!');
          print('│ • 암호화 키: $encryptionKey');
          print('│ • 키 길이: ${encryptionKey.length} 문자');
          print('└─────────────────────────────────────────────────────────────────────────────┘');
          print('');
        }
      }

      // 4. 좌표 암호화 (문서: docs/게임_참가_프로세스.md 4.1 단계 4)
      print('┌─────────────────────────────────────────────────────────────────────────────┐');
      print('│ 🔒 [4/7] 좌표 암호화                                                         │');
      print('├─────────────────────────────────────────────────────────────────────────────┤');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.coordinateEncryption,
        message: '선택한 좌표를 암호화하고 있습니다...',
      );

      final encryptionService = ref.read(coordinateEncryptionServiceProvider);

      print('│ • 입력 좌표: row=$row, col=$col');
      print('│ • 암호화 키: $encryptionKey');
      print('│ • 키 길이: ${encryptionKey.length} 문자');
      print('│');

      String coordCiphertext;
      try {
        coordCiphertext = encryptionService.encryptCoordinate(
          row: row,
          col: col,
          encryptionKeyHex: encryptionKey,
        );
        print('│ ✅ 좌표 암호화 완료');
        print('│ • 암호문: $coordCiphertext');
        print('│ • 암호문 길이: ${coordCiphertext.length} 문자');
      } catch (encryptError) {
        print('│ ❌ 좌표 암호화 실패: $encryptError');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        throw Exception('좌표 암호화 중 오류 발생: $encryptError');
      }
      print('└─────────────────────────────────────────────────────────────────────────────┘');
      print('');

      // 5. joinGame Mutation 호출 준비: 지갑 주소 해시화 (문서: docs/게임_참가_프로세스.md 5.2)
      print('┌─────────────────────────────────────────────────────────────────────────────┐');
      print('│ 📤 [5/7] joinGame Mutation 전송                                              │');
      print('├─────────────────────────────────────────────────────────────────────────────┤');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.walletHashing,
        message: '지갑 주소를 해시화하고 있습니다...',
      );

      final walletBytes = utf8.encode(walletAddress.toLowerCase());
      final walletHash = sha256.convert(walletBytes).toString();

      print('│ ✅ 지갑 주소 해시화 완료 (익명성 보장)');
      print('│ • 원본 지갑: $walletAddress');
      print('│ • 해시된 지갑: $walletHash');
      print('│');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.joinMutation,
        message: '게임 참여 요청을 전송하고 있습니다...',
      );

      // idempotencyKey 생성 (중복 참여 방지)
      // 128자 제한을 고려하여 해시를 16자로 축약 (충분한 고유성 보장)
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final shortWalletHash = walletHash.substring(0, 16); // 64비트 (충분한 고유성)
      final idempotencyKey = '$gameId-$shortWalletHash-$timestamp';
      // 총 길이: 36 + 16 + 13 + 2(하이픈) = 67자 (128자 이내)

      print('│ 📤 Mutation 파라미터:');
      print('│    • gameId: $gameId');
      print('│    • selectedGameProductId: $selectedGameProductId');
      print('│    • coordCiphertext: $coordCiphertext');
      print('│    • idempotencyKey: $idempotencyKey');
      print('│    • signerWallet: $walletHash');
      print('│    • contractAddress: $contractAddress');
      print('│');

      final client = await ref.read(graphqlClientProvider.future);

      QueryResult result;
      try {
        result = await client.mutate(
          MutationOptions(
            document: gql(_joinGameMutation),
            variables: {
              'input': {
                'gameId': gameId,
                'selectedGameProductId': selectedGameProductId,
                'coordCiphertext': coordCiphertext,
                'idempotencyKey': idempotencyKey,
                'signerWallet': walletHash, // 해시된 지갑 주소
                'contractAddress': contractAddress,
              },
            },
          ),
        );
        print('│ ✅ GraphQL 요청 완료');
      } catch (mutationError) {
        print('│ ❌ GraphQL Mutation 네트워크 에러: $mutationError');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        throw Exception('GraphQL 요청 실패: $mutationError');
      }

      if (result.hasException) {
        print('│ ❌ joinGame Mutation 에러');
        print('│    • Exception: ${result.exception}');
        if (result.exception?.graphqlErrors != null && result.exception!.graphqlErrors.isNotEmpty) {
          print('│    • GraphQL Errors:');
          for (var error in result.exception!.graphqlErrors) {
            print('│       - ${error.message}');
          }
        }
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        throw Exception(result.exception.toString());
      }

      final data = result.data?['joinGame'];
      if (data == null) {
        print('│ ❌ 응답 데이터 없음');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        throw Exception('joinGame 응답 데이터가 없습니다');
      }

      GameJoinResult joinResult;
      try {
        joinResult = GameJoinResult.fromJson(data as Map<String, dynamic>);
      } catch (parseError) {
        print('│ ❌ 응답 파싱 실패: $parseError');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        throw Exception('응답 데이터 파싱 실패: $parseError');
      }

      print('│');
      print('│ 📥 서버 응답:');
      print('│    • success: ${joinResult.success}');
      print('│    • message: ${joinResult.message}');
      print('│    • entryId: ${joinResult.entryId}');
      print('│    • status: ${joinResult.status}');
      print('│    • txHash: ${joinResult.txHash}');
      print('│    • errorCode: ${joinResult.errorCode}');

      if (joinResult.success) {
        print('│');
        print('│ ✅ joinGame Mutation 성공!');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
      } else {
        print('│');
        print('│ ❌ joinGame Mutation 실패');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        state = AsyncValue.data(joinResult);
        return joinResult;
      }
      print('');

      // 7. 게임 참여 상태 폴링 (문서: docs/게임_참가_프로세스.md 4.1 단계 7, 4.3)
      print('┌─────────────────────────────────────────────────────────────────────────────┐');
      print('│ 🔄 [6/7] 게임 참여 상태 폴링 (Entry Status Polling)                          │');
      print('├─────────────────────────────────────────────────────────────────────────────┤');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.polling,
        message: '블록체인 트랜잭션을 처리하고 있습니다...',
      );

      final entryId = joinResult.entryId;
      if (entryId == null || entryId.isEmpty) {
        print('│ ⚠️  Entry ID가 없어 폴링을 건너뜁니다.');
        print('└─────────────────────────────────────────────────────────────────────────────┘');
        state = AsyncValue.data(joinResult);
        return joinResult;
      }

      print('│ • Entry ID: $entryId');
      print('│');

      final pollingService = EntryStatusPollingService(client: client);

      try {
        EntryStatus? finalStatus;

        await for (final status in pollingService.pollEntryStatus(entryId)) {
          finalStatus = status;
          print('│ 🔄 Status: ${status.status}');
          for (final tx in status.txIntents) {
            print('│    - TX: ${tx.txHash ?? "pending"} (${tx.status})');
          }

          // UI 상태 업데이트 (폴링 중)
          ref.read(gameJoinProgressNotifierProvider.notifier).updatePollingProgress(
            entryId: entryId,
            currentTxCount: status.txIntents.where((tx) => tx.status == 'CONFIRMED').length,
            totalTxCount: status.txIntents.length,
            currentTxHash: status.txIntents.lastOrNull?.txHash,
          );
        }

        print('│');
        if (finalStatus?.isConfirmed == true) {
          print('│ ✅ 게임 참여 완료! (블록체인 확정)');
          print('│ • Entry ID: $entryId');
          print('│ • Final Status: ${finalStatus!.status}');
          print('│ • Transactions: ${finalStatus.txIntents.length}개 완료');
          for (final tx in finalStatus.txIntents) {
            if (tx.txHash != null) {
              print('│ 🔗 PolygonScan TX: https://amoy.polygonscan.com/tx/${tx.txHash}');
            }
          }
        } else {
          print('│ ⚠️  게임 참여 상태: ${finalStatus?.status ?? "UNKNOWN"}');
        }
        print('└─────────────────────────────────────────────────────────────────────────────┘');

        // 최종 결과로 업데이트
        final finalResult = GameJoinResult(
          success: finalStatus?.isConfirmed == true,
          message: finalStatus?.isConfirmed == true
              ? '게임 참여가 완료되었습니다!'
              : joinResult.message,
          entryId: entryId,
          status: finalStatus?.status ?? joinResult.status,
          txHash: finalStatus?.txIntents.firstOrNull?.txHash,
          errorCode: finalStatus?.errorMessage != null ? 'POLLING_ERROR' : null,
        );

        state = AsyncValue.data(finalResult);
        return finalResult;

      } catch (pollingError) {
        print('│ ⚠️  폴링 에러 발생: $pollingError');
        print('│ → 기본 응답으로 처리합니다.');
        print('└─────────────────────────────────────────────────────────────────────────────┘');

        // 최종 요약 (폴링 에러 시)
        final endTime = DateTime.now();
        print('');
        print('╔═══════════════════════════════════════════════════════════════════════════╗');
        print('║  ⚠️  게임 참여 프로세스 완료 (폴링 에러 발생)                               ║');
        print('║  ⏰ ${endTime.toIso8601String()}                                          ║');
        print('║  ⏱️  소요 시간: ${endTime.difference(startTime).inSeconds}초                                                    ║');
        print('╚═══════════════════════════════════════════════════════════════════════════╝');
        print('');

        // 폴링 실패해도 joinGame은 성공했으므로 기본 결과 반환
        state = AsyncValue.data(joinResult);
        return joinResult;
      }
    } catch (e, stackTrace) {
      print('');
      print('╔═══════════════════════════════════════════════════════════════════════════╗');
      print('║  ❌ 게임 참여 프로세스 실패                                                 ║');
      print('╚═══════════════════════════════════════════════════════════════════════════╝');
      print('');
      print('🔍 에러 상세:');
      print('   $e');
      print('');
      print('📚 Stack Trace (처음 10줄):');
      final stackLines = stackTrace.toString().split('\n').take(10);
      for (final line in stackLines) {
        print('   $line');
      }
      print('');

      final errorResult = GameJoinResult(
        success: false,
        message: e.toString(),
        errorCode: 'CLIENT_ERROR',
      );

      state = AsyncValue.data(errorResult);

      rethrow;
    }
  }

  /// 참여 상태 초기화
  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// 게임 참여 가능 여부 확인
///
/// - 지갑이 있는지 확인
/// - GraphQL 클라이언트 연결 확인
@riverpod
Future<bool> canJoinGame(Ref ref) async {
  try {
    // 지갑 확인
    final walletService = ref.watch(blockchainWalletServiceProvider);
    final hasWallet = await walletService.hasWallet();

    if (!hasWallet) {
      print('ℹ️  지갑이 없습니다. 자동 생성됩니다.');
    }

    // GraphQL 클라이언트 연결 확인
    try {
      await ref.read(graphqlClientProvider.future);
      return true;
    } catch (e) {
      print('❌ GraphQL 클라이언트 연결 실패: $e');
      return false;
    }
  } catch (e) {
    print('❌ canJoinGame 확인 실패: $e');
    return false;
  }
}

/// 사용자 지갑 주소 조회
@riverpod
Future<String?> userWalletAddress(Ref ref) async {
  try {
    final walletService = ref.watch(blockchainWalletServiceProvider);
    return await walletService.getWalletAddress();
  } catch (e) {
    print('❌ 지갑 주소 조회 실패: $e');
    return null;
  }
}
