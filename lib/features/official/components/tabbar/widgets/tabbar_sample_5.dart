import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// TabBar 샘플 #5 - Material 3 스타일 TabBar
class TabBarSample5 extends StatefulWidget {
  const TabBarSample5({super.key});

  @override
  State<TabBarSample5> createState() => _TabBarSample5State();
}

class _TabBarSample5State extends State<TabBarSample5>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<_TabData> _tabs = [
    _TabData(icon: Icons.home, label: '홈'),
    _TabData(icon: Icons.explore, label: '탐색'),
    _TabData(icon: Icons.favorite, label: '좋아요'),
    _TabData(icon: Icons.person, label: '프로필'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Material 3 TabBar',
          style: AppTextStyles.large.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) {
            return Tab(
              icon: Icon(tab.icon),
              text: tab.label,
            );
          }).toList(),
          labelColor: AppColors.blue,
          unselectedLabelColor: AppColors.medium,
          indicatorColor: AppColors.blue,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.map((tab) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  tab.icon,
                  size: 100,
                  color: AppColors.blue,
                ),
                const SizedBox(height: 20),
                Text(
                  tab.label,
                  style: AppTextStyles.display.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _TabData {
  final IconData icon;
  final String label;

  _TabData({required this.icon, required this.label});
}
