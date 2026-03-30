import 'package:flutter/material.dart';
import '../../models/game_round_model.dart';
import '../../models/block_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// 마이픽 카드 컴포넌트
///
/// 참여한 게임의 정보와 선택한 블록을 표시
class MyPickCard extends StatelessWidget {
  final GameRound game;
  final List<BlockModel> myPicks;
  final VoidCallback? onTap;

  const MyPickCard({
    super.key,
    required this.game,
    required this.myPicks,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: AppColors.buleGray, width: 1),
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
              // 상품 이미지
              _buildImage(),

              // 게임 정보
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 제목
                    Text(
                      game.title,
                      style: AppTextStyles.heading1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // 가격 정보
                    Row(
                      children: [
                        Text(
                          '\$${(game.currentPrice / 100).toStringAsFixed(2)}',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '• ${(game.originalPrice / 1000).toStringAsFixed(1)}K',
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.medium,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 게임 통계
                    _buildGameStats(),

                    const SizedBox(height: 16),

                    // 구분선
                    Divider(color: AppColors.buleGray.withOpacity(0.3), height: 1),

                    const SizedBox(height: 12),

                    // 내 픽 정보
                    _buildMyPicks(),

                    const SizedBox(height: 12),

                    // 구분선
                    Divider(color: AppColors.buleGray.withOpacity(0.3), height: 1),

                    const SizedBox(height: 12),

                    // 남은 시간
                    _buildTimeLeft(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상품 이미지
  Widget _buildImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppConstants.radiusLg),
      ),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.asset(
          game.imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.blueWhite,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: AppColors.medium,
                  size: 48,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 게임 통계 (참가자, 블록, 필수 픽, 당첨자)
  Widget _buildGameStats() {
    return Row(
      children: [
        _buildStatItem(
          '👥',
          '${game.participants}',
          tooltip: 'Participants',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          '📦',
          '${game.totalBlocks ~/ (game.actualGridWidth * game.actualGridHeight) * 100}/${game.totalBlocks ~/ (game.actualGridWidth * game.actualGridHeight) * 100}',
          tooltip: 'Blocks',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          '✅',
          '${game.participants - 50}',
          tooltip: 'Required Pick',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          '🏆',
          '${game.winners}',
          tooltip: 'Winners',
        ),
      ],
    );
  }

  /// 통계 항목
  Widget _buildStatItem(String emoji, String value, {String? tooltip}) {
    return Tooltip(
      message: tooltip ?? '',
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.body4.copyWith(
              color: AppColors.dark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 내 픽 정보
  Widget _buildMyPicks() {
    final totalValue = (myPicks.length * game.currentPrice / 100).toStringAsFixed(1);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${myPicks.length} Picks',
          style: AppTextStyles.body3.copyWith(
            color: AppColors.blue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          'Total $totalValue',
          style: AppTextStyles.body3.copyWith(
            color: AppColors.dark,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// 남은 시간
  Widget _buildTimeLeft() {
    Color timeColor;
    if (game.status.isEnded) {
      timeColor = AppColors.medium;
    } else if (game.timeLeft.contains('분') && !game.timeLeft.contains('시간')) {
      timeColor = AppColors.red;
    } else {
      timeColor = AppColors.dark;
    }

    return Row(
      children: [
        Icon(
          Icons.access_time,
          size: 16,
          color: timeColor,
        ),
        const SizedBox(width: 4),
        Text(
          game.status.isEnded ? 'Ended' : 'Ends in ${game.timeLeft}',
          style: AppTextStyles.body3.copyWith(
            color: timeColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
