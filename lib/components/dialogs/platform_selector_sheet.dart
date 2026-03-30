import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select your mode',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

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
          const SizedBox(height: 12),

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
          const SizedBox(height: 12),

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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.buleGray,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? AppColors.blue.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.blue.withOpacity(0.1)
                    : AppColors.deepWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.blue : AppColors.dark,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.title2,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.medium,
                    ),
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
