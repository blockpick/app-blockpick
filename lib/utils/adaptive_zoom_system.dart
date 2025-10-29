import 'dart:math' as math;
import '../core/constants/app_constants.dart';

/// 그리드 크기
class GridSize {
  final int rows;
  final int cols;

  const GridSize(this.rows, this.cols);

  int get maxDim => rows > cols ? rows : cols;
  int get minDim => rows < cols ? rows : cols;
}

/// Zoom 스펙 (선택 가능한 레벨 정의)
class ZoomSpec {
  /// 최소 레벨 (0: 전체 보기)
  final int minLevel;

  /// 최대 레벨
  final int maxLevel;

  /// 선택 가능 레벨 (cellPx >= 16인 레벨)
  final int selectLevel;

  /// 선택 가능한 최소 셀 크기 (px)
  final double cellSelectPx;

  const ZoomSpec({
    required this.minLevel,
    required this.maxLevel,
    required this.selectLevel,
    this.cellSelectPx = 16.0,
  });

  /// 현재 레벨이 선택 가능한지 확인
  bool isSelectable(int level) => level >= selectLevel;

  /// 레벨 범위 확인
  bool isValidLevel(int level) => level >= minLevel && level <= maxLevel;
}

/// Zoom 스펙 계산
ZoomSpec computeZoomSpec({
  required GridSize grid,
  required double viewportShortSidePx,
  double cellSelectPx = 16.0,
  double cellSize = 30.0, // AppConstants.cellSize
}) {
  final maxDim = grid.maxDim;

  // 그리드 규모별 권장 레벨 수
  final suggestedMax = maxDim <= 100
      ? 3
      : maxDim <= 1000
          ? 6
          : maxDim <= 2500
              ? 7
              : maxDim <= 10000
                  ? 8
                  : 10;

  // 선택 가능 레벨 찾기
  int selectLevel = 3; // 기본값
  for (int l = 1; l <= suggestedMax; l++) {
    // 레벨 l에서 보이는 셀 수 (각 레벨은 2배씩 확대)
    final gridInView = (maxDim / math.pow(2, l - 1)).ceil();
    final cellPx = viewportShortSidePx / gridInView;

    if (cellPx >= cellSelectPx) {
      selectLevel = l;
      break;
    }
  }

  return ZoomSpec(
    minLevel: 0,
    maxLevel: suggestedMax,
    selectLevel: selectLevel,
    cellSelectPx: cellSelectPx,
  );
}

/// Zoom 매퍼 (레벨 ↔ 스케일 변환)
class ZoomMapper {
  final int minLevel;
  final int maxLevel;
  final double baseScale; // L1 기준 배율

  const ZoomMapper({
    required this.minLevel,
    required this.maxLevel,
    required this.baseScale,
  });

  /// 레벨 → 스케일
  double levelToScale(int level) {
    if (level <= 0) return baseScale * 0.5; // L0은 전체 보기
    return baseScale * math.pow(2, level - 1);
  }

  /// 스케일 → 가장 가까운 레벨
  int scaleToNearestLevel(double scale) {
    int bestLevel = 1;
    double bestDiff = double.infinity;

    for (int l = minLevel; l <= maxLevel; l++) {
      final s = levelToScale(l);
      final d = (s - scale).abs();
      if (d < bestDiff) {
        bestLevel = l;
        bestDiff = d;
      }
    }

    return bestLevel;
  }

  /// 현재 스케일에서의 셀 크기 계산
  double getCellSize(double scale, {double baseCellSize = 30.0}) {
    return baseCellSize * scale;
  }

  /// 레벨별 셀 크기 (px)
  double getCellSizeAtLevel(int level, {double baseCellSize = 30.0}) {
    return baseCellSize * levelToScale(level);
  }
}

/// 셀 크기 기반 레벨 상태
enum CellSizeLevel {
  /// 탐색 (선택 불가): cellPx < 12
  explore,

  /// 안내 (곧 선택 가능): 12 ≤ cellPx < 16
  guide,

  /// 선택 가능: cellPx ≥ 16
  selectable,
}

/// 셀 크기로 상태 판단
CellSizeLevel getCellSizeLevel(double cellPx) {
  if (cellPx < 12.0) {
    return CellSizeLevel.explore;
  } else if (cellPx < 16.0) {
    return CellSizeLevel.guide;
  } else {
    return CellSizeLevel.selectable;
  }
}

/// 셀 크기 레벨 메시지
String getCellSizeLevelMessage(CellSizeLevel level) {
  switch (level) {
    case CellSizeLevel.explore:
      return '더 확대해주세요';
    case CellSizeLevel.guide:
      return '조금만 더 확대하면 선택할 수 있습니다';
    case CellSizeLevel.selectable:
      return '선택 가능';
  }
}
