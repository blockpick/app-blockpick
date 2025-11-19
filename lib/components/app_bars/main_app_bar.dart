import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/dialogs/auth_dialogs.dart';
import '../../providers/platform_mode_provider.dart';

/// 메인 AppBar (플랫폼 선택 드롭다운 포함)
class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onUserTap;

  const MainAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onUserTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platformMode = ref.watch(platformModeNotifierProvider);

    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: onMenuTap != null
          ? IconButton(
              icon: const Icon(LucideIcons.menu, color: AppColors.dark),
              onPressed: onMenuTap,
            )
          : null, // null이면 자동으로 drawer 아이콘 표시
      // title: GestureDetector(
      //   onTap: () => showPlatformSelector(context, ref),
      //   child: Container(
      //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      //     decoration: BoxDecoration(
      //       color: const Color(0xFFDCDCDC),
      //       borderRadius: BorderRadius.circular(20),
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Text(
      //           platformMode.displayName,
      //           style: const TextStyle(
      //             fontSize: 16,
      //             fontWeight: FontWeight.w600,
      //             color: AppColors.dark,
      //           ),
      //         ),
      //         const SizedBox(width: 4),
      //         const Icon(
      //           LucideIcons.chevronDown,
      //           size: 16,
      //           color: AppColors.dark,
      //         ),
      //       ],
      //     ),
      //   ),
      // ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.bell, color: AppColors.dark),
          onPressed: onNotificationTap ?? () {},
        ),
        IconButton(
          icon: const Icon(LucideIcons.user, color: AppColors.dark),
          onPressed:
              onUserTap ??
              () {
                final isAuthenticated = ref.read(isAuthenticatedProvider);
                if (!isAuthenticated) {
                  showLoginDialog(context);
                }
              },
        ),
      ],
    );
  }
}
