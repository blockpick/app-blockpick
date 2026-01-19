import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/blockpick/blockpick_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
// 새로운 토스 스타일 인증 화면들
import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/permission_screen.dart';
import '../../features/auth/presentation/pages/onboarding_screen.dart';
// LoginScreen은 더 이상 사용하지 않음 (EmailLoginScreen으로 대체)
import '../../features/auth/presentation/pages/signup_screen.dart';
// login_select_screen은 더 이상 사용하지 않음 (/login = EmailLoginScreen으로 통합)
import '../../features/auth/presentation/pages/email_login_screen.dart';
import '../../features/auth/presentation/pages/signup_select_screen.dart';
import '../../features/auth/presentation/pages/phone_verify_screen.dart';
import '../../features/auth/presentation/pages/email_signup_screen.dart';
import '../../features/auth/presentation/pages/email_password_setup_screen.dart';
import '../../features/auth/presentation/pages/terms_agree_screen.dart';
import '../../features/auth/presentation/pages/email_verify_screen.dart';
import '../../features/auth/presentation/pages/password_setup_screen.dart';
import '../../features/auth/presentation/pages/signup_complete_screen.dart';
import '../../features/auth/presentation/pages/forgot_password_screen.dart';
import '../../features/auth/presentation/pages/find_email_screen.dart';
import '../../features/auth/presentation/pages/find_email_result_screen.dart';
import '../../features/auth/presentation/pages/find_password_screen.dart';
import '../../features/game/game_screen.dart';
import '../../features/game/gacha_game_screen.dart';
import '../../features/game/screens/game_join_test_screen.dart';
import '../../features/optimal/optimal_game_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/pages/profile_edit_screen.dart';
import '../../features/settings/pages/password_change_screen.dart';
import '../../features/settings/pages/terms_screen.dart';
import '../../features/settings/pages/privacy_policy_screen.dart';
import '../../features/settings/pages/customer_service_screen.dart';
import '../../features/my/pages/game_history_screen.dart';
import '../../features/my/pages/order_history_screen.dart';
import '../../features/my/pages/winning_history_screen.dart';
import '../../features/my/pages/transaction_screen.dart';
import '../../features/my/pages/charge_screen.dart';
import '../../features/my/pages/refund_screen.dart';
import '../../features/my/pages/coupon_screen.dart';
import '../../features/my/pages/announcement_screen.dart';
import '../../features/my/pages/usage_guide_screen.dart';
import '../../features/notification/notification_screen.dart';
import '../../features/winners/winners_screen.dart';
import '../auth/domain/providers/auth_provider.dart';
// More modes
import '../../features/more/modes/gravity_pick_screen.dart';
import '../../features/more/modes/time_pick_screen.dart';
import '../../features/more/modes/draw_pick_screen.dart';
import '../../features/more/modes/wave_pick_screen.dart';
import '../../features/more/modes/voice_pick_screen.dart';
import '../../features/more/modes/farm_pick_screen.dart';
import '../../features/more/modes/rpg_pick_screen.dart';
import '../../features/more/modes/duo_pick_screen.dart';
import '../../features/more/modes/fortune_pick_screen.dart';
import '../../features/more/modes/predict_pick_screen.dart';
import '../../features/more/modes/gacha_pick_screen.dart';
import '../../features/more/modes/treasure_pick_screen.dart';
// Unity 3D Game
import '../../features/more/unity/unity_blockpick_screen.dart';
import '../../features/more/unity/unity_game_select_screen.dart';

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
        '/permission',
        '/onboarding',
        '/login',
        '/signup',
        '/phone-verify',
        '/email-password-setup',
        '/find-email',
        '/find-email-result',
        '/find-password',
        '/auth/email-login',
        '/auth/signup-select',
        '/auth/phone-verify',
        '/auth/email-signup',
        '/auth/terms-agree',
        '/auth/email-verify',
        '/auth/password-setup',
        '/auth/signup-complete',
        '/auth/forgot-password',
        '/forgot-password', // 기존 비밀번호 찾기 페이지
        '/settings/privacy', // 개인정보처리방침 (공개)
        '/settings/terms', // 이용약관 (공개)
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
        return '/login?redirect=${Uri.encodeComponent(currentPath)}';
      }

      // 로그인 관련 페이지인데 이미 인증됨 -> 홈으로 (회원가입 완료 제외)
      if (isAuthRoute && isAuth && currentPath != '/auth/signup-complete') {
        // splash, login 등에서 이미 로그인된 경우 홈으로
        if (currentPath == '/splash' ||
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

      // 권한 설정 화면
      GoRoute(
        path: '/permission',
        builder: (context, state) => const PermissionScreen(),
      ),

      // 온보딩 화면
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // 홈 화면
      GoRoute(
        path: '/',
        builder: (context, state) => const BlockpickScreen(),
      ),

      // ============ 새로운 인증 플로우 ============
      // 로그인 화면 (이메일 로그인이 기본)
      GoRoute(
        path: '/login',
        builder: (context, state) => const EmailLoginScreen(),
      ),

      // 회원가입 화면
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),

      // 휴대폰 인증 화면
      GoRoute(
        path: '/phone-verify',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PhoneVerifyScreen(
            signupType: extra?['signupType'] as String?,
            flowType: extra?['flowType'] as String?,
          );
        },
      ),

      // 이메일/비밀번호 설정 화면
      GoRoute(
        path: '/email-password-setup',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return EmailPasswordSetupScreen(
            phone: extra?['phone'] as String?,
            phoneE164: extra?['phoneE164'] as String?,
            agreeMarketing: extra?['agreeMarketing'] as bool?,
          );
        },
      ),

      // 이메일 찾기 화면
      GoRoute(
        path: '/find-email',
        builder: (context, state) => const FindEmailScreen(),
      ),

      // 이메일 찾기 결과 화면
      GoRoute(
        path: '/find-email-result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return FindEmailResultScreen(
            phone: extra?['phone'] as String?,
            phoneE164: extra?['phoneE164'] as String?,
          );
        },
      ),

      // 비밀번호 찾기 화면
      GoRoute(
        path: '/find-password',
        builder: (context, state) => const FindPasswordScreen(),
      ),

      // ============ 새로운 토스 스타일 인증 플로우 ============
      // /auth/login-select는 더 이상 사용하지 않음 (/login으로 통합)
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
            signupType: extra?['provider'] as String?,
            flowType: 'signup',
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
        path: '/old-login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/old-signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ============ 게임 관련 ============
      // Gacha 스타일 게임 화면 (기본)
      GoRoute(
        path: '/game/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GachaGameScreen(gameId: gameId);
        },
      ),
      // 기존 그리드 방식 게임 화면 (백업)
      GoRoute(
        path: '/game-grid/:gameId',
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
      GoRoute(
        path: '/settings/profile',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/settings/password',
        builder: (context, state) => const PasswordChangeScreen(),
      ),
      GoRoute(
        path: '/settings/terms',
        builder: (context, state) => const TermsScreen(),
      ),
      GoRoute(
        path: '/settings/privacy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/settings/customer-service',
        builder: (context, state) => const CustomerServiceScreen(),
      ),

      // ============ MY 서브 페이지 ============
      GoRoute(
        path: '/my/game-history',
        builder: (context, state) => const GameHistoryScreen(),
      ),
      GoRoute(
        path: '/my/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/my/winning-history',
        builder: (context, state) => const WinningHistoryScreen(),
      ),
      GoRoute(
        path: '/my/transactions',
        builder: (context, state) => const TransactionScreen(),
      ),
      GoRoute(
        path: '/my/charge',
        builder: (context, state) => const ChargeScreen(),
      ),
      GoRoute(
        path: '/my/refund',
        builder: (context, state) => const RefundScreen(),
      ),
      GoRoute(
        path: '/my/coupon',
        builder: (context, state) => const CouponScreen(),
      ),
      GoRoute(
        path: '/my/announcements',
        builder: (context, state) => const AnnouncementScreen(),
      ),
      GoRoute(
        path: '/my/usage-guide',
        builder: (context, state) => const UsageGuideScreen(),
      ),

      // ============ 알림 ============
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      // ============ 당첨자 ============
      GoRoute(
        path: '/winners',
        builder: (context, state) => const WinnersScreen(),
      ),

      // ============ E2E 테스트 ============
      GoRoute(
        path: '/test/game-join',
        builder: (context, state) => const GameJoinTestScreen(),
      ),

      // ============ More 모드들 ============
      GoRoute(
        path: '/more/gravity',
        builder: (context, state) => const GravityPickScreen(),
      ),
      GoRoute(
        path: '/more/time',
        builder: (context, state) => const TimePickScreen(),
      ),
      GoRoute(
        path: '/more/draw',
        builder: (context, state) => const DrawPickScreen(),
      ),
      GoRoute(
        path: '/more/wave',
        builder: (context, state) => const WavePickScreen(),
      ),
      GoRoute(
        path: '/more/voice',
        builder: (context, state) => const VoicePickScreen(),
      ),
      GoRoute(
        path: '/more/farm',
        builder: (context, state) => const FarmPickScreen(),
      ),
      GoRoute(
        path: '/more/rpg',
        builder: (context, state) => const RpgPickScreen(),
      ),
      GoRoute(
        path: '/more/duo',
        builder: (context, state) => const DuoPickScreen(),
      ),
      GoRoute(
        path: '/more/fortune',
        builder: (context, state) => const FortunePickScreen(),
      ),
      GoRoute(
        path: '/more/predict',
        builder: (context, state) => const PredictPickScreen(),
      ),
      GoRoute(
        path: '/more/gacha',
        builder: (context, state) => const GachaPickScreen(),
      ),
GoRoute(
        path: '/more/treasure',
        builder: (context, state) => const TreasurePickScreen(),
      ),

      // ============ Unity 3D 게임 ============
      // 게임 선택 화면
      GoRoute(
        path: '/more/unity',
        builder: (context, state) => const UnityGameSelectScreen(),
      ),
      // Unity 게임 플레이 화면
      GoRoute(
        path: '/more/unity/play',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return UnityBlockpickScreen(
            gameId: extra?['gameId'] as String?,
            gridRows: extra?['gridRows'] as int?,
            gridCols: extra?['gridCols'] as int?,
            imageUrl: extra?['imageUrl'] as String?,
            title: extra?['title'] as String?,
          );
        },
      ),
      GoRoute(
        path: '/unity-game/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          final rows = int.tryParse(state.uri.queryParameters['rows'] ?? '100');
          final cols = int.tryParse(state.uri.queryParameters['cols'] ?? '100');
          final imageUrl = state.uri.queryParameters['imageUrl'];
          final title = state.uri.queryParameters['title'];
          return UnityBlockpickScreen(
            gameId: gameId,
            gridRows: rows,
            gridCols: cols,
            imageUrl: imageUrl,
            title: title,
          );
        },
      ),
    ],
  );
});
