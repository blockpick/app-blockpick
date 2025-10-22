import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/home/home_screen.dart';
import 'features/game/game_screen.dart';

void main() {
  runApp(
    // Riverpod Provider 스코프
    const ProviderScope(
      child: BlockPickApp(),
    ),
  );
}

/// BlockPick 앱
class BlockPickApp extends StatelessWidget {
  const BlockPickApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BlockPick',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
      onGenerateRoute: (settings) {
        // 라우트 처리
        if (settings.name == '/game-detail') {
          final gameId = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => GameScreen(gameId: gameId),
          );
        }
        return null;
      },
    );
  }
}
