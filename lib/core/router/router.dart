import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/blockpick/blockpick_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
// 새로운 토스 스타일 인증 화면들
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_select_screen.dart';
import '../../features/auth/presentation/pages/email_login_screen.dart';
import '../../features/auth/presentation/pages/signup_select_screen.dart';
import '../../features/auth/presentation/pages/phone_verify_screen.dart';
import '../../features/auth/presentation/pages/email_signup_screen.dart';
import '../../features/auth/presentation/pages/terms_agree_screen.dart';
import '../../features/auth/presentation/pages/email_verify_screen.dart';
import '../../features/auth/presentation/pages/password_setup_screen.dart';
import '../../features/auth/presentation/pages/signup_complete_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/game/game_screen.dart';
import '../../features/game/screens/game_join_test_screen.dart';
import '../../features/optimal/optimal_game_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../auth/domain/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final isAuth = isAuthenticated;
      final currentPath = state.matchedLocation;

      // 인증 관련 경로들 (로그인 안해도 접근 가능)
      final authRoutes = [
        '/splash',
        '/auth/login-select',
        '/auth/email-login',
        '/auth/signup-select',
        '/auth/phone-verify',
        '/auth/email-signup',
        '/auth/terms-agree',
        '/auth/email-verify',
        '/auth/password-setup',
        '/auth/signup-complete',
        '/auth/forgot-password',
        '/login', // 기존 로그인 페이지
        '/signup', // 기존 회원가입 페이지
        '/forgot-password', // 기존 비밀번호 찾기 페이지
      ];

      final isAuthRoute = authRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      // 보호된 경로 목록
      final protectedRoutes = [
        '/block-select',
        '/block-stage',
        '/block-vibe',
        '/my-pick',
        '/my-wallet',
        '/my-profile',
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => currentPath.startsWith(route),
      );

      // 보호된 경로인데 인증 안 됨 -> 로그인으로
      if (isProtectedRoute && !isAuth) {
        return '/auth/login-select?redirect=${Uri.encodeComponent(currentPath)}';
      }

      // 로그인 관련 페이지인데 이미 인증됨 -> 홈으로 (회원가입 완료 제외)
      if (isAuthRoute && isAuth && currentPath != '/auth/signup-complete') {
        // splash, login-select 등에서 이미 로그인된 경우 홈으로
        if (currentPath == '/splash' ||
            currentPath == '/auth/login-select' ||
            currentPath == '/auth/email-login' ||
            currentPath == '/login') {
          final redirect = state.uri.queryParameters['redirect'];
          return redirect ?? '/';
        }
      }

      return null; // 정상 진행
    },
    routes: [
      // 스플래시 화면
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 홈 화면
      GoRoute(
        path: '/',
        builder: (context, state) => const BlockpickScreen(),
      ),

      // ============ 새로운 토스 스타일 인증 플로우 ============
      GoRoute(
        path: '/auth/login-select',
        builder: (context, state) => const LoginSelectScreen(),
      ),
      GoRoute(
        path: '/auth/email-login',
        builder: (context, state) => const EmailLoginScreen(),
      ),
      GoRoute(
        path: '/auth/signup-select',
        builder: (context, state) => const SignupSelectScreen(),
      ),
      GoRoute(
        path: '/auth/phone-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PhoneVerifyScreen(
            provider: extra?['provider'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/auth/email-signup',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EmailSignupScreen(
            phone: extra?['phone'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/auth/terms-agree',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return TermsAgreeScreen(
            provider: extra?['provider'] as String?,
            phone: extra?['phone'] as String?,
            email: extra?['email'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/auth/email-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EmailVerifyScreen(
            email: extra?['email'] as String?,
            phone: extra?['phone'] as String?,
            marketingAgreed: extra?['marketingAgreed'] as bool?,
          );
        },
      ),
      GoRoute(
        path: '/auth/password-setup',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PasswordSetupScreen(
            email: extra?['email'] as String?,
            phone: extra?['phone'] as String?,
            marketingAgreed: extra?['marketingAgreed'] as bool?,
            verificationCode: extra?['verificationCode'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/auth/signup-complete',
        builder: (context, state) => const SignupCompleteScreen(),
      ),
      GoRoute(
        path: '/auth/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // ============ 기존 인증 페이지 (하위 호환성) ============
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ============ 게임 관련 ============
      GoRoute(
        path: '/game/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GameScreen(gameId: gameId);
        },
      ),
      GoRoute(
        path: '/optimal/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return OptimalGameScreen(gameId: gameId);
        },
      ),

      // ============ 설정 ============
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ============ E2E 테스트 ============
      GoRoute(
        path: '/test/game-join',
        builder: (context, state) => const GameJoinTestScreen(),
      ),
    ],
  );
});
