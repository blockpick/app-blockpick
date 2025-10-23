import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../models/block_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'dart:math' as math;

/// 그리드를 렌더링하는 CustomPainter
///
/// Sparse Grid 최적화 및 LOD (Level of Detail) 시스템을 적용하여
/// 대형 그리드(최대 10000x10000)를 효율적으로 렌더링합니다.
class GridPainter extends CustomPainter {
  /// 그리드 가로 크기
  final int gridWidth;

  /// 그리드 세로 크기
  final int gridHeight;

  /// 셀 크기 (픽셀)
  final double cellSize;

  /// 줌 레벨
  final double zoom;

  /// 팬 오프셋
  final Offset pan;

  /// 선택된 블록 목록
  final List<BlockModel> selectedBlocks;

  /// 와이어프레임 모드
  final bool wireframeMode;

  /// 그리드 색상
  final Color gridColor;

  /// 선택된 셀 색상
  final Color selectedColor;

  /// 배경 이미지 (제품 이미지)
  final ui.Image? backgroundImage;

  GridPainter({
    required this.gridWidth,
    required this.gridHeight,
    this.cellSize = AppConstants.cellSize,
    required this.zoom,
    required this.pan,
    this.selectedBlocks = const [],
    this.wireframeMode = false,
    this.gridColor = AppColors.buleGray,
    this.selectedColor = AppColors.blue,
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Canvas 저장 (변환 전 상태)
    canvas.save();

    // 🎯 전체 캔버스에 pan/zoom 적용 (n8n 워크플로우처럼)
    // 1. 팬 적용
    canvas.translate(pan.dx, pan.dy);
    // 2. 줌 적용
    canvas.scale(zoom);

    // 이제 모든 그리기는 변환된 좌표계에서 수행됨
    final scaledCellSize = cellSize; // zoom은 이미 canvas.scale로 적용됨

    // 배경 이미지 그리기 (0, 0부터 그리드 크기만큼)
    _drawBackgroundTransformed(canvas, size);

    // 그리드 선 그리기
    _drawGridLinesTransformed(canvas, size);

    // Canvas 복원
    canvas.restore();
  }

  /// 뷰포트 경계 계산 (Viewport Culling)
  _ViewportBounds _getViewportBounds(Size size) {
    final scaledCellSize = cellSize * zoom;

    // 뷰포트에 보이는 시작/끝 행/열 계산
    final startRow = math.max(1, (-pan.dy / scaledCellSize).floor());
    final endRow = math.min(
      gridHeight,
      ((-pan.dy + size.height) / scaledCellSize).ceil(),
    );

    final startCol = math.max(1, (-pan.dx / scaledCellSize).floor());
    final endCol = math.min(
      gridWidth,
      ((-pan.dx + size.width) / scaledCellSize).ceil(),
    );

    return _ViewportBounds(
      minRow: startRow,
      maxRow: endRow,
      minCol: startCol,
      maxCol: endCol,
    );
  }

  /// LOD (Level of Detail) 레벨 계산
  int _getLODLevel(double zoom) {
    if (zoom < AppConstants.lodThresholds['ultraLow']!) return 0;
    if (zoom < AppConstants.lodThresholds['veryLow']!) return 1;
    if (zoom < AppConstants.lodThresholds['low']!) return 2;
    if (zoom < AppConstants.lodThresholds['medium']!) return 3;
    if (zoom < AppConstants.lodThresholds['high']!) return 4;
    return 5;
  }

  /// 배경 그리기 (변환된 좌표계)
  void _drawBackgroundTransformed(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      // 그리드 전체 크기 (변환 전 좌표)
      final totalGridWidth = gridWidth * cellSize;
      final totalGridHeight = gridHeight * cellSize;

      final srcRect = Rect.fromLTWH(
        0,
        0,
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      );

      // 그리드 크기에 맞춰 이미지 렌더링 (0, 0부터 시작)
      final dstRect = Rect.fromLTWH(
        0,
        0,
        totalGridWidth,
        totalGridHeight,
      );

      // 이미지를 그리드에 맞춰 그리기 (약간 밝게)
      final imagePaint = Paint()
        ..filterQuality = FilterQuality.high
        ..colorFilter = ColorFilter.mode(
          Colors.white.withOpacity(0.3),
          BlendMode.lighten,
        );

      canvas.drawImageRect(
        backgroundImage!,
        srcRect,
        dstRect,
        imagePaint,
      );

      // 약한 오버레이 (그리드 가시성을 위해)
      final overlayPaint = Paint()
        ..color = Colors.black.withOpacity(0.05);

      canvas.drawRect(dstRect, overlayPaint);
    } else {
      // 배경 이미지가 없으면 그리드 영역만 그라데이션
      final totalGridWidth = gridWidth * cellSize;
      final totalGridHeight = gridHeight * cellSize;

      final paint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.deepWhite,
            AppColors.blueWhite,
            AppColors.blueWhite,
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, totalGridWidth, totalGridHeight));

      canvas.drawRect(
        Rect.fromLTWH(0, 0, totalGridWidth, totalGridHeight),
        paint,
      );
    }
  }

  /// 그리드 선 그리기 (변환된 좌표계 + Viewport Culling)
  void _drawGridLinesTransformed(
    Canvas canvas,
    Size size,
  ) {
    // 배경 이미지가 있을 때는 더 투명하게
    final opacity = backgroundImage != null ? 0.15 : 0.3;

    // 줌에 상관없이 일정한 선 두께 (Canvas가 이미 scale되었으므로)
    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity) // 검은색 그리드
      ..strokeWidth = 1.0 // 고정된 선 두께 (canvas.scale이 이미 적용됨)
      ..style = PaintingStyle.stroke;

    // LOD에 따라 그리드 선 간격 조정
    final lodLevel = _getLODLevel(zoom);
    final maxGridSize = gridWidth > gridHeight ? gridWidth : gridHeight;
    int step;

    if (maxGridSize >= 5000) {
      // 매우 큰 그리드 (10000x10000 등)
      if (lodLevel <= 0) {
        step = 500; // 극저 줌 (0.05 이하)
      } else if (lodLevel <= 1) {
        step = 200; // 매우 낮은 줌 (0.05-0.1)
      } else if (lodLevel <= 2) {
        step = 100; // 낮은 줌 (0.1-0.3)
      } else if (lodLevel <= 3) {
        step = 50; // 중간 줌 (0.3-0.6)
      } else if (lodLevel <= 4) {
        step = 20; // 높은 줌 (0.6-1.0)
      } else {
        step = 10; // 매우 높은 줌 (1.0+)
      }
    } else if (maxGridSize >= 1000) {
      // 큰 그리드 (1000x1000)
      if (lodLevel <= 0) {
        step = 100;
      } else if (lodLevel <= 1) {
        step = 50;
      } else if (lodLevel <= 2) {
        step = 20;
      } else if (lodLevel <= 3) {
        step = 10;
      } else {
        step = 5;
      }
    } else {
      // 작은 그리드 (100x100)
      if (lodLevel <= 1) {
        step = 10;
      } else if (lodLevel <= 2) {
        step = 5;
      } else {
        step = 1;
      }
    }

    // 그리드 영역 (변환 전 좌표)
    final totalGridWidth = gridWidth * cellSize;
    final totalGridHeight = gridHeight * cellSize;

    // 🚀 Viewport Culling: 화면에 보이는 영역만 계산
    // canvas.scale(zoom)이 적용된 상태이므로, 역변환하여 뷰포트 범위 계산
    final viewportLeft = -pan.dx / zoom;
    final viewportRight = (-pan.dx + size.width) / zoom;
    final viewportTop = -pan.dy / zoom;
    final viewportBottom = (-pan.dy + size.height) / zoom;

    // 뷰포트에 보이는 그리드 선만 그리기
    final startCol = ((viewportLeft / cellSize).floor() / step).floor() * step;
    final endCol = ((viewportRight / cellSize).ceil() / step).ceil() * step;
    final startRow = ((viewportTop / cellSize).floor() / step).floor() * step;
    final endRow = ((viewportBottom / cellSize).ceil() / step).ceil() * step;

    // 세로 선 (뷰포트에 보이는 것만)
    for (int col = startCol.clamp(0, gridWidth); col <= endCol.clamp(0, gridWidth); col += step) {
      final x = col * cellSize;
      canvas.drawLine(
        Offset(x, math.max(0, viewportTop)),
        Offset(x, math.min(totalGridHeight, viewportBottom)),
        paint,
      );
    }

    // 가로 선 (뷰포트에 보이는 것만)
    for (int row = startRow.clamp(0, gridHeight); row <= endRow.clamp(0, gridHeight); row += step) {
      final y = row * cellSize;
      canvas.drawLine(
        Offset(math.max(0, viewportLeft), y),
        Offset(math.min(totalGridWidth, viewportRight), y),
        paint,
      );
    }
  }

  /// 선택된 셀 그리기 (배경만, SVG 아이콘은 Widget으로 렌더링)
  void _drawSelectedCells(Canvas canvas, _ViewportBounds bounds) {
    // SVG 아이콘으로 대체되므로 배경 렌더링은 제거
    // 블록 상태는 GameGridWidget의 SVG 오버레이로 표시됨
  }

  /// 셀 라벨 그리기 (고줌 레벨에서만)
  void _drawCellLabels(Canvas canvas, _ViewportBounds bounds) {
    final scaledCellSize = cellSize * zoom;

    // 텍스트가 충분히 보일 정도로 줌이 큰 경우에만 렌더링
    if (scaledCellSize < 40) return;

    for (final block in selectedBlocks) {
      if (block.row < bounds.minRow ||
          block.row > bounds.maxRow ||
          block.col < bounds.minCol ||
          block.col > bounds.maxCol) {
        continue;
      }

      final centerX =
          (block.col - 1) * scaledCellSize + pan.dx + scaledCellSize / 2;
      final centerY =
          (block.row - 1) * scaledCellSize + pan.dy + scaledCellSize / 2;

      final textSpan = TextSpan(
        text: '${block.row},${block.col}',
        style: TextStyle(
          color: Colors.white,
          fontSize: (scaledCellSize * 0.2).clamp(10, 16),
          fontWeight: FontWeight.w600,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          centerX - textPainter.width / 2,
          centerY - textPainter.height / 2,
        ),
      );
    }
  }

  /// 블록 상태에 따른 색상 반환
  Color _getBlockColor(BlockState state) {
    switch (state) {
      case BlockState.selected:
        return AppColors.blue;
      case BlockState.winner:
        return AppColors.yellow;
      case BlockState.unique:
        return AppColors.green;
      case BlockState.duplicate:
        return AppColors.red;
      case BlockState.past:
        return AppColors.medium;
      case BlockState.empty:
      default:
        return Colors.transparent;
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.pan != pan ||
        oldDelegate.selectedBlocks != selectedBlocks ||
        oldDelegate.wireframeMode != wireframeMode ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}

/// 뷰포트 경계
class _ViewportBounds {
  final int minRow;
  final int maxRow;
  final int minCol;
  final int maxCol;

  _ViewportBounds({
    required this.minRow,
    required this.maxRow,
    required this.minCol,
    required this.maxCol,
  });
}
