import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/graphql/graphql_client.dart';
import '../services/blockchain_wallet_service.dart';
import '../services/coordinate_encryption_service.dart';
import '../services/smart_contract_service.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'game_participation_provider.g.dart';

/// requestEncryptionKey Mutation (서버 가스비 대납 방식)
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
/// 전체 프로세스:
/// 1. 블록체인 지갑 확인/생성
/// 2. GraphQL로 암호화 키 요청 (서버가 가스비 지불)
/// 3. 좌표 암호화
/// 4. 지갑 주소 해시화 (익명성 보장)
/// 5. joinGame Mutation 호출
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
      print('\n═══════════════════════════════════════════════════════════');
      print('🎮 게임 참여 프로세스 시작');
      print('═══════════════════════════════════════════════════════════');
      print('📋 입력 파라미터:');
      print('   • 게임 ID: $gameId');
      print('   • 상품 ID: $selectedGameProductId');
      print('   • 선택 좌표: ($row, $col)');
      print('   • 컨트랙트 주소: $contractAddress');
      print('');

      // 1. 블록체인 지갑 확인/생성
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [1/5] 블록체인 지갑 확인/생성                             │');
      print('└─────────────────────────────────────────────────────────┘');
      final walletService = ref.read(blockchainWalletServiceProvider);

      final hasExistingWallet = await walletService.hasWallet();
      // if (hasExistingWallet) {
      //   print('✓ 기존 지갑 발견');
      // } else {
      //   print('! 지갑 없음 - 새로 생성 중...');
      // }

      final credentials = await walletService.getOrCreateWallet();
      final walletAddress = credentials.address.hex;

      print('✓ 지갑 준비 완료: $walletAddress');
      // print('   • 지갑 주소: $walletAddress');
      print('');

      // 2. 암호화 키 조회 또는 생성
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [2/5] 암호화 키 조회/생성                                │');
      print('└─────────────────────────────────────────────────────────┘');

      // userIndex 생성: 게임별로 고정 (wallet-gameId 형식)
      final userIndex = '$walletAddress-$gameId';
      // print('✓ UserIndex 생성 (게임별 고정): ${userIndex.substring(0, 50)}...');
      print('');

      final contractService = SmartContractService();
      String encryptionKey;

      // Step 1: 먼저 블록체인에서 키가 이미 있는지 조회
      print('→ [Step 1] 블록체인에서 기존 키 조회 중...');
      // print('   • 컨트랙트: $contractAddress');
      // print('   • Index: ${userIndex.substring(0, 30)}...');
      // print('   ⚠️  이미 생성된 키가 있으면 재사용 (가스비 절약)');
      // print('');

      try {
        encryptionKey = await contractService.getEncryptionKey(
          contractAddress: contractAddress,
          userIndex: userIndex,
          userAddress: walletAddress,
        );

        print('✅ 기존 키 발견! 재사용 (가스비 절약)');
        print('   🔍 키 길이: ${encryptionKey.length} 문자 (필요: 64자리 hex)');
        print('   🔍 키 전체: $encryptionKey');
        // print('   • 키: ${encryptionKey.substring(0, 16)}...');
        // print('   ℹ️  서버 요청 없이 기존 키 재사용');
        print('');
      } catch (e) {
        // 키가 없으면 서버를 통해 생성
        print('→ [Step 2] 서버를 통한 새 키 생성 중...');
        // print('ℹ️  기존 키 없음: $e');
        // print('→ [Step 2] 서버를 통한 새 키 생성 (가스비 대납)...');
        // print('');

        final client = await ref.read(graphqlClientProvider.future);

        // print('→ GraphQL requestEncryptionKey Mutation 호출 중...');
        // print('   • gameId: $gameId');
        // print('   • userAddress: $walletAddress');
        // print('   • index: ${userIndex.substring(0, 30)}...');
        // print('   ⚠️  서버가 가스비를 지불합니다 (사용자 부담 없음)');

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
          ),
        );

        if (keyResult.hasException) {
          print('');
          print('❌ requestEncryptionKey Mutation 에러');
          print('   ${keyResult.exception}');
          throw Exception('암호화 키 생성 실패: ${keyResult.exception}');
        }

        final keyData = keyResult.data?['requestEncryptionKey'];
        if (keyData == null) {
          print('❌ 암호화 키 응답 데이터 없음');
          throw Exception('암호화 키를 받지 못했습니다');
        }

        if (keyData['success'] != true) {
          print('❌ 암호화 키 생성 실패: ${keyData['message']}');
          throw Exception(keyData['message'] ?? '암호화 키 생성 실패');
        }

        final blockchainTxHash = keyData['txHash'] as String?;
        final contractAddr = keyData['contractAddress'] as String?;

        print('✅ 서버 트랜잭션 성공!');
        // print('✓ 트랜잭션 성공! (서버 가스비 지불 완료)');
        // if (blockchainTxHash != null) {
        //   print('   • TX Hash: ${blockchainTxHash.substring(0, 20)}...');
        // }
        // if (contractAddr != null) {
        //   print('   • 컨트랙트: $contractAddr');
        // }
        // print('   • 메시지: ${keyData['message']}');
        print('');

        // 서버 응답에서 키를 받거나, 없으면 블록체인에서 다시 조회
        if (keyData['encryptionKey'] != null && keyData['encryptionKey'] != '') {
          encryptionKey = keyData['encryptionKey'] as String;
          print('✓ 키 수신 완료 (서버 응답)');
          print('   🔍 키 길이: ${encryptionKey.length} 문자 (필요: 64자리 hex)');
          print('   🔍 키 전체: $encryptionKey');
          // print('✓ 암호화 키 수신 완료 (서버 응답)');
          // print('   • 키: ${encryptionKey.substring(0, 16)}...');
          print('');
        } else {
          print('→ 블록체인에서 키 조회 중...');
          // print('⚠️  서버가 encryptionKey를 반환하지 않음 (보안 정책)');
          // print('→ 블록체인 컨트랙트에서 직접 조회합니다...');
          // print('');

          try {
            encryptionKey = await contractService.getEncryptionKey(
              contractAddress: contractAddr ?? contractAddress,
              userIndex: userIndex,
              userAddress: walletAddress,
            );

            print('✅ 블록체인 키 조회 완료!');
            print('   🔍 키 길이: ${encryptionKey.length} 문자 (필요: 64자리 hex)');
            print('   🔍 키 전체: $encryptionKey');
            // print('✅ 블록체인에서 새로 생성된 키 조회 완료!');
            // print('   • 키: ${encryptionKey.substring(0, 16)}...');
            print('');
          } catch (e) {
            print('❌ 블록체인에서 키 조회 실패: $e');
            throw Exception('암호화 키를 블록체인에서 조회할 수 없습니다: $e');
          }
        }
      }

      // 3. 좌표 암호화
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [3/5] 좌표 암호화                                        │');
      print('└─────────────────────────────────────────────────────────┘');
      final encryptionService = ref.read(coordinateEncryptionServiceProvider);

      // print('→ 평문 좌표: ($row, $col)');
      final coordCiphertext = encryptionService.encryptCoordinate(
        row: row,
        col: col,
        encryptionKeyHex: encryptionKey,
      );

      print('✓ 좌표 암호화 완료');
      // print('   • 암호문: ${coordCiphertext.substring(0, 40)}...');
      print('');

      // 4. 지갑 주소 해시화 (SHA-256)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [4/5] 지갑 주소 해시화                                   │');
      print('└─────────────────────────────────────────────────────────┘');
      final walletBytes = utf8.encode(walletAddress.toLowerCase());
      final walletHash = sha256.convert(walletBytes).toString();

      print('✓ 해시 완료 (익명성 보장)');
      // print('✓ SHA-256 해시 완료');
      // print('   • 원본: $walletAddress');
      // print('   • 해시: $walletHash');
      // print('   ⚠️  백엔드는 해시된 주소만 저장 (원본 지갑 주소 모름)');
      print('');

      // 5. joinGame Mutation 호출
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [5/5] joinGame Mutation 전송                            │');
      print('└─────────────────────────────────────────────────────────┘');

      // idempotencyKey 생성 (중복 참여 방지)
      final idempotencyKey =
          '$gameId-$walletHash-${DateTime.now().millisecondsSinceEpoch}';

      print('→ Mutation 파라미터:');
      print('   • gameId: $gameId');
      print('   • selectedGameProductId: $selectedGameProductId');
      print('   • coordCiphertext: $coordCiphertext');
      print('   • idempotencyKey: $idempotencyKey');
      print('   • signerWallet (해시): ${walletHash.substring(0, 16)}...');
      print('   • contractAddress: $contractAddress');
      // print('   • gameId: $gameId');
      // print('   • selectedGameProductId: $selectedGameProductId');
      // print('   • coordCiphertext: ${coordCiphertext.substring(0, 30)}...');
      // print('   • idempotencyKey: $idempotencyKey');
      // print('   • signerWallet (해시): ${walletHash.substring(0, 16)}...');
      // print('   • contractAddress: $contractAddress');
      print('');
      print('→ Mutation 전송 중...');

      final client = await ref.read(graphqlClientProvider.future);
      final result = await client.mutate(
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

      if (result.hasException) {
        print('');
        print('❌ joinGame Mutation 에러');
        print('   ${result.exception}');
        throw Exception(result.exception.toString());
      }

      print('✓ 응답 수신');

      final data = result.data?['joinGame'];
      if (data == null) {
        print('❌ 응답 데이터 없음');
        throw Exception('joinGame 응답 데이터가 없습니다');
      }

      // print('   Raw Data: $data');

      final joinResult = GameJoinResult.fromJson(data as Map<String, dynamic>);

      print('');
      print('═══════════════════════════════════════════════════════════');
      if (joinResult.success) {
        print('✅ 게임 참가 성공!');
        print('═══════════════════════════════════════════════════════════');
        // print('📋 결과 정보:');
        print('   • Entry ID: ${joinResult.entryId}');
        print('   • Status: ${joinResult.status}');
        // print('   • TX Hash: ${joinResult.txHash}');
        print('   • Message: ${joinResult.message}');
      } else {
        print('❌ 게임 참가 실패');
        print('═══════════════════════════════════════════════════════════');
        // print('📋 에러 정보:');
        print('   • Message: ${joinResult.message}');
        print('   • Error Code: ${joinResult.errorCode}');
      }
      print('═══════════════════════════════════════════════════════════\n');

      // State 업데이트
      state = AsyncValue.data(joinResult);

      return joinResult;
    } catch (e, stackTrace) {
      print('');
      print('═══════════════════════════════════════════════════════════');
      print('❌ 게임 참여 프로세스 실패');
      print('═══════════════════════════════════════════════════════════');
      print('🔍 에러 상세:');
      print('   $e');
      print('');
      print('📚 Stack Trace:');
      print('$stackTrace');
      print('═══════════════════════════════════════════════════════════\n');

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
