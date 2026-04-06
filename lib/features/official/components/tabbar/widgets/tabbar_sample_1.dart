import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// TabBar 샘플 #1 - 네온 글로우 + 모핑 애니메이션
class TabBarSample1 extends StatefulWidget {
  const TabBarSample1({super.key});

  @override
  State<TabBarSample1> createState() => _TabBarSample1State();
}

class _TabBarSample1State extends State<TabBarSample1>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _glowController;
  late AnimationController _morphController;

  final List<_TabItem> _tabs = [
    _TabItem(icon: Icons.home, label: '홈', gradient: LinearGradient(colors: [Color(0xFF00F5FF), Color(0xFF0080FF)])),
    _TabItem(icon: Icons.explore, label: '탐색', gradient: LinearGradient(colors: [Color(0xFFFF00FF), Color(0xFFFF0080)])),
    _TabItem(icon: Icons.favorite, label: '좋아요', gradient: LinearGradient(colors: [Color(0xFFFF0080), Color(0xFFFF8000)])),
    _TabItem(icon: Icons.person, label: '프로필', gradient: LinearGradient(colors: [Color(0xFF8000FF), Color(0xFF0080FF)])),
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _morphController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    _morphController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0E27),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Neon Glow TabBar',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          // Neon 탭바
          _buildNeonTabBar(),
          const SizedBox(height: 40),
          // 컨텐츠
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTabBar() {
    return Container(
      height: 80,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1535),
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        border: Border.all(
          color: const Color(0xFF1E2749),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 글로우 배경 애니메이션
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) {
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                left: (_selectedIndex * (MediaQuery.of(context).size.width - 80) / _tabs.length) + 10,
                top: 10,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 80) / _tabs.length - 20,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: _tabs[_selectedIndex].gradient,
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    boxShadow: [
                      BoxShadow(
                        color: _tabs[_selectedIndex].gradient.colors.first
                            .withValues(alpha: 0.6 + (_glowController.value * 0.4)),
                        blurRadius: 25 + (_glowController.value * 15),
                        spreadRadius: -5,
                      ),
                      BoxShadow(
                        color: _tabs[_selectedIndex].gradient.colors.last
                            .withValues(alpha: 0.4 + (_glowController.value * 0.3)),
                        blurRadius: 40 + (_glowController.value * 20),
                        spreadRadius: -10,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // 탭 버튼들
          Row(
            children: List.generate(_tabs.length, (index) {
              return Expanded(
                child: _buildNeonTab(index),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildNeonTab(int index) {
    final isSelected = _selectedIndex == index;
    final tab = _tabs[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _morphController.forward(from: 0);
      },
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
        ),
        child: AnimatedBuilder(
          animation: _morphController,
          builder: (context, child) {
            final morphValue = isSelected ? _morphController.value : 1 - _morphController.value;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      if (isSelected) {
                        return tab.gradient.createShader(bounds);
                      }
                      return const LinearGradient(
                        colors: [AppColors.gray400, AppColors.gray400],
                      ).createShader(bounds);
                    },
                    child: Icon(
                      tab.icon,
                      size: 28,
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // 라벨
                AnimatedOpacity(
                  opacity: isSelected ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  child: ShaderMask(
                    shaderCallback: (bounds) {
                      if (isSelected) {
                        return tab.gradient.createShader(bounds);
                      }
                      return LinearGradient(
                        colors: [AppColors.gray400, AppColors.gray400],
                      ).createShader(bounds);
                    },
                    child: Text(
                      tab.label,
                      style: AppTextStyles.body4.copyWith(
                        color: AppColors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Center(
        key: ValueKey(_selectedIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) {
                return _tabs[_selectedIndex].gradient.createShader(bounds);
              },
              child: Icon(
                _tabs[_selectedIndex].icon,
                size: 120,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 24),
            ShaderMask(
              shaderCallback: (bounds) {
                return _tabs[_selectedIndex].gradient.createShader(bounds);
              },
              child: Text(
                _tabs[_selectedIndex].label,
                style: AppTextStyles.display1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final Gradient gradient;

  _TabItem({
    required this.icon,
    required this.label,
    required this.gradient,
  });
}
