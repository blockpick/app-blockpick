import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 튜토리얼 링크 위젯
class TutorialLinkWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const TutorialLinkWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: InkWell(
        onTap: onTap ?? () {
          // TODO: 튜토리얼 페이지로 이동
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('튜토리얼 페이지 준비 중입니다')),
          );
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.school_outlined,
                size: 18,
                color: AppColors.medium,
              ),
              SizedBox(width: 8),
              Text(
                '블록픽 참가 방법이 처음이신가요? 튜토리얼 보기',
                style: AppTextStyles.body4.copyWith(
                  color: AppColors.medium,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: AppColors.medium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
