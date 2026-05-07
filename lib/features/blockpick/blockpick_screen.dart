import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../components/navigation/bottom_nav_bar.dart';
import '../../providers/current_tab_provider.dart';
import '../home/new_home_screen.dart';
import '../blockpick_list/blockpick_list_screen.dart';
import '../participation/participation_history_screen.dart';
import '../referral/referral_main_screen.dart';
import '../my/my_screen.dart';

/// 메인 화면 (기획서 IA 5탭)
/// 홈 / 블록픽 / 참여내역 / 친구초대 / 마이
class BlockpickScreen extends ConsumerStatefulWidget {
  const BlockpickScreen({super.key});

  @override
  ConsumerState<BlockpickScreen> createState() => _BlockpickScreenState();
}

class _BlockpickScreenState extends ConsumerState<BlockpickScreen> {
  final List<Widget> _screens = const [
    NewHomeScreen(), // 0: 홈
    BlockpickListScreen(), // 1: 블록픽
    ParticipationHistoryScreen(), // 2: 참여내역
    ReferralMainScreen(), // 3: 친구초대
    MyScreen(), // 4: 마이
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(currentTabProvider);
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
      ),
    );
  }
}
