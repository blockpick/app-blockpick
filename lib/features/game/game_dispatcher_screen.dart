import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_model.dart';
import '../../providers/game_provider.dart';
import 'gacha_game_screen.dart';
import 'game_screen.dart';
import 'widgets/game_result_view.dart';

/// 게임 타입에 따라 적절한 게임 화면으로 분기하는 디스패처
///
/// - 종료된 게임 → GameResultScreen (결과 화면)
/// - DAILY  → GachaGameScreen (가차방식)
/// - SELECT → GameScreen (블록선택)
/// - VIBE   → GachaGameScreen (가차방식)
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

        // 종료된 게임은 결과 화면으로 분기
        if (game.isEnded) {
          return _GameResultScreen(game: game);
        }

        switch (game.gameType?.toUpperCase()) {
          case 'SELECT':
            return GameScreen(gameId: gameId);
          case 'VIBE':
            return GachaGameScreen(gameId: gameId);
          case 'DAILY':
          default:
            return GachaGameScreen(gameId: gameId);
        }
      },
    );
  }
}

/// 종료된 게임 결과 화면 (래퍼)
class _GameResultScreen extends StatelessWidget {
  final Game game;

  const _GameResultScreen({required this.game});

  String _getGameTypeTitle(String? gameType) {
    switch (gameType?.toUpperCase()) {
      case 'DAILY':
        return 'Daily Events';
      case 'SELECT':
        return 'Select Events';
      case 'VIBE':
        return 'Vibe Events';
      case 'PRIME':
        return 'Prime Events';
      default:
        return 'Events';
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameRound = game.toGameRound();

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: AppColors.white,
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/');
                      }
                    },
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 22,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _getGameTypeTitle(game.gameType),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                  // 공유 버튼 (placeholder)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 22,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: GameResultView(game: game, gameRound: gameRound),
    );
  }
}
