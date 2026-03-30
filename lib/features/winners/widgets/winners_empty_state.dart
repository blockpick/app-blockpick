import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 당첨자/리뷰 없음 빈 상태
class WinnersEmptyState extends StatelessWidget {
  final String message;
  final String subMessage;
  final String buttonText;
  final VoidCallback? onButtonTap;

  const WinnersEmptyState({
    super.key,
    required this.message,
    required this.subMessage,
    required this.buttonText,
    this.onButtonTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 메인 메시지
            Text(
              message,
              style: AppTextStyles.title1.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // 서브 메시지
            Text(
              subMessage,
              style: AppTextStyles.body3.copyWith(
                color: AppColors.medium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // 참여 버튼
            GestureDetector(
              onTap: onButtonTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  buttonText,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
