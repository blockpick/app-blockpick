import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// SELECT 게임 캐러셀 위젯 (프리미엄 디자인)
class SelectCarouselPremiumWidget extends StatefulWidget {
  const SelectCarouselPremiumWidget({super.key});

  @override
  State<SelectCarouselPremiumWidget> createState() => _SelectCarouselPremiumWidgetState();
}

class _SelectCarouselPremiumWidgetState extends State<SelectCarouselPremiumWidget>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _shimmerController;
  late AnimationController _floatController;

  final List<SelectGameData> _games = const [
    SelectGameData(
      productName: 'GUCCI SMALL TOP HANDLE BAG',
      price: 5.00,
      accentColor1: AppColors.primaryMain,
      accentColor2: AppColors.primaryLight,
    ),
    SelectGameData(
      productName: 'LOUIS VUITTON POCHETTE',
      price: 4.50,
      accentColor1: AppColors.pink,
      accentColor2: AppColors.primaryLight,
    ),
    SelectGameData(
      productName: 'NIKE AIR JORDAN RETRO',
      price: 3.50,
      accentColor1: AppColors.blue,
      accentColor2: AppColors.blue,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _shimmerController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // SELECT 게임 상세로 이동
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.white,
              AppColors.gray100,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryMain.withValues(alpha: 0.08),
              blurRadius: 30,
              offset: const Offset(0, 15),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: AppColors.textBlack.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // 배경 패턴 레이어
              Positioned.fill(
                child: CustomPaint(
                  painter: _BackgroundPatternPainter(),
                ),
              ),

              // 메인 콘텐츠
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 히어로 영역
                  SizedBox(
                    height: 360,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 배경 글로우 효과
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _shimmerController,
                            builder: (context, child) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: RadialGradient(
                                    center: Alignment(
                                      math.sin(_shimmerController.value * math.pi * 2) * 0.5,
                                      math.cos(_shimmerController.value * math.pi * 2) * 0.5,
                                    ),
                                    radius: 1.5,
                                    colors: [
                                      _games[_currentPage].accentColor1.withValues(alpha: 0.12),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // SELECT 배경 텍스트 (큰 사이즈, 반투명)
                        Positioned(
                          top: 80,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  _games[_currentPage].accentColor1.withValues(alpha: 0.06),
                                  _games[_currentPage].accentColor2.withValues(alpha: 0.06),
                                ],
                              ).createShader(bounds),
                              child: const Text(
                                'SELECT',
                                style: TextStyle(
                                  fontSize: 100,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 8,
                                  height: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),

                        // SELECT 상단 텍스트 (작은 사이즈, 선명)
                        Positioned(
                          top: 28,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Stack(
                              children: [
                                // 텍스트 글로우
                                ShaderMask(
                                  shaderCallback: (bounds) => LinearGradient(
                                    colors: [
                                      _games[_currentPage].accentColor1,
                                      _games[_currentPage].accentColor2,
                                    ],
                                  ).createShader(bounds),
                                  child: Text(
                                    'SELECT',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 4,
                                      height: 1.0,
                                      shadows: [
                                        Shadow(
                                          color: _games[_currentPage].accentColor1.withValues(alpha: 0.5),
                                          blurRadius: 20,
                                        ),
                                        Shadow(
                                          color: _games[_currentPage].accentColor2.withValues(alpha: 0.3),
                                          blurRadius: 40,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // 상품 이미지 캐러셀
                        Positioned(
                          top: 100,
                          left: 0,
                          right: 0,
                          child: SizedBox(
                            height: 240,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentPage = index;
                                });
                              },
                              itemCount: _games.length,
                              itemBuilder: (context, index) {
                                return _buildProductCard(_games[index]);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 하단 정보 영역
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.0),
                          Colors.white,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // 상품명 with shine effect
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              AppColors.textBlack,
                              AppColors.gray800,
                            ],
                          ).createShader(bounds),
                          child: Text(
                            _games[_currentPage].productName,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.5,
                              height: 1.3,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        SizedBox(height: 8),

                        // 서브 텍스트
                        Text(
                          'Join now and claim yours!',
                          style: AppTextStyles.title3.copyWith(color: AppColors.gray600),
                        ),

                        const SizedBox(height: 16),

                        // 페이지 인디케이터 (더 화려하게)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_games.length, (index) {
                            final isActive = index == _currentPage;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: isActive ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                gradient: isActive
                                    ? LinearGradient(
                                        colors: [
                                          _games[_currentPage].accentColor1,
                                          _games[_currentPage].accentColor2,
                                        ],
                                      )
                                    : null,
                                color: isActive ? null : AppColors.gray200,
                                boxShadow: isActive
                                    ? [
                                        BoxShadow(
                                          color: _games[_currentPage].accentColor1.withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                            );
                          }),
                        ),

                        const SizedBox(height: 18),

                        // JOIN NOW 버튼 (훨씬 더 화려하게)
                        _buildPremiumButton(),
                      ],
                    ),
                  ),
                ],
              ),

              // 상단 shimmer 효과
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: 200,
                child: AnimatedBuilder(
                  animation: _shimmerController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment(-1.0 + _shimmerController.value * 4, -1.0),
                          end: Alignment(1.0 + _shimmerController.value * 4, 1.0),
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.05),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(SelectGameData game) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, math.sin(_floatController.value * math.pi * 2) * 8),
          child: Center(
            child: Container(
              width: 230,
              height: 230,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    game.accentColor1.withValues(alpha: 0.02),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: game.accentColor1.withValues(alpha: 0.15),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                    spreadRadius: -5,
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // 상품 이미지 플레이스홀더 (with gradient overlay)
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            game.accentColor1.withValues(alpha: 0.1),
                            game.accentColor2.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        size: 80,
                        color: game.accentColor1.withValues(alpha: 0.3),
                      ),
                    ),
                  ),

                  // 프리미엄 가격 뱃지 (폭발형 + 글로우)
                  Positioned(
                    right: -8,
                    bottom: 20,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 글로우 레이어
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                game.accentColor1.withValues(alpha: 0.4),
                                game.accentColor2.withValues(alpha: 0.1),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),

                        // 배지 본체
                        ClipPath(
                          clipper: _StarBurstClipper(points: 12),
                          child: Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  game.accentColor1,
                                  game.accentColor2,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: game.accentColor1.withValues(alpha: 0.5),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '\$${game.price.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black26,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPremiumButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: LinearGradient(
          colors: [
            _games[_currentPage].accentColor1,
            _games[_currentPage].accentColor2,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: _games[_currentPage].accentColor1.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: _games[_currentPage].accentColor2.withValues(alpha: 0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(32),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'JOIN NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 배경 패턴 페인터
class _BackgroundPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryMain.withValues(alpha: 0.02)
      ..style = PaintingStyle.fill;

    // 도트 패턴
    for (double x = 0; x < size.width; x += 40) {
      for (double y = 0; y < size.height; y += 40) {
        canvas.drawCircle(Offset(x, y), 1.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 별 폭발 클리퍼
class _StarBurstClipper extends CustomClipper<Path> {
  const _StarBurstClipper({this.points = 12});

  final int points;

  @override
  Path getClip(Size size) {
    final path = Path();
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = math.min(size.width, size.height) / 2;
    final innerRadius = outerRadius * 0.7;
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

class SelectGameData {
  final String productName;
  final double price;
  final Color accentColor1;
  final Color accentColor2;

  const SelectGameData({
    required this.productName,
    required this.price,
    required this.accentColor1,
    required this.accentColor2,
  });
}
