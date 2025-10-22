import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../game/game_list_screen.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 홈 화면 (탭 네비게이션)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppColors.gradientBluePurplePink,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.grid,
                color: AppColors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text('BlockPick'),
          ],
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: const BoxDecoration(
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
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.search),
            onPressed: () {
              // TODO: 검색 기능
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell),
            onPressed: () {
              // TODO: 알림 기능
            },
          ),
          IconButton(
            icon: const Icon(LucideIcons.user),
            onPressed: () {
              // TODO: 프로필 기능
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          GameListScreen(gameType: GameType.daily),
          GameListScreen(gameType: GameType.select),
          GameListScreen(gameType: GameType.vibe),
        ],
      ),
    );
  }
}
