import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/presentation/dialogs/auth_dialogs.dart';

/// 토스 스타일 메인 AppBar
class MainAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onUserTap;
  final bool showLogo;
  final bool hasNotification;

  const MainAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onUserTap,
    this.showLogo = false,
    this.hasNotification = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              // 왼쪽: 메뉴 또는 로고
              if (showLogo)
                const Text(
                  'BlockPick',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                    letterSpacing: -0.5,
                  ),
                )
              else
                GestureDetector(
                  onTap: onMenuTap ?? () => Scaffold.of(context).openDrawer(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_rounded,
                      color: AppColors.darkBlue,
                      size: 24,
                    ),
                  ),
                ),

              const Spacer(),

              // 오른쪽: 알림 + 프로필
              Row(
                children: [
                  // 알림 버튼
                  GestureDetector(
                    onTap: onNotificationTap ?? () {},
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(
                            Icons.notifications_none_rounded,
                            color: AppColors.darkBlue,
                            size: 26,
                          ),
                          if (hasNotification)
                            Positioned(
                              right: 6,
                              top: 6,
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
                  ),

                  const SizedBox(width: 4),

                  // 프로필 버튼
                  GestureDetector(
                    onTap: onUserTap ??
                        () {
                          if (!isAuthenticated) {
                            showLoginDialog(context);
                          }
                        },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isAuthenticated
                            ? CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.darkBlue,
                                child: Text(
                                  (user?.nickname ?? user?.email ?? 'U')[0]
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.white,
                                  ),
                                ),
                              )
                            : CircleAvatar(
                                radius: 15,
                                backgroundColor: AppColors.gray300,
                                child: const Icon(
                                  Icons.person_rounded,
                                  size: 18,
                                  color: AppColors.gray600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
