/// BlockPick 앱의 전역 상수
class AppConstants {
  // ========== Spacing ==========

  /// 최소 간격 (4px)
  static const double spacingXs = 4.0;

  /// 작은 간격 (8px)
  static const double spacingSm = 8.0;

  /// 기본 간격 (12px)
  static const double spacingMd = 12.0;

  /// 큰 간격 (16px)
  static const double spacingLg = 16.0;

  /// 매우 큰 간격 (24px)
  static const double spacingXl = 24.0;

  /// 섹션 간격 (32px)
  static const double spacing2Xl = 32.0;

  /// 큰 섹션 간격 (48px)
  static const double spacing3Xl = 48.0;

  // ========== Border Radius ==========

  /// 작은 radius (4px)
  static const double radiusSm = 4.0;

  /// 기본 radius (8px)
  static const double radiusMd = 8.0;

  /// 큰 radius (12px)
  static const double radiusLg = 12.0;

  /// 매우 큰 radius (16px)
  static const double radiusXl = 16.0;

  /// 초대형 radius (24px)
  static const double radius2Xl = 24.0;

  /// 원형 radius
  static const double radiusFull = 9999.0;

  // ========== Breakpoints ==========

  /// 모바일 breakpoint (< 768px)
  static const double breakpointMobile = 768.0;

  /// 태블릿 breakpoint (>= 768px)
  static const double breakpointTablet = 768.0;

  /// 데스크톱 breakpoint (>= 1024px)
  static const double breakpointDesktop = 1024.0;

  /// 대형 데스크톱 breakpoint (>= 1440px)
  static const double breakpointLargeDesktop = 1440.0;

  // ========== Grid Constants ==========

  /// 셀 크기 (픽셀)
  static const double cellSize = 30.0;

  /// 최소 줌 레벨
  static const double minZoom = 0.1;

  /// 최대 줌 레벨
  static const double maxZoom = 10.0;

  /// 기본 줌 레벨
  static const double defaultZoom = 1.0;

  /// 드래그 임계값 (픽셀)
  static const double dragThreshold = 5.0;

  /// 터치 타겟 최소 크기 (모바일)
  static const double minTouchTarget = 44.0;

  /// 터치 타겟 권장 크기
  static const double recommendedTouchTarget = 48.0;

  // ========== Grid Sizes ==========

  /// 지원되는 그리드 크기
  static const List<int> supportedGridSizes = [
    10,
    20,
    50,
    100,
    500,
    1000,
  ];

  // ========== LOD Thresholds ==========

  /// LOD (Level of Detail) 임계값
  static const Map<String, double> lodThresholds = {
    'ultraLow': 0.05,
    'veryLow': 0.1,
    'low': 0.3,
    'medium': 0.6,
    'high': 1.0,
    'ultraHigh': 2.0,
  };

  // ========== Animation Durations ==========

  /// 빠른 애니메이션 (150ms)
  static const Duration animationFast = Duration(milliseconds: 150);

  /// 기본 애니메이션 (200ms)
  static const Duration animationNormal = Duration(milliseconds: 200);

  /// 줌 애니메이션 (300ms)
  static const Duration animationZoom = Duration(milliseconds: 300);

  /// 느린 애니메이션 (500ms)
  static const Duration animationSlow = Duration(milliseconds: 500);

  /// 진행률 애니메이션 (1000ms)
  static const Duration animationProgress = Duration(milliseconds: 1000);

  /// 스태거 딜레이 (50ms)
  static const Duration animationStagger = Duration(milliseconds: 50);

  // ========== Spring Physics ==========

  /// Spring damping (기본)
  static const double springDamping = 25.0;

  /// Spring stiffness (기본)
  static const double springStiffness = 200.0;

  /// Spring damping (버튼)
  static const double springDampingButton = 17.0;

  /// Spring stiffness (버튼)
  static const double springStiffnessButton = 400.0;

  // ========== Performance ==========

  /// 타일 풀 크기 (최소)
  static const int tilePoolMinSize = 500;

  /// 타일 풀 크기 (최대)
  static const int tilePoolMaxSize = 1000;

  /// 최대 가시 셀 수
  static const int maxVisibleCells = 25000;

  /// 목표 FPS
  static const int targetFps = 60;

  /// 프레임 시간 (ms)
  static const double frameTime = 16.67; // 1000 / 60

  // ========== Bottom Sheet ==========

  /// 바텀시트 높이 (peek 상태)
  static const double bottomSheetPeekHeight = 350.0;

  /// 바텀시트 높이 (expanded 상태, 뷰포트의 %)
  static const double bottomSheetExpandedHeightRatio = 0.4;

  /// 바텀시트 드래그 핸들 너비
  static const double bottomSheetHandleWidth = 48.0;

  /// 바텀시트 드래그 핸들 높이
  static const double bottomSheetHandleHeight = 4.0;

  /// 바텀시트 드래그 임계값
  static const Map<String, double> bottomSheetDragThresholds = {
    'close': 100.0,
    'peek': 50.0,
    'open': -50.0,
  };

  // ========== Sidebar ==========

  /// 왼쪽 사이드바 너비 (Product Panel)
  static const double leftSidebarWidth = 320.0;

  /// 오른쪽 사이드바 너비 (Game Info Panel)
  static const double rightSidebarWidth = 384.0;

  // ========== Header ==========

  /// 헤더 높이
  static const double headerHeight = 64.0;

  // ========== Minimap ==========

  /// 미니맵 크기 (기본)
  static const double minimapSize = 100.0;

  /// 미니맵 크기 (확장)
  static const double minimapSizeExpanded = 160.0;

  /// 미니맵 위치 (bottom)
  static const double minimapBottom = 192.0;

  /// 미니맵 위치 (right)
  static const double minimapRight = 16.0;

  // ========== Floating Controls ==========

  /// 플로팅 컨트롤 버튼 크기 (데스크톱)
  static const double floatingControlSizeDesktop = 48.0;

  /// 플로팅 컨트롤 버튼 크기 (모바일)
  static const double floatingControlSizeMobile = 44.0;

  /// 플로팅 컨트롤 간격
  static const double floatingControlSpacing = 12.0;

  /// 플로팅 컨트롤 하단 여백
  static const double floatingControlBottom = 24.0;
}
