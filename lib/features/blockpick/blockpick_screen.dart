import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../components/navigation/bottom_nav_bar.dart';
import '../../providers/current_tab_provider.dart';
import '../home/new_home_screen.dart';
import '../mall/mall_screen.dart';
import '../home/home_screen.dart'; // Event 탭 (기존 게임 목록)
import '../my/my_screen.dart';

/// SC-008 디자인 메인 화면
/// Home / Shopping / Event / My (4개 탭)
class BlockpickScreen extends ConsumerStatefulWidget {
  const BlockpickScreen({super.key});

  @override
  ConsumerState<BlockpickScreen> createState() => _BlockpickScreenState();
}

class _BlockpickScreenState extends ConsumerState<BlockpickScreen> {
  // SC-008 디자인 화면들 (4개 탭)
  final List<Widget> _screens = [
    const NewHomeScreen(),  // 0: Home (새 홈 화면)
    const MallScreen(),     // 1: Shopping (쇼핑몰)
    const HomeScreen(),     // 2: Event (기존 게임 목록 - Daily/Select/Vibe/Prime)
    const MyScreen(),       // 3: My (마이페이지)
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabProvider);
    // 인덱스가 범위를 벗어나면 0으로 리셋
    final safeIndex = currentIndex.clamp(0, _screens.length - 1);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: safeIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: safeIndex,
        onTap: (index) {
          ref.read(currentTabProvider.notifier).setTab(index);
        },
        hasEventNotification: true, // TODO: 실제 알림 상태 연동
      ),
    );
  }
}
