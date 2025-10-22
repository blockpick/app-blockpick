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

  /// 줌 인
  void zoomIn() {
    setZoom(state.zoom * 1.1);
  }

  /// 줌 아웃
  void zoomOut() {
    setZoom(state.zoom * 0.9);
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

/// 그리드 상태 프로바이더
final gridStateProvider =
    StateNotifierProvider<GridStateNotifier, GridState>((ref) {
  return GridStateNotifier();
});

/// 선택된 블록 수 프로바이더
final selectedBlockCountProvider = Provider<int>((ref) {
  final gridState = ref.watch(gridStateProvider);
  return gridState.selectedBlocks.length;
});

/// 특정 블록이 선택되었는지 확인하는 프로바이더
final isBlockSelectedProvider =
    Provider.family<bool, String>((ref, blockId) {
  final gridState = ref.watch(gridStateProvider);
  return gridState.isBlockSelected(blockId);
});
