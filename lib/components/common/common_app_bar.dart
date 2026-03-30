import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 공통 앱바 컴포넌트
/// 모든 메인 탭 화면에서 일관된 스타일로 사용
class CommonAppBar extends StatelessWidget {
  final String? title;
  final bool showLogo;
  final Widget? trailing;
  final Color? backgroundColor;

  const CommonAppBar({
    super.key,
    this.title,
    this.showLogo = false,
    this.trailing,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      color: backgroundColor ?? Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 좌측: 로고 또는 타이틀
          if (showLogo)
            _buildLogo()
          else if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                letterSpacing: -0.5,
              ),
            ),

          // 우측: trailing 위젯
          if (trailing != null) trailing!,
        ],
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.check_rounded,
            size: 18,
            color: AppColors.white,
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'Blockpick',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.darkBlue,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

/// 알림 버튼 위젯
class NotificationButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool hasNotification;

  const NotificationButton({
    super.key,
    this.onTap,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 24,
              color: AppColors.darkBlue,
            ),
            if (hasNotification)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 설정 버튼 위젯
class SettingsButton extends StatelessWidget {
  final VoidCallback? onTap;

  const SettingsButton({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.settings_rounded,
          size: 22,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }
}

/// 포인트 뱃지 위젯
class PointBadge extends StatelessWidget {
  final int balance;
  final VoidCallback? onTap;

  const PointBadge({
    super.key,
    required this.balance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.darkBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              _formatNumber(balance),
              style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
