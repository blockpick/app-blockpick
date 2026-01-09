import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../services/blockchain_wallet_service.dart';

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

@Riverpod(keepAlive: false)
class Auth extends _$Auth {
  @override
  Future<AuthState> build() async {
    print('🚀 Auth Provider build() 시작');
    // 앱 시작 시 저장된 토큰 확인
    final repository = await ref.watch(authRepositoryProvider.future);
    print('   - repository 획득');

    final token = await repository.getToken();
    print('   - token: ${token != null ? "있음" : "없음"}');
    if (token == null) {
      print('   - token 없음, 빈 AuthState 반환');
      return const AuthState();
    }

    // 토큰이 있으면 유저 정보 가져오기
    print('   - getCurrentUser() 호출 시작');
    try {
      final user = await repository.getCurrentUser();
      print('   - getCurrentUser() 결과: ${user != null ? user.email : "null"}');
      if (user != null) {
        print('✅ 사용자 정보 로드 성공: ${user.email}');
        return AuthState(user: user, token: token);
      }
    } catch (e) {
      print('⚠️ 사용자 정보 로드 실패: $e');
      print('   - 스택 트레이스: ${StackTrace.current}');
      // me 쿼리 실패해도 JWT 토큰으로 인증 유지
    }

    print('   - user null, token만 있는 AuthState 반환');
    return AuthState(token: token);
  }

  // 로그인 + 지갑 확인/생성
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

      // 🔑 로그인 후 블록체인 지갑 확인/생성 (사용자 모르게)
      try {
        final walletService = BlockchainWalletService();
        final hasWallet = await walletService.hasWallet();

        if (!hasWallet) {
          print('');
          print('┌─────────────────────────────────────────────────────────┐');
          print('│ 🔑 블록체인 지갑 자동 생성 (백그라운드)                   │');
          print('└─────────────────────────────────────────────────────────┘');

          final credentials = await walletService.getOrCreateWallet();
          final walletAddress = credentials.address.hex;

          print('✅ 블록체인 지갑 생성 완료!');
          print('   • 지갑 주소: $walletAddress');
          print('   ⚠️  사용자는 지갑 생성을 알 필요 없음');
          print('');
        }
      } catch (e) {
        print('⚠️ 지갑 확인/생성 실패 (나중에 재시도 가능): $e');
      }

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

  // 회원가입 3단계 - 최종 회원가입 + 지갑 자동 생성
  Future<void> signUp({
    required String email,
    required String password,
    required String phoneNumber,
    String? nickname,
  }) async {
    print('📝 회원가입 3단계: 최종 회원가입 - $email');
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.signUp(
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        nickname: nickname,
      );
      final token = await repository.getToken();

      print('✅ 회원가입 성공!');
      print('   - 이메일: ${user.email}');
      print('   - 닉네임: ${user.nickname}');
      print('   - 토큰: ${token?.substring(0, 20)}...');

      // 🔑 회원가입 후 블록체인 지갑 자동 생성 (사용자 모르게)
      print('');
      print('┌─────────────────────────────────────────────────────────┐');
      print('│ 🔑 블록체인 지갑 자동 생성 시작 (백그라운드)              │');
      print('└─────────────────────────────────────────────────────────┘');

      try {
        final walletService = BlockchainWalletService();

        // 기존 지갑 확인
        final hasWallet = await walletService.hasWallet();

        if (!hasWallet) {
          print('→ 지갑이 없습니다. 새로 생성합니다...');
          final credentials = await walletService.getOrCreateWallet();
          final walletAddress = credentials.address.hex;

          print('✅ 블록체인 지갑 생성 완료!');
          print('   • 지갑 주소: $walletAddress');
          print('   • 저장 위치: 디바이스 보안 저장소 (Keychain/EncryptedSharedPreferences)');
          print('   ⚠️  사용자는 지갑 생성을 알 필요 없음 (자동 처리)');
        } else {
          print('✓ 기존 지갑이 이미 존재합니다.');
          final walletAddress = await walletService.getWalletAddress();
          print('   • 지갑 주소: $walletAddress');
        }

        print('└─────────────────────────────────────────────────────────┘');
        print('');
      } catch (e) {
        // 지갑 생성 실패해도 회원가입은 성공으로 처리
        print('⚠️ 지갑 생성 실패 (나중에 재시도 가능): $e');
        print('   → 회원가입은 성공했으므로 계속 진행합니다.');
      }

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

  // 소셜 로그인
  Future<void> socialSignIn({
    required String provider,
    required String socialId,
    required String email,
    String? name,
    String? profileImageUrl,
  }) async {
    print('🔐 소셜 로그인 시도: $provider - $email');
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = await ref.read(authRepositoryProvider.future);
      final user = await repository.socialLogin(
        provider: provider,
        socialId: socialId,
        email: email,
        name: name,
        profileImageUrl: profileImageUrl,
      );
      final token = await repository.getToken();

      print('✅ 소셜 로그인 성공!');
      print('   - 이메일: ${user.email}');
      print('   - 토큰: ${token?.substring(0, 20)}...');

      // 🔑 로그인 후 블록체인 지갑 확인/생성 (사용자 모르게)
      try {
        final walletService = BlockchainWalletService();
        final hasWallet = await walletService.hasWallet();

        if (!hasWallet) {
          print('');
          print('┌─────────────────────────────────────────────────────────┐');
          print('│ 🔑 블록체인 지갑 자동 생성 (백그라운드)                   │');
          print('└─────────────────────────────────────────────────────────┘');

          final credentials = await walletService.getOrCreateWallet();
          final walletAddress = credentials.address.hex;

          print('✅ 블록체인 지갑 생성 완료!');
          print('   • 지갑 주소: $walletAddress');
        }
      } catch (e) {
        print('⚠️ 지갑 확인/생성 실패 (나중에 재시도 가능): $e');
      }

      return AuthState(user: user, token: token);
    });

    // 에러 발생 시 로그
    state.whenOrNull(
      error: (error, stackTrace) {
        print('❌ 소셜 로그인 실패: $error');
      },
    );
  }

  // SMS 인증 코드 발송
  Future<({bool success, String? code, String? message})> sendSmsVerificationCode({
    required String phoneNumber,
    required String verifyType,
  }) async {
    print('📱 SMS 인증 코드 발송 요청: $phoneNumber ($verifyType)');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.sendSmsVerificationCode(
      phoneNumber: phoneNumber,
      verifyType: verifyType,
    );
    print(result.success ? '✅ SMS 인증 코드 발송 성공' : '❌ SMS 인증 코드 발송 실패: ${result.message}');
    return result;
  }

  // SMS 인증 코드 검증
  Future<({bool success, String? message})> verifySmsCode({
    required String phoneNumber,
    required String code,
    required String verifyType,
  }) async {
    print('🔍 SMS 인증 코드 검증: $phoneNumber');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.verifySmsCode(
      phoneNumber: phoneNumber,
      code: code,
      verifyType: verifyType,
    );
    print(result.success ? '✅ SMS 인증 코드 검증 성공' : '❌ SMS 인증 코드 검증 실패: ${result.message}');
    return result;
  }

  // 이메일 찾기 (SMS 인증 완료 후)
  Future<({bool success, String? code, String? message, String? email})> findEmail({
    required String phoneNumber,
  }) async {
    print('📧 이메일 찾기 요청: $phoneNumber');
    final repository = await ref.read(authRepositoryProvider.future);
    final result = await repository.findEmail(phoneNumber: phoneNumber);
    print(result.success ? '✅ 이메일 찾기 성공: ${result.email}' : '❌ 이메일 찾기 실패: ${result.message}');
    return result;
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
