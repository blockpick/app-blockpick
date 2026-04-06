import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 서브 AppBar (일반 제목만)
class SubAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onSettingsTap;
  final List<Widget>? actions;

  const SubAppBar({
    super.key,
    required this.title,
    this.onBackTap,
    this.onNotificationTap,
    this.onSettingsTap,
    this.actions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: onBackTap != null
          ? IconButton(
              icon: const Icon(LucideIcons.arrowLeft, color: AppColors.gray800),
              onPressed: onBackTap,
            )
          : null,
      title: Text(
        title,
        style: AppTextStyles.title1.copyWith(color: AppColors.textBlack),
      ),
      centerTitle: true,
      actions: actions ??
          [
            if (onNotificationTap != null)
              IconButton(
                icon: const Icon(LucideIcons.bell, color: AppColors.gray800),
                onPressed: onNotificationTap,
              ),
            if (onSettingsTap != null)
              IconButton(
                icon: const Icon(LucideIcons.settings, color: AppColors.gray800),
                onPressed: onSettingsTap,
              ),
          ],
    );
  }
}
