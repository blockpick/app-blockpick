import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 가격 블록 아이템 위젯
///
/// ListWheelScrollView에서 사용되는 개별 가격 블록
/// 3D 블록 효과로 레고 블록처럼 입체적으로 표현
class PriceBlockItem extends StatelessWidget {
  final int price;
  final bool isSelected;
  final bool isFocused; // 휠 중앙에 위치한 블록
  final int? recentBidders; // 최근 1시간 입찰자 수 (선택 사항)

  const PriceBlockItem({
    super.key,
    required this.price,
    this.isSelected = false,
    this.isFocused = false,
    this.recentBidders,
  });

  @override
  Widget build(BuildContext context) {
    // 포커스된 블록은 크고 선명하게
    final scale = isFocused ? 1.0 : 0.85;
    final opacity = isFocused ? 1.0 : 0.5;

    // 3D 효과 강도 (선택/포커스 시 더 입체적)
    final depth = (isSelected || isFocused) ? 8.0 : 4.0;

    return Transform.scale(
      scale: scale,
      child: Opacity(opacity: opacity, child: _build3DBlock(depth)),
    );
  }

  /// 3D Isometric 블록 효과 생성 (레고 블록 스타일)
  Widget _build3DBlock(double depth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: CustomPaint(
        painter: _IsometricBlockPainter(
          isSelected: isSelected,
          isFocused: isFocused,
          depth: depth,
        ),
        child: Container(
          height: 90,
          alignment: Alignment.center,
          child: Text(
            _formatPrice(price),
            style: AppTextStyles.large.copyWith(
              color: isSelected ? AppColors.white : AppColors.darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: isFocused ? 28 : 24,
              shadows: isSelected
                  ? [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  /// 가격을 원화 형식으로 포맷
  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}

/// Isometric 스타일 블록 페인터 (레고 블록처럼 입체적)
class _IsometricBlockPainter extends CustomPainter {
  final bool isSelected;
  final bool isFocused;
  final double depth;

  _IsometricBlockPainter({
    required this.isSelected,
    required this.isFocused,
    required this.depth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final blockDepth = depth * 2; // 등각투상 깊이
    final cornerRadius = 16.0;

    // 색상 정의 (배경은 반투명, 테두리만 불투명)
    final topColor = isSelected
        ? AppColors.blue.withValues(alpha: 0.3)
        : AppColors.bgWhite.withValues(alpha: 0.3);

    final sideColor = isSelected
        ? AppColors.blue.withValues(alpha: 0.25)
        : AppColors.buleGray.withValues(alpha: 0.2);

    final rightSideColor = isSelected
        ? AppColors.blue.withValues(alpha: 0.2)
        : AppColors.buleGray.withValues(alpha: 0.15);

    // 1. 메인 블록 배경
    _drawMainBlock(canvas, size, blockDepth, cornerRadius, sideColor);

    // 2. 오른쪽 측면 (어두운 면)
    _drawRightSide(canvas, size, blockDepth, cornerRadius, rightSideColor);

    // 3. 상단 면 (밝은 면)
    _drawTopFace(canvas, size, blockDepth, cornerRadius, topColor);

    // 4. 테두리 강조
    _drawBorder(canvas, size, blockDepth, cornerRadius);
  }

  /// 오른쪽 측면 그리기
  void _drawRightSide(
    Canvas canvas,
    Size size,
    double blockDepth,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, blockDepth)
      ..lineTo(size.width - blockDepth, 0)
      ..lineTo(size.width - blockDepth, size.height - blockDepth)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// 메인 블록 배경 그리기
  void _drawMainBlock(
    Canvas canvas,
    Size size,
    double blockDepth,
    double radius,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 메인 사각형 영역
    final rect = Rect.fromLTWH(
      0,
      blockDepth,
      size.width,
      size.height - blockDepth,
    );
    canvas.drawRect(rect, paint);
  }

  /// 상단 면 그리기 (메인 면 - 평면)
  void _drawTopFace(
    Canvas canvas,
    Size size,
    double blockDepth,
    double radius,
    Color color,
  ) {
    // 평면 단색으로 그리기 (그라데이션 제거)
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, blockDepth)
      ..lineTo(blockDepth, 0)
      ..lineTo(size.width - blockDepth, 0)
      ..lineTo(size.width, blockDepth)
      ..lineTo(size.width, blockDepth)
      ..lineTo(0, blockDepth)
      ..close();

    canvas.drawPath(path, paint);
  }

  /// 테두리 그리기 (4개 모서리 입체적으로)
  void _drawBorder(Canvas canvas, Size size, double blockDepth, double radius) {
    final borderPaint = Paint()
      ..color = isSelected
          ? AppColors.blue
          : AppColors.buleGray.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 3 : 2;

    // 상단 면 테두리 (4개 변 모두 그리기)
    final topPath = Path()
      ..moveTo(0, blockDepth) // 좌하단
      ..lineTo(blockDepth, 0) // 좌상단
      ..lineTo(size.width - blockDepth, 0) // 우상단
      ..lineTo(size.width, blockDepth) // 우하단
      ..close(); // 마지막 선 연결

    canvas.drawPath(topPath, borderPaint);

    // 왼쪽 세로 테두리
    final leftPath = Path()
      ..moveTo(0, blockDepth)
      ..lineTo(0, size.height);

    canvas.drawPath(leftPath, borderPaint);

    // 오른쪽 세로 테두리
    final rightPath = Path()
      ..moveTo(size.width, blockDepth)
      ..lineTo(size.width, size.height);

    canvas.drawPath(rightPath, borderPaint);

    // 하단 테두리 (정면 하단 선)
    final bottomPath = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width, size.height);

    canvas.drawPath(bottomPath, borderPaint);

    // 숨겨진 모서리 점선 (내부 디테일)
    final dashedPaint = Paint()
      ..color = isSelected
          ? AppColors.blue.withValues(alpha: 0.4)
          : AppColors.buleGray.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1.5;

    // 뒷면 상단 가로 점선
    _drawDashedLine(
      canvas,
      Offset(blockDepth, 0),
      Offset(size.width - blockDepth, 0),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );

    // 왼쪽 뒷면 세로 점선
    _drawDashedLine(
      canvas,
      Offset(blockDepth, 0),
      Offset(blockDepth, size.height - blockDepth),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );

    // 뒷면 하단 가로 점선
    _drawDashedLine(
      canvas,
      Offset(blockDepth, size.height - blockDepth),
      Offset(size.width - blockDepth, size.height - blockDepth),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );

    // 오른쪽 뒷면 세로 점선
    _drawDashedLine(
      canvas,
      Offset(size.width - blockDepth, 0),
      Offset(size.width - blockDepth, size.height - blockDepth),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );

    // 왼쪽 측면 뒷면 대각선 점선 (상단)
    _drawDashedLine(
      canvas,
      Offset(0, blockDepth),
      Offset(blockDepth, 0),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 3,
    );

    // 왼쪽 측면 뒷면 대각선 점선 (하단)
    _drawDashedLine(
      canvas,
      Offset(0, size.height),
      Offset(blockDepth, size.height - blockDepth),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );

    // 오른쪽 측면 뒷면 대각선 점선 (상단)
    _drawDashedLine(
      canvas,
      Offset(size.width, blockDepth),
      Offset(size.width - blockDepth, 0),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );

    // 오른쪽 측면 뒷면 대각선 점선 (하단)
    _drawDashedLine(
      canvas,
      Offset(size.width, size.height),
      Offset(size.width - blockDepth, size.height - blockDepth),
      dashedPaint,
      dashWidth: 2,
      dashSpace: 1,
    );
  }

  /// 점선 그리기 헬퍼 함수
  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint, {
    double dashWidth = 5,
    double dashSpace = 3,
  }) {
    final distance = (end - start).distance;
    final dashCount = (distance / (dashWidth + dashSpace)).floor();

    final direction = (end - start) / distance;

    for (int i = 0; i < dashCount; i++) {
      final dashStart =
          start + direction * (dashWidth + dashSpace) * i.toDouble();
      final dashEnd = dashStart + direction * dashWidth;
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(_IsometricBlockPainter oldDelegate) {
    return oldDelegate.isSelected != isSelected ||
        oldDelegate.isFocused != isFocused ||
        oldDelegate.depth != depth;
  }
}
