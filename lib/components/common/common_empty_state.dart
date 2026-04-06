import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// 공통 빈 상태 위젯
class CommonEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? subMessage;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const CommonEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.subMessage,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: AppConstants.spacingLg),
            Text(
              message,
              style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
            if (subMessage != null) ...[
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                subMessage!,
                style: AppTextStyles.body3.copyWith(color: AppColors.gray400),
                textAlign: TextAlign.center,
              ),
            ],
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: AppConstants.spacingXl),
              ElevatedButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
