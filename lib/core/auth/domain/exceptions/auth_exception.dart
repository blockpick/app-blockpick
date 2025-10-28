/// GraphQL 응답의 success/code/message 구조를 처리하는 예외 클래스
class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({
    required this.message,
    this.code,
  });

  @override
  String toString() => message;
}
