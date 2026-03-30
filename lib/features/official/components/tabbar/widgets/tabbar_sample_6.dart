import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// TabBar 샘플 #6 - 카카오톡 스타일 TabBar
class TabBarSample6 extends StatefulWidget {
  const TabBarSample6({super.key});

  @override
  State<TabBarSample6> createState() => _TabBarSample6State();
}

class _TabBarSample6State extends State<TabBarSample6> {
  int _selectedIndex = 0;

  final List<_KakaoTab> _tabs = [
    _KakaoTab(icon: Icons.chat_bubble, label: '채팅', badge: '3'),
    _KakaoTab(icon: Icons.people, label: '친구', badge: null),
    _KakaoTab(icon: Icons.shopping_bag, label: '쇼핑', badge: null),
    _KakaoTab(icon: Icons.more_horiz, label: '더보기', badge: null),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '카카오톡 스타일',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.buleGray,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                _tabs[_selectedIndex].label,
                style: AppTextStyles.display1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ),
          // 카카오톡 스타일 하단 탭바
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(
                top: BorderSide(color: AppColors.buleGray, width: 0.5),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(_tabs.length, (index) {
                    return _buildKakaoTab(index);
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKakaoTab(int index) {
    final tab = _tabs[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  tab.icon,
                  size: 28,
                  color: isSelected ? AppColors.darkBlue : AppColors.medium,
                ),
                if (tab.badge != null)
                  Positioned(
                    right: -10,
                    top: -5,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        tab.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              tab.label,
              style: AppTextStyles.body4.copyWith(
                color: isSelected ? AppColors.darkBlue : AppColors.medium,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KakaoTab {
  final IconData icon;
  final String label;
  final String? badge;

  _KakaoTab({required this.icon, required this.label, this.badge});
}
