import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/data/datasources/token_local_datasource.dart';
import 'package:http/http.dart' as http;

part 'graphql_client.g.dart';

// Dio를 사용한 커스텀 HTTP 클라이언트
class DioHttpClient extends http.BaseClient {
  final Dio _dio;

  DioHttpClient(this._dio);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    print('📤 DioHttpClient 요청:');
    print('   - URL: ${request.url}');
    print('   - Method: ${request.method}');
    print('   - Headers: ${request.headers}');
    print('   - Timestamp: ${DateTime.now().toIso8601String()}');

    try {
      final options = Options(
        method: request.method,
        headers: request.headers,
        responseType: ResponseType.plain,
        validateStatus: (status) => true, // 모든 상태 코드 허용
        // 응답 헤더 수집
        responseDecoder: null,
      );

      String? body;
      if (request is http.Request) {
        body = request.body;

        // __typename 제거
        if (body != null && body.contains('__typename')) {
          final decoded = jsonDecode(body);
          if (decoded['query'] != null) {
            decoded['query'] = (decoded['query'] as String)
                .replaceAll(RegExp(r'\s*__typename\s*\n'), '\n')
                .replaceAll(RegExp(r'\s*__typename\s*'), '');
            body = jsonEncode(decoded);
          }
        }

        print('   - Body: $body');
      }

      final response = await _dio.request(
        request.url.toString(),
        data: body,
        options: options,
      );

      print('📥 DioHttpClient 응답:');
      print('   - Status: ${response.statusCode}');
      print('   - Timestamp: ${DateTime.now().toIso8601String()}');
      print('   - Headers: ${response.headers.map}');
      print('   - Data length: ${response.data?.toString().length ?? 0}');
      print('   - Data: ${response.data}');

      // 서버 에러 상세 분석
      if (response.data != null && response.data.toString().contains('INTERNAL_ERROR')) {
        print('');
        print('⚠️  서버 INTERNAL_ERROR 감지!');
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('📋 디버깅 정보 (백엔드 팀에 전달):');
        print('   - Request URL: ${request.url}');
        print('   - Request Time: ${DateTime.now().toIso8601String()}');
        print('   - Response Headers:');
        response.headers.map.forEach((key, value) {
          print('     * $key: ${value.join(", ")}');
        });
        try {
          final data = jsonDecode(response.data);
          final error = data['data']?['requestEncryptionKey'];
          if (error != null) {
            print('   - Error Code: ${error['code']}');
            print('   - Error Message: ${error['message']}');
          }
        } catch (e) {
          // JSON 파싱 실패는 무시
        }
        print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        print('');
      }

      return http.StreamedResponse(
        Stream.value(utf8.encode(response.data?.toString() ?? '')),
        response.statusCode ?? 500,
        headers: response.headers.map.map(
          (key, value) => MapEntry(key, value.join(', ')),
        ),
      );
    } catch (e) {
      print('❌ DioHttpClient 에러: $e');
      rethrow;
    }
  }
}

class GraphQLClientService {
  static const String _endpoint = 'https://api-dev.blockpick.net/graphql';
  final TokenLocalDataSource? tokenDataSource;

  GraphQLClientService({this.tokenDataSource});

  GraphQLClient createClient({String? token}) {
    print('🌐 GraphQL Client 생성 (Dio 사용)');
    print('   - Endpoint: $_endpoint');
    print('   - Token: ${token != null ? "있음 (${token.substring(0, 20)}...)" : "없음"}');

    // Dio 인스턴스 생성
    final dio = Dio(BaseOptions(
      baseUrl: _endpoint,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Accept-Encoding': 'gzip, deflate, br',
      },
    ));

    // 인터셉터 추가 (로깅, 토큰 추가, 자동 갱신)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 최신 토큰 가져오기
        if (tokenDataSource != null) {
          final currentToken = await tokenDataSource!.getToken();
          if (currentToken != null) {
            options.headers['Authorization'] = 'Bearer $currentToken';
            print('🔑 Authorization 헤더 추가');
            print('🔑 Token (first 20 chars): ${currentToken.substring(0, currentToken.length > 20 ? 20 : currentToken.length)}...');
            print('🔑 Token length: ${currentToken.length}');
          }
        } else if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Authorization 헤더 추가');
          print('🔑 Token (first 20 chars): ${token!.substring(0, token!.length > 20 ? 20 : token!.length)}...');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Dio 응답 성공: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('❌ Dio 에러: ${error.message}');

        // 401 Unauthorized 에러 처리
        if (error.response?.statusCode == 401 && tokenDataSource != null) {
          print('🔄 토큰 갱신 시도');

          try {
            // RefreshToken 가져오기
            final refreshToken = await tokenDataSource!.getRefreshToken();

            if (refreshToken != null) {
              // 토큰 갱신 요청
              final refreshResponse = await dio.post(
                _endpoint,
                data: {
                  'query': r'''
                    mutation RefreshToken($refreshToken: String!) {
                      refreshToken(refreshToken: $refreshToken) {
                        success
                        accessToken
                        refreshToken
                      }
                    }
                  ''',
                  'variables': {'refreshToken': refreshToken},
                },
              );

              final data = refreshResponse.data?['data']?['refreshToken'];

              if (data?['success'] == true) {
                final newAccessToken = data['accessToken'];
                final newRefreshToken = data['refreshToken'];

                // 새 토큰 저장
                await tokenDataSource!.saveToken(newAccessToken);
                await tokenDataSource!.saveRefreshToken(newRefreshToken);

                print('✅ 토큰 갱신 성공');

                // 원래 요청 재시도
                error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retryResponse = await dio.fetch(error.requestOptions);
                return handler.resolve(retryResponse);
              }
            }
          } catch (e) {
            print('❌ 토큰 갱신 실패: $e');
            // 갱신 실패 시 모든 토큰 삭제 (로그아웃 처리)
            await tokenDataSource!.deleteAllTokens();
          }
        }

        return handler.next(error);
      },
    ));

    // DioHttpClient를 사용한 HttpLink
    final httpLink = HttpLink(
      _endpoint,
      httpClient: DioHttpClient(dio),
    );

    // 로깅을 위한 커스텀 Link
    final loggingLink = Link.function((request, [forward]) {
      print('📤 GraphQL 요청:');
      print('   - Operation: ${request.operation.operationName ?? "unnamed"}');
      print('   - Variables: ${request.variables}');

      return forward!(request).map((response) {
        print('📥 GraphQL 응답:');
        print('   - Data: ${response.data}');
        print('   - Errors: ${response.errors}');
        return response;
      }).handleError((error) {
        print('❌ GraphQL 에러: $error');
        throw error;
      });
    });

    // 에러를 무시하는 Link 추가
    final errorIgnoringLink = Link.function((request, [forward]) {
      return forward!(request).handleError((error) {
        // UnexpectedResponseStructureException은 무시하고 데이터만 반환
        print('⚠️  캐시 에러 무시: $error');
      });
    });

    final Link linkWithErrorHandling = Link.from([
      errorIgnoringLink,
      loggingLink,
      httpLink,
    ]);

    return GraphQLClient(
      cache: GraphQLCache(
        store: InMemoryStore(),
        dataIdFromObject: (object) => null, // 캐시 정규화 비활성화
      ),
      link: linkWithErrorHandling,
      defaultPolicies: DefaultPolicies(
        query: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
        mutate: Policies(
          fetch: FetchPolicy.networkOnly,
        ),
      ),
    );
  }
}

@riverpod
Future<GraphQLClient> graphqlClient(GraphqlClientRef ref) async {
  // 토큰 가져오기
  final tokenDataSource = ref.watch(tokenLocalDataSourceProvider);
  final token = await tokenDataSource.getToken();

  return GraphQLClientService(tokenDataSource: tokenDataSource)
      .createClient(token: token);
}

/// 인증 없는 GraphQL 클라이언트 (공개 API용)
@riverpod
GraphQLClient publicGraphqlClient(PublicGraphqlClientRef ref) {
  return GraphQLClientService().createClient();
}
