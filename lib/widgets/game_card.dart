import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/game_round_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 게임 카드 위젯
class GameCard extends StatelessWidget {
  final GameRound game;
  final VoidCallback? onTap;

  const GameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.buleGray),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    style: AppTextStyles.medium.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w700,
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
            aspectRatio: 16 / 9,
            child: game.imageUrl.isEmpty
                ? Container(
                    color: AppColors.blueWhite,
                    child: const Center(
                      child: Icon(
                        LucideIcons.image,
                        size: 48,
                        color: AppColors.buleGray,
                      ),
                    ),
                  )
                : Image.network(
                    game.imageUrl.replaceAll(' ', '%20'),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.blueWhite,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.blue,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      print('❌ 이미지 로드 에러: $error');
                      print('   이미지 URL: ${game.imageUrl}');
                      return Container(
                        color: AppColors.blueWhite,
                        child: const Center(
                          child: Icon(
                            LucideIcons.image,
                            size: 48,
                            color: AppColors.buleGray,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),

        // 상태 배지
        Positioned(
          top: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getStatusColor(),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getStatusText(),
              style: AppTextStyles.caption.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        // 타입 배지
        Positioned(
          top: 12,
          right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _getTypeColor()),
            ),
            child: Text(
              _getTypeText(),
              style: AppTextStyles.caption.copyWith(
                color: _getTypeColor(),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 통계 정보
  Widget _buildStatistics() {
    return Column(
      children: [
        _buildStatRow(
          LucideIcons.users,
          'Participants',
          '${game.participants.toStringAsFixed(0)}명',
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          LucideIcons.grid,
          'Blocks',
          _formatNumber(game.totalBlocks),
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          LucideIcons.target,
          'Required Picks',
          game.requiredPicks.toString(),
        ),
        const SizedBox(height: 8),
        _buildStatRow(
          LucideIcons.trophy,
          'Winners',
          '${game.winners}명',
        ),
      ],
    );
  }

  /// 통계 행
  Widget _buildStatRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.medium),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.medium),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 가격 및 시간
  Widget _buildPriceAndTime() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 가격
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (game.originalPrice != game.currentPrice)
              Text(
                '₩${_formatNumber(game.originalPrice)}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.medium,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            Text(
              '₩${_formatNumber(game.currentPrice)}',
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        // 남은 시간
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blueWhite,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                LucideIcons.clock,
                size: 14,
                color: AppColors.red,
              ),
              const SizedBox(width: 4),
              Text(
                game.timeLeft,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
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
      case GameStatus.active:
        return AppColors.green;
      case GameStatus.drawing:
        return AppColors.purple;
      case GameStatus.ended:
        return AppColors.medium;
    }
  }

  /// 상태 텍스트
  String _getStatusText() {
    switch (game.status) {
      case GameStatus.active:
        return 'Active';
      case GameStatus.drawing:
        return 'Drawing';
      case GameStatus.ended:
        return 'Ended';
    }
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
