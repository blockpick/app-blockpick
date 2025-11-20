import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../models/block_model.dart';
import '../providers/grid_state_provider.dart';

/// 미니맵 위젯
///
/// 우측 하단에 표시되는 전체 그리드 미니맵
class MinimapWidget extends ConsumerStatefulWidget {
  final GridConfig gridConfig;
  final double screenWidth;
  final double screenHeight;

  const MinimapWidget({
    super.key,
    required this.gridConfig,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  ConsumerState<MinimapWidget> createState() => _MinimapWidgetState();
}

class _MinimapWidgetState extends ConsumerState<MinimapWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final gridState = ref.watch(gridStateProvider(widget.gridConfig));
    final gridNotifier = ref.read(gridStateProvider(widget.gridConfig).notifier);

    final minimapSize = _isExpanded
        ? AppConstants.minimapSizeExpanded
        : AppConstants.minimapSize;

    return Positioned(
      bottom: AppConstants.minimapBottom,
      right: AppConstants.minimapRight,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        child: AnimatedContainer(
          duration: AppConstants.animationNormal,
          width: minimapSize,
          height: minimapSize,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.buleGray,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // 미니맵 캔버스
                CustomPaint(
                  painter: _MinimapPainter(
                    gridWidth: gridState.gridWidth,
                    gridHeight: gridState.gridHeight,
                    selectedBlocks: gridState.selectedBlocks,
                    currentZoom: gridState.zoom,
                    currentPanX: gridState.panX,
                    currentPanY: gridState.panY,
                    screenWidth: widget.screenWidth,
                    screenHeight: widget.screenHeight,
                  ),
                  size: Size(minimapSize, minimapSize),
                ),

                // 확대/축소 아이콘
                if (!_isExpanded)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      LucideIcons.maximize2,
                      size: 12,
                      color: AppColors.medium,
                    ),
                  ),

                // 탭 영역 (전체)
                Positioned.fill(
                  child: GestureDetector(
                    onTapDown: (details) {
                      _handleMinimapTap(
                        details.localPosition,
                        minimapSize,
                        gridState,
                        gridNotifier,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 미니맵 탭 처리
  void _handleMinimapTap(
    Offset localPosition,
    double minimapSize,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    // 미니맵 좌표를 그리드 좌표로 변환
    final gridPixelWidth = gridState.gridWidth * AppConstants.cellSize;
    final gridPixelHeight = gridState.gridHeight * AppConstants.cellSize;

    // 미니맵 내에서의 비율
    final ratioX = localPosition.dx / minimapSize;
    final ratioY = localPosition.dy / minimapSize;

    // 그리드 내 위치
    final gridX = ratioX * gridPixelWidth;
    final gridY = ratioY * gridPixelHeight;

    // 현재 줌에서 화면 중앙에 오도록 팬 계산
    final newPanX = widget.screenWidth / 2 - gridX * gridState.zoom;
    final newPanY = widget.screenHeight / 2 - gridY * gridState.zoom;

    gridNotifier.setPan(newPanX, newPanY);
  }
}

/// 미니맵 페인터
class _MinimapPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final List<BlockModel> selectedBlocks;
  final double currentZoom;
  final double currentPanX;
  final double currentPanY;
  final double screenWidth;
  final double screenHeight;

  _MinimapPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.selectedBlocks,
    required this.currentZoom,
    required this.currentPanX,
    required this.currentPanY,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경
    final bgPaint = Paint()..color = AppColors.deepWhite;
    canvas.drawRect(Offset.zero & size, bgPaint);

    // 그리드 전체 크기
    final gridPixelWidth = gridWidth * AppConstants.cellSize;
    final gridPixelHeight = gridHeight * AppConstants.cellSize;

    // 미니맵 스케일 계산
    final scaleX = size.width / gridPixelWidth;
    final scaleY = size.height / gridPixelHeight;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // 선택된 블록들을 폴리곤 영역으로 그리기
    _drawSelectedBlocksPolygon(canvas, scale);

    // 현재 보이는 영역 그리기
    _drawViewport(canvas, size, scale, gridPixelWidth, gridPixelHeight);
  }

  /// 선택된 블록들을 폴리곤 영역으로 그리기 (땅따먹기 스타일)
  void _drawSelectedBlocksPolygon(Canvas canvas, double scale) {
    if (selectedBlocks.isEmpty) return;

    // 선택된 블록들의 좌표를 Set으로 저장 (빠른 검색)
    final selectedCoords = <String>{};
    for (var block in selectedBlocks) {
      selectedCoords.add('${block.row},${block.col}');
    }

    // 미니맵에서의 셀 크기
    final minimapCellSize = AppConstants.cellSize * scale;

    // 채우기 페인트 (반투명 분홍색)
    final fillPaint = Paint()
      ..color = const Color(0xFFFF69B4).withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // 테두리 페인트 (진한 분홍색)
    final borderPaint = Paint()
      ..color = const Color(0xFFFF1493).withOpacity(0.8)
      ..strokeWidth = 1.5 // 미니맵에서는 얇은 선
      ..style = PaintingStyle.stroke;

    // 각 선택된 블록에 대해
    for (var block in selectedBlocks) {
      final x = (block.col - 1) * minimapCellSize;
      final y = (block.row - 1) * minimapCellSize;

      // 셀 영역 채우기
      canvas.drawRect(
        Rect.fromLTWH(x, y, minimapCellSize, minimapCellSize),
        fillPaint,
      );

      // 외곽선만 그리기 (인접하지 않은 변만)
      // 위쪽 변
      if (!selectedCoords.contains('${block.row - 1},${block.col}')) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x + minimapCellSize, y),
          borderPaint,
        );
      }
      // 아래쪽 변
      if (!selectedCoords.contains('${block.row + 1},${block.col}')) {
        canvas.drawLine(
          Offset(x, y + minimapCellSize),
          Offset(x + minimapCellSize, y + minimapCellSize),
          borderPaint,
        );
      }
      // 왼쪽 변
      if (!selectedCoords.contains('${block.row},${block.col - 1}')) {
        canvas.drawLine(
          Offset(x, y),
          Offset(x, y + minimapCellSize),
          borderPaint,
        );
      }
      // 오른쪽 변
      if (!selectedCoords.contains('${block.row},${block.col + 1}')) {
        canvas.drawLine(
          Offset(x + minimapCellSize, y),
          Offset(x + minimapCellSize, y + minimapCellSize),
          borderPaint,
        );
      }
    }
  }

  void _drawViewport(
    Canvas canvas,
    Size size,
    double scale,
    double gridPixelWidth,
    double gridPixelHeight,
  ) {
    // 현재 화면에 보이는 그리드 영역 계산
    final viewportGridLeft = -currentPanX / currentZoom;
    final viewportGridTop = -currentPanY / currentZoom;
    final viewportGridRight = viewportGridLeft + screenWidth / currentZoom;
    final viewportGridBottom = viewportGridTop + screenHeight / currentZoom;

    // 미니맵 좌표로 변환
    final minimapLeft = (viewportGridLeft * scale).clamp(0.0, size.width);
    final minimapTop = (viewportGridTop * scale).clamp(0.0, size.height);
    final minimapRight =
        (viewportGridRight * scale).clamp(0.0, size.width);
    final minimapBottom =
        (viewportGridBottom * scale).clamp(0.0, size.height);

    final viewportRect = Rect.fromLTRB(
      minimapLeft,
      minimapTop,
      minimapRight,
      minimapBottom,
    );

    // 반투명 박스
    final viewportFillPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.15)
      ..style = PaintingStyle.fill;
    canvas.drawRect(viewportRect, viewportFillPaint);

    // 테두리
    final viewportBorderPaint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(viewportRect, viewportBorderPaint);
  }

  @override
  bool shouldRepaint(_MinimapPainter oldDelegate) {
    return oldDelegate.selectedBlocks != selectedBlocks ||
        oldDelegate.currentZoom != currentZoom ||
        oldDelegate.currentPanX != currentPanX ||
        oldDelegate.currentPanY != currentPanY ||
        oldDelegate.gridWidth != gridWidth ||
        oldDelegate.gridHeight != gridHeight;
  }
}
