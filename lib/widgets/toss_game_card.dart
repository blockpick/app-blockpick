import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/game_round_model.dart';

/// 토스 스타일 게임 카드 위젯
class TossGameCard extends StatelessWidget {
  final GameRound game;
  final VoidCallback? onTap;

  const TossGameCard({super.key, required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 이미지 섹션
            _buildImageSection(),

            // 정보 섹션
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // 통계
                  _buildStatistics(),

                  const SizedBox(height: 12),

                  // 가격 및 시간
                  _buildPriceAndTime(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 섹션
  Widget _buildImageSection() {
    return Stack(
      children: [
        // 제품 이미지
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: AspectRatio(
            aspectRatio: 1.8,
            child: game.imageUrl.isEmpty
                ? Container(
                    color: AppColors.gray100,
                    child: Center(
                      child: Icon(
                        Icons.image_rounded,
                        size: 48,
                        color: AppColors.gray400,
                      ),
                    ),
                  )
                : Image.network(
                    game.imageUrl.replaceAll(' ', '%20'),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.gray100,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.gray400,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.gray100,
                      child: Center(
                        child: Icon(
                          Icons.image_rounded,
                          size: 48,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // 상태 배지
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getStatusText(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),

        // 타입 배지
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              _getTypeText(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: _getTypeColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 통계 정보
  Widget _buildStatistics() {
    return Row(
      children: [
        _buildStatChip(
          Icons.people_outline_rounded,
          '${game.participants.toStringAsFixed(0)}명',
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          Icons.grid_view_rounded,
          _formatNumber(game.totalBlocks),
        ),
        const SizedBox(width: 8),
        _buildStatChip(
          Icons.emoji_events_outlined,
          '${game.winners}명',
        ),
      ],
    );
  }

  Widget _buildStatChip(IconData icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.gray600),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  /// 가격 및 시간
  Widget _buildPriceAndTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 가격
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (game.originalPrice != game.currentPrice) ...[
              Text(
                '₩${_formatNumber(game.originalPrice)}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              '₩${_formatNumber(game.currentPrice)}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.blue,
              ),
            ),
          ],
        ),

        // 남은 시간
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.red.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 14,
                color: AppColors.red,
              ),
              const SizedBox(width: 4),
              Text(
                game.timeLeft,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 상태 색상
  Color _getStatusColor() {
    switch (game.status) {
      case GameStatus.scheduled:
        return AppColors.blue;
      case GameStatus.active:
        return AppColors.green;
      case GameStatus.paused:
        return AppColors.yellow;
      case GameStatus.settling:
        return AppColors.orange;
      case GameStatus.ended:
      case GameStatus.completed:
        return AppColors.gray500;
      case GameStatus.failed:
        return AppColors.red;
    }
  }

  /// 상태 텍스트
  String _getStatusText() {
    return game.status.badgeText;
  }

  /// 타입 색상
  Color _getTypeColor() {
    switch (game.type) {
      case GameType.daily:
        return AppColors.pink;
      case GameType.select:
        return AppColors.purple;
      case GameType.vibe:
        return AppColors.blue;
      case GameType.prime:
        return AppColors.yellow;
    }
  }

  /// 타입 텍스트
  String _getTypeText() {
    switch (game.type) {
      case GameType.daily:
        return 'Daily';
      case GameType.select:
        return 'Select';
      case GameType.vibe:
        return 'Vibe';
      case GameType.prime:
        return 'Prime';
    }
  }

  /// 숫자 포맷팅
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
