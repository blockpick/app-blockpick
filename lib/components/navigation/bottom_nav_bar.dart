import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// 하단 네비게이션 바
/// 홈 / 데일리 / 위시(플로팅) / 프라임 / MY (5개 탭)
class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool hasWishNotification;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.hasWishNotification = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              // 홈
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: '홈',
                isSelected: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              // 데일리
              _NavItem(
                icon: Icons.wb_sunny_outlined,
                activeIcon: Icons.wb_sunny_rounded,
                label: '데일리',
                isSelected: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              // 위시 (가운데 플로팅)
              _CenterNavItem(
                isSelected: currentIndex == 2,
                onTap: () => onTap(2),
                showBadge: hasWishNotification,
              ),
              // 프라임
              _NavItem(
                icon: Icons.diamond_outlined,
                activeIcon: Icons.diamond_rounded,
                label: '프라임',
                isSelected: currentIndex == 3,
                onTap: () => onTap(3),
              ),
              // My
              _NavItem(
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'My',
                isSelected: currentIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 가운데 플로팅 위시 버튼
class _CenterNavItem extends StatelessWidget {
  final bool isSelected;
  final VoidCallback onTap;
  final bool showBadge;

  const _CenterNavItem({
    required this.isSelected,
    required this.onTap,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Transform.translate(
              offset: const Offset(0, -18),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.textBlack : AppColors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? AppColors.textBlack : AppColors.gray200,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textBlack.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      isSelected ? Icons.auto_awesome : Icons.auto_awesome_outlined,
                      size: 24,
                      color: isSelected ? AppColors.white : AppColors.gray400,
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      right: 2,
                      top: 2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -16),
              child: Text(
                '위시',
                style: AppTextStyles.caption4.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.textBlack : AppColors.gray400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 일반 네비게이션 아이템
class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.only(top: AppConstants.spacingSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                isSelected ? activeIcon : icon,
                size: 24,
                color: isSelected ? AppColors.textBlack : AppColors.gray400,
              ),
              const SizedBox(height: AppConstants.spacingXs),
              Text(
                label,
                style: AppTextStyles.caption4.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.textBlack : AppColors.gray400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
