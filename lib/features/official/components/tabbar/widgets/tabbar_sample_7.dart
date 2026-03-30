import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// TabBar 샘플 #7 - 네이버 스타일 Underline TabBar
class TabBarSample7 extends StatefulWidget {
  const TabBarSample7({super.key});

  @override
  State<TabBarSample7> createState() => _TabBarSample7State();
}

class _TabBarSample7State extends State<TabBarSample7> {
  int _selectedIndex = 0;

  final List<String> _tabs = ['뉴스', '증권', '부동산', '쇼핑', '영화'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '네이버 스타일',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: List.generate(_tabs.length, (index) {
                    return Expanded(
                      child: _buildNaverTab(index),
                    );
                  }),
                ),
              ),
              Container(
                height: 1,
                color: AppColors.buleGray,
              ),
            ],
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article,
              size: 100,
              color: AppColors.green500,
            ),
            SizedBox(height: 20),
            Text(
              _tabs[_selectedIndex],
              style: AppTextStyles.display1.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNaverTab(int index) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.green500 : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Center(
          child: Text(
            _tabs[index],
            style: AppTextStyles.body3.copyWith(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.darkBlue : AppColors.medium,
            ),
          ),
        ),
      ),
    );
  }
}
