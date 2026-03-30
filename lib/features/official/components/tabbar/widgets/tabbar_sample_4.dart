import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// TabBar 샘플 #4 - iOS 스타일 Segmented Control
class TabBarSample4 extends StatefulWidget {
  const TabBarSample4({super.key});

  @override
  State<TabBarSample4> createState() => _TabBarSample4State();
}

class _TabBarSample4State extends State<TabBarSample4> {
  int _selectedIndex = 0;

  final List<String> _tabs = ['홈', '탐색', '알림', '프로필'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'iOS Segmented Control',
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
          const SizedBox(height: 20),
          // iOS 스타일 Segmented Control
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _selectedIndex == index
                              ? AppColors.white
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: _selectedIndex == index
                              ? [
                                  BoxShadow(
                                    color: AppColors.darkBlue.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            _tabs[index],
                            style: AppTextStyles.body3.copyWith(
                              fontWeight: _selectedIndex == index
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: _selectedIndex == index
                                  ? AppColors.darkBlue
                                  : AppColors.medium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          SizedBox(height: 40),
          // 컨텐츠
          Expanded(
            child: Center(
              child: Text(
                _tabs[_selectedIndex],
                style: AppTextStyles.display1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
