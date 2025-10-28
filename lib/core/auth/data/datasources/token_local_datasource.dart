import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_local_datasource.g.dart';

class TokenLocalDataSource {
  static const _tokenKey = 'auth-token';
  static const _refreshTokenKey = 'refresh-token';
  final FlutterSecureStorage _storage;

  TokenLocalDataSource(this._storage);

  // Access Token 관련
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Refresh Token 관련
  Future<void> saveRefreshToken(String refreshToken) async {
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> deleteRefreshToken() async {
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> hasRefreshToken() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  // 모든 토큰 삭제 (로그아웃/탈퇴 시 사용)
  Future<void> deleteAllTokens() async {
    await Future.wait([
      deleteToken(),
      deleteRefreshToken(),
    ]);
  }
}

@riverpod
TokenLocalDataSource tokenLocalDataSource(TokenLocalDataSourceRef ref) {
  return TokenLocalDataSource(const FlutterSecureStorage());
}
