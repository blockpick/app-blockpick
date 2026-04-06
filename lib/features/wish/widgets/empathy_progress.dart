import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wish_model.dart';

/// 소원 공감 프로그레스 바
class EmpathyProgress extends StatelessWidget {
  final Wish wish;

  const EmpathyProgress({super.key, required this.wish});

  @override
  Widget build(BuildContext context) {
    // 업체 소원은 공감 불필요
    if (wish.isBusinessWish) return const SizedBox.shrink();

    final isReached = wish.isEmpathyReached;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 공감 수 / 목표
        Row(
          children: [
            Icon(
              isReached ? Icons.favorite : Icons.favorite_outline,
              size: 16,
              color: isReached ? AppColors.red : AppColors.gray400,
            ),
            const SizedBox(width: 6),
            Text(
              '공감 ${wish.empathyCount}/${wish.empathyThreshold}',
              style: AppTextStyles.title3,
            ),
            if (isReached) ...[
              SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Text(
                  '✅ 활성화',
                  style: AppTextStyles.caption4.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        // 프로그레스 바
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          child: LinearProgressIndicator(
            value: wish.empathyProgress,
            minHeight: 6,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation(
              isReached ? AppColors.primary : AppColors.primaryLight,
            ),
          ),
        ),
        const SizedBox(height: 4),
        // 안내 텍스트
        Text(
          isReached
              ? '소원이 활성화되었어요! 🎉'
              : '소원이 되기까지 ${wish.remainingEmpathy}개 더 필요해요',
          style: TextStyle(
            fontSize: 12,
            color: isReached ? AppColors.primary : AppColors.gray400,
          ),
        ),
      ],
    );
  }
}
