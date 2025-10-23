import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/block_model.dart';
import '../core/constants/app_constants.dart';

/// 그리드 상태
@immutable
class GridState {
  /// 줌 레벨
  final double zoom;

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

  const GridState({
    this.zoom = AppConstants.defaultZoom,
    this.panX = 0.0,
    this.panY = 0.0,
    this.isDragging = false,
    this.selectedBlocks = const [],
    this.wireframeMode = false,
    this.autoRotate = false,
    this.centerCell,
    this.showBottomSheet = true,
    this.focusedBlockId,
  });

  GridState copyWith({
    double? zoom,
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
  }) {
    return GridState(
      zoom: zoom ?? this.zoom,
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
      isDragging: isDragging ?? this.isDragging,
      selectedBlocks: selectedBlocks ?? this.selectedBlocks,
      wireframeMode: wireframeMode ?? this.wireframeMode,
      autoRotate: autoRotate ?? this.autoRotate,
      centerCell: clearCenterCell ? null : (centerCell ?? this.centerCell),
      showBottomSheet: showBottomSheet ?? this.showBottomSheet,
      focusedBlockId: clearFocusedBlock ? null : (focusedBlockId ?? this.focusedBlockId),
    );
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
  GridStateNotifier() : super(const GridState());

  /// 줌 설정
  void setZoom(double zoom) {
    final clampedZoom = zoom.clamp(AppConstants.minZoom, AppConstants.maxZoom);
    state = state.copyWith(zoom: clampedZoom);
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

    // 줌 변경
    final clampedZoom = newZoom.clamp(AppConstants.minZoom, AppConstants.maxZoom);

    // 같은 그리드 좌표가 화면 중앙에 오도록 pan 조정
    final newPanX = screenWidth / 2 - centerX * clampedZoom;
    final newPanY = screenHeight / 2 - centerY * clampedZoom;

    state = state.copyWith(
      zoom: clampedZoom,
      panX: newPanX,
      panY: newPanY,
    );
  }

  /// 팬 설정
  void setPan(double x, double y) {
    state = state.copyWith(panX: x, panY: y);
  }

  /// 팬 추가
  void addPan(double dx, double dy) {
    state = state.copyWith(
      panX: state.panX + dx,
      panY: state.panY + dy,
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
    state = state.copyWith(
      zoom: AppConstants.defaultZoom,
      panX: 0.0,
      panY: 0.0,
    );
  }

  /// 특정 블록으로 줌 및 이동
  void focusOnBlock(BlockModel block, {double targetZoom = 2.0}) {
    // 블록 중심으로 팬 이동
    final blockCenterX = (block.col - 1) * AppConstants.cellSize;
    final blockCenterY = (block.row - 1) * AppConstants.cellSize;

    state = state.copyWith(
      zoom: targetZoom,
      panX: -blockCenterX * targetZoom,
      panY: -blockCenterY * targetZoom,
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
    final newZoom = targetZoom ?? (state.zoom < 0.5 ? 0.8 : state.zoom);

    // 블록의 중심 좌표 계산 (그리드 좌표계)
    final blockCenterX = (block.col - 0.5) * AppConstants.cellSize;
    final blockCenterY = (block.row - 0.5) * AppConstants.cellSize;

    // 블록이 화면 중앙에 오도록 pan 계산
    // 화면 중앙 = screenWidth/2, screenHeight/2
    // pan + blockCenter * zoom = screenCenter
    // pan = screenCenter - blockCenter * zoom
    final newPanX = screenWidth / 2 - blockCenterX * newZoom;
    final newPanY = screenHeight / 2 - blockCenterY * newZoom;

    state = state.copyWith(
      zoom: newZoom.clamp(AppConstants.minZoom, AppConstants.maxZoom),
      panX: newPanX,
      panY: newPanY,
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
}

/// 그리드 상태 프로바이더 (라운드별 분리)
/// gameId를 받아서 각 게임별로 독립적인 상태를 관리
final gridStateProvider =
    StateNotifierProvider.family<GridStateNotifier, GridState, String>((ref, gameId) {
  return GridStateNotifier();
});

/// 선택된 블록 수 프로바이더 (라운드별)
final selectedBlockCountProvider = Provider.family<int, String>((ref, gameId) {
  final gridState = ref.watch(gridStateProvider(gameId));
  return gridState.selectedBlocks.length;
});

/// 특정 블록이 선택되었는지 확인하는 프로바이더 (라운드별)
final isBlockSelectedProvider =
    Provider.family<bool, (String gameId, String blockId)>((ref, params) {
  final gridState = ref.watch(gridStateProvider(params.$1));
  return gridState.isBlockSelected(params.$2);
});
