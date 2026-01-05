import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../components/navigation/bottom_nav_bar.dart';
import '../../components/navigation/app_drawer.dart';
import '../../components/app_bars/main_app_bar.dart';
import '../../components/app_bars/sub_app_bar.dart';
import '../../models/platform_mode.dart';
import '../../providers/platform_mode_provider.dart';
import '../../providers/current_tab_provider.dart';
import '../home/home_screen.dart';
import '../home/toss_home_screen.dart';
import '../my_pick/my_pick_screen.dart';
import '../winners/winners_screen.dart';
import '../my/my_screen.dart';
import '../official/official_screen.dart';
import '../mall/mall_screen.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';

/// BlockPick 메인 화면 (하단 네비게이션 + 플랫폼 전환 포함)
class BlockpickScreen extends ConsumerStatefulWidget {
  const BlockpickScreen({super.key});

  @override
  ConsumerState<BlockpickScreen> createState() => _BlockpickScreenState();
}

class _BlockpickScreenState extends ConsumerState<BlockpickScreen> {
  // BlockPick 앱 화면들
  final List<Widget> _blockpickScreens = [
    const TossHomeScreen(),   // 0: HOME (토스 스타일 디자인)
    const MyPickScreen(),     // 1: My Pick (참여한 게임)
    const HomeScreen(),       // 2: PICK (가운데 큰 버튼 - 게임 목록)
    const WinnersScreen(),    // 3: Winners (기획 중)
    const MallScreen(),       // 4: MALL (쇼핑몰)
    const MyScreen(),         // 5: MY (마이페이지)
  ];

  @override
  Widget build(BuildContext context) {
    final platformMode = ref.watch(platformModeNotifierProvider);
    final currentIndex = ref.watch(currentTabProvider);

    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      appBar: _buildAppBar(platformMode, currentIndex),
      drawer: const AppDrawer(),
      body: _buildBody(platformMode, currentIndex),
      bottomNavigationBar: _buildBottomNav(platformMode, currentIndex),
    );
  }

  Widget _buildBody(PlatformMode platformMode, int currentIndex) {
    switch (platformMode) {
      case PlatformMode.official:
        return const OfficialScreen();
      case PlatformMode.blockpick:
        return IndexedStack(
          index: currentIndex,
          children: _blockpickScreens,
        );
      case PlatformMode.mall:
        return const MallScreen();
    }
  }

  Widget? _buildBottomNav(PlatformMode platformMode, int currentIndex) {
    // BlockPick 모드에서만 하단 네비게이션 표시
    if (platformMode != PlatformMode.blockpick) {
      return null;
    }

    return BottomNavBar(
      currentIndex: currentIndex,
      onTap: (index) {
        ref.read(currentTabProvider.notifier).setTab(index);
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(PlatformMode platformMode, int currentIndex) {
    // HOME 탭(index 0)은 TossHomeScreen이 자체 SliverAppBar를 가지므로 AppBar 숨김
    if (platformMode == PlatformMode.blockpick && currentIndex == 0) {
      return null;
    }

    // MY 탭(index 5)은 MyScreen이 자체 SliverAppBar를 가지므로 AppBar 숨김
    if (platformMode == PlatformMode.blockpick && currentIndex == 5) {
      return null;
    }

    // 메인 페이지 - 플랫폼 선택 드롭다운 표시
    // 1. OFFICIAL 모드
    // 2. MALL 모드
    // 3. BlockPick의 PICK 탭 (index 2 - 가운데 큰 버튼)
    final bool isMainPage = platformMode == PlatformMode.official ||
        platformMode == PlatformMode.mall ||
        (platformMode == PlatformMode.blockpick && currentIndex == 2);

    if (isMainPage) {
      return MainAppBar(
        onMenuTap: null, // null이면 자동으로 drawer 아이콘 표시
        onNotificationTap: () {
          // TODO: 알림 기능
        },
        onUserTap: () {
          final isAuthenticated = ref.read(isAuthenticatedProvider);
          if (isAuthenticated) {
            // MY 페이지로 이동 (인덱스 5)
            ref.read(currentTabProvider.notifier).goToMy();
          } else {
            showLoginDialog(context);
          }
        },
      );
    }

    // 서브 페이지 - 일반 제목만 표시 (BlockPick의 다른 탭들)
    final titles = ['HOME', 'My Pick', 'PICK', 'Winners', 'MALL', 'MY'];
    final title = titles[currentIndex];

    return SubAppBar(
      title: title,
      onNotificationTap: () {
        // TODO: 알림 기능
      },
    );
  }

}
