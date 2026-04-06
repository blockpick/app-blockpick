import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_constants.dart';
import '../../../core/theme/app_text_styles.dart';
import '../more_screen.dart';

/// 모드 선택 카드 위젯
class ModeCard extends StatelessWidget {
  final PickMode mode;
  final VoidCallback onTap;

  const ModeCard({
    super.key,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          boxShadow: [
            BoxShadow(
              color: mode.color.withValues(alpha:0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          child: Stack(
            children: [
              // 그라데이션 배경
              Positioned(
                top: -30,
                right: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        mode.color.withValues(alpha:0.3),
                        mode.color.withValues(alpha:0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // 콘텐츠
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 아이콘
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: mode.color.withValues(alpha:0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                      ),
                      child: Center(
                        child: Text(
                          mode.icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),

                    const Spacer(),

                    // 이름
                    Text(
                      mode.name,
                      style: AppTextStyles.title1.copyWith(
                        color: AppColors.textBlack,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // 설명
                    Text(
                      mode.description,
                      style: AppTextStyles.caption1.copyWith(
                        color: AppColors.gray400,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // 화살표
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: mode.color.withValues(alpha:0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: mode.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(duration: 300.ms)
          .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),
    );
  }
}
