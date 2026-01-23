import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'core/theme/app_theme.dart';
import 'core/router/router.dart';
import 'services/admob_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 웹에서 path 기반 URL 사용 (# 없는 깔끔한 URL)
  usePathUrlStrategy();

  // AdMob SDK 초기화 (웹이 아닌 경우에만)
  if (!kIsWeb) {
    await AdMobService.initialize();
  }

  runApp(
    // Riverpod Provider 스코프
    const ProviderScope(
      child: BlockPickApp(),
    ),
  );
}

/// BlockPick 앱
class BlockPickApp extends ConsumerWidget {
  const BlockPickApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BlockPick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
