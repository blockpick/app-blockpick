import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../models/block_model.dart';

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
    // debugPrint('🎨 GridPainter.paint() 호출');
    // debugPrint('   - size: $size');
    // debugPrint('   - zoom: $zoom');
    // debugPrint('   - pan: $pan');
    // debugPrint('   - gridSize: $gridWidth x $gridHeight');
    // debugPrint('   - backgroundImage: ${backgroundImage != null ? "있음" : "없음"}');

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

    // 그리드 선 그리기 (셀 경계)
    _drawGridLinesTransformed(canvas, size);

    // 선택된 블록들을 폴리곤 영역으로 그리기 (땅따먹기 스타일)
    _drawSelectedBlocksPolygon(canvas, size);

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

  /// LOD (Level of Detail) 레벨 계산 (동적, 줌에 따라 무한 증가)
  int _getLODLevel(double zoom) {
    if (zoom < 0.05) return 0;
    if (zoom < 0.1) return 1;
    if (zoom < 0.3) return 2;
    if (zoom < 0.6) return 3;
    if (zoom < 1.0) return 4;
    if (zoom < 2.0) return 5;
    if (zoom < 4.0) return 6;
    if (zoom < 8.0) return 7;
    if (zoom < 16.0) return 8;
    // 줌이 계속 커지면 레벨도 계속 증가
    return (math.log(zoom) / math.log(2)).floor() + 4;
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
      final dstRect = Rect.fromLTWH(0, 0, totalGridWidth, totalGridHeight);

      // 이미지를 그리드에 맞춰 그리기
      final imagePaint = Paint()..filterQuality = FilterQuality.high;

      canvas.drawImageRect(backgroundImage!, srcRect, dstRect, imagePaint);

      // 🎮 강한 오버레이 (구역 패턴 가시성을 위해)
      final overlayPaint = Paint()..color = Colors.white.withOpacity(0.5);

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

  /// 줌 레벨에 따른 구역 분할 수 계산 (동적으로 증가)
  int _getRegionDivisions(int lodLevel) {
    switch (lodLevel) {
      case 0:
        return 3; // 3x3 = 9
      case 1:
        return 3; // 3x3 = 9
      case 2:
        return 4; // 4x4 = 16
      case 3:
        return 6; // 6x6 = 36
      case 4:
        return 8; // 8x8 = 64
      case 5:
        return 12; // 12x12 = 144
      case 6:
        return 16; // 16x16 = 256
      case 7:
        return 24; // 24x24 = 576
      case 8:
        return 32; // 32x32 = 1024
      default:
        // L9+: 동적으로 계속 증가
        if (lodLevel > 8) {
          return math.min(64, 32 + (lodLevel - 8) * 8);
        }
        return 0; // 구역 없음
    }
  }

  /// 블록의 구역 ID 계산 (각 LOD 레벨마다 독립적인 명명)
  String _getBlockRegionId(int row, int col, int lodLevel) {
    final divisions = _getRegionDivisions(lodLevel);
    if (divisions == 0) return '';

    // 현재 LOD 레벨에서 블록이 속한 구역 계산
    final regionWidth = gridWidth / divisions;
    final regionHeight = gridHeight / divisions;

    final regionRow = ((row - 1) / regionHeight).floor();
    final regionCol = ((col - 1) / regionWidth).floor();

    // 숫자 기반 명명 체계: R행C열
    // 예: R1C1, R1C2, R2C1, R2C2, ...
    return 'R${regionRow + 1}C${regionCol + 1}';
  }

  /// 구역별 배경색 가져오기
  Color _getRegionColor(int regionRow, int regionCol) {
    // 9개 색상 팔레트 (파스텔 톤)
    final colors = [
      const Color(0xFFE8F4F8), // 연한 파랑
      const Color(0xFFF0E8F4), // 연한 보라
      const Color(0xFFFFF0F0), // 연한 분홍
      const Color(0xFFFFF8E8), // 연한 노랑
      const Color(0xFFE8F8E8), // 연한 초록
      const Color(0xFFF8F0E8), // 연한 주황
      const Color(0xFFE8F0FF), // 연한 하늘색
      const Color(0xFFF8E8FF), // 연한 라벤더
      const Color(0xFFFFE8F0), // 연한 핑크
    ];

    // 체스판 패턴으로 색상 배치
    final index = (regionRow + regionCol) % colors.length;
    return colors[index];
  }

  /// 🎮 지뢰찾기 스타일: 전체 구역 체스판 패턴 그리기
  void _drawAllRegionGrid(Canvas canvas, Size size) {
    final lodLevel = _getLODLevel(zoom);
    final divisions = _getRegionDivisions(lodLevel);

    if (divisions == 0) return;

    final totalGridWidth = gridWidth * cellSize;
    final totalGridHeight = gridHeight * cellSize;

    final regionWidth = totalGridWidth / divisions;
    final regionHeight = totalGridHeight / divisions;

    // Viewport Culling: 화면에 보이는 구역만 그리기
    final viewportLeft = -pan.dx / zoom;
    final viewportRight = (-pan.dx + size.width) / zoom;
    final viewportTop = -pan.dy / zoom;
    final viewportBottom = (-pan.dy + size.height) / zoom;

    final startRegionCol = math.max(0, (viewportLeft / regionWidth).floor());
    final endRegionCol = math.min(divisions - 1, (viewportRight / regionWidth).ceil());
    final startRegionRow = math.max(0, (viewportTop / regionHeight).floor());
    final endRegionRow = math.min(divisions - 1, (viewportBottom / regionHeight).ceil());

    // LOD 레벨별 색상 강도 (더 진하게!)
    double baseOpacity;
    if (lodLevel <= 1) {
      baseOpacity = 0.15; // L0-L1: 연함
    } else if (lodLevel <= 3) {
      baseOpacity = 0.18; // L2-L3: 보통
    } else if (lodLevel <= 5) {
      baseOpacity = 0.20; // L4-L5: 진함
    } else {
      baseOpacity = 0.22; // L6+: 더 진함
    }

    // 전체 구역에 체스판 패턴 그리기
    for (int row = startRegionRow; row <= endRegionRow; row++) {
      for (int col = startRegionCol; col <= endRegionCol; col++) {
        final x = col * regionWidth;
        final y = row * regionHeight;

        final regionRect = Rect.fromLTWH(x, y, regionWidth, regionHeight);

        // 체스판 패턴 (짝수/홀수로 색상 교차)
        final isEven = (row + col) % 2 == 0;
        final bgColor = isEven
            ? _getRegionColor(row, col).withOpacity(baseOpacity)
            : _getRegionColor(row, col).withOpacity(baseOpacity * 0.5);

        final bgPaint = Paint()
          ..color = bgColor
          ..style = PaintingStyle.fill;

        canvas.drawRect(regionRect, bgPaint);

        // 🎮 LOD별 구역 테두리 색상 (지뢰찾기 스타일)
        Color borderColor;
        double borderOpacity;

        if (lodLevel <= 1) {
          borderColor = AppColors.blue;
          borderOpacity = 0.3;
        } else if (lodLevel <= 3) {
          borderColor = AppColors.green;
          borderOpacity = 0.3;
        } else if (lodLevel <= 5) {
          borderColor = AppColors.yellow;
          borderOpacity = 0.3;
        } else {
          borderColor = AppColors.red;
          borderOpacity = 0.3;
        }

        final borderPaint = Paint()
          ..color = borderColor.withOpacity(borderOpacity)
          ..strokeWidth = math.max(1.0, 2.0 / zoom)
          ..style = PaintingStyle.stroke;

        canvas.drawRect(regionRect, borderPaint);
      }
    }
  }

  /// 🎮 지뢰찾기 스타일: 선택된 개별 셀만 하이라이트
  void _drawSelectedCellsHighlight(Canvas canvas, Size size) {
    if (selectedBlocks.isEmpty) return;

    final lodLevel = _getLODLevel(zoom);

    // LOD별 셀 하이라이트 색상
    Color highlightColor;
    double opacity;

    if (lodLevel <= 1) {
      highlightColor = AppColors.blue;
      opacity = 0.4;
    } else if (lodLevel <= 3) {
      highlightColor = AppColors.green;
      opacity = 0.45;
    } else if (lodLevel <= 5) {
      highlightColor = AppColors.yellow;
      opacity = 0.5;
    } else {
      highlightColor = AppColors.red;
      opacity = 0.55;
    }

    // 각 선택된 블록(셀)을 개별적으로 그리기
    for (final block in selectedBlocks) {
      final x = (block.col - 1) * cellSize;
      final y = (block.row - 1) * cellSize;

      final cellRect = Rect.fromLTWH(x, y, cellSize, cellSize);

      // 셀 배경 (지뢰찾기 스타일)
      final bgPaint = Paint()
        ..color = highlightColor.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawRect(cellRect, bgPaint);

      // 셀 테두리 (진하게)
      final borderPaint = Paint()
        ..color = highlightColor.withOpacity(0.8)
        ..strokeWidth = math.max(2.0, 3.0 / zoom)
        ..style = PaintingStyle.stroke;

      canvas.drawRect(cellRect, borderPaint);
    }
  }

  /// [사용 안 함] 구역 강조 (개별 셀 하이라이트로 대체됨)
  void _drawRegionBackgrounds_OLD(Canvas canvas, Size size) {
    final lodLevel = _getLODLevel(zoom);
    final divisions = _getRegionDivisions(lodLevel);

    if (divisions == 0 || selectedBlocks.isEmpty) return;

    final totalGridWidth = gridWidth * cellSize;
    final totalGridHeight = gridHeight * cellSize;

    final regionWidth = totalGridWidth / divisions;
    final regionHeight = totalGridHeight / divisions;

    // LOD 레벨별 하이라이트 강도 (더 진하게!)
    double highlightOpacity;
    double borderWidth;
    Color borderColor;

    if (lodLevel <= 1) {
      // L0-L1: 넓은 구역, 매우 진한 하이라이트
      highlightOpacity = 0.6;
      borderWidth = 10.0 / zoom;
      borderColor = AppColors.blue; // 파란색
    } else if (lodLevel <= 3) {
      // L2-L3: 중간 구역, 진한 하이라이트
      highlightOpacity = 0.55;
      borderWidth = 8.0 / zoom;
      borderColor = AppColors.green; // 초록색
    } else if (lodLevel <= 5) {
      // L4-L5: 좁은 구역, 보통 하이라이트
      highlightOpacity = 0.5;
      borderWidth = 6.0 / zoom;
      borderColor = AppColors.yellow; // 노란색
    } else {
      // L6+: 매우 좁은 구역, 약한 하이라이트
      highlightOpacity = 0.45;
      borderWidth = 5.0 / zoom;
      borderColor = AppColors.red; // 빨간색
    }

    // 선택된 블록이 속한 구역들만 표시
    final Map<String, int> regionBlockCounts = {}; // 구역별 블록 수

    for (final block in selectedBlocks) {
      // 블록이 속한 구역 계산
      final regionRow = ((block.row - 1) / (gridHeight / divisions)).floor();
      final regionCol = ((block.col - 1) / (gridWidth / divisions)).floor();

      final regionKey = '$regionRow-$regionCol';
      regionBlockCounts[regionKey] = (regionBlockCounts[regionKey] ?? 0) + 1;
    }

    // 각 구역 그리기 (블록 수에 따라 강도 조절)
    for (final entry in regionBlockCounts.entries) {
      final parts = entry.key.split('-');
      final regionRow = int.parse(parts[0]);
      final regionCol = int.parse(parts[1]);
      final blockCount = entry.value;

      final x = regionCol * regionWidth;
      final y = regionRow * regionHeight;

      final regionRect = Rect.fromLTWH(x, y, regionWidth, regionHeight);

      // 블록 수가 많을수록 진하게 (최대 2배)
      final intensityMultiplier = math.min(2.0, 1.0 + (blockCount - 1) * 0.2);

      // 구역 배경색 (지뢰찾기 스타일)
      final bgPaint = Paint()
        ..color = _getRegionColor(regionRow, regionCol)
            .withOpacity(highlightOpacity * intensityMultiplier)
        ..style = PaintingStyle.fill;

      canvas.drawRect(regionRect, bgPaint);

      // 구역 테두리 (LOD별 다른 색상)
      final borderPaint = Paint()
        ..color = borderColor.withOpacity(0.9)
        ..strokeWidth = borderWidth
        ..style = PaintingStyle.stroke;

      canvas.drawRect(regionRect, borderPaint);

      // 🎯 블록 개수 표시 (LOD 3 이상에서만)
      if (lodLevel >= 3 && blockCount > 1) {
        final textSpan = TextSpan(
          text: '×$blockCount',
          style: TextStyle(
            color: Colors.white,
            fontSize: (regionWidth * 0.15 / zoom).clamp(12.0, 24.0),
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.7),
                offset: Offset(1.0 / zoom, 1.0 / zoom),
                blurRadius: 2.0 / zoom,
              ),
            ],
          ),
        );

        final textPainter = TextPainter(
          text: textSpan,
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        // 구역 우상단에 배치
        textPainter.paint(
          canvas,
          Offset(
            x + regionWidth - textPainter.width - 10 / zoom,
            y + 10 / zoom,
          ),
        );
      }
    }
  }

  /// 그리드 선 그리기 (변환된 좌표계 + Viewport Culling)
  void _drawGridLinesTransformed(Canvas canvas, Size size) {
    // 배경 이미지가 있을 때는 더 투명하게
    final opacity = backgroundImage != null ? 0.15 : 0.3;

    // 줌에 상관없이 화면에서 1픽셀로 보이도록 선 두께 조정
    // Canvas가 이미 scale(zoom)되었으므로, 1/zoom으로 보정
    final paint = Paint()
      ..color = Colors.black
          .withOpacity(opacity) // 검은색 그리드
      ..strokeWidth =
          1.0 / zoom // 줌 레벨에 따라 조정 (화면에서 항상 1px)
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
    for (
      int col = startCol.clamp(0, gridWidth);
      col <= endCol.clamp(0, gridWidth);
      col += step
    ) {
      final x = col * cellSize;
      canvas.drawLine(
        Offset(x, math.max(0, viewportTop)),
        Offset(x, math.min(totalGridHeight, viewportBottom)),
        paint,
      );
    }

    // 가로 선 (뷰포트에 보이는 것만)
    for (
      int row = startRow.clamp(0, gridHeight);
      row <= endRow.clamp(0, gridHeight);
      row += step
    ) {
      final y = row * cellSize;
      canvas.drawLine(
        Offset(math.max(0, viewportLeft), y),
        Offset(math.min(totalGridWidth, viewportRight), y),
        paint,
      );
    }
  }

  /// 선택된 블록들을 폴리곤 영역으로 그리기 (땅따먹기 스타일)
  void _drawSelectedBlocksPolygon(Canvas canvas, Size size) {
    if (selectedBlocks.isEmpty) return;

    // 선택된 블록들의 좌표를 Set으로 저장 (빠른 검색)
    final selectedCoords = <String>{};
    for (var block in selectedBlocks) {
      selectedCoords.add('${block.row},${block.col}');
    }

    // 채우기 페인트 (반투명 분홍색)
    final fillPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // 테두리 페인트 (진한 분홍색, 두꺼운 선)
    final borderPaint = Paint()
      ..color = const Color(0xFFFF1493).withOpacity(0.8)
      ..strokeWidth = 3.0 / zoom // 화면에서 3px로 보이도록
      ..style = PaintingStyle.stroke;

    // 각 선택된 블록에 대해
    for (var block in selectedBlocks) {
      final x = (block.col - 1) * cellSize;
      final y = (block.row - 1) * cellSize;

      // 셀 영역 채우기
      canvas.drawRect(
        Rect.fromLTWH(x, y, cellSize, cellSize),
        fillPaint,
      );

      // 외곽선만 그리기 (인접하지 않은 변만)
      // 위쪽 변
      if (!selectedCoords.contains('${block.row - 1},${block.col}')) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + cellSize, y),
          borderPaint,
        );
      }
      // 아래쪽 변
      if (!selectedCoords.contains('${block.row + 1},${block.col}')) {
        canvas.drawLine(
          Offset(x, y + cellSize),
          Offset(x + cellSize, y + cellSize),
          borderPaint,
        );
      }
      // 왼쪽 변
      if (!selectedCoords.contains('${block.row},${block.col - 1}')) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + cellSize),
          borderPaint,
        );
      }
      // 오른쪽 변
      if (!selectedCoords.contains('${block.row},${block.col + 1}')) {
        canvas.drawLine(
          Offset(x + cellSize, y),
          Offset(x + cellSize, y + cellSize),
          borderPaint,
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
