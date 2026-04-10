import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../components/navigation/bottom_nav_bar.dart';
import '../../providers/current_tab_provider.dart';
import '../../providers/wish_provider.dart';
import '../home/new_home_screen.dart';
import '../daily/daily_screen.dart';
import '../daily_legacy/daily_legacy_screen.dart';
import '../wish/wish_screen.dart';
import '../prime/prime_screen.dart';
import '../my/my_screen.dart';

/// 메인 화면
/// 홈 / 데일리 / 위시 / 프라임 / MY (5개 탭)
class BlockpickScreen extends ConsumerStatefulWidget {
  const BlockpickScreen({super.key});

  @override
  ConsumerState<BlockpickScreen> createState() => _BlockpickScreenState();
}

class _BlockpickScreenState extends ConsumerState<BlockpickScreen> {
  final List<Widget> _screens = [
    const NewHomeScreen(),    // 0: 홈
    const DailyScreen(),        // 1: 데일리
    const WishScreen(),       // 2: 위시 (소원/소문)
    const PrimeScreen(),      // 3: 프라임 (역경매)
    const MyScreen(),         // 4: MY (마이페이지)
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabProvider);
    // 인덱스가 범위를 벗어나면 0으로 리셋
    final safeIndex = currentIndex.clamp(0, _screens.length - 1);

    // 위시 스와이프 모드일 때만 바텀바 숨김
    final hideBottomBar = safeIndex == 2 && ref.watch(wishSwipeModeProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      body: IndexedStack(
        index: safeIndex,
        children: _screens,
      ),
      bottomNavigationBar: hideBottomBar
          ? null
          : BottomNavBar(
              currentIndex: safeIndex,
              onTap: (index) {
                ref.read(currentTabProvider.notifier).setTab(index);
              },
              hasWishNotification: false, // TODO: 위시 알림 상태 연동
            ),
    );
  }
}
