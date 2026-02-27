import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 프리미엄 상품 쇼케이스 위젯
class ProductShowcasePremiumWidget extends StatelessWidget {
  const ProductShowcasePremiumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      _ProductData(
        name: 'Dior Book Tote',
        label: 'Select Block',
        icon: Icons.shopping_bag,
        colors: const [
          AppColors.gray800,
          AppColors.gray800,
        ],
        accentColor: AppColors.primaryMain,
      ),
      _ProductData(
        name: 'IPHONE 16',
        label: 'Stage Block',
        icon: Icons.phone_iphone,
        colors: const [
          AppColors.gray700,
          AppColors.gray600,
        ],
        accentColor: AppColors.blue,
      ),
    ];

    return SizedBox(
      height: 110,
      child: Row(
        children: List.generate(products.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 0 ? 12 : 0),
              child: _PremiumProductCard(product: products[index]),
            ),
          );
        }),
      ),
    );
  }
}

class _ProductData {
  final String name;
  final String label;
  final IconData icon;
  final List<Color> colors;
  final Color accentColor;

  _ProductData({
    required this.name,
    required this.label,
    required this.icon,
    required this.colors,
    required this.accentColor,
  });
}

class _PremiumProductCard extends StatefulWidget {
  final _ProductData product;

  const _PremiumProductCard({required this.product});

  @override
  State<_PremiumProductCard> createState() => _PremiumProductCardState();
}

class _PremiumProductCardState extends State<_PremiumProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.product.colors,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.product.colors.last.withValues(alpha: 0.4),
                blurRadius: _isHovered ? 20 : 14,
                offset: Offset(0, _isHovered ? 10 : 6),
              ),
              BoxShadow(
                color: widget.product.accentColor.withValues(alpha: _isHovered ? 0.15 : 0.08),
                blurRadius: 25,
                offset: const Offset(0, 12),
                spreadRadius: -5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              children: [
                // 배경 패턴
                Positioned.fill(
                  child: CustomPaint(
                    painter: _DiagonalLinesPainter(
                      color: Colors.white.withValues(alpha: 0.03),
                    ),
                  ),
                ),

                // 상단 글로우
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // 애니메이션 shimmer
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Positioned(
                      top: 0,
                      bottom: 0,
                      left: -100 + (_controller.value * (MediaQuery.of(context).size.width + 200)),
                      child: Container(
                        width: 100,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.08),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),

                // 콘텐츠
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // 상품 이미지 박스
                      _buildProductImageBox(),
                      const SizedBox(width: 14),

                      // 텍스트 영역
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 라벨 배지
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.product.accentColor.withValues(alpha: 0.25),
                                    widget.product.accentColor.withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: widget.product.accentColor.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.product.accentColor.withValues(alpha: 0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.emoji_events,
                                    color: widget.product.accentColor,
                                    size: 13,
                                    shadows: const [
                                      Shadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.product.label,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 8),

                            // 상품명
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [
                                  AppColors.white,
                                  AppColors.gray200,
                                ],
                              ).createShader(bounds),
                              child: Text(
                                widget.product.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black38,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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
        ),
      ),
    );
  }

  Widget _buildProductImageBox() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: widget.product.accentColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 그라데이션
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: RadialGradient(
                  colors: [
                    widget.product.accentColor.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 아이콘
          Center(
            child: Icon(
              widget.product.icon,
              size: 36,
              color: widget.product.accentColor.withValues(alpha: 0.4),
            ),
          ),

          // 상단 하이라이트
          Positioned(
            top: 8,
            left: 8,
            right: 8,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 대각선 패턴 페인터
class _DiagonalLinesPainter extends CustomPainter {
  final Color color;

  _DiagonalLinesPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (double i = -size.height; i < size.width + size.height; i += 25) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
