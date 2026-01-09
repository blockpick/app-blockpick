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
    await _localDataSource.saveToken(result.accessToken);
    await _localDataSource.saveRefreshToken(result.refreshToken);

    // 유저 정보 반환
    return result.user;
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

  // 회원가입 3단계 - 최종 회원가입
  Future<User> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    String? nickname,
  }) async {
    final user = await _remoteDataSource.signUp(
      email: email,
      password: password,
      phoneNumber: phoneNumber,
      nickname: nickname,
    );

    // 회원가입 후 자동 로그인
    final loginResult = await _remoteDataSource.login(
      email: email,
      password: password,
    );
    await _localDataSource.saveToken(loginResult.accessToken);
    await _localDataSource.saveRefreshToken(loginResult.refreshToken);

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
      verificationCode: code,
      newPassword: newPassword,
    );
  }

  // 현재 유저 정보 가져오기 (백그라운드)
  Future<User?> getCurrentUser() async {
    return await _remoteDataSource.fetchCurrentUser();
  }

  // 로그아웃
  Future<void> logout() async {
    await _localDataSource.deleteAllTokens();
  }

  // 토큰 확인
  Future<bool> hasValidToken() async {
    return await _localDataSource.hasToken();
  }

  // 저장된 토큰 가져오기
  Future<String?> getToken() async {
    return await _localDataSource.getToken();
  }

  // 토큰 갱신
  Future<User> refreshToken(String refreshToken) async {
    final result = await _remoteDataSource.refreshToken(refreshToken);
    await _localDataSource.saveToken(result.accessToken);
    await _localDataSource.saveRefreshToken(result.refreshToken);
    return result.user;
  }

  // 비밀번호 변경
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return await _remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  // 회원 탈퇴
  Future<bool> withdrawUser({
    required String password,
    String? reason,
  }) async {
    final success = await _remoteDataSource.withdrawUser(
      password: password,
      reason: reason,
    );

    if (success) {
      // 탈퇴 성공 시 모든 토큰 삭제
      await _localDataSource.deleteAllTokens();
    }

    return success;
  }

  // 소셜 로그인
  Future<User> socialLogin({
    required String provider,
    required String socialId,
    required String email,
    String? name,
    String? profileImageUrl,
  }) async {
    final result = await _remoteDataSource.socialLogin(
      provider: provider,
      socialId: socialId,
      email: email,
      name: name,
      profileImageUrl: profileImageUrl,
    );

    // 토큰 저장
    await _localDataSource.saveToken(result.accessToken);
    await _localDataSource.saveRefreshToken(result.refreshToken);

    // 유저 정보 반환
    return result.user;
  }

  // SMS 인증 코드 발송
  Future<({bool success, String? code, String? message})> sendSmsVerificationCode({
    required String phoneNumber,
    required String verifyType,
  }) async {
    return await _remoteDataSource.sendSmsVerificationCode(
      phoneNumber: phoneNumber,
      verifyType: verifyType,
    );
  }

  // SMS 인증 코드 검증
  Future<({bool success, String? message})> verifySmsCode({
    required String phoneNumber,
    required String code,
    required String verifyType,
  }) async {
    return await _remoteDataSource.verifySmsCode(
      phoneNumber: phoneNumber,
      code: code,
      verifyType: verifyType,
    );
  }

  // 이메일 찾기 (SMS 인증 완료 후)
  Future<({bool success, String? code, String? message, String? email})> findEmail({
    required String phoneNumber,
  }) async {
    return await _remoteDataSource.findEmail(
      phoneNumber: phoneNumber,
    );
  }

  // 전화번호 가입 여부 확인
  Future<({bool success, String? code, String? message, bool exists})> checkPhoneNumber({
    required String phoneNumber,
  }) async {
    return await _remoteDataSource.checkPhoneNumber(
      phoneNumber: phoneNumber,
    );
  }
}

@riverpod
Future<AuthRepository> authRepository(AuthRepositoryRef ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  final remoteDataSource = AuthRemoteDataSource(client);
  final localDataSource = ref.watch(tokenLocalDataSourceProvider);

  return AuthRepository(remoteDataSource, localDataSource);
}
