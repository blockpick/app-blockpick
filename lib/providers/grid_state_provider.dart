import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../models/block_model.dart';
import '../core/constants/app_constants.dart';

/// 그리드 상태
@immutable
class GridState {
  /// 줌 레벨
  final double zoom;

  /// 기준 줌 레벨 (그리드 크기에 따라 계산됨)
  final double baseZoom;

  /// 그리드 가로 크기
  final int gridWidth;

  /// 그리드 세로 크기
  final int gridHeight;

  /// 팬 오프셋 (X축)
  final double panX;

  /// 팬 오프셋 (Y축)
  final double panY;

  /// 드래깅 중인지 여부
  final bool isDragging;

  /// 선택된 블록 목록
  final List<BlockModel> selectedBlocks;

  /// 와이어프레임 모드
  final bool wireframeMode;

  /// 자동 회전
  final bool autoRotate;

  /// 중심 셀 (포커스)
  final BlockModel? centerCell;

  /// 바텀시트 표시 여부
  final bool showBottomSheet;

  /// 포커스된 블록 ID (바텀시트에서 클릭한 블록)
  final String? focusedBlockId;

  /// 튜토리얼 목표 블록 (튜토리얼에서 선택해야 할 블록)
  final BlockModel? tutorialTargetBlock;

  /// LOD (Level of Detail) 레벨 - 줌에 따라 자동 계산됨
  final int lodLevel;

  GridState({
    this.zoom = AppConstants.defaultZoom,
    this.baseZoom = AppConstants.defaultZoom,
    this.gridWidth = 100,
    this.gridHeight = 100,
    this.panX = 0.0,
    this.panY = 0.0,
    this.isDragging = false,
    this.selectedBlocks = const [],
    this.wireframeMode = false,
    this.autoRotate = false,
    this.centerCell,
    this.showBottomSheet = true,
    this.focusedBlockId,
    this.tutorialTargetBlock,
    int? lodLevel,
  }) : lodLevel = lodLevel ?? _calculateLODLevel(zoom);

  GridState copyWith({
    double? zoom,
    double? baseZoom,
    int? gridWidth,
    int? gridHeight,
    double? panX,
    double? panY,
    bool? isDragging,
    List<BlockModel>? selectedBlocks,
    bool? wireframeMode,
    bool? autoRotate,
    BlockModel? centerCell,
    bool clearCenterCell = false,
    bool? showBottomSheet,
    String? focusedBlockId,
    bool clearFocusedBlock = false,
    BlockModel? tutorialTargetBlock,
    bool clearTutorialTarget = false,
    int? lodLevel,
  }) {
    final newZoom = zoom ?? this.zoom;
    return GridState(
      zoom: newZoom,
      baseZoom: baseZoom ?? this.baseZoom,
      gridWidth: gridWidth ?? this.gridWidth,
      gridHeight: gridHeight ?? this.gridHeight,
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      isDragging: isDragging ?? this.isDragging,
      selectedBlocks: selectedBlocks ?? this.selectedBlocks,
      wireframeMode: wireframeMode ?? this.wireframeMode,
      autoRotate: autoRotate ?? this.autoRotate,
      centerCell: clearCenterCell ? null : (centerCell ?? this.centerCell),
      showBottomSheet: showBottomSheet ?? this.showBottomSheet,
      focusedBlockId: clearFocusedBlock ? null : (focusedBlockId ?? this.focusedBlockId),
      tutorialTargetBlock: clearTutorialTarget ? null : (tutorialTargetBlock ?? this.tutorialTargetBlock),
      lodLevel: lodLevel ?? _calculateLODLevel(newZoom),
    );
  }

  /// LOD 레벨 계산 (정적 메서드)
  static int _calculateLODLevel(double zoom) {
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

  /// 블록 추가
  GridState addBlock(BlockModel block) {
    if (selectedBlocks.any((b) => b.id == block.id)) {
      return this;
    }
    return copyWith(
      selectedBlocks: [...selectedBlocks, block],
    );
  }

  /// 블록 제거
  GridState removeBlock(String blockId) {
    return copyWith(
      selectedBlocks: selectedBlocks.where((b) => b.id != blockId).toList(),
    );
  }

  /// 모든 블록 제거
  GridState clearBlocks() {
    return copyWith(selectedBlocks: []);
  }

  /// 블록이 선택되어 있는지 확인
  bool isBlockSelected(String blockId) {
    return selectedBlocks.any((b) => b.id == blockId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GridState &&
        other.zoom == zoom &&
        other.panX == panX &&
        other.panY == panY &&
        other.isDragging == isDragging &&
        listEquals(other.selectedBlocks, selectedBlocks) &&
        other.wireframeMode == wireframeMode &&
        other.autoRotate == autoRotate &&
        other.centerCell == centerCell;
  }

  @override
  int get hashCode {
    return Object.hash(
      zoom,
      panX,
      panY,
      isDragging,
      Object.hashAll(selectedBlocks),
      wireframeMode,
      autoRotate,
      centerCell,
    );
  }
}

/// 그리드 상태 노티파이어
class GridStateNotifier extends StateNotifier<GridState> {
  /// 뷰포트 크기 (pan/zoom 클램핑에 사용)
  double _viewportWidth = 0;
  double _viewportHeight = 0;

  GridStateNotifier({
    required int gridWidth,
    required int gridHeight,
    required double baseZoom,
  }) : super(GridState(
          gridWidth: gridWidth,
          gridHeight: gridHeight,
          baseZoom: baseZoom,
          zoom: baseZoom, // 초기 줌을 baseZoom으로 설정
        ));

  /// 뷰포트 크기 설정 (GameGridWidget에서 호출)
  void setViewportSize(double width, double height) {
    _viewportWidth = width;
    _viewportHeight = height;
  }

  /// 뷰포트를 채우기 위한 최소 줌 계산
  double get _minZoomForViewport {
    if (_viewportWidth <= 0 || _viewportHeight <= 0) return AppConstants.minZoom;
    final gridTotalWidth = state.gridWidth * AppConstants.cellSize;
    final gridTotalHeight = state.gridHeight * AppConstants.cellSize;
    final minZoomW = _viewportWidth / gridTotalWidth;
    final minZoomH = _viewportHeight / gridTotalHeight;
    return math.max(minZoomW, minZoomH);
  }

  /// 줌 클램핑 (뷰포트 최소 줌 보장)
  double _clampZoom(double zoom) {
    return zoom.clamp(_minZoomForViewport, AppConstants.maxZoom);
  }

  /// pan 클램핑 (게임판이 항상 뷰포트를 채우도록)
  double _clampPanX(double panX, double zoom) {
    if (_viewportWidth <= 0) return panX;
    final gridRenderedWidth = state.gridWidth * AppConstants.cellSize * zoom;
    // panX <= 0 (왼쪽 가장자리), panX >= viewportWidth - gridRenderedWidth (오른쪽 가장자리)
    final minPanX = _viewportWidth - gridRenderedWidth;
    return panX.clamp(minPanX, 0.0);
  }

  double _clampPanY(double panY, double zoom) {
    if (_viewportHeight <= 0) return panY;
    final gridRenderedHeight = state.gridHeight * AppConstants.cellSize * zoom;
    final minPanY = _viewportHeight - gridRenderedHeight;
    return panY.clamp(minPanY, 0.0);
  }

  /// 줌 설정
  void setZoom(double zoom) {
    final clampedZoom = _clampZoom(zoom);
    // 줌 변경 후 pan도 재클램핑
    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(state.panX, clampedZoom),
      panY: _clampPanY(state.panY, clampedZoom),
    );
  }

  /// 줌 인 (스마트 단계별 줌 - 화면 중앙 기준)
  void zoomIn({double? screenWidth, double? screenHeight}) {
    final currentZoom = state.zoom;
    double zoomFactor;

    // 현재 줌 레벨에 따라 다른 증가율 적용
    if (currentZoom < 0.01) {
      zoomFactor = 5.0; // 극저 줌: 5배 증가
    } else if (currentZoom < 0.05) {
      zoomFactor = 3.0; // 매우 낮은 줌: 3배 증가
    } else if (currentZoom < 0.1) {
      zoomFactor = 2.0; // 낮은 줌: 2배 증가
    } else if (currentZoom < 0.5) {
      zoomFactor = 1.5; // 중간 줌: 1.5배 증가
    } else {
      zoomFactor = 1.2; // 높은 줌: 1.2배 증가
    }

    final newZoom = (currentZoom * zoomFactor).clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );

    // 화면 중앙 기준으로 줌
    if (screenWidth != null && screenHeight != null) {
      _zoomAtCenter(newZoom, screenWidth, screenHeight);
    } else {
      setZoom(newZoom);
    }
  }

  /// 줌 아웃 (스마트 단계별 줌 - 화면 중앙 기준)
  void zoomOut({double? screenWidth, double? screenHeight}) {
    final currentZoom = state.zoom;
    double zoomFactor;

    // 현재 줌 레벨에 따라 다른 감소율 적용
    if (currentZoom > 0.5) {
      zoomFactor = 1.2; // 높은 줌: 1/1.2배 감소
    } else if (currentZoom > 0.1) {
      zoomFactor = 1.5; // 중간 줌: 1/1.5배 감소
    } else if (currentZoom > 0.05) {
      zoomFactor = 2.0; // 낮은 줌: 1/2배 감소
    } else if (currentZoom > 0.01) {
      zoomFactor = 3.0; // 매우 낮은 줌: 1/3배 감소
    } else {
      zoomFactor = 5.0; // 극저 줌: 1/5배 감소
    }

    final newZoom = (currentZoom / zoomFactor).clamp(
      AppConstants.minZoom,
      AppConstants.maxZoom,
    );

    // 화면 중앙 기준으로 줌
    if (screenWidth != null && screenHeight != null) {
      _zoomAtCenter(newZoom, screenWidth, screenHeight);
    } else {
      setZoom(newZoom);
    }
  }

  /// 화면 중앙 기준으로 줌 적용
  void _zoomAtCenter(double newZoom, double screenWidth, double screenHeight) {
    final oldZoom = state.zoom;

    // 현재 화면 중앙의 그리드 좌표 계산
    final centerX = (screenWidth / 2 - state.panX) / oldZoom;
    final centerY = (screenHeight / 2 - state.panY) / oldZoom;

    // 줌 변경 (뷰포트 최소 줌 보장)
    final clampedZoom = _clampZoom(newZoom);

    // 같은 그리드 좌표가 화면 중앙에 오도록 pan 조정
    final newPanX = screenWidth / 2 - centerX * clampedZoom;
    final newPanY = screenHeight / 2 - centerY * clampedZoom;

    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(newPanX, clampedZoom),
      panY: _clampPanY(newPanY, clampedZoom),
    );
  }

  /// 특정 포인트(focal point) 기준으로 줌 적용
  /// 주로 핀치 제스처에서 사용됨
  void zoomAtPoint({
    required double newZoom,
    required double focalPointX,
    required double focalPointY,
  }) {
    final oldZoom = state.zoom;

    // focal point의 그리드 좌표 계산 (줌 전)
    final gridX = (focalPointX - state.panX) / oldZoom;
    final gridY = (focalPointY - state.panY) / oldZoom;

    // 줌 변경 (뷰포트 최소 줌 보장)
    final clampedZoom = _clampZoom(newZoom);

    // focal point가 같은 그리드 좌표를 가리키도록 pan 조정
    final newPanX = focalPointX - gridX * clampedZoom;
    final newPanY = focalPointY - gridY * clampedZoom;

    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(newPanX, clampedZoom),
      panY: _clampPanY(newPanY, clampedZoom),
    );
  }

  /// 팬 설정
  void setPan(double x, double y) {
    state = state.copyWith(
      panX: _clampPanX(x, state.zoom),
      panY: _clampPanY(y, state.zoom),
    );
  }

  /// 팬 추가
  void addPan(double dx, double dy) {
    final newPanX = state.panX + dx;
    final newPanY = state.panY + dy;
    state = state.copyWith(
      panX: _clampPanX(newPanX, state.zoom),
      panY: _clampPanY(newPanY, state.zoom),
    );
  }

  /// 드래깅 상태 설정
  void setDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
  }

  /// 블록 토글 (선택/해제)
  void toggleBlock(BlockModel block) {
    if (state.isBlockSelected(block.id)) {
      state = state.removeBlock(block.id);
    } else {
      state = state.addBlock(block);
    }
  }

  /// 블록 추가
  void addBlock(BlockModel block) {
    state = state.addBlock(block);
  }

  /// 블록 제거
  void removeBlock(String blockId) {
    state = state.removeBlock(blockId);
  }

  /// 모든 블록 제거
  void clearBlocks() {
    state = state.clearBlocks();
  }

  /// 와이어프레임 토글
  void toggleWireframe() {
    state = state.copyWith(wireframeMode: !state.wireframeMode);
  }

  /// 자동 회전 토글
  void toggleAutoRotate() {
    state = state.copyWith(autoRotate: !state.autoRotate);
  }

  /// 셀 중심으로 이동
  void setCenterCell(BlockModel? cell) {
    state = state.copyWith(
      centerCell: cell,
      clearCenterCell: cell == null,
    );
  }

  /// 뷰 리셋
  void resetView() {
    final clampedZoom = _clampZoom(AppConstants.defaultZoom);
    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(0.0, clampedZoom),
      panY: _clampPanY(0.0, clampedZoom),
    );
  }

  /// 특정 블록으로 줌 및 이동
  void focusOnBlock(BlockModel block, {double targetZoom = 2.0}) {
    final clampedZoom = _clampZoom(targetZoom);
    // 블록 중심으로 팬 이동
    final blockCenterX = (block.col - 1) * AppConstants.cellSize;
    final blockCenterY = (block.row - 1) * AppConstants.cellSize;

    final panX = -blockCenterX * clampedZoom;
    final panY = -blockCenterY * clampedZoom;

    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(panX, clampedZoom),
      panY: _clampPanY(panY, clampedZoom),
      centerCell: block,
    );
  }

  /// 특정 블록 위치로 이동 (화면 중앙에 블록 배치)
  void navigateToBlock(
    BlockModel block, {
    required double screenWidth,
    required double screenHeight,
    double? targetZoom,
  }) {
    // 현재 포커스된 블록과 같으면 토글 (포커스 해제)
    if (state.focusedBlockId == block.id) {
      state = state.copyWith(clearFocusedBlock: true);
      return;
    }

    // 목표 줌 레벨 설정 (지정되지 않으면 현재 줌 유지하되, 너무 작으면 적당히 확대)
    final rawZoom = targetZoom ?? (state.zoom < 0.5 ? 0.8 : state.zoom);
    final clampedZoom = _clampZoom(rawZoom);

    // 블록의 중심 좌표 계산 (그리드 좌표계)
    final blockCenterX = (block.col - 0.5) * AppConstants.cellSize;
    final blockCenterY = (block.row - 0.5) * AppConstants.cellSize;

    // 블록이 화면 중앙에 오도록 pan 계산
    final newPanX = screenWidth / 2 - blockCenterX * clampedZoom;
    final newPanY = screenHeight / 2 - blockCenterY * clampedZoom;

    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(newPanX, clampedZoom),
      panY: _clampPanY(newPanY, clampedZoom),
      centerCell: block,
      focusedBlockId: block.id, // 포커스 설정
    );
  }

  /// 바텀시트 표시 설정
  void setShowBottomSheet(bool show) {
    state = state.copyWith(showBottomSheet: show);
  }

  /// 바텀시트 숨기기 (블록은 유지)
  void hideBottomSheet() {
    state = state.copyWith(showBottomSheet: false);
  }

  /// 바텀시트 보이기
  void showBottomSheet() {
    state = state.copyWith(showBottomSheet: true);
  }

  /// 튜토리얼 목표 블록 설정
  void setTutorialTargetBlock(BlockModel? block) {
    state = state.copyWith(
      tutorialTargetBlock: block,
      clearTutorialTarget: block == null,
    );
  }

  /// 특정 섹션으로 이동 (화면 중앙에 섹션 배치)
  void navigateToSection(
    dynamic section, {
    required double screenWidth,
    required double screenHeight,
    double? targetZoom,
  }) {
    // section의 중심 좌표 계산 (그리드 좌표계)
    final centerRow = (section.startRow + section.endRow) / 2;
    final centerCol = (section.startCol + section.endCol) / 2;

    final sectionCenterX = (centerCol - 0.5) * AppConstants.cellSize;
    final sectionCenterY = (centerRow - 0.5) * AppConstants.cellSize;

    // 섹션이 화면에 잘 보이도록 적절한 줌 레벨 계산
    final sectionWidth = (section.endCol - section.startCol + 1) * AppConstants.cellSize;
    final sectionHeight = (section.endRow - section.startRow + 1) * AppConstants.cellSize;

    final zoomToFitWidth = screenWidth / sectionWidth * 0.8; // 80% 여유
    final zoomToFitHeight = screenHeight / sectionHeight * 0.8;

    final rawZoom = targetZoom ??
        (zoomToFitWidth < zoomToFitHeight ? zoomToFitWidth : zoomToFitHeight);
    final clampedZoom = _clampZoom(rawZoom);

    // 섹션이 화면 중앙에 오도록 pan 계산
    final newPanX = screenWidth / 2 - sectionCenterX * clampedZoom;
    final newPanY = screenHeight / 2 - sectionCenterY * clampedZoom;

    state = state.copyWith(
      zoom: clampedZoom,
      panX: _clampPanX(newPanX, clampedZoom),
      panY: _clampPanY(newPanY, clampedZoom),
      clearFocusedBlock: true, // 섹션 이동 시 블록 포커스 해제
    );
  }
}

/// 그리드 설정 매개변수
class GridConfig {
  final String gameId;
  final int gridWidth;
  final int gridHeight;
  final double baseZoom;

  const GridConfig({
    required this.gameId,
    required this.gridWidth,
    required this.gridHeight,
    required this.baseZoom,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GridConfig &&
          runtimeType == other.runtimeType &&
          gameId == other.gameId &&
          gridWidth == other.gridWidth &&
          gridHeight == other.gridHeight &&
          baseZoom == other.baseZoom;

  @override
  int get hashCode =>
      gameId.hashCode ^ gridWidth.hashCode ^ gridHeight.hashCode ^ baseZoom.hashCode;
}

/// 그리드 상태 프로바이더 (라운드별 분리)
/// GridConfig를 받아서 각 게임별로 독립적인 상태를 관리
final gridStateProvider =
    StateNotifierProvider.family<GridStateNotifier, GridState, GridConfig>((ref, config) {
  return GridStateNotifier(
    gridWidth: config.gridWidth,
    gridHeight: config.gridHeight,
    baseZoom: config.baseZoom,
  );
});

/// 선택된 블록 수 프로바이더 (라운드별)
final selectedBlockCountProvider = Provider.family<int, GridConfig>((ref, config) {
  final gridState = ref.watch(gridStateProvider(config));
  return gridState.selectedBlocks.length;
});

/// 특정 블록이 선택되었는지 확인하는 프로바이더 (라운드별)
final isBlockSelectedProvider =
    Provider.family<bool, (GridConfig config, String blockId)>((ref, params) {
  final gridState = ref.watch(gridStateProvider(params.$1));
  return gridState.isBlockSelected(params.$2);
});
