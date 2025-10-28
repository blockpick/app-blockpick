import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../game/game_list_screen.dart';
import '../optimal/optimal_game_list_screen.dart';

/// 홈 화면 (PICK 탭 - DAILY/SELECT/VIBE/OPTIMAL)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 탭 바
          Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.buleGray),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.blue,
            indicatorWeight: 3,
            labelColor: AppColors.blue,
            unselectedLabelColor: AppColors.medium,
            labelStyle: AppTextStyles.button,
            tabs: const [
              Tab(text: 'DAILY'),
              Tab(text: 'SELECT'),
              Tab(text: 'VIBE'),
              Tab(text: 'OPTIMAL'),
            ],
          ),
        ),
        // 탭 뷰
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              GameListScreen(gameType: GameType.daily),
              GameListScreen(gameType: GameType.select),
              GameListScreen(gameType: GameType.vibe),
              OptimalGameListScreen(),
            ],
          ),
        ),
      ],
      ),
    );
  }
}
