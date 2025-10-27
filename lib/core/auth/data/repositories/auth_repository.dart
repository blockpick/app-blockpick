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

  // 회원가입 1단계 - 이메일 인증 코드 발송
  Future<bool> sendSignUpVerificationCode(String email) async {
    return await _remoteDataSource.sendSignUpVerificationCode(email);
  }

  // 회원가입 2단계 - 인증 코드 확인
  Future<({bool isValid, String? message})> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    return await _remoteDataSource.verifySignUpCode(
      email: email,
      code: code,
    );
  }

  // 회원가입 3단계 - 최종 회원가입 (토큰 없이 User 객체만 반환)
  Future<User> signUp({
    required String email,
    required String password,
    String? nickname,
  }) async {
    final user = await _remoteDataSource.signUp(
      email: email,
      password: password,
      nickname: nickname,
    );

    // 회원가입 후 자동 로그인
    final loginResult = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _localDataSource.saveToken(loginResult.token);

    return user;
  }

  // 비밀번호 찾기 1단계 - 이메일 인증 코드 발송
  Future<bool> sendPasswordResetCode(String email) async {
    return await _remoteDataSource.sendPasswordResetCode(email);
  }

  // 비밀번호 찾기 2단계 - 인증 코드 확인
  Future<({bool isValid, String? message})> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    return await _remoteDataSource.verifyPasswordResetCode(
      email: email,
      code: code,
    );
  }

  // 비밀번호 찾기 3단계 - 새 비밀번호 설정
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    return await _remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
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
