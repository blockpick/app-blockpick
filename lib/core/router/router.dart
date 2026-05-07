import 'package:flutter/material.dart';
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
import '../../features/game/game_dispatcher_screen.dart';
import '../../features/optimal/optimal_game_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/settings/pages/profile_edit_screen.dart';
import '../../features/settings/pages/email_change_screen.dart';
import '../../features/settings/pages/phone_change_screen.dart';
import '../../features/settings/pages/password_change_screen.dart';
import '../../features/settings/pages/withdrawal_screen.dart';
import '../../features/settings/pages/terms_screen.dart';
import '../../features/settings/pages/privacy_policy_screen.dart';
import '../../features/settings/pages/customer_service_screen.dart';
import '../../features/my/pages/participation_history_screen.dart' as legacy_my;
import '../../features/my/pages/event_points_screen.dart';
import '../../features/my/pages/review_management_screen.dart';
import '../../features/my/pages/review_write_screen.dart';
import '../../features/my/pages/shipping_address_screen.dart';
import '../../features/my/pages/order_history_screen.dart';
import '../../features/my/pages/winning_history_screen.dart' as legacy_my_winning;
// 새 5탭 IA 화면들
import '../../features/blockpick_detail/blockpick_detail_screen.dart';
import '../../features/blockpick_list/blockpick_list_screen.dart';
import '../../features/participation/participation_history_screen.dart';
import '../../features/entry_flow/block_select_screen.dart';
import '../../features/entry_flow/entry_result_screen.dart';
import '../../features/referral/referral_main_screen.dart';
import '../../features/referral/referral_history_screen.dart';
import '../../features/mission/mission_list_screen.dart';
import '../../features/mission/mission_complete_screen.dart';
import '../../features/ad_reward/ad_reward_screen.dart';
import '../../features/ad_reward/ad_reward_complete_screen.dart';
import '../../features/winning/winning_list_screen.dart';
import '../../features/winning/winning_detail_screen.dart';
import '../../features/winning/delivery_address_form_screen.dart';
import '../../features/settings/notification_settings_screen.dart';
import '../../data/blockpick/blockpick_models.dart';
import '../../data/entry/entry_models.dart';
import '../../data/winning/winning_models.dart';
import '../../data/delivery_address/delivery_address_models.dart';
import '../../data/ad_reward/ad_reward_models.dart';
import '../../data/mission/mission_models.dart';
// 별도 라우트 분리: 데일리/위시/프라임 (5탭에서 빠진 옛 게임 모드)
import '../../features/daily/daily_screen.dart';
import '../../features/wish/wish_screen.dart';
import '../../features/prime/prime_screen.dart';
import '../../features/my/pages/transaction_screen.dart';
import '../../features/my/pages/charge_screen.dart';
import '../../features/my/pages/refund_screen.dart';
import '../../features/my/pages/coupon_screen.dart';
import '../../features/my/pages/announcement_screen.dart';
import '../../features/my/pages/usage_guide_screen.dart';
import '../../features/notification/notification_screen.dart';
import '../../features/winners/winners_screen.dart';
import '../../features/winners/winner_detail_screen.dart';
import '../../features/home/widgets/daily_checkin_modal.dart';
import '../../features/common/webview_screen.dart';
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
// Wish (소원)
import '../../features/wish/wish_create_screen.dart';
import '../../features/wish/wish_detail_screen.dart';
import '../../features/wish/my_wishes_screen.dart';

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
            socialId: extra?['socialId'] as String?,
            socialEmail: extra?['socialEmail'] as String?,
            socialName: extra?['socialName'] as String?,
            socialPhotoUrl: extra?['socialPhotoUrl'] as String?,
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
      // 게임 타입별 자동 분기 (DAILY→가차, SELECT→블록선택, VIBE→혼합, PRIME→입찰)
      GoRoute(
        path: '/game/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GameDispatcherScreen(gameId: gameId);
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
        path: '/settings/profile/email',
        builder: (context, state) => const EmailChangeScreen(),
      ),
      GoRoute(
        path: '/settings/profile/phone',
        builder: (context, state) => const PhoneChangeScreen(),
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
        path: '/settings/withdrawal',
        builder: (context, state) => const WithdrawalScreen(),
      ),
      GoRoute(
        path: '/settings/customer-service',
        builder: (context, state) => const CustomerServiceScreen(),
      ),

      // ============ MY 서브 페이지 ============
      // 새 IA: /participation 으로 통합. 옛 /my/game-history 는 호환을 위해 새 화면으로 리다이렉트
      GoRoute(
        path: '/my/game-history',
        builder: (context, state) => const ParticipationHistoryScreen(),
      ),
      GoRoute(
        path: '/participation',
        builder: (context, state) => const ParticipationHistoryScreen(),
      ),
      // 옛 화면이 필요하면 직접 진입
      GoRoute(
        path: '/legacy/my/game-history',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return legacy_my.ParticipationHistoryScreen(
            initialTab: extra?['tab'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/my/shipping-address',
        builder: (context, state) => const ShippingAddressScreen(),
      ),
      GoRoute(
        path: '/my/order-history',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      // 새 IA: /winnings 사용. /my/winning-history 는 호환 진입로
      GoRoute(
        path: '/my/winning-history',
        builder: (context, state) => const WinningListScreen(),
      ),
      GoRoute(
        path: '/legacy/my/winning-history',
        builder: (context, state) => const legacy_my_winning.WinningHistoryScreen(),
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
      GoRoute(
        path: '/my/reviews',
        builder: (context, state) => const ReviewManagementScreen(),
      ),
      GoRoute(
        path: '/my/reviews/write',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return ReviewWriteScreen(
            productName: extra?['productName'] as String? ?? '',
            productImageUrl: extra?['productImageUrl'] as String?,
            eventType: extra?['eventType'] as String? ?? '',
            participatedAt: extra?['participatedAt'] as String? ?? '',
            existingReview: extra?['existingReview'] as String?,
          );
        },
      ),

      GoRoute(
        path: '/my/event-points',
        builder: (context, state) => const EventPointsScreen(),
      ),

      // ============ 위시 (소원) ============
      GoRoute(
        path: '/my/wishes',
        builder: (context, state) => const MyWishesScreen(),
      ),
      GoRoute(
        path: '/wish/create',
        builder: (context, state) => const WishCreateScreen(),
      ),
      GoRoute(
        path: '/wish/:wishId',
        builder: (context, state) {
          final wishId = state.pathParameters['wishId']!;
          return WishDetailScreen(wishId: wishId);
        },
      ),

      // ============ 알림 ============
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),
      GoRoute(
        path: '/settings/notifications',
        builder: (context, state) => const NotificationSettingsScreen(),
      ),

      // ============ 새 IA: 블록픽 ============
      GoRoute(
        path: '/blockpicks',
        builder: (context, state) => const BlockpickListScreen(),
      ),
      GoRoute(
        path: '/blockpick/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BlockpickDetailScreen(blockpickId: id);
        },
      ),

      // ============ 새 IA: 참여 흐름 (블록 선택 → 결과) ============
      GoRoute(
        path: '/entry/select',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final detail = extra?['detail'] as BlockpickDetail?;
          if (detail == null) {
            return const Scaffold(
              body: Center(child: Text('블록픽 정보가 없습니다.')),
            );
          }
          return BlockSelectScreen(detail: detail);
        },
      ),
      GoRoute(
        path: '/entry/result',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final entry = extra?['entry'] as BlockpickEntry?;
          final detail = extra?['detail'] as BlockpickDetail?;
          if (entry == null || detail == null) {
            return const Scaffold(
              body: Center(child: Text('참여 결과 정보가 없습니다.')),
            );
          }
          return EntryResultScreen(entry: entry, detail: detail);
        },
      ),

      // ============ 새 IA: 친구초대 ============
      GoRoute(
        path: '/referral',
        builder: (context, state) => const ReferralMainScreen(),
      ),
      GoRoute(
        path: '/referral/history',
        builder: (context, state) => const ReferralHistoryScreen(),
      ),

      // ============ 새 IA: 미션 ============
      GoRoute(
        path: '/mission',
        builder: (context, state) {
          final blockpickId = state.uri.queryParameters['blockpickId'];
          return MissionListScreen(blockpickId: blockpickId);
        },
      ),
      GoRoute(
        path: '/mission/complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final mission = extra?['mission'] as Mission?;
          final ticketsIssued = extra?['ticketsIssued'] as int? ?? 0;
          if (mission == null) {
            return const Scaffold(
              body: Center(child: Text('미션 정보가 없습니다.')),
            );
          }
          return MissionCompleteScreen(
            mission: mission,
            ticketsIssued: ticketsIssued,
          );
        },
      ),

      // ============ 새 IA: 광고 보상 ============
      GoRoute(
        path: '/ad-reward/:blockpickId',
        builder: (context, state) {
          final blockpickId = state.pathParameters['blockpickId']!;
          return AdRewardScreen(blockpickId: blockpickId);
        },
      ),
      GoRoute(
        path: '/ad-reward/complete',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final log = extra?['log'] as AdRewardLog?;
          final ticketId = extra?['ticketId'] as String?;
          if (log == null) {
            return const Scaffold(
              body: Center(child: Text('보상 정보가 없습니다.')),
            );
          }
          return AdRewardCompleteScreen(log: log, ticketId: ticketId);
        },
      ),

      // ============ 새 IA: 당첨/배송지 ============
      GoRoute(
        path: '/winnings',
        builder: (context, state) => const WinningListScreen(),
      ),
      GoRoute(
        path: '/winning/detail',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final winning = extra?['winning'] as WinningRecord?;
          if (winning == null) {
            return const Scaffold(
              body: Center(child: Text('당첨 정보가 없습니다.')),
            );
          }
          return WinningDetailScreen(winning: winning);
        },
      ),
      GoRoute(
        path: '/delivery-address/new',
        builder: (context, state) =>
            const DeliveryAddressFormScreen(),
      ),
      GoRoute(
        path: '/delivery-address/edit',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final initial = extra?['initial'] as DeliveryAddress?;
          return DeliveryAddressFormScreen(initial: initial);
        },
      ),

      // ============ 옛 게임 모드 별도 진입로 (BottomNav에서 빠짐) ============
      GoRoute(
        path: '/daily',
        builder: (context, state) => const DailyScreen(),
      ),
      GoRoute(
        path: '/wish',
        builder: (context, state) => const WishScreen(),
      ),
      GoRoute(
        path: '/prime',
        builder: (context, state) => const PrimeScreen(),
      ),

      // ============ 당첨자 ============
      GoRoute(
        path: '/winners',
        builder: (context, state) => const WinnersScreen(),
      ),
      GoRoute(
        path: '/winners/:winnerId',
        builder: (context, state) {
          final winnerId = state.pathParameters['winnerId']!;
          return WinnerDetailScreen(winnerId: winnerId);
        },
      ),

      // ============ 출석체크 ============
      GoRoute(
        path: '/checkin',
        builder: (context, state) => const DailyCheckinScreen(),
      ),

      // ============ WebView ============
      GoRoute(
        path: '/webview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return WebViewScreen(
            url: extra?['url'] as String? ?? '',
            title: extra?['title'] as String?,
          );
        },
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
