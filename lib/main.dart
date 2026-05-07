import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'core/analytics/analytics_service.dart';
import 'core/deep_link/deep_link_service.dart';
import 'core/notification/fcm_config.dart';
import 'core/observability/sentry_config.dart';
import 'core/router/router.dart';
import 'core/sharing/kakao_share_service.dart';
import 'core/theme/app_theme.dart';
import 'services/admob_service.dart';

Future<void> main() async {
  // Sentry zone으로 감싸서 글로벌 에러 캡처
  await SentryConfig.init(_bootstrap);
}

/// Sentry zone 내에서 실행되는 실제 부트스트랩
Future<void> _bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 웹에서 path 기반 URL 사용 (# 없는 깔끔한 URL)
  usePathUrlStrategy();

  // ── Firebase 초기화 (FCM의 전제 조건) ──────────────────────────────────────
  // google-services.json / GoogleService-Info.plist 미추가 시 예외 발생 → SKIP
  try {
    await Firebase.initializeApp();
    if (kDebugMode) debugPrint('[Bootstrap] Firebase 초기화 완료');
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Firebase 초기화 실패 (google-services 파일 확인): $e');
    }
  }

  // ── FCM 초기화 ─────────────────────────────────────────────────────────────
  try {
    await FcmConfig.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] FCM 초기화 실패: $e');
    }
  }

  // ── Kakao SDK 초기화 ───────────────────────────────────────────────────────
  try {
    await KakaoShareService.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Kakao SDK 초기화 실패: $e');
    }
  }

  // ── Mixpanel Analytics 초기화 ──────────────────────────────────────────────
  try {
    await AnalyticsService.init();
  } catch (e) {
    if (kDebugMode) {
      debugPrint('[Bootstrap] Analytics 초기화 실패: $e');
    }
  }

  // ── AdMob 초기화 (웹 제외) ─────────────────────────────────────────────────
  if (!kIsWeb) {
    try {
      await AdMobService.initialize();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Bootstrap] AdMob 초기화 실패: $e');
      }
    }
  }

  runApp(
    // Riverpod Provider 스코프
    const ProviderScope(
      child: BlockPickApp(),
    ),
  );
}

/// BlockPick 앱
class BlockPickApp extends ConsumerStatefulWidget {
  const BlockPickApp({super.key});

  @override
  ConsumerState<BlockPickApp> createState() => _BlockPickAppState();
}

class _BlockPickAppState extends ConsumerState<BlockPickApp> {
  @override
  void initState() {
    super.initState();
    // DeepLink 서비스 초기화 — router가 준비된 후 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDeepLink();
    });
  }

  Future<void> _initDeepLink() async {
    try {
      final router = ref.read(routerProvider);
      await DeepLinkService.init(router: router);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Bootstrap] DeepLink 초기화 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BlockPick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
