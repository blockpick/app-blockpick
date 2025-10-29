import 'dart:math' as math;
import '../core/constants/app_constants.dart';

/// 줌 레벨 타입
enum ZoomLevel {
  /// 매우 축소 (클러스터 마커 표시)
  ultraZoomedOut,

  /// 축소 (고정 크기 마커 표시)
  zoomedOut,

  /// 중간 (적응형 마커)
  medium,

  /// 확대 (전체 셀 마커)
  zoomedIn,

  /// 매우 확대 (상세 정보)
  ultraZoomedIn,
}

/// 그리드 크기별 줌 레벨 계산
class ZoomCalculator {
  /// 그리드 크기에 따른 기준 줌 레벨 계산
  ///
  /// 기준 줌은 화면에 그리드 전체가 보이는 정도의 줌 레벨
  ///
  /// [gridWidth] 그리드 가로 크기
  /// [gridHeight] 그리드 세로 크기
  /// [screenWidth] 화면 가로 크기
  /// [screenHeight] 화면 세로 크기
  static double calculateBaseZoom({
    required int gridWidth,
    required int gridHeight,
    required double screenWidth,
    required double screenHeight,
  }) {
    // 그리드 전체 크기 (픽셀)
    final gridPixelWidth = gridWidth * AppConstants.cellSize;
    final gridPixelHeight = gridHeight * AppConstants.cellSize;

    // 화면에 맞추기 위한 줌 비율 계산
    final zoomX = screenWidth / gridPixelWidth;
    final zoomY = screenHeight / gridPixelHeight;

    // 둘 중 작은 값을 사용 (전체가 보이도록)
    // 약간의 패딩을 위해 0.9 곱하기
    final baseZoom = math.min(zoomX, zoomY) * 0.9;

    // 최소/최대 줌 제한
    return baseZoom.clamp(AppConstants.minZoom, AppConstants.maxZoom);
  }

  /// 현재 줌이 어느 레벨인지 판단
  ///
  /// [currentZoom] 현재 줌 값
  /// [baseZoom] 기준 줌 값
  static ZoomLevel getZoomLevel(double currentZoom, double baseZoom) {
    final ratio = currentZoom / baseZoom;

    if (ratio < 0.3) {
      return ZoomLevel.ultraZoomedOut;
    } else if (ratio < 0.7) {
      return ZoomLevel.zoomedOut;
    } else if (ratio < 2.0) {
      return ZoomLevel.medium;
    } else if (ratio < 5.0) {
      return ZoomLevel.zoomedIn;
    } else {
      return ZoomLevel.ultraZoomedIn;
    }
  }

  /// 마커 크기 계산 (적응형)
  ///
  /// [cellSize] 현재 셀 크기 (zoom 적용된 크기)
  /// [zoomLevel] 현재 줌 레벨
  static double calculateMarkerSize(double cellSize, ZoomLevel zoomLevel) {
    switch (zoomLevel) {
      case ZoomLevel.ultraZoomedOut:
        // 매우 축소: 고정 크기 (28px) - 클러스터링
        return 28.0;

      case ZoomLevel.zoomedOut:
        // 축소: 고정 크기 (24px)
        return 24.0;

      case ZoomLevel.medium:
        // 중간: 셀 크기에 맞추되 최소 크기 보장
        return math.max(cellSize * 0.8, 16.0);

      case ZoomLevel.zoomedIn:
        // 확대: 셀에 꽉 차는 크기
        return cellSize * 0.95;

      case ZoomLevel.ultraZoomedIn:
        // 매우 확대: 셀에 꽉 차는 크기
        return cellSize * 0.95;
    }
  }

  /// 클러스터링 임계값 계산 (픽셀 단위)
  ///
  /// 이 거리 이내의 픽들은 하나의 클러스터로 묶임
  ///
  /// [zoomLevel] 현재 줌 레벨
  static double getClusterThreshold(ZoomLevel zoomLevel) {
    switch (zoomLevel) {
      case ZoomLevel.ultraZoomedOut:
        return 40.0; // 40px 이내면 클러스터링

      case ZoomLevel.zoomedOut:
        return 30.0; // 30px 이내면 클러스터링

      default:
        return 0.0; // 클러스터링 안 함
    }
  }

  /// 마커가 렌더링되어야 하는지 확인
  ///
  /// 너무 작은 경우 렌더링 생략하여 성능 향상
  ///
  /// [cellSize] 현재 셀 크기
  static bool shouldRenderMarker(double cellSize) {
    return cellSize >= 2.0; // 2px 이상일 때만 렌더링
  }

  /// 적정 줌 레벨 추천
  ///
  /// [gridWidth] 그리드 가로 크기
  /// [gridHeight] 그리드 세로 크기
  static Map<String, double> getRecommendedZoomLevels({
    required int gridWidth,
    required int gridHeight,
    required double screenWidth,
    required double screenHeight,
  }) {
    final baseZoom = calculateBaseZoom(
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
    );

    return {
      'overview': baseZoom * 0.8, // 전체 보기
      'default': baseZoom, // 기본 뷰
      'comfortable': baseZoom * 1.5, // 편안한 뷰
      'detail': baseZoom * 3.0, // 상세 뷰
      'extreme': baseZoom * 6.0, // 극대 확대
    };
  }
}
