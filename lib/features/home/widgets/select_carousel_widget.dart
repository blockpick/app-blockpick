import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

/// SELECT 게임 캐러셀 위젯 (좌우 스와이프)
class SelectCarouselWidget extends StatefulWidget {
  const SelectCarouselWidget({super.key});

  @override
  State<SelectCarouselWidget> createState() => _SelectCarouselWidgetState();
}

class _SelectCarouselWidgetState extends State<SelectCarouselWidget> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // SELECT 게임 목 데이터
  final List<SelectGameData> _games = const [
    SelectGameData(
      productName: 'GUCCI SMALL TOP HANDLE BAG',
      price: 5.00,
      imageAsset: 'assets/images/home/gucci-bag-hero.png',
      accentColor: Color(0xFF7359F7),
    ),
    SelectGameData(
      productName: 'LOUIS VUITTON POCHETTE',
      price: 4.50,
      imageAsset: 'assets/images/home/louis-vuitton-bag.png',
      accentColor: Color(0xFF6E5AE9),
    ),
    SelectGameData(
      productName: 'NIKE AIR JORDAN RETRO',
      price: 3.50,
      imageAsset: 'assets/images/home/nike-air-jordan.png',
      accentColor: Color(0xFF5C9DFF),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // SELECT 게임 상세로 이동
      },
      child: Container(
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 히어로 영역 (배경 고정, 이미지/배지 페이징)
            SizedBox(
              height: 320,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 38,
                    left: 0,
                    right: 0,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFF7455FF), Color(0xFF8F7CFF)],
                      ).createShader(bounds),
                      child: const Text(
                        'SELECT',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 58,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: SizedBox(
                      height: 300,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPage = index;
                          });
                        },
                        itemCount: _games.length,
                        itemBuilder: (context, index) {
                          return _SelectHeroItem(game: _games[index]);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 하단 정보 영역
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // 상품명
                  Text(
                    _games[_currentPage].productName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                      letterSpacing: 0.3,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // 서브 텍스트
                  const Text(
                    'Join now and claim yours!',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grayBlue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_games.length, (index) {
                      return Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentPage
                              ? const Color(0xFF6E5AE9)
                              : AppColors.gray300,
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 14),

                  // JOIN NOW 버튼
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFF6E5AE9),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF6E5AE9,
                          ).withValues(alpha: 0.18),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'JOIN NOW',
                          style: TextStyle(
                            color: Color(0xFF1F2140),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [Color(0xFF6E5AE9), Color(0xFF9B7EFF)],
                            ),
                          ),
                          child: const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// SELECT 게임 데이터 모델
class SelectGameData {
  final String productName;
  final double price;
  final String imageAsset;
  final Color accentColor;

  const SelectGameData({
    required this.productName,
    required this.price,
    required this.imageAsset,
    required this.accentColor,
  });
}

/// 12각 폭발형 배지를 위한 커스텀 클리퍼
class _BurstClipper extends CustomClipper<Path> {
  const _BurstClipper({this.points = 12});

  final int points;

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.74;
    final step = math.pi / points;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (step * i) - math.pi / 2;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// 상품 이미지 + 가격 배지 (스와이프 대상)
class _SelectHeroItem extends StatelessWidget {
  const _SelectHeroItem({required this.game});

  final SelectGameData game;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 260,
        height: 220,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              bottom: 14,
              left: 48,
              right: 48,
              child: Container(
                height: 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Colors.black.withValues(alpha: 0.05),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.center,
              child: Image.asset(game.imageAsset, fit: BoxFit.contain),
            ),
            Positioned(
              right: 48,
              bottom: 30,
              child: ClipPath(
                clipper: const _BurstClipper(points: 16),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF7C4DFF), Color(0xFF9B7EFF)],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '\$${game.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
