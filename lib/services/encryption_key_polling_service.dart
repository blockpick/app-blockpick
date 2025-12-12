import 'dart:async';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/encryption_key_status.dart';

/// encryptionKeyStatus 쿼리
const String _encryptionKeyStatusQuery = r'''
  query EncryptionKeyStatus($requestId: String!) {
    encryptionKeyStatus(requestId: $requestId) {
      success
      requestId
      status
      txHash
      errorCode
      errorMessage
    }
  }
''';

/// 암호화 키 생성 상태 폴링 서비스
class EncryptionKeyPollingService {
  final GraphQLClient client;

  EncryptionKeyPollingService({required this.client});

  /// 암호화 키 생성 상태 폴링
  ///
  /// [requestId]: requestEncryptionKey에서 받은 요청 ID
  /// [interval]: 폴링 간격 (기본 2초)
  /// [maxAttempts]: 최대 시도 횟수 (기본 30회 = 약 1분)
  ///
  /// Returns: EncryptionKeyStatus 스트림
  /// - COMPLETED 또는 FAILED 상태가 되면 스트림 종료
  /// - 최대 시도 횟수 초과 시 TimeoutException 발생
  Stream<EncryptionKeyStatus> pollEncryptionKeyStatus(
    String requestId, {
    Duration interval = const Duration(seconds: 2),
    int maxAttempts = 30,
  }) async* {
    int attempts = 0;

    while (attempts < maxAttempts) {
      attempts++;

      try {
        print('🔄 [암호화 키 폴링] 시도 $attempts/$maxAttempts (requestId: $requestId)');

        final result = await client.query(
          QueryOptions(
            document: gql(_encryptionKeyStatusQuery),
            variables: {'requestId': requestId},
            fetchPolicy: FetchPolicy.noCache, // 캐시 완전 비활성화 (__typename 에러 방지)
          ),
        );

        if (result.hasException) {
          final exceptionStr = result.exception.toString();
          print('⚠️  [암호화 키 폴링] GraphQL 에러: $exceptionStr');

          // 네트워크 에러 확인
          final isNetworkError = exceptionStr.contains('Network') ||
                                  exceptionStr.contains('SocketException') ||
                                  exceptionStr.contains('TimeoutException');

          // 네트워크 에러는 재시도
          if (isNetworkError && attempts < maxAttempts) {
            print('   → 네트워크 에러 감지, ${maxAttempts - attempts}회 재시도 남음');
            await Future.delayed(interval);
            continue;
          } else if (attempts < maxAttempts) {
            // 기타 에러도 일단 재시도 (최대 3번)
            if (attempts <= 3) {
              print('   → ${maxAttempts - attempts}회 재시도 남음');
              await Future.delayed(interval);
              continue;
            }
            throw Exception('암호화 키 상태 조회 실패: ${result.exception}');
          } else {
            throw Exception('암호화 키 상태 조회 실패 (재시도 초과): ${result.exception}');
          }
        }

        final data = result.data?['encryptionKeyStatus'];
        if (data == null) {
          print('⚠️  [암호화 키 폴링] 응답 데이터 없음');

          if (attempts < maxAttempts) {
            await Future.delayed(interval);
            continue;
          } else {
            throw Exception('암호화 키 상태 응답이 없습니다');
          }
        }

        final status = EncryptionKeyStatus.fromJson(data as Map<String, dynamic>);
        print('📊 [암호화 키 폴링] 상태: ${status.status}');

        if (status.txHash != null) {
          print('   • TX Hash: ${status.txHash}');
        }

        // 상태 반환
        yield status;

        // 완료 또는 실패 시 폴링 종료
        if (status.isCompleted) {
          print('✅ [암호화 키 폴링] 완료!');
          return;
        }

        if (status.isFailed) {
          print('❌ [암호화 키 폴링] 실패: ${status.errorMessage}');
          throw Exception(status.errorMessage ?? '암호화 키 생성 실패');
        }

        // 다음 폴링까지 대기
        await Future.delayed(interval);
      } catch (e) {
        if (e.toString().contains('암호화 키')) {
          rethrow; // 비즈니스 에러는 그대로 throw
        }

        // 기타 에러는 로그만 찍고 재시도
        print('⚠️  [암호화 키 폴링] 에러 발생 (재시도 예정): $e');

        if (attempts < maxAttempts) {
          await Future.delayed(interval);
          continue;
        } else {
          rethrow;
        }
      }
    }

    // 최대 시도 횟수 초과
    print('⏱️  [암호화 키 폴링] 타임아웃 (최대 시도 횟수 초과)');
    throw TimeoutException(
      '암호화 키 생성 타임아웃 (${maxAttempts * interval.inSeconds}초)',
    );
  }
}
