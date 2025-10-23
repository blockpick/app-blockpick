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
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.login(email: email, password: password);
      final token = await repository.getToken();

      return AuthState(user: user, token: token);
    });
  }

  // 회원가입
  Future<void> signUp({
    required String email,
    required String password,
    String? name,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.signup(
        email: email,
        password: password,
        name: name,
      );
      final token = await repository.getToken();

      return AuthState(user: user, token: token);
    });
  }

  // 로그아웃
  Future<void> signOut() async {
    final repository = await ref.read(authRepositoryProvider.future);
    await repository.logout();
    state = const AsyncData(AuthState());
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
