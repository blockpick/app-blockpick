import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../components/navigation/bottom_nav_bar.dart';
import '../../components/navigation/app_drawer.dart';
import '../../components/app_bars/main_app_bar.dart';
import '../../components/app_bars/sub_app_bar.dart';
import '../../models/platform_mode.dart';
import '../../providers/platform_mode_provider.dart';
import '../home/home_screen.dart';
import '../my_pick/my_pick_screen.dart';
import '../play/play_screen.dart';
import '../history/history_screen.dart';
import '../my/my_screen.dart';
import '../official/official_screen.dart';
import '../mall/mall_screen.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';

/// 메인 화면 (하단 네비게이션 + 플랫폼 전환 포함)
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _currentIndex = 0;

  // BlockPick 앱 화면들
  final List<Widget> _blockpickScreens = const [
    HomeScreen(),      // 0: PICK
    MyPickScreen(),    // 1: My Pick
    PlayScreen(),      // 2: PLAY
    HistoryScreen(),   // 3: History
    MyScreen(),        // 4: MY
  ];

  @override
  Widget build(BuildContext context) {
    final platformMode = ref.watch(platformModeNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      appBar: _buildAppBar(platformMode),
      drawer: const AppDrawer(),
      body: _buildBody(platformMode),
      bottomNavigationBar: _buildBottomNav(platformMode),
    );
  }

  Widget _buildBody(PlatformMode platformMode) {
    switch (platformMode) {
      case PlatformMode.official:
        return const OfficialScreen();
      case PlatformMode.blockpick:
        return IndexedStack(
          index: _currentIndex,
          children: _blockpickScreens,
        );
      case PlatformMode.mall:
        return const MallScreen();
    }
  }

  Widget? _buildBottomNav(PlatformMode platformMode) {
    // BlockPick 모드에서만 하단 네비게이션 표시
    if (platformMode != PlatformMode.blockpick) {
      return null;
    }

    return BottomNavBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        // 중앙 버튼(PLAY, index 2) 재클릭 시 메뉴 표시
        if (index == 2 && _currentIndex == 2) {
          _showPlayMenu();
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
    );
  }

  void _showPlayMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              'Game Modes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(LucideIcons.zap, color: AppColors.dark),
              title: const Text(
                'STAGE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Daily block game'),
              trailing: const Icon(LucideIcons.chevronRight, color: AppColors.medium),
              onTap: () {
                Navigator.pop(context);
                // TODO: STAGE 게임으로 이동
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.target, color: AppColors.dark),
              title: const Text(
                'SELECT',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Choose your blocks'),
              trailing: const Icon(LucideIcons.chevronRight, color: AppColors.medium),
              onTap: () {
                Navigator.pop(context);
                // TODO: SELECT 게임으로 이동
              },
            ),
            ListTile(
              leading: const Icon(LucideIcons.music, color: AppColors.dark),
              title: const Text(
                'VIBE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text('Feel the rhythm'),
              trailing: const Icon(LucideIcons.chevronRight, color: AppColors.medium),
              onTap: () {
                Navigator.pop(context);
                // TODO: VIBE 게임으로 이동
              },
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(PlatformMode platformMode) {
    // 메인 페이지 - 플랫폼 선택 드롭다운 표시
    // 1. OFFICIAL 모드
    // 2. MALL 모드
    // 3. BlockPick의 PICK 탭 (index 0)
    final bool isMainPage = platformMode == PlatformMode.official ||
        platformMode == PlatformMode.mall ||
        (platformMode == PlatformMode.blockpick && _currentIndex == 0);

    if (isMainPage) {
      return MainAppBar(
        onMenuTap: null, // null이면 자동으로 drawer 아이콘 표시
        onNotificationTap: () {
          // TODO: 알림 기능
        },
        onUserTap: () {
          final isAuthenticated = ref.read(isAuthenticatedProvider);
          if (isAuthenticated) {
            setState(() => _currentIndex = 4);
          } else {
            showLoginDialog(context);
          }
        },
      );
    }

    // 서브 페이지 - 일반 제목만 표시 (BlockPick의 다른 탭들)
    final titles = ['PICK', 'My Pick', 'PLAY', 'History', 'MY'];
    final title = titles[_currentIndex];

    return SubAppBar(
      title: title,
      onNotificationTap: () {
        // TODO: 알림 기능
      },
    );
  }

}
