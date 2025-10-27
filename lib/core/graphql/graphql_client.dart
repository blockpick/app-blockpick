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

    try {
      final options = Options(
        method: request.method,
        headers: request.headers,
        responseType: ResponseType.plain,
        validateStatus: (status) => true, // 모든 상태 코드 허용
      );

      String? body;
      if (request is http.Request) {
        body = request.body;
        print('   - Body: $body');
      }

      final response = await _dio.request(
        request.url.toString(),
        data: body,
        options: options,
      );

      print('📥 DioHttpClient 응답:');
      print('   - Status: ${response.statusCode}');
      print('   - Data length: ${response.data?.toString().length ?? 0}');
      print('   - Data: ${response.data}');

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
  static const String _endpoint = 'https://api-dev.blockpick.net/api/graphql';

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
      },
    ));

    // 인터셉터 추가 (로깅 및 토큰 추가)
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔑 Authorization 헤더 추가');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print('✅ Dio 응답 성공: ${response.statusCode}');
        return handler.next(response);
      },
      onError: (error, handler) {
        print('❌ Dio 에러: ${error.message}');
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

    final Link link = Link.from([
      loggingLink,
      httpLink,
    ]);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }
}

@riverpod
Future<GraphQLClient> graphqlClient(GraphqlClientRef ref) async {
  // 토큰 가져오기
  final tokenDataSource = ref.watch(tokenLocalDataSourceProvider);
  final token = await tokenDataSource.getToken();

  return GraphQLClientService().createClient(token: token);
}
