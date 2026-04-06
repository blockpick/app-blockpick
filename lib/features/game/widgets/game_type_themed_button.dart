import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/game_round_model.dart';
import '../../../core/constants/app_constants.dart';

/// 게임 타입별 테마가 적용된 참가 버튼
///
/// DAILY: Blue-Purple 그라데이션
/// SELECT: Purple-Pink 그라데이션
/// VIBE: Pink-Red 그라데이션
class GameTypeThemedButton extends ConsumerWidget {
  final String gameId;
  final String selectedGameProductId;
  final int selectedRow;
  final int selectedCol;
  final String contractAddress;
  final GameType gameType;
  final VoidCallback? onSuccess;

  const GameTypeThemedButton({
    super.key,
    required this.gameId,
    required this.selectedGameProductId,
    required this.selectedRow,
    required this.selectedCol,
    required this.contractAddress,
    required this.gameType,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gradient = _getGradientForType(gameType);
    final icon = _getIconForType(gameType);
    final text = _getTextForType(gameType);

    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor(gameType),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleJoinGame(context, ref),
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: AppColors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  text,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _getGradientForType(GameType type) {
    switch (type) {
      case GameType.daily:
        return const LinearGradient(
          colors: [AppColors.blue, AppColors.purple],
        );
      case GameType.select:
        return const LinearGradient(
          colors: [AppColors.purple, AppColors.pink],
        );
      case GameType.vibe:
        return const LinearGradient(
          colors: [AppColors.pink, AppColors.red],
        );
      case GameType.prime:
        return const LinearGradient(
          colors: [AppColors.yellow500, AppColors.orange],
        );
    }
  }

  IconData _getIconForType(GameType type) {
    switch (type) {
      case GameType.daily:
        return Icons.calendar_today;
      case GameType.select:
        return Icons.playlist_add_check;
      case GameType.vibe:
        return Icons.music_note;
      case GameType.prime:
        return Icons.diamond_outlined;
    }
  }

  String _getTextForType(GameType type) {
    switch (type) {
      case GameType.daily:
        return '데일리 게임 참가하기';
      case GameType.select:
        return '셀렉트 게임 참가하기';
      case GameType.vibe:
        return '바이브 게임 참가하기';
      case GameType.prime:
        return '프라임 게임 참가하기';
    }
  }

  Color _getShadowColor(GameType type) {
    switch (type) {
      case GameType.daily:
        return AppColors.blue.withValues(alpha: 0.4);
      case GameType.select:
        return AppColors.purple.withValues(alpha: 0.4);
      case GameType.vibe:
        return AppColors.pink.withValues(alpha: 0.4);
      case GameType.prime:
        return AppColors.yellow500.withValues(alpha: 0.4);
    }
  }

  Future<void> _handleJoinGame(BuildContext context, WidgetRef ref) async {
    // GameJoinButton과 동일한 로직 사용
    // (생략 - 실제로는 GameJoinButton의 _handleJoinGame 로직 재사용)
  }
}
