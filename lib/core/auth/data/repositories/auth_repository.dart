import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/token_local_datasource.dart';
import '../../../graphql/graphql_client.dart';

part 'auth_repository.g.dart';

class AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenLocalDataSource _localDataSource;

  AuthRepository(this._remoteDataSource, this._localDataSource);

  // 로그인
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDataSource.login(
      email: email,
      password: password,
    );

    // 토큰 저장
    await _localDataSource.saveToken(result.token);

    // 기본 유저 정보 반환
    return User(email: result.email);
  }

  // 회원가입
  Future<User> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    final result = await _remoteDataSource.signup(
      email: email,
      password: password,
      name: name,
    );

    // 토큰 저장
    await _localDataSource.saveToken(result.token);

    // 기본 유저 정보 반환
    return User(email: result.email, name: name);
  }

  // 현재 유저 정보 가져오기 (백그라운드)
  Future<User?> getCurrentUser() async {
    return await _remoteDataSource.fetchCurrentUser();
  }

  // 로그아웃
  Future<void> logout() async {
    await _localDataSource.deleteToken();
  }

  // 토큰 확인
  Future<bool> hasValidToken() async {
    return await _localDataSource.hasToken();
  }

  // 저장된 토큰 가져오기
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }
}

@riverpod
Future<AuthRepository> authRepository(AuthRepositoryRef ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  final remoteDataSource = AuthRemoteDataSource(client);
  final localDataSource = ref.watch(tokenLocalDataSourceProvider);

  return AuthRepository(remoteDataSource, localDataSource);
}
