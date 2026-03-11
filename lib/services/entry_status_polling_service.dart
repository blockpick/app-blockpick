import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/entry_status.dart';

/// entryStatus 쿼리
const String _entryStatusQuery = r'''
  query EntryStatus($entryId: String!) {
    entryStatus(entryId: $entryId) {
      success
      entryId
      status
      txIntents {
        intentId
        status
        txHash
        errorCode
        errorMessage
        createdAt
        updatedAt
      }
      errorMessage
    }
  }
''';

/// 게임 참여 상태 폴링 서비스
class EntryStatusPollingService {
  final GraphQLClient client;

  EntryStatusPollingService({required this.client});

  /// 게임 참여 상태 폴링
  ///
  /// [entryId]: joinGame에서 받은 참여 ID
  /// [interval]: 폴링 간격 (기본 2초)
  /// [maxAttempts]: 최대 시도 횟수 (기본 30회 = 약 1분)
  ///
  /// Returns: EntryStatus 스트림
  /// - CONFIRMED 또는 FAILED 상태가 되면 스트림 종료
  /// - 최대 시도 횟수 초과 시 TimeoutException 발생
  Stream<EntryStatus> pollEntryStatus(
    String entryId, {
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 30,
  }) async* {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        print('🔄 [게임 참여 폴링] 시도 $attempts/$maxAttempts (entryId: $entryId)');

        final result = await client.query(
          QueryOptions(
            document: gql(_entryStatusQuery),
            variables: {'entryId': entryId},
            fetchPolicy: FetchPolicy.noCache, // 캐시 정규화 우회 (__typename 미포함 응답 대응)
          ),
        );

        if (result.hasException) {
          final exceptionStr = result.exception.toString();
          print('⚠️  [게임 참여 폴링] GraphQL 에러: $exceptionStr');
          print('   • Exception 타입: ${result.exception.runtimeType}');
          print('   • GraphQL Errors: ${result.exception?.graphqlErrors}');
          print('   • Link Exception: ${result.exception?.linkException}');

          // 네트워크 에러 확인
          final isNetworkError = exceptionStr.contains('Network') ||
                                  exceptionStr.contains('SocketException') ||
                                  exceptionStr.contains('TimeoutException') ||
                                  exceptionStr.contains('Connection') ||
                                  exceptionStr.contains('Failed host lookup');

          // 네트워크 에러는 재시도
          if (isNetworkError && attempts < maxAttempts) {
            print('   → 네트워크 에러 감지, ${maxAttempts - attempts}회 재시도 남음');
            await Future.delayed(interval);
            continue;
          } else if (attempts < maxAttempts) {
            // 기타 에러도 일단 재시도 (최대 5번)
            if (attempts <= 5) {
              print('   → 기타 에러, ${maxAttempts - attempts}회 재시도 남음');
              await Future.delayed(interval);
              continue;
            }
            print('   ❌ 재시도 횟수 초과, 에러 throw');
            throw Exception('게임 참여 상태 조회 실패: ${result.exception}');
          } else {
            throw Exception('게임 참여 상태 조회 실패 (재시도 초과): ${result.exception}');
          }
        }

        final data = result.data?['entryStatus'];
        if (data == null) {
          print('⚠️  [게임 참여 폴링] 응답 데이터 없음');
          print('   • result.data: ${result.data}');

          if (attempts < maxAttempts) {
            await Future.delayed(interval);
            continue;
          } else {
            throw Exception('게임 참여 상태 응답이 없습니다');
          }
        }

        final status = EntryStatus.fromJson(data as Map<String, dynamic>);
        print('📊 [게임 참여 폴링] 상태: ${status.status}');
        print('   • Success: ${status.success}');
        print('   • 트랜잭션: ${status.txIntents.length}개');
        print('   • Error Message: ${status.errorMessage ?? "없음"}');

        if (status.txIntents.isNotEmpty) {
          for (var tx in status.txIntents) {
            print('   • [${tx.status}] ${tx.txHash ?? "처리 중"} (Intent: ${tx.intentId})');
          }
        }

        // 상태 반환 (매번 yield하여 UI 업데이트)
        yield status;

        // 완료 또는 실패 시 폴링 종료
        if (status.isConfirmed) {
          print('✅ [게임 참여 폴링] 완료! (CONFIRMED 상태)');
          return;
        }

        if (status.isFailed) {
          print('❌ [게임 참여 폴링] 실패: ${status.errorMessage}');
          throw Exception(status.errorMessage ?? '게임 참여 실패');
        }

        // PENDING이나 PROCESSING 상태면 계속 폴링
        if (status.isProcessing) {
          print('   ⏳ 처리 중... (${status.status})');
        } else {
          print('   ⚠️  예상치 못한 상태: ${status.status}');
        }

        // 다음 폴링까지 대기
        await Future.delayed(interval);
      } catch (e) {
        // TimeoutException은 그대로 throw
        if (e is TimeoutException) {
          print('⏱️  [게임 참여 폴링] 타임아웃 예외 발생');
          rethrow;
        }

        // 비즈니스 에러 (게임 참여 실패 등)는 그대로 throw
        if (e.toString().contains('게임 참여') ||
            e.toString().contains('실패') ||
            e.toString().contains('FAILED')) {
          print('❌ [게임 참여 폴링] 비즈니스 에러: $e');
          rethrow;
        }

        // 기타 에러는 로그만 찍고 재시도
        print('⚠️  [게임 참여 폴링] 예외 발생 (재시도 예정): $e');
        print('   • 에러 타입: ${e.runtimeType}');

        if (attempts < maxAttempts) {
          print('   → ${maxAttempts - attempts}회 재시도 남음');
          await Future.delayed(interval);
          continue;
        } else {
          print('   ❌ 최대 재시도 횟수 초과, 에러 throw');
          rethrow;
        }
      }
    }

    // 최대 시도 횟수 초과 (while 루프를 빠져나온 경우)
    print('⏱️  [게임 참여 폴링] 타임아웃 (최대 시도 횟수 초과: $maxAttempts회)');
    throw TimeoutException(
      '게임 참여 처리 타임아웃 (${maxAttempts * interval.inSeconds}초)',
    );
  }
}
