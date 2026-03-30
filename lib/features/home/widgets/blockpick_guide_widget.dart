import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// BlockPick 가이드 위젯 (게임 작동 방식 설명)
class BlockPickGuideWidget extends StatelessWidget {
  const BlockPickGuideWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.blue,
                  size: 24,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'THIS IS HOW\nA FAIR GAME WORKS',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 가이드 단계들
          _buildGuideStep(
            icon: Icons.grid_on,
            iconColor: AppColors.purple,
            title: 'Join by Choosing a Block',
            description: 'Select a block on the grid to join the game.',
            stepNumber: 1,
          ),

          const SizedBox(height: 20),

          _buildGuideStep(
            icon: Icons.emoji_events,
            iconColor: AppColors.yellow500,
            title: 'Be the Last Unique Block',
            description: 'The first to pick the longest-lasting solo block wins.',
            stepNumber: 2,
          ),

          const SizedBox(height: 20),

          _buildGuideStep(
            icon: Icons.card_giftcard,
            iconColor: AppColors.pink,
            title: 'Full Refund if Canceled',
            description: 'Game off? Get your cash back',
            stepNumber: 3,
          ),
        ],
      ),
    );
  }

  /// 가이드 단계 위젯
  Widget _buildGuideStep({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required int stepNumber,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.deepWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buleGray),
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 32,
            ),
          ),

          SizedBox(width: 16),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
          ),

          // 화살표 (마지막 단계 제외)
          if (stepNumber < 3) ...[
            const SizedBox(width: 8),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.blue,
              size: 24,
            ),
          ],
        ],
      ),
    );
  }
}
