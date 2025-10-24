import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/blockpick/blockpick_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/game/game_screen.dart';
import '../auth/domain/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(isAuthenticatedProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuth = isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';

      // 보호된 경로 목록 (Next.js의 PROTECTED_ROUTES와 동일)
      final protectedRoutes = [
        '/block-select',
        '/block-stage',
        '/block-vibe',
        '/my-pick',
        '/my-wallet',
        '/my-profile',
      ];

      final isProtectedRoute = protectedRoutes.any(
        (route) => state.matchedLocation.startsWith(route),
      );

      // 보호된 경로인데 인증 안 됨 -> 로그인으로
      if (isProtectedRoute && !isAuth) {
        return '/login?redirect=${Uri.encodeComponent(state.matchedLocation)}';
      }

      // 로그인 페이지인데 이미 인증됨 -> 홈으로
      if (isLoginRoute && isAuth) {
        final redirect = state.uri.queryParameters['redirect'];
        return redirect ?? '/';
      }

      return null; // 정상 진행
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const BlockpickScreen(),
      ),
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
      GoRoute(
        path: '/game/:gameId',
        builder: (context, state) {
          final gameId = state.pathParameters['gameId']!;
          return GameScreen(gameId: gameId);
        },
      ),
      // TODO: 다른 경로들 추가
      // GoRoute(
      //   path: '/block-select',
      //   builder: (context, state) => const BlockSelectPage(),
      // ),
    ],
  );
});
