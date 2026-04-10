import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/block_model.dart';

/// BlockPick 공통 캔버스 페인터
///
/// BuzzCanvas의 `_StitchGridPainter`를 기반으로 확장:
/// - BlockModel 기반 블록 렌더링 (selected/winner/past 등 상태별 색상)
/// - LOD 3단계 (<4px 단색 / <14px border / 14px+ 둥근)
/// - 뷰포트 컬링
/// - 폴리곤 외곽선 (grid_painter.dart의 _drawSelectedBlocksPolygon 이식)
/// - 무한 점 패턴 (BuzzCanvas 방식)
/// - 배경 이미지 / 격자선 / 채워진 블록
/// - 줌% 인디케이터
/// - 다크/라이트 테마
class BlockPickPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double zoom;
  final Offset pan;
  final List<BlockModel> selectedBlocks;
  final ui.Image? backgroundImage;
  final bool showDotPattern;
  final bool darkMode;

  // 셀 크기 상수 (BuzzCanvas 기준)
  static const double cellSize = 24.0;
  static const double cellGap = 2.0;
  static const double gridStep = cellSize + cellGap;

  // 다크 모드 색상
  static const Color _darkBgColor = Color(0xFF1B1D21);
  static const Color _darkDotColor = Color(0xFF3A3D44);
  static const Color _darkBlockColor = Color(0xFF2A2D33);
  static const Color _darkBlockBorder = Color(0xFF3E4149);

  // 라이트 모드 색상
  static const Color _lightBgColor = Color(0xFFF7F8FA);
  static const Color _lightDotColor = Color(0xFFDDE0E4);
  static const Color _lightBlockColor = Color(0xFFFFFFFF);
  static const Color _lightBlockBorder = Color(0xFFE5E8EB);

  const BlockPickPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.zoom,
    required this.pan,
    this.selectedBlocks = const [],
    this.backgroundImage,
    this.showDotPattern = true,
    this.darkMode = true,
  });

  Color get _bgColor => darkMode ? _darkBgColor : _lightBgColor;
  Color get _dotColor => darkMode ? _darkDotColor : _lightDotColor;
  Color get _blockColor => darkMode ? _darkBlockColor : _lightBlockColor;
  Color get _blockBorder => darkMode ? _darkBlockBorder : _lightBlockBorder;
  Color get _zoomBgColor => darkMode ? const Color(0xFF2A2D33) : const Color(0xFFE5E8EB);
  Color get _zoomTextColor => darkMode ? const Color(0xFF6B7684) : const Color(0xFF6B7684);

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = _bgColor,
    );

    // 2. 무한 점 패턴
    if (showDotPattern) {
      _drawInfiniteDots(canvas, size);
    }

    // 3. 배경 이미지
    if (backgroundImage != null) {
      _drawBackgroundImage(canvas, size);
    }

    // 4. 그리드 블록
    final scaledStep = gridStep * zoom;
    final scaledCell = cellSize * zoom;

    if (backgroundImage != null) {
      // 이미지 있으면 격자선만
      if (scaledCell >= 6) {
        _drawGridLines(canvas, size, scaledStep, scaledCell);
      }
    } else {
      // 이미지 없으면 채워진 블록
      if (scaledCell >= 2) {
        _drawBlocks(canvas, size, scaledStep, scaledCell);
      }
    }

    // 5. 선택된 블록 (BlockModel 기반)
    if (selectedBlocks.isNotEmpty) {
      _drawSelectedBlocksWithPolygon(canvas, size, scaledStep, scaledCell);
    }

    // 6. 줌 레벨 표시
    _drawZoomIndicator(canvas, size);
  }

  /// 배경 이미지 — 그리드 영역에 맞춰 그리기
  void _drawBackgroundImage(Canvas canvas, Size size) {
    final img = backgroundImage!;
    final gridSize = math.max(gridWidth, gridHeight);
    final totalGrid = gridSize * gridStep;
    final dstRect = Rect.fromLTWH(
      pan.dx,
      pan.dy,
      totalGrid * zoom,
      totalGrid * zoom,
    );
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    if (!dstRect.overlaps(screenRect)) return;

    final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    canvas.drawImageRect(
      img,
      srcRect,
      dstRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  /// 무한 점 패턴
  void _drawInfiniteDots(Canvas canvas, Size size) {
    double dotSpacing = gridStep * zoom;

    while (dotSpacing < 12) {
      dotSpacing *= 2;
    }
    while (dotSpacing > 80) {
      dotSpacing /= 2;
    }

    final dotPaint = Paint()
      ..color = _dotColor
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final offsetX = pan.dx % dotSpacing;
    final offsetY = pan.dy % dotSpacing;

    final points = <Offset>[];
    for (double y = offsetY; y < size.height; y += dotSpacing) {
      for (double x = offsetX; x < size.width; x += dotSpacing) {
        points.add(Offset(x, y));
      }
    }

    canvas.drawPoints(ui.PointMode.points, points, dotPaint);
  }

  /// 이미지 위 격자선
  void _drawGridLines(Canvas canvas, Size size, double step, double cellPx) {
    final startCol = math.max(0, (-pan.dx / step).floor());
    final endCol = math.min(gridWidth, ((-pan.dx + size.width) / step).ceil());
    final startRow = math.max(0, (-pan.dy / step).floor());
    final endRow = math.min(gridHeight, ((-pan.dy + size.height) / step).ceil());

    final linePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 0.5;

    for (int col = startCol; col <= endCol; col++) {
      final x = pan.dx + col * step;
      final yStart = pan.dy + startRow * step;
      final yEnd = pan.dy + endRow * step;
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), linePaint);
    }
    for (int row = startRow; row <= endRow; row++) {
      final y = pan.dy + row * step;
      final xStart = pan.dx + startCol * step;
      final xEnd = pan.dx + endCol * step;
      canvas.drawLine(Offset(xStart, y), Offset(xEnd, y), linePaint);
    }
  }

  /// 그리드 블록 렌더링 (LOD 3단계 + 뷰포트 컬링)
  void _drawBlocks(Canvas canvas, Size size, double step, double cellPx) {
    final startCol = math.max(0, (-pan.dx / step).floor());
    final endCol = math.min(gridWidth, ((-pan.dx + size.width) / step).ceil());
    final startRow = math.max(0, (-pan.dy / step).floor());
    final endRow = math.min(gridHeight, ((-pan.dy + size.height) / step).ceil());

    if (cellPx < 4) {
      // LOD 0: 단색 사각형
      final paint = Paint()..color = _blockColor;
      for (int row = startRow; row < endRow; row++) {
        for (int col = startCol; col < endCol; col++) {
          canvas.drawRect(
            Rect.fromLTWH(pan.dx + col * step, pan.dy + row * step, cellPx, cellPx),
            paint,
          );
        }
      }
    } else if (cellPx < 14) {
      // LOD 1: border 추가
      final fill = Paint()..color = _blockColor;
      final border = Paint()
        ..color = _blockBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      for (int row = startRow; row < endRow; row++) {
        for (int col = startCol; col < endCol; col++) {
          final rect = Rect.fromLTWH(pan.dx + col * step, pan.dy + row * step, cellPx, cellPx);
          canvas.drawRect(rect, fill);
          canvas.drawRect(rect, border);
        }
      }
    } else {
      // LOD 2: 둥근 사각형 + border
      final fill = Paint()..color = _blockColor;
      final border = Paint()
        ..color = _blockBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      final radius = Radius.circular(math.min(4.0, cellPx * 0.12));

      for (int row = startRow; row < endRow; row++) {
        for (int col = startCol; col < endCol; col++) {
          final rect = Rect.fromLTWH(pan.dx + col * step, pan.dy + row * step, cellPx, cellPx);
          final rrect = RRect.fromRectAndRadius(rect, radius);
          canvas.drawRRect(rrect, fill);
          canvas.drawRRect(rrect, border);
        }
      }
    }
  }

  /// 선택된 블록 렌더링 + 폴리곤 외곽선
  ///
  /// BlockModel 기반: 상태별 색상 + 인접하지 않은 변만 외곽선
  void _drawSelectedBlocksWithPolygon(
    Canvas canvas,
    Size size,
    double step,
    double cellPx,
  ) {
    // 인접 블록 검사를 위한 좌표 Set
    final selectedCoords = <String>{};
    for (final block in selectedBlocks) {
      // BlockModel은 1-based → 0-based로 변환하여 좌표 저장
      selectedCoords.add('${block.row},${block.col}');
    }

    // 폴리곤 외곽선 페인트
    final borderPaint = Paint()
      ..color = AppColors.primaryMain.withValues(alpha: 0.85)
      ..strokeWidth = math.max(1.5, 2.5 * (cellPx / 24).clamp(0.5, 2.0))
      ..style = PaintingStyle.stroke;

    for (final block in selectedBlocks) {
      // 0-based 좌표 계산 (BlockModel은 1-based)
      final col0 = block.col - 1;
      final row0 = block.row - 1;
      final x = pan.dx + col0 * step;
      final y = pan.dy + row0 * step;

      // 뷰포트 컬링
      if (x + cellPx < 0 || x > size.width || y + cellPx < 0 || y > size.height) {
        continue;
      }

      final rect = Rect.fromLTWH(x, y, cellPx, cellPx);
      final radius = Radius.circular(math.min(4.0, cellPx * 0.12));
      final rrect = RRect.fromRectAndRadius(rect, radius);

      // 블록 상태별 색상
      final blockColor = _getBlockStateColor(block.state);

      // 글로우 효과
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(6 * (cellPx / 24).clamp(0.5, 2.0)), radius),
        Paint()
          ..color = blockColor.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );

      // 블록 채우기
      canvas.drawRRect(rrect, Paint()..color = blockColor);

      // 블록 테두리
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = blockColor.withValues(alpha: 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );

      // 별 아이콘 (충분히 클 때만)
      if (cellPx > 18) {
        _drawStar(canvas, rect.center, math.min(cellPx * 0.4, 16.0));
      }

      // 폴리곤 외곽선 — 인접하지 않은 변만
      // 위쪽 변
      if (!selectedCoords.contains('${block.row - 1},${block.col}')) {
        canvas.drawLine(Offset(x, y), Offset(x + cellPx, y), borderPaint);
      }
      // 아래쪽 변
      if (!selectedCoords.contains('${block.row + 1},${block.col}')) {
        canvas.drawLine(Offset(x, y + cellPx), Offset(x + cellPx, y + cellPx), borderPaint);
      }
      // 왼쪽 변
      if (!selectedCoords.contains('${block.row},${block.col - 1}')) {
        canvas.drawLine(Offset(x, y), Offset(x, y + cellPx), borderPaint);
      }
      // 오른쪽 변
      if (!selectedCoords.contains('${block.row},${block.col + 1}')) {
        canvas.drawLine(Offset(x + cellPx, y), Offset(x + cellPx, y + cellPx), borderPaint);
      }
    }
  }

  /// 블록 상태별 색상
  Color _getBlockStateColor(BlockState state) {
    switch (state) {
      case BlockState.selected:
        return AppColors.primaryMain;
      case BlockState.winner:
        return AppColors.yellow500;
      case BlockState.unique:
        return AppColors.green500;
      case BlockState.duplicate:
        return AppColors.red;
      case BlockState.past:
        return AppColors.gray400;
      case BlockState.empty:
        return AppColors.primaryMain;
    }
  }

  /// 별(십자) 아이콘
  void _drawStar(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = AppColors.white;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.25, height: size),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size, height: size * 0.25),
      paint,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.785);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size * 0.2, height: size * 0.7),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size * 0.7, height: size * 0.2),
      paint,
    );
    canvas.restore();
  }

  /// 줌 퍼센트 표시
  void _drawZoomIndicator(Canvas canvas, Size size) {
    final percent = (zoom * 100).toInt();
    final tp = TextPainter(
      text: TextSpan(
        text: '$percent%',
        style: TextStyle(
          color: _zoomTextColor,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - tp.width - 20,
        12,
        tp.width + 12,
        tp.height + 8,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, Paint()..color = _zoomBgColor);
    tp.paint(canvas, Offset(size.width - tp.width - 14, 16));
  }

  @override
  bool shouldRepaint(covariant BlockPickPainter old) {
    return old.zoom != zoom ||
        old.pan != pan ||
        old.selectedBlocks != selectedBlocks ||
        old.backgroundImage != backgroundImage ||
        old.showDotPattern != showDotPattern ||
        old.darkMode != darkMode ||
        old.gridWidth != gridWidth ||
        old.gridHeight != gridHeight;
  }
}
