import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../features/auth/presentation/dialogs/auth_dialogs.dart';
import '../../models/platform_mode.dart';
import '../../providers/platform_mode_provider.dart';

/// 앱 사이드 드로어
class AppDrawer extends ConsumerWidget {
  final VoidCallback? onClose;

  const AppDrawer({
    super.key,
    this.onClose,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final platformMode = ref.watch(platformModeNotifierProvider);

    return Drawer(
      width: MediaQuery.of(context).size.width, // 화면 전체 너비
      backgroundColor: AppColors.white,
      child: SafeArea(
        child: Column(
          children: [
            // 닫기 버튼
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(LucideIcons.x, color: AppColors.dark),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // 프로필 영역
            _buildProfileSection(context, ref, isAuthenticated),

            const SizedBox(height: 8),
            const Divider(color: AppColors.buleGray, height: 1),

            // 스크롤 가능한 메뉴 영역
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                children: [
                  // Shortcuts
                  _buildSectionTitle('Shortcuts'),
                  const SizedBox(height: 8),
                  _buildGridSection([
                    _GridItem(
                      icon: LucideIcons.trophy,
                      label: 'My Picks',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: My Picks로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.barChart3,
                      label: 'Leaderboard',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Leaderboard로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.gift,
                      label: 'Daily Rewards',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Daily Rewards로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.bell,
                      label: 'Notifications',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Notifications로 이동
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.medium, height: 1),

                  // Game Modes
                  _buildSectionTitle('Game Modes'),
                  const SizedBox(height: 8),
                  _buildGridSection([
                    _GridItem(
                      icon: LucideIcons.zap,
                      label: 'STAGE',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: STAGE 게임으로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.target,
                      label: 'SELECT',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: SELECT 게임으로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.music,
                      label: 'VIBE',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: VIBE 게임으로 이동
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.medium, height: 1),

                  // Platform Switch
                  _buildSectionTitle('Platform'),
                  const SizedBox(height: 8),
                  _buildGridSection([
                    _GridItem(
                      icon: LucideIcons.globe,
                      label: 'OFFICIAL',
                      isSelected: platformMode == PlatformMode.official,
                      onTap: () {
                        ref.read(platformModeNotifierProvider.notifier)
                            .changePlatform(PlatformMode.official);
                        Navigator.pop(context);
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.grid,
                      label: 'BlockPick',
                      isSelected: platformMode == PlatformMode.blockpick,
                      onTap: () {
                        ref.read(platformModeNotifierProvider.notifier)
                            .changePlatform(PlatformMode.blockpick);
                        Navigator.pop(context);
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.shoppingBag,
                      label: 'MALL',
                      isSelected: platformMode == PlatformMode.mall,
                      onTap: () {
                        ref.read(platformModeNotifierProvider.notifier)
                            .changePlatform(PlatformMode.mall);
                        Navigator.pop(context);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),
                  const Divider(color: AppColors.medium, height: 1),

                  // Account
                  _buildSectionTitle('Account'),
                  const SizedBox(height: 8),
                  _buildGridSection([
                    _GridItem(
                      icon: LucideIcons.settings,
                      label: 'Settings',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Settings로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.helpCircle,
                      label: 'Help',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: Help로 이동
                      },
                    ),
                    _GridItem(
                      icon: LucideIcons.info,
                      label: 'About',
                      onTap: () {
                        Navigator.pop(context);
                        // TODO: About로 이동
                      },
                    ),
                    if (isAuthenticated)
                      _GridItem(
                        icon: LucideIcons.logOut,
                        label: 'Logout',
                        onTap: () {
                          ref.read(authProvider.notifier).signOut();
                          Navigator.pop(context);
                        },
                      ),
                  ]),
                ],
              ),
            ),

            // 하단 버전 정보
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Version 1.0.0',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.medium,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref, bool isAuthenticated) {
    if (!isAuthenticated) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.gradientBluePurplePink.scale(0.3),
                border: Border.all(
                  color: AppColors.blue.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: const Icon(
                LucideIcons.user,
                color: AppColors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Guest',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Login to unlock features',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.medium,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showLoginDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: AppTextStyles.title3,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 로그인된 경우
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.gradientBluePurplePink,
              border: Border.all(
                color: AppColors.blue.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              LucideIcons.user,
              color: AppColors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SIMJAE',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.blue.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Level 5',
                        style: AppTextStyles.caption4.copyWith(color: AppColors.blue),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.purple.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: AppColors.purple.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: const Text(
                        'Regular user',
                        style: AppTextStyles.caption4.copyWith(color: AppColors.purple),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight, color: AppColors.dark, size: 20),
            onPressed: () {
              Navigator.pop(context);
              // TODO: 프로필 페이지로 이동
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Text(
        title,
        style: AppTextStyles.caption2.copyWith(color: AppColors.medium),
      ),
    );
  }

  Widget _buildGridSection(List<_GridItem> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) => _buildGridItem(item)).toList(),
    );
  }

  Widget _buildGridItem(_GridItem item) {
    return GestureDetector(
      onTap: item.onTap,
      child: Container(
        width: 80,
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.isSelected
                    ? AppColors.blue.withOpacity(0.1)
                    : AppColors.deepWhite,
                borderRadius: BorderRadius.circular(12),
                border: item.isSelected
                    ? Border.all(color: AppColors.blue, width: 2)
                    : null,
              ),
              child: Icon(
                item.icon,
                color: item.isSelected ? AppColors.blue : AppColors.dark,
                size: 24,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: item.isSelected ? FontWeight.w600 : FontWeight.w400,
                color: item.isSelected ? AppColors.blue : AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isSelected;

  const _GridItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isSelected = false,
  });
}
