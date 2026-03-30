import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 가격 블록 아이템 위젯 (글라스모피즘 스타일)
///
/// Figma 스펙:
/// - Fill: #222222 20%
/// - Effects: Glass
/// - Corner radius: 8
/// - Opacity: 100% (center) / 80% (±1) / 30% (±2+)
class PriceBlockItem extends StatelessWidget {
  final int price;
  final bool isSelected;
  final bool isFocused;
  final int distanceFromCenter; // 중앙으로부터 거리 (0=중앙, 1=인접, 2+=원거리)
  final int? recentBidders;

  const PriceBlockItem({
    super.key,
    required this.price,
    this.isSelected = false,
    this.isFocused = false,
    this.distanceFromCenter = 0,
    this.recentBidders,
  });

  /// Figma 스펙 기반 Opacity: 100% / 80% / 30%
  double get _itemOpacity {
    if (distanceFromCenter == 0) return 1.0;
    if (distanceFromCenter == 1) return 0.8;
    return 0.3;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: _itemOpacity,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                // Figma: Fill #222222 20%
                color: const Color(0xFF222222).withValues(alpha: 0.20),
                borderRadius: BorderRadius.circular(8),
              ),
              // 선택된 블록: 그라데이션 보더 (파랑→보라→분홍)
              foregroundDecoration: isSelected
                  ? BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: GradientBorder(
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF7C3AED),
                            Color(0xFFFF58BB),
                          ],
                        ),
                        width: 2.5,
                      ),
                    )
                  : null,
              child: Center(
                child: Text(
                  _formatPrice(price),
                  style: AppTextStyles.heading1.copyWith(
                    // 선택: 금색 / 비선택: 어두운 텍스트
                    color: isSelected
                        ? const Color(0xFFFFD700)
                        : AppColors.textBlack,
                    fontWeight: FontWeight.w700,
                    fontSize: isFocused ? 26 : 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }
}

/// 그라데이션 보더 구현
class GradientBorder extends BoxBorder {
  final Gradient gradient;
  final double width;

  const GradientBorder({
    required this.gradient,
    this.width = 1.0,
  });

  @override
  BorderSide get top => BorderSide.none;

  @override
  BorderSide get bottom => BorderSide.none;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(width);

  @override
  bool get isUniform => true;

  @override
  void paint(
    Canvas canvas,
    Rect rect, {
    TextDirection? textDirection,
    BoxShape shape = BoxShape.rectangle,
    BorderRadius? borderRadius,
  }) {
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = width
      ..style = PaintingStyle.stroke;

    if (borderRadius != null) {
      final rrect = borderRadius.toRRect(rect).deflate(width / 2);
      canvas.drawRRect(rrect, paint);
    } else {
      canvas.drawRect(rect.deflate(width / 2), paint);
    }
  }

  @override
  ShapeBorder scale(double t) {
    return GradientBorder(
      gradient: gradient,
      width: width * t,
    );
  }
}
