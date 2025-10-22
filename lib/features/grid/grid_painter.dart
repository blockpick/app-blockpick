import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../models/block_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import 'dart:math' as math;

/// 그리드를 렌더링하는 CustomPainter
///
/// Sparse Grid 최적화 및 LOD (Level of Detail) 시스템을 적용하여
/// 대형 그리드(최대 1000x1000)를 효율적으로 렌더링합니다.
class GridPainter extends CustomPainter {
  /// 그리드 크기 (N x N)
  final int gridSize;

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
    required this.gridSize,
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
    // 뷰포트 경계 계산
    final viewportBounds = _getViewportBounds(size);

    // 배경 그리기
    _drawBackground(canvas, size);

    // 그리드 선 그리기 (항상 표시)
    _drawGridLines(canvas, size, viewportBounds);

    // 선택된 셀 그리기
    _drawSelectedCells(canvas, viewportBounds);

    // LOD에 따라 추가 정보 렌더링
    final lodLevel = _getLODLevel(zoom);
    if (lodLevel >= 3) {
      _drawCellLabels(canvas, viewportBounds);
    }

    // 디버그: 렌더링 정보 출력 (첫 프레임만)
    if (backgroundImage != null) {
      print('🎨 GridPainter: Drawing with background image ${backgroundImage!.width}x${backgroundImage!.height}');
    } else {
      print('🎨 GridPainter: Drawing without background image');
    }
  }

  /// 뷰포트 경계 계산 (Viewport Culling)
  _ViewportBounds _getViewportBounds(Size size) {
    final scaledCellSize = cellSize * zoom;

    // 뷰포트에 보이는 시작/끝 행/열 계산
    final startRow = math.max(1, (-pan.dy / scaledCellSize).floor());
    final endRow = math.min(
      gridSize,
      ((-pan.dy + size.height) / scaledCellSize).ceil(),
    );

    final startCol = math.max(1, (-pan.dx / scaledCellSize).floor());
    final endCol = math.min(
      gridSize,
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

  /// 배경 그리기
  void _drawBackground(Canvas canvas, Size size) {
    if (backgroundImage != null) {
      // 배경 이미지를 그리드 크기에 맞춰 렌더링 (지도처럼 팬/줌 가능)
      final scaledCellSize = cellSize * zoom;
      final totalGridSize = gridSize * scaledCellSize;

      final srcRect = Rect.fromLTWH(
        0,
        0,
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      );

      // 그리드 전체 크기에 맞춰 이미지 렌더링 (팬/줌 적용)
      final dstRect = Rect.fromLTWH(
        pan.dx,
        pan.dy,
        totalGridSize,
        totalGridSize,
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
      // 배경 이미지가 없으면 그라데이션 배경
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
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        paint,
      );
    }
  }

  /// 그리드 선 그리기
  void _drawGridLines(
    Canvas canvas,
    Size size,
    _ViewportBounds bounds,
  ) {
    // 배경 이미지가 있을 때는 더 투명하게
    final opacity = backgroundImage != null ? 0.15 : 0.3;

    final paint = Paint()
      ..color = Colors.black.withOpacity(opacity) // 검은색 그리드
      ..strokeWidth = 0.5 / zoom // 더 얇은 선
      ..style = PaintingStyle.stroke;

    final scaledCellSize = cellSize * zoom;

    // LOD에 따라 그리드 선 간격 조정
    // 줌 레벨에 따라 동적으로 step 계산 (화면에 적절한 수의 그리드 라인 표시)
    final lodLevel = _getLODLevel(zoom);
    int step;

    if (gridSize >= 5000) {
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
    } else if (gridSize >= 1000) {
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

    // 그리드 영역 계산
    final totalGridSize = gridSize * scaledCellSize;
    final gridLeft = pan.dx;
    final gridTop = pan.dy;
    final gridRight = pan.dx + totalGridSize;
    final gridBottom = pan.dy + totalGridSize;

    // 세로 선 (그리드 영역 내에만)
    for (int col = bounds.minCol; col <= bounds.maxCol; col += step) {
      final x = col * scaledCellSize + pan.dx;
      // 그리드 영역 내에만 그리기
      if (x >= gridLeft && x <= gridRight) {
        canvas.drawLine(
          Offset(x, math.max(0, gridTop)),
          Offset(x, math.min(size.height, gridBottom)),
          paint,
        );
      }
    }

    // 가로 선 (그리드 영역 내에만)
    for (int row = bounds.minRow; row <= bounds.maxRow; row += step) {
      final y = row * scaledCellSize + pan.dy;
      // 그리드 영역 내에만 그리기
      if (y >= gridTop && y <= gridBottom) {
        canvas.drawLine(
          Offset(math.max(0, gridLeft), y),
          Offset(math.min(size.width, gridRight), y),
          paint,
        );
      }
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
        oldDelegate.wireframeMode != wireframeMode;
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
