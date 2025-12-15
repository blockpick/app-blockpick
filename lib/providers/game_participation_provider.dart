import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/graphql/graphql_client.dart';
import '../services/blockchain_wallet_service.dart';
import '../services/coordinate_encryption_service.dart';
import '../services/smart_contract_service.dart';
import '../services/entry_status_polling_service.dart';
import '../models/entry_status.dart';
import '../features/game/widgets/game_join_progress_overlay.dart';
import 'game_join_progress_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

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
      print('\n═══════════════════════════════════════════════════════════');
      print('🎮 게임 참여 프로세스 시작');
      print('═══════════════════════════════════════════════════════════');
      print('📋 입력 파라미터:');
      print('   • 게임 ID: $gameId');
      print('   • 상품 ID: $selectedGameProductId');
      print('   • 선택 좌표: ($row, $col)');
      print('   • 컨트랙트 주소: $contractAddress');
      print('');

      // 2. 지갑 준비 (문서: docs/게임_참가_프로세스.md 4.1 단계 2)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [2/7] 지갑 준비                                         │');
      print('└─────────────────────────────────────────────────────────┘');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.walletCheck,
        message: '블록체인 지갑을 확인하고 있습니다...',
      );

      final walletService = ref.read(blockchainWalletServiceProvider);

      final credentials = await walletService.getOrCreateWallet();
      final walletAddress = credentials.address.hex;

      print('✓ 지갑 준비 완료: $walletAddress');
      // print('   • 지갑 주소: $walletAddress');
      print('');

      // 3. 암호화 키 확보 (하이브리드 전략) (문서: docs/게임_참가_프로세스.md 3.2)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [3/7] 암호화 키 확보 (하이브리드 전략)                   │');
      print('└─────────────────────────────────────────────────────────┘');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.encryptionKey,
        message: '암호화 키를 생성하고 있습니다...',
      );

      // userIndex 생성: 게임별로 고정 (문서: docs/게임_참가_프로세스.md 3.1)
      // 형식: SHA256(walletAddress-gameId) - DB VARCHAR(64) 제한 준수
      final rawIndex = '${walletAddress.toLowerCase()}-$gameId';
      final bytes = utf8.encode(rawIndex);
      final digest = sha256.convert(bytes);
      final userIndex = digest.toString(); // 64자 hex string
      print('✓ UserIndex 생성: ${userIndex.substring(0, 30)}...');
      print('   • 형식: SHA256(walletAddress-gameId) - 64자 고정');
      print('');

      final contractService = SmartContractService();
      String encryptionKey;

      // 하이브리드 암호화 키 전략 (문서: docs/게임_참가_프로세스.md 3.2)
      // Step 1: 온체인 View 조회 (가스비 없음)
      print('→ [Step 1] 온체인 View 조회: getEncryptionKey()');
      print('   • 컨트랙트: $contractAddress');
      print('   • userIndex: ${userIndex.substring(0, 40)}...');
      print('   • 목적: 기존 키 재사용 (가스비 절약)');
      print('');

      try {
        encryptionKey = await contractService.getEncryptionKey(
          contractAddress: contractAddress,
          userIndex: userIndex,
          userAddress: walletAddress,
        );

        print('✅ 기존 키 발견! 재사용 (가스비 절약)');
        print('   🔍 키 길이: ${encryptionKey.length} 문자');
        print('   ℹ️  서버 호출 없이 즉시 사용 가능');
        print('');
      } catch (e) {
        // Step 2: 서버 가스 대납 생성 (문서: docs/게임_참가_프로세스.md 3.2)
        print('→ [Step 2] 서버 가스 대납 생성: requestEncryptionKey Mutation');
        print('   • 기존 키 없음: $e');
        print('   • 서버가 트랜잭션 실행 및 가스비 지불');
        print('');

        final client = await ref.read(graphqlClientProvider.future);

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
          print('');
          print('❌ requestEncryptionKey Mutation 에러');
          print('   ${keyResult.exception}');
          // 문서 8장: 실패 시 즉시 에러 처리 (폴링 없음)
          throw Exception('암호화 키 생성 실패: ${keyResult.exception}');
        }

        final keyData = keyResult.data?['requestEncryptionKey'];
        if (keyData == null) {
          print('❌ 암호화 키 응답 데이터 없음');
          throw Exception('암호화 키를 받지 못했습니다');
        }

        if (keyData['success'] != true) {
          print('❌ 암호화 키 생성 실패: ${keyData['message']}');
          print('   • Code: ${keyData['code']}');
          // 문서 8장: KEY_REQUEST_PROCESSING_FAILED 등 실패 케이스 처리
          throw Exception(keyData['message'] ?? '암호화 키 생성 실패');
        }

        final blockchainTxHash = keyData['txHash'] as String?;
        final contractAddr = keyData['contractAddress'] as String?;
        final requestId = keyData['requestId'] as String?;

        print('✅ 서버 트랜잭션 성공!');
        if (blockchainTxHash != null) {
          print('   • TX Hash: ${blockchainTxHash.substring(0, 20)}...');
        }
        if (requestId != null) {
          print('   • Request ID: $requestId (폴링용, 현재 미사용)');
        }
        print('');

        // Step 3: 후속 조회 (문서: docs/게임_참가_프로세스.md 3.2)
        // 서버 응답에 키가 있으면 사용, 없으면 온체인 재조회 (폴링)
        if (keyData['encryptionKey'] != null && keyData['encryptionKey'] != '') {
          encryptionKey = keyData['encryptionKey'] as String;
          print('✓ 키 수신 완료 (서버 응답)');
          print('   🔍 키 길이: ${encryptionKey.length} 문자');
          print('');
        } else {
          print('→ [Step 3] 온체인 폴링: getEncryptionKey() 반복 조회');
          print('   • 서버 응답에 키 없음 → 블록체인에서 폴링');
          print('   • 최대 30회 시도 (간격 2초, 총 60초)');
          print('');

          // UI 상태 업데이트
          ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
            step: GameJoinStep.encryptionKey,
            message: '블록체인에서 암호화 키 생성 대기 중...',
          );

          const maxAttempts = 30;
          const pollInterval = Duration(seconds: 2);
          int attempts = 0;
          String? polledKey;

          while (attempts < maxAttempts && polledKey == null) {
            attempts++;
            print('   🔄 폴링 시도 $attempts/$maxAttempts');

            try {
              polledKey = await contractService.getEncryptionKey(
                contractAddress: contractAddr ?? contractAddress,
                userIndex: userIndex,
                userAddress: walletAddress,
              );

              print('   ✅ 키 발견!');
              break;
            } catch (e) {
              if (attempts < maxAttempts) {
                print('   ⏳ 키 아직 없음, ${pollInterval.inSeconds}초 후 재시도...');
                await Future.delayed(pollInterval);
              } else {
                print('   ❌ 타임아웃 (${maxAttempts * pollInterval.inSeconds}초)');
                throw Exception('암호화 키 생성 타임아웃: 블록체인에서 키를 찾을 수 없습니다');
              }
            }
          }

          if (polledKey == null) {
            throw Exception('암호화 키를 블록체인에서 조회할 수 없습니다');
          }

          encryptionKey = polledKey;
          print('');
          print('✅ 블록체인 키 조회 완료!');
          print('   🔍 키 길이: ${encryptionKey.length} 문자');
          print('   ⏱️  소요 시간: ${attempts * pollInterval.inSeconds}초');
          print('');
        }
      }

      // 4. 좌표 암호화 (문서: docs/게임_참가_프로세스.md 4.1 단계 4)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [4/7] 좌표 암호화                                        │');
      print('└─────────────────────────────────────────────────────────┘');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.coordinateEncryption,
        message: '선택한 좌표를 암호화하고 있습니다...',
      );

      final encryptionService = ref.read(coordinateEncryptionServiceProvider);

      print('→ 암호화 입력 파라미터:');
      print('   • row: $row');
      print('   • col: $col');
      print('   • encryptionKey 길이: ${encryptionKey.length}');
      print('   • encryptionKey: $encryptionKey');
      print('');

      String coordCiphertext;
      try {
        coordCiphertext = encryptionService.encryptCoordinate(
          row: row,
          col: col,
          encryptionKeyHex: encryptionKey,
        );
        print('✓ 좌표 암호화 완료');
        print('   • 암호문 길이: ${coordCiphertext.length}');
        print('   • 암호문: $coordCiphertext');
      } catch (encryptError) {
        print('❌ 좌표 암호화 실패!');
        print('   • 에러: $encryptError');
        throw Exception('좌표 암호화 중 오류 발생: $encryptError');
      }
      print('');

      // 5. joinGame Mutation 호출 준비: 지갑 주소 해시화 (문서: docs/게임_참가_프로세스.md 5.2)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [5/7] joinGame Mutation 전송 준비                        │');
      print('└─────────────────────────────────────────────────────────┘');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.walletHashing,
        message: '지갑 주소를 해시화하고 있습니다...',
      );

      final walletBytes = utf8.encode(walletAddress.toLowerCase());
      final walletHash = sha256.convert(walletBytes).toString();

      print('✓ 해시 완료 (익명성 보장)');
      // print('✓ SHA-256 해시 완료');
      // print('   • 원본: $walletAddress');
      // print('   • 해시: $walletHash');
      // print('   ⚠️  백엔드는 해시된 주소만 저장 (원본 지갑 주소 모름)');
      print('');

      // 5. joinGame Mutation 호출 (문서: docs/게임_참가_프로세스.md 4.1 단계 5)
      print('→ joinGame Mutation 전송 중...');

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

      print('→ Mutation 파라미터:');
      print('   • gameId: $gameId');
      print('   • selectedGameProductId: $selectedGameProductId');
      print('   • coordCiphertext: $coordCiphertext');
      print('   • idempotencyKey: $idempotencyKey');
      print('   • signerWallet (해시): ${walletHash.substring(0, 16)}...');
      print('   • contractAddress: $contractAddress');
      print('');
      print('→ Mutation 전송 중...');

      print('');
      print('→ GraphQL 클라이언트 획득 중...');
      final client = await ref.read(graphqlClientProvider.future);
      print('✓ GraphQL 클라이언트 준비 완료');
      print('');

      print('→ joinGame Mutation 실행 시작...');
      final mutationStartTime = DateTime.now();
      print('   • 시작 시간: $mutationStartTime');
      print('');

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
        final mutationEndTime = DateTime.now();
        final duration = mutationEndTime.difference(mutationStartTime);
        print('✓ GraphQL 요청 완료');
        print('   • 완료 시간: $mutationEndTime');
        print('   • 소요 시간: ${duration.inMilliseconds}ms');
      } catch (mutationError) {
        final mutationEndTime = DateTime.now();
        final duration = mutationEndTime.difference(mutationStartTime);
        print('');
        print('❌ GraphQL Mutation 네트워크 에러');
        print('   • 에러 타입: ${mutationError.runtimeType}');
        print('   • 에러 메시지: $mutationError');
        print('   • 실패 시간: $mutationEndTime');
        print('   • 소요 시간: ${duration.inMilliseconds}ms');
        print('');
        print('⚠️  [Step 6/7], [Step 7/7] 실행되지 않음 (네트워크 에러로 중단)');
        throw Exception('GraphQL 요청 실패: $mutationError');
      }

      print('');
      print('→ GraphQL 응답 검증 중...');
      print('   • hasException: ${result.hasException}');
      print('   • data 존재 여부: ${result.data != null}');
      if (result.data != null) {
        print('   • data 키 목록: ${result.data!.keys.toList()}');
      }

      if (result.hasException) {
        print('');
        print('❌ joinGame Mutation 에러');
        print('   • Exception: ${result.exception}');
        if (result.exception?.graphqlErrors != null && result.exception!.graphqlErrors.isNotEmpty) {
          print('   • GraphQL Errors 개수: ${result.exception!.graphqlErrors.length}');
          print('   • GraphQL Errors:');
          for (var i = 0; i < result.exception!.graphqlErrors.length; i++) {
            final error = result.exception!.graphqlErrors[i];
            print('      [$i] Message: ${error.message}');
            print('          Path: ${error.path}');
            print('          Locations: ${error.locations}');
            if (error.extensions != null) {
              print('          Extensions: ${error.extensions}');
              if (error.extensions!['classification'] != null) {
                print('          Classification: ${error.extensions!['classification']}');
              }
            }
          }
        } else {
          print('   • GraphQL Errors: 없음');
        }
        if (result.exception?.linkException != null) {
          print('   • Link Exception: ${result.exception!.linkException}');
          print('   • Link Exception 타입: ${result.exception!.linkException.runtimeType}');
        } else {
          print('   • Link Exception: 없음');
        }
        print('');
        print('⚠️  [Step 6/7] 초기 응답 처리 - 실패로 인해 중단');
        print('⚠️  [Step 7/7] 상태 폴링 - 실행되지 않음');
        throw Exception(result.exception.toString());
      }

      print('✓ 응답 수신 성공 (예외 없음)');
      print('');

      // 6. 초기 응답 처리 (문서: docs/게임_참가_프로세스.md 4.1 단계 6)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [6/7] 초기 응답 처리                                     │');
      print('└─────────────────────────────────────────────────────────┘');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.joinMutation,
        message: '서버 응답을 처리하고 있습니다...',
      );

      print('→ 응답 데이터 확인 중...');
      final data = result.data?['joinGame'];
      print('   • result.data: ${result.data}');
      print('   • joinGame 데이터 존재: ${data != null}');

      if (data == null) {
        print('');
        print('❌ 응답 데이터 없음');
        print('   • result.data 전체: ${result.data}');
        print('   • 가능한 원인:');
        print('      - 서버에서 null 반환');
        print('      - GraphQL 스키마 불일치');
        print('      - 필드명 오타');
        print('');
        print('⚠️  [Step 7/7] 상태 폴링 - 실행되지 않음 (데이터 없음)');
        throw Exception('joinGame 응답 데이터가 없습니다');
      }

      print('✓ 응답 데이터 존재 확인');
      print('');

      print('→ 응답 데이터 파싱 중...');
      print('   • Raw Data 타입: ${data.runtimeType}');
      print('   • Raw Data: $data');
      if (data is Map) {
        print('   • 필드 목록: ${data.keys.toList()}');
        print('   • success: ${data['success']}');
        print('   • code: ${data['code']}');
        print('   • message: ${data['message']}');
        print('   • entryId: ${data['entryId']}');
        print('   • status: ${data['status']}');
        print('   • txHash: ${data['txHash']}');
        print('   • errorCode: ${data['errorCode']}');
      }
      print('');

      GameJoinResult joinResult;
      try {
        joinResult = GameJoinResult.fromJson(data as Map<String, dynamic>);
        print('✓ 응답 파싱 완료');
        print('   • GameJoinResult 객체 생성 성공');
        print('   • joinResult.success: ${joinResult.success}');
        print('   • joinResult.message: ${joinResult.message}');
        print('   • joinResult.entryId: ${joinResult.entryId}');
        print('   • joinResult.status: ${joinResult.status}');
        print('   • joinResult.txHash: ${joinResult.txHash}');
        print('   • joinResult.errorCode: ${joinResult.errorCode}');
      } catch (parseError) {
        print('❌ 응답 파싱 실패');
        print('   • 에러 타입: ${parseError.runtimeType}');
        print('   • 에러 메시지: $parseError');
        print('   • 원본 데이터: $data');
        print('');
        print('⚠️  [Step 7/7] 상태 폴링 - 실행되지 않음 (파싱 실패)');
        throw Exception('응답 데이터 파싱 실패: $parseError');
      }

      print('');
      print('═══════════════════════════════════════════════════════════');
      if (joinResult.success) {
        print('✅ joinGame Mutation 성공!');
        print('═══════════════════════════════════════════════════════════');
        print('   • Entry ID: ${joinResult.entryId}');
        print('   • Initial Status: ${joinResult.status}');
        print('   • Message: ${joinResult.message}');
        print('   • TX Hash: ${joinResult.txHash ?? "아직 없음 (폴링 필요)"}');
        print('');
        print('→ [Step 7/7] 상태 폴링으로 진행...');
      } else {
        print('❌ joinGame Mutation 실패 (서버 비즈니스 로직 에러)');
        print('═══════════════════════════════════════════════════════════');
        print('   • Success: ${joinResult.success}');
        print('   • Message: ${joinResult.message}');
        print('   • Error Code: ${joinResult.errorCode}');
        print('   • Entry ID: ${joinResult.entryId ?? "없음"}');
        print('   • Status: ${joinResult.status ?? "없음"}');
        print('');
        print('⚠️  [Step 7/7] 상태 폴링 - 실행되지 않음 (서버 실패 응답)');
        print('═══════════════════════════════════════════════════════════\n');

        state = AsyncValue.data(joinResult);
        return joinResult;
      }
      print('');

      // 7. 게임 참여 상태 폴링 (문서: docs/게임_참가_프로세스.md 4.1 단계 7, 4.3)
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ [7/7] 게임 참여 상태 폴링 (EntryStatusPollingService)   │');
      print('└─────────────────────────────────────────────────────────┘');

      // UI 상태 업데이트
      ref.read(gameJoinProgressNotifierProvider.notifier).updateProgress(
        step: GameJoinStep.polling,
        message: '블록체인 트랜잭션을 처리하고 있습니다...',
      );

      final entryId = joinResult.entryId;
      print('→ Entry ID 확인 중...');
      print('   • entryId: $entryId');
      print('   • entryId 유효성: ${entryId != null && entryId.isNotEmpty}');

      if (entryId == null || entryId.isEmpty) {
        print('');
        print('⚠️  Entry ID가 없어 폴링을 건너뜁니다.');
        print('   • 가능한 원인:');
        print('      - 서버에서 entryId를 반환하지 않음');
        print('      - 비동기 처리로 인해 아직 생성되지 않음');
        print('   • 현재 joinResult를 그대로 반환합니다.');
        print('═══════════════════════════════════════════════════════════\n');
        state = AsyncValue.data(joinResult);
        return joinResult;
      }

      print('✓ Entry ID 유효');
      print('');

      print('→ EntryStatusPollingService 초기화 중...');
      final pollingService = EntryStatusPollingService(client: client);
      print('✓ 폴링 서비스 준비 완료');
      print('');

      print('→ 폴링 시작...');
      print('   • 대상 Entry ID: $entryId');
      print('   • 폴링 간격: 2초');
      print('   • 최대 대기 시간: 60초');
      print('');

      final pollingStartTime = DateTime.now();
      int pollingCount = 0;

      try {
        EntryStatus? finalStatus;

        await for (final status in pollingService.pollEntryStatus(entryId)) {
          pollingCount++;
          finalStatus = status;

          print('   🔄 폴링 #$pollingCount');
          print('      • Status: ${status.status}');
          print('      • TX Intents 수: ${status.txIntents.length}');
          if (status.txIntents.isNotEmpty) {
            print('      • TX 목록:');
            for (var i = 0; i < status.txIntents.length; i++) {
              final tx = status.txIntents[i];
              print('         [$i] ${tx.txHash?.substring(0, 20) ?? "pending"}... (${tx.status})');
            }
          }
          final confirmedCount = status.txIntents.where((tx) => tx.status == 'CONFIRMED').length;
          print('      • 확정된 TX: $confirmedCount/${status.txIntents.length}');
          print('');

          // UI 상태 업데이트 (폴링 중)
          ref.read(gameJoinProgressNotifierProvider.notifier).updatePollingProgress(
            entryId: entryId,
            currentTxCount: confirmedCount,
            totalTxCount: status.txIntents.length,
            currentTxHash: status.txIntents.lastOrNull?.txHash,
          );
        }

        final pollingEndTime = DateTime.now();
        final pollingDuration = pollingEndTime.difference(pollingStartTime);

        print('');
        print('✓ 폴링 완료');
        print('   • 총 폴링 횟수: $pollingCount');
        print('   • 총 소요 시간: ${pollingDuration.inSeconds}초');
        print('');

        print('═══════════════════════════════════════════════════════════');
        if (finalStatus?.isConfirmed == true) {
          print('✅ 게임 참여 완료! (블록체인 확정)');
          print('═══════════════════════════════════════════════════════════');
          print('   • Entry ID: $entryId');
          print('   • Final Status: ${finalStatus!.status}');
          print('   • Transactions: ${finalStatus.txIntents.length}개 완료');
          for (var i = 0; i < finalStatus.txIntents.length; i++) {
            final tx = finalStatus.txIntents[i];
            print('      [$i] TX Hash: ${tx.txHash}');
            print('          Status: ${tx.status}');
          }
        } else {
          print('⚠️  게임 참여 상태: ${finalStatus?.status ?? "UNKNOWN"}');
          print('═══════════════════════════════════════════════════════════');
          print('   • Entry ID: $entryId');
          if (finalStatus != null) {
            print('   • Status: ${finalStatus.status}');
            print('   • Error Message: ${finalStatus.errorMessage ?? "없음"}');
            print('   • TX Intents:');
            for (var i = 0; i < finalStatus.txIntents.length; i++) {
              final tx = finalStatus.txIntents[i];
              print('      [$i] ${tx.txHash ?? "pending"} (${tx.status})');
            }
          }
        }
        print('═══════════════════════════════════════════════════════════\n');

        // 최종 결과로 업데이트
        print('→ 최종 결과 생성 중...');
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
        print('✓ 최종 결과:');
        print('   • success: ${finalResult.success}');
        print('   • message: ${finalResult.message}');
        print('   • entryId: ${finalResult.entryId}');
        print('   • status: ${finalResult.status}');
        print('   • txHash: ${finalResult.txHash}');
        print('   • errorCode: ${finalResult.errorCode}');
        print('');

        state = AsyncValue.data(finalResult);
        return finalResult;

      } catch (pollingError, pollingStackTrace) {
        final pollingEndTime = DateTime.now();
        final pollingDuration = pollingEndTime.difference(pollingStartTime);

        print('');
        print('⚠️  폴링 에러 발생!');
        print('   • 에러 타입: ${pollingError.runtimeType}');
        print('   • 에러 메시지: $pollingError');
        print('   • 폴링 횟수: $pollingCount');
        print('   • 소요 시간: ${pollingDuration.inSeconds}초');
        print('');
        print('📚 Polling Stack Trace:');
        print('$pollingStackTrace');
        print('');
        print('→ joinGame은 성공했으므로 기본 응답으로 처리합니다.');
        print('   • 사용자에게는 성공으로 표시됨');
        print('   • 백그라운드에서 트랜잭션 처리 중일 수 있음');
        print('');

        // 폴링 실패해도 joinGame은 성공했으므로 기본 결과 반환
        state = AsyncValue.data(joinResult);
        return joinResult;
      }
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
