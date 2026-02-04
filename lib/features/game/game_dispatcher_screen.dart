import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/game_provider.dart';
import '../optimal/optimal_game_screen.dart';
import 'gacha_game_screen.dart';
import 'game_screen.dart';

/// 게임 타입에 따라 적절한 게임 화면으로 분기하는 디스패처
///
/// - DAILY  → GachaGameScreen (가차방식)
/// - SELECT → GameScreen (블록선택)
/// - VIBE   → gameMethod에 따라 분기 (기본: 가차)
/// - PRIME  → OptimalGameScreen (최저가 입찰)
class GameDispatcherScreen extends ConsumerWidget {
  final String gameId;

  const GameDispatcherScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameAsync = ref.watch(gameProvider(gameId));

    return gameAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.gray100,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        backgroundColor: AppColors.gray100,
        body: Center(
          child: Text('게임을 불러올 수 없습니다',
            style: TextStyle(color: AppColors.gray500),
          ),
        ),
      ),
      data: (game) {
        if (game == null) {
          return Scaffold(
            backgroundColor: AppColors.gray100,
            body: Center(
              child: Text('게임을 찾을 수 없습니다',
                style: TextStyle(color: AppColors.gray500),
              ),
            ),
          );
        }

        switch (game.gameType?.toUpperCase()) {
          case 'SELECT':
            return GameScreen(gameId: gameId);
          case 'VIBE':
            if (game.gameMethod?.toUpperCase() == 'BLOCK_PICK') {
              return GameScreen(gameId: gameId);
            }
            return GachaGameScreen(gameId: gameId);
          case 'PRIME':
            return OptimalGameScreen(gameId: gameId);
          case 'DAILY':
          default:
            return GachaGameScreen(gameId: gameId);
        }
      },
    );
  }
}
