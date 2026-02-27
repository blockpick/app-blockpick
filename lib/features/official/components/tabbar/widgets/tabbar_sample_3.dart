import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';

/// TabBar 샘플 #3 - Liquid Swipe + 입자 효과
class TabBarSample3 extends StatefulWidget {
  const TabBarSample3({super.key});

  @override
  State<TabBarSample3> createState() => _TabBarSample3State();
}

class _TabBarSample3State extends State<TabBarSample3>
    with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _liquidController;
  late AnimationController _particleController;
  final List<Particle> _particles = [];

  final List<_LiquidTab> _tabs = [
    _LiquidTab(
      icon: Icons.rocket_launch,
      label: '런치',
      colors: [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)],
    ),
    _LiquidTab(
      icon: Icons.flash_on,
      label: '에너지',
      colors: [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
    ),
    _LiquidTab(
      icon: Icons.auto_awesome,
      label: '매직',
      colors: [const Color(0xFFB24592), const Color(0xFFF15F79)],
    ),
    _LiquidTab(
      icon: Icons.nights_stay,
      label: '밤',
      colors: [const Color(0xFF2E3192), const Color(0xFF1BFFFF)],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _liquidController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();

    for (int i = 0; i < 30; i++) {
      _particles.add(Particle());
    }
  }

  @override
  void dispose() {
    _liquidController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _tabs[_selectedIndex].colors,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _particleController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: ParticlePainter(
                        particles: _particles,
                        animation: _particleController.value,
                      ),
                    );
                  },
                ),
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                        Text(
                          'Liquid Swipe TabBar',
                          style: AppTextStyles.large.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _buildContent(),
                  ),
                  const SizedBox(height: 20),
                  _buildLiquidTabBar(),
                  const SizedBox(height: 40),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidTabBar() {
    return Container(
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(45),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textBlack.withValues(alpha: 0.2),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(45),
              child: BackdropFilter(
                filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: AppColors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _liquidController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(double.infinity, 90),
                painter: LiquidPainter(
                  selectedIndex: _selectedIndex,
                  tabCount: _tabs.length,
                  animation: _liquidController.value,
                  color: AppColors.white,
                ),
              );
            },
          ),
          Row(
            children: List.generate(_tabs.length, (index) {
              return Expanded(
                child: _buildLiquidTab(index),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidTab(int index) {
    final isSelected = _selectedIndex == index;
    final tab = _tabs[index];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _liquidController.forward(from: 0);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(45),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: isSelected ? 1.0 : 0.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: 1.0 + (value * 0.2),
                  child: Icon(
                    tab.icon,
                    size: 32,
                    color: isSelected
                        ? _tabs[_selectedIndex].colors.first
                        : AppColors.white.withValues(alpha: 0.6),
                  ),
                );
              },
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: isSelected ? 13 : 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? _tabs[_selectedIndex].colors.first
                    : AppColors.white.withValues(alpha: 0.6),
              ),
              child: Text(tab.label),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Center(
        key: ValueKey(_selectedIndex),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.5),
                  width: 3,
                ),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: AppColors.white.withValues(alpha: 0.1),
                    child: Icon(
                      _tabs[_selectedIndex].icon,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              _tabs[_selectedIndex].label,
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiquidTab {
  final IconData icon;
  final String label;
  final List<Color> colors;

  _LiquidTab({
    required this.icon,
    required this.label,
    required this.colors,
  });
}

class LiquidPainter extends CustomPainter {
  final int selectedIndex;
  final int tabCount;
  final double animation;
  final Color color;

  LiquidPainter({
    required this.selectedIndex,
    required this.tabCount,
    required this.animation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final tabWidth = size.width / tabCount;
    final centerX = (selectedIndex + 0.5) * tabWidth;
    final centerY = size.height / 2;

    final path = Path();
    const radius = 35.0;
    final liquidWidth = tabWidth * 0.7;
    final waveHeight = 15 * (1 - animation);

    path.moveTo(centerX - liquidWidth / 2, centerY);

    path.quadraticBezierTo(
      centerX - liquidWidth / 2,
      centerY - radius - waveHeight,
      centerX - liquidWidth / 4,
      centerY - radius,
    );

    path.quadraticBezierTo(
      centerX,
      centerY - radius + waveHeight,
      centerX + liquidWidth / 4,
      centerY - radius,
    );

    path.quadraticBezierTo(
      centerX + liquidWidth / 2,
      centerY - radius - waveHeight,
      centerX + liquidWidth / 2,
      centerY,
    );

    path.quadraticBezierTo(
      centerX + liquidWidth / 2,
      centerY + radius + waveHeight,
      centerX + liquidWidth / 4,
      centerY + radius,
    );

    path.quadraticBezierTo(
      centerX,
      centerY + radius - waveHeight,
      centerX - liquidWidth / 4,
      centerY + radius,
    );

    path.quadraticBezierTo(
      centerX - liquidWidth / 2,
      centerY + radius + waveHeight,
      centerX - liquidWidth / 2,
      centerY,
    );

    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(LiquidPainter oldDelegate) => true;
}

class Particle {
  double x = math.Random().nextDouble();
  double y = math.Random().nextDouble();
  double size = math.Random().nextDouble() * 3 + 1;
  double speedX = (math.Random().nextDouble() - 0.5) * 0.002;
  double speedY = (math.Random().nextDouble() - 0.5) * 0.002;

  void update() {
    x += speedX;
    y += speedY;

    if (x < 0 || x > 1) speedX *= -1;
    if (y < 0 || y > 1) speedY *= -1;
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animation;

  ParticlePainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      particle.update();
      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) => true;
}
