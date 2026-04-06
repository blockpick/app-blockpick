import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// TabBar 샘플 #2 - 3D Floating + 리플 파동 효과
class TabBarSample2 extends StatefulWidget {
  const TabBarSample2({super.key});

  @override
  State<TabBarSample2> createState() => _TabBarSample2State();
}

class _TabBarSample2State extends State<TabBarSample2>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _rippleController;
  late AnimationController _floatController;
  Offset? _ripplePosition;

  final List<_Tab3D> _tabs = [
    _Tab3D(icon: Icons.dashboard, label: '대시보드', color: AppColors.primaryMain),
    _Tab3D(icon: Icons.bar_chart, label: '통계', color: AppColors.pink),
    _Tab3D(icon: Icons.notifications, label: '알림', color: AppColors.yellow500),
    _Tab3D(icon: Icons.settings, label: '설정', color: AppColors.green500),
  ];

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rippleController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  void _triggerRipple(Offset position) {
    setState(() {
      _ripplePosition = position;
    });
    _rippleController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A2E),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '3D Floating TabBar',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 배경 파티클
          ...List.generate(20, (index) {
            return AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                final offset = math.sin((_floatController.value + index / 20) * 2 * math.pi) * 20;
                return Positioned(
                  left: (index % 5) * (MediaQuery.of(context).size.width / 5),
                  top: (index ~/ 5) * 150 + offset,
                  child: Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                  ),
                );
              },
            );
          }),
          Column(
            children: [
              const Spacer(),
              // 컨텐츠
              Expanded(
                flex: 3,
                child: _buildContent(),
              ),
              const SizedBox(height: 40),
              // 3D 플로팅 탭바
              _build3DTabBar(),
              const SizedBox(height: 40),
            ],
          ),
          // 리플 효과
          if (_ripplePosition != null)
            AnimatedBuilder(
              animation: _rippleController,
              builder: (context, child) {
                return Positioned(
                  left: _ripplePosition!.dx - (150 * _rippleController.value),
                  top: _ripplePosition!.dy - (150 * _rippleController.value),
                  child: IgnorePointer(
                    child: Container(
                      width: 300 * _rippleController.value,
                      height: 300 * _rippleController.value,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: _tabs[_selectedIndex].color
                              .withValues(alpha: 1 - _rippleController.value),
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _build3DTabBar() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final floatOffset = math.sin(_floatController.value * 2 * math.pi) * 10;
        return Transform.translate(
          offset: Offset(0, floatOffset),
          child: Container(
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Stack(
              children: [
                // 그림자 레이어
                Positioned(
                  bottom: 0,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 20,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textBlack.withValues(alpha: 0.3),
                          blurRadius: 30,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
                // 메인 탭바
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF2D2D44),
                        Color(0xFF1F1F30),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textBlack.withValues(alpha: 0.5),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: List.generate(_tabs.length, (index) {
                      return Expanded(
                        child: _build3DTab(index),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _build3DTab(int index) {
    final isSelected = _selectedIndex == index;
    final tab = _tabs[index];

    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        _triggerRipple(localPosition);
      },
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
        duration: const Duration(milliseconds: 400),
        curve: Curves.elasticOut,
        builder: (context, value, child) {
          return Transform.scale(
            scale: 1.0 + (value * 0.15),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [
                          tab.color,
                          tab.color.withValues(alpha: 0.8),
                        ]
                      : [
                          Colors.transparent,
                          Colors.transparent,
                        ],
                ),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: tab.color.withValues(alpha: 0.6),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tab.icon,
                    size: 28,
                    color: isSelected ? AppColors.white : AppColors.gray400,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    tab.label,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? AppColors.white : AppColors.gray400,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: Center(
        key: ValueKey(_selectedIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _tabs[_selectedIndex].color,
                    _tabs[_selectedIndex].color.withValues(alpha: 0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _tabs[_selectedIndex].color.withValues(alpha: 0.5),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _tabs[_selectedIndex].icon,
                size: 70,
                color: AppColors.white,
              ),
            ),
            SizedBox(height: 32),
            Text(
              _tabs[_selectedIndex].label,
              style: AppTextStyles.display1.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab3D {
  final IconData icon;
  final String label;
  final Color color;

  _Tab3D({
    required this.icon,
    required this.label,
    required this.color,
  });
}
