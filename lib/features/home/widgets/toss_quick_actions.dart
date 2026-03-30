import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 토스 스타일 퀵 액션 버튼들
class TossQuickActions extends StatelessWidget {
  const TossQuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _QuickActionItem(
            icon: Icons.grid_view_rounded,
            label: 'SELECT',
            color: AppColors.blue,
            onTap: () {},
          ),
          _QuickActionItem(
            icon: Icons.calendar_today_rounded,
            label: 'DAILY',
            color: AppColors.green500,
            onTap: () {},
          ),
          _QuickActionItem(
            icon: Icons.auto_awesome_rounded,
            label: 'VIBE',
            color: AppColors.purple,
            onTap: () {},
          ),
          _QuickActionItem(
            icon: Icons.history_rounded,
            label: '내 기록',
            color: AppColors.pink,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionItem({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 26,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
          ),
        ],
      ),
    );
  }
}
