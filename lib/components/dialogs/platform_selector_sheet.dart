import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/platform_mode.dart';
import '../../providers/platform_mode_provider.dart';

/// 플랫폼 선택 바텀시트
Future<void> showPlatformSelector(BuildContext context, WidgetRef ref) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => const PlatformSelectorSheet(),
  );
}

class PlatformSelectorSheet extends ConsumerWidget {
  const PlatformSelectorSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMode = ref.watch(platformModeNotifierProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radius2Xl),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select your mode',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textBlack),
          ),
          const SizedBox(height: AppConstants.spacingXl),

          // OFFICIAL
          _PlatformOption(
            icon: LucideIcons.globe,
            title: PlatformMode.official.displayName,
            subtitle: 'Service introduction & resources',
            isSelected: currentMode == PlatformMode.official,
            onTap: () {
              ref.read(platformModeNotifierProvider.notifier)
                  .changePlatform(PlatformMode.official);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // BlockPick (현재 선택된 모드)
          _PlatformOption(
            icon: LucideIcons.grid,
            title: PlatformMode.blockpick.displayName,
            subtitle: 'PICK game & compete',
            isSelected: currentMode == PlatformMode.blockpick,
            onTap: () {
              ref.read(platformModeNotifierProvider.notifier)
                  .changePlatform(PlatformMode.blockpick);
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),

          // MALL
          _PlatformOption(
            icon: LucideIcons.shoppingBag,
            title: PlatformMode.mall.displayName,
            subtitle: 'Shop products & marketplace',
            isSelected: currentMode == PlatformMode.mall,
            onTap: () {
              ref.read(platformModeNotifierProvider.notifier)
                  .changePlatform(PlatformMode.mall);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _PlatformOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlatformOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spacingLg),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.gray200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          color: isSelected
              ? AppColors.blue.withValues(alpha: 0.05)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blue.withValues(alpha: 0.1)
                    : AppColors.gray100,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd + 2),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.blue : AppColors.gray800,
                size: 24,
              ),
            ),
            const SizedBox(width: AppConstants.spacingLg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title2.copyWith(
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXs),
                  Text(
                    subtitle,
                    style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.blue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  LucideIcons.check,
                  color: AppColors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
