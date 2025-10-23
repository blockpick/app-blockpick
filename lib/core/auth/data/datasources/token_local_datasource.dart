import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_local_datasource.g.dart';

class TokenLocalDataSource {
  static const _tokenKey = 'auth-token';
  final FlutterSecureStorage _storage;

  TokenLocalDataSource(this._storage);

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
}

@riverpod
TokenLocalDataSource tokenLocalDataSource(TokenLocalDataSourceRef ref) {
  return TokenLocalDataSource(const FlutterSecureStorage());
}
