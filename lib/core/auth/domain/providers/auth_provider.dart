import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../../data/repositories/auth_repository.dart';

part 'auth_provider.g.dart';

// 인증 상태 클래스
class AuthState {
  final User? user;
  final String? token;

  const AuthState({this.user, this.token});

  bool get isAuthenticated => token != null;

  AuthState copyWith({User? user, String? token}) {
    return AuthState(
      user: user ?? this.user,
      token: token ?? this.token,
    );
  }
}

@riverpod
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    // 앱 시작 시 저장된 토큰 확인
    final repository = await ref.watch(authRepositoryProvider.future);

    final token = await repository.getToken();
    if (token == null) {
      return const AuthState();
    }

    // 토큰이 있으면 초기 상태 설정
    // Next.js의 localStorage 복원 로직과 동일

    // 백그라운드에서 실제 유저 정보 가져오기
    repository.getCurrentUser().then((user) {
      if (user != null) {
        state = AsyncData(AuthState(user: user, token: token));
      }
    }).catchError((_) {
      // me 쿼리 실패해도 JWT 토큰으로 인증 유지
      print('JWT 토큰으로 인증 유지');
    });

    return AuthState(token: token);
  }

  // 로그인
  Future<void> signIn(String email, String password) async {
    print('🔐 로그인 시도: $email');
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.login(email: email, password: password);
      final token = await repository.getToken();

      print('✅ 로그인 성공!');
      print('   - 이메일: ${user.email}');
      print('   - 토큰: ${token?.substring(0, 20)}...');
      print('   - 사용자: ${user.nickname ?? "이름 없음"}');

      return AuthState(user: user, token: token);
    });

    // 에러 발생 시 로그
    state.whenOrNull(
      error: (error, stackTrace) {
        print('❌ 로그인 실패: $error');
      },
    );
  }

  // 회원가입 1단계 - 이메일 인증 코드 발송
  Future<bool> sendSignUpVerificationCode(String email) async {
    print('📧 회원가입 1단계: 인증 코드 발송 요청 - $email');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.sendSignUpVerificationCode(email);
    print(result ? '✅ 인증 코드 발송 성공' : '❌ 인증 코드 발송 실패');
    return result;
  }

  // 회원가입 2단계 - 인증 코드 확인
  Future<({bool isValid, String? message})> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    print('🔍 회원가입 2단계: 인증 코드 확인 - $code');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.verifySignUpCode(email: email, code: code);
    print(result.isValid ? '✅ 인증 코드 확인 성공' : '❌ 인증 코드 확인 실패: ${result.message}');
    return result;
  }

  // 회원가입 3단계 - 최종 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    String? nickname,
  }) async {
    print('📝 회원가입 3단계: 최종 회원가입 - $email');
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.signUp(
        email: email,
        password: password,
        nickname: nickname,
      );
      final token = await repository.getToken();

      print('✅ 회원가입 성공!');
      print('   - 이메일: ${user.email}');
      print('   - 닉네임: ${user.nickname}');
      print('   - 토큰: ${token?.substring(0, 20)}...');

      return AuthState(user: user, token: token);
    });

    // 에러 발생 시 로그
    state.whenOrNull(
      error: (error, stackTrace) {
        print('❌ 회원가입 실패: $error');
      },
    );
  }

  // 비밀번호 찾기 1단계 - 이메일 인증 코드 발송
  Future<bool> sendPasswordResetCode(String email) async {
    print('🔑 비밀번호 찾기 1단계: 인증 코드 발송 요청 - $email');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.sendPasswordResetCode(email);
    print(result ? '✅ 인증 코드 발송 성공' : '❌ 인증 코드 발송 실패');
    return result;
  }

  // 비밀번호 찾기 2단계 - 인증 코드 확인
  Future<({bool isValid, String? message})> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    print('🔍 비밀번호 찾기 2단계: 인증 코드 확인 - $code');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.verifyPasswordResetCode(email: email, code: code);
    print(result.isValid ? '✅ 인증 코드 확인 성공' : '❌ 인증 코드 확인 실패: ${result.message}');
    return result;
  }

  // 비밀번호 찾기 3단계 - 새 비밀번호 설정
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    print('🔐 비밀번호 찾기 3단계: 새 비밀번호 설정 - $email');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
    print(result ? '✅ 비밀번호 재설정 성공' : '❌ 비밀번호 재설정 실패');
    return result;
  }

  // 로그아웃
  Future<void> signOut() async {
    print('🚪 로그아웃 시도');
    final repository = await ref.read(authRepositoryProvider.future);
    await repository.logout();
    state = const AsyncData(AuthState());
    print('✅ 로그아웃 성공');
  }

  // 유저 정보 새로고침
  Future<void> refreshUser() async {
    final repository = await ref.read(authRepositoryProvider.future);
    final user = await repository.getCurrentUser();
    final token = await repository.getToken();

    if (user != null) {
      state = AsyncData(AuthState(user: user, token: token));
    }
  }
}

// 편의 Provider들
@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authProvider);
  return authState.valueOrNull?.isAuthenticated ?? false;
}

@riverpod
User? currentUser(CurrentUserRef ref) {
  return ref.watch(authProvider).valueOrNull?.user;
}

@riverpod
String? authToken(AuthTokenRef ref) {
  return ref.watch(authProvider).valueOrNull?.token;
}
