import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Pick HUD (상단, 선택 상태 표시)
class PickHud extends StatelessWidget {
  /// 현재 선택된 블록 수
  final int selected;

  /// 최대 선택 가능 블록 수
  final int pickMax;

  /// Submit 콜백
  final VoidCallback? onSubmit;

  /// HUD 투명도 (0.0 ~ 1.0)
  final double opacity;

  /// 현재 줌 레벨 (선택사항)
  final int? zoomLevel;

  const PickHud({
    super.key,
    required this.selected,
    required this.pickMax,
    this.onSubmit,
    this.opacity = 0.75,
    this.zoomLevel,
  });

  @override
  Widget build(BuildContext context) {
    final done = selected >= pickMax;
    final progress = pickMax > 0 ? (selected / pickMax).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: done ? AppColors.green500 : AppColors.buleGray,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 줌 레벨 표시 (있을 경우)
          if (zoomLevel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.blueWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'L$zoomLevel',
                style: AppTextStyles.body4.copyWith(
                  fontSize: 12,
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // 텍스트
          Text(
            'Select $selected/$pickMax',
            style: AppTextStyles.body4.copyWith(
              fontSize: 14,
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 12),

          // 진행바
          SizedBox(
            width: 100,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.disable,
                valueColor: AlwaysStoppedAnimation<Color>(
                  done ? AppColors.green500 : AppColors.blue,
                ),
                minHeight: 6,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Submit 버튼
          ElevatedButton(
            onPressed: done ? onSubmit : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: done ? AppColors.green500 : AppColors.disable,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: done ? 4 : 0,
            ),
            child: Text(
              done ? 'Submit' : 'Pick',
              style: AppTextStyles.body4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact Pick HUD (모바일용, 더 작은 버전)
class CompactPickHud extends StatelessWidget {
  final int selected;
  final int pickMax;
  final VoidCallback? onSubmit;
  final double opacity;

  const CompactPickHud({
    super.key,
    required this.selected,
    required this.pickMax,
    this.onSubmit,
    this.opacity = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final done = selected >= pickMax;
    final progress = pickMax > 0 ? (selected / pickMax).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: done ? AppColors.green500 : AppColors.buleGray,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 텍스트
          Text(
            '$selected/$pickMax',
            style: AppTextStyles.body4.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),

          // 진행바
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.disable,
                valueColor: AlwaysStoppedAnimation<Color>(
                  done ? AppColors.green500 : AppColors.blue,
                ),
                minHeight: 4,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // 아이콘 버튼
          IconButton(
            onPressed: done ? onSubmit : null,
            icon: Icon(
              done ? Icons.check_circle : Icons.radio_button_unchecked,
              color: done ? AppColors.green500 : AppColors.disable,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
