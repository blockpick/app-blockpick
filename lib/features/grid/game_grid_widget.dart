import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'dart:io' show Platform;
import 'dart:ui' as ui;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'grid_painter.dart';
import '../../providers/grid_state_provider.dart';
import '../../models/block_model.dart';
import '../../core/constants/app_constants.dart';

/// 게임 그리드 위젯
///
/// CustomPaint를 사용하여 대형 그리드를 렌더링하고
/// 제스처를 처리합니다.
class GameGridWidget extends ConsumerStatefulWidget {
  /// 그리드 크기 (N x N)
  final int gridSize;

  /// 블록 클릭 콜백
  final Function(BlockModel)? onBlockTap;

  /// 배경 이미지 경로 (제품 이미지)
  final String? backgroundImagePath;

  const GameGridWidget({
    super.key,
    required this.gridSize,
    this.onBlockTap,
    this.backgroundImagePath,
  });

  @override
  ConsumerState<GameGridWidget> createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends ConsumerState<GameGridWidget>
    with SingleTickerProviderStateMixin {
  // 제스처 처리
  Offset? _lastTouchPosition;
  Offset? _initialFocalPoint;
  double? _initialZoom;
  bool _isDragging = false;

  // 애니메이션
  late AnimationController _animationController;
  Animation<double>? _zoomAnimation;

  // 배경 이미지
  ui.Image? _backgroundImage;
  bool _imageLoading = false;

  /// 현재 플랫폼이 모바일인지 확인
  bool get _isMobile {
    if (kIsWeb) return false;
    try {
      return Platform.isAndroid || Platform.isIOS;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationZoom,
    );

    // 배경 이미지 로드
    if (widget.backgroundImagePath != null) {
      _loadBackgroundImage();
    }
  }

  @override
  void didUpdateWidget(GameGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 배경 이미지가 변경되면 다시 로드
    if (widget.backgroundImagePath != oldWidget.backgroundImagePath) {
      if (widget.backgroundImagePath != null) {
        _loadBackgroundImage();
      } else {
        setState(() {
          _backgroundImage = null;
        });
      }
    }
  }

  /// 배경 이미지 로드
  Future<void> _loadBackgroundImage() async {
    if (_imageLoading) return;

    debugPrint('🖼️ Starting to load background image: ${widget.backgroundImagePath}');

    setState(() {
      _imageLoading = true;
    });

    try {
      debugPrint('🖼️ Loading asset from rootBundle: ${widget.backgroundImagePath}');
      final ByteData data = await rootBundle.load(widget.backgroundImagePath!);
      debugPrint('🖼️ Asset loaded, size: ${data.lengthInBytes} bytes');

      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      debugPrint('🖼️ Image decoded: ${frame.image.width}x${frame.image.height}');

      if (mounted) {
        setState(() {
          _backgroundImage = frame.image;
          _imageLoading = false;
        });
        debugPrint('✅ Background image loaded successfully');
      }
    } catch (e) {
      debugPrint('❌ Failed to load background image: $e');
      if (mounted) {
        setState(() {
          _imageLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gridState = ref.watch(gridStateProvider);
    final gridNotifier = ref.read(gridStateProvider.notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          // 탭 처리 (블록 선택)
          onTapUp: (details) => _handleTap(
            details.localPosition,
            constraints.biggest,
            gridState,
            gridNotifier,
          ),

          // 스케일 제스처 (핀치 투 줌 + 팬)
          onScaleStart: (details) => _handleScaleStart(details, gridState),
          onScaleUpdate: (details) =>
              _handleScaleUpdate(details, gridState, gridNotifier),
          onScaleEnd: (details) => _handleScaleEnd(gridNotifier),

          child: Stack(
            children: [
              // 그리드 렌더링
              CustomPaint(
                painter: GridPainter(
                  gridSize: widget.gridSize,
                  zoom: gridState.zoom,
                  pan: Offset(gridState.panX, gridState.panY),
                  selectedBlocks: gridState.selectedBlocks,
                  wireframeMode: gridState.wireframeMode,
                  backgroundImage: _backgroundImage,
                ),
                size: constraints.biggest,
              ),

              // 선택된 블록 위에 SVG 아이콘 오버레이
              ..._buildBlockIcons(gridState, constraints.biggest),
            ],
          ),
        );
      },
    );
  }

  /// 선택된 블록 위에 SVG 아이콘 렌더링
  List<Widget> _buildBlockIcons(GridState gridState, Size size) {
    final icons = <Widget>[];
    final cellSize = AppConstants.cellSize * gridState.zoom;

    for (final block in gridState.selectedBlocks) {
      final x = (block.col - 1) * cellSize + gridState.panX;
      final y = (block.row - 1) * cellSize + gridState.panY;

      // 화면 밖 블록은 렌더링하지 않음
      if (x + cellSize < 0 || x > size.width || y + cellSize < 0 || y > size.height) {
        continue;
      }

      // 블록 상태에 따른 SVG 경로 결정
      String iconPath;
      switch (block.state) {
        case BlockState.selected:
          iconPath = 'assets/icons/pick/selected.svg';
          break;
        case BlockState.past:
          iconPath = 'assets/icons/pick/past.svg';
          break;
        case BlockState.winner:
        case BlockState.unique:
        case BlockState.duplicate:
          iconPath = 'assets/icons/pick/selected.svg'; // 기본값
          break;
        default:
          iconPath = 'assets/icons/pick/selected.svg';
      }

      icons.add(
        Positioned(
          left: x,
          top: y,
          width: cellSize * 0.95,
          height: cellSize * 0.95,
          child: SvgPicture.asset(
            iconPath,
            fit: BoxFit.contain,
          ),
        ),
      );
    }

    return icons;
  }

  /// 탭 처리 (블록 선택)
  void _handleTap(
    Offset position,
    Size size,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    // 드래그 중이었으면 탭 무시
    if (_isDragging) return;

    // 탭 위치를 그리드 좌표로 변환
    final cellSize = AppConstants.cellSize * gridState.zoom;
    final gridX = (position.dx - gridState.panX) / cellSize;
    final gridY = (position.dy - gridState.panY) / cellSize;

    final col = (gridX + 1).floor();
    final row = (gridY + 1).floor();

    // 그리드 범위 확인
    if (row >= 1 && row <= widget.gridSize && col >= 1 && col <= widget.gridSize) {
      // 줌 레벨이 충분한지 확인 (셀 선택 임계값)
      final threshold = _getCellSelectionThreshold(widget.gridSize);
      if (gridState.zoom >= threshold) {
        final block = BlockModel.fromPosition(row, col, state: BlockState.selected);

        // 블록 토글
        gridNotifier.toggleBlock(block);

        // 콜백 호출
        widget.onBlockTap?.call(block);
      } else {
        // 줌이 충분하지 않으면 해당 영역으로 줌 인
        _zoomToCell(row, col, gridState, gridNotifier);
      }
    }
  }

  /// 셀 선택 임계값 계산
  double _getCellSelectionThreshold(int gridSize) {
    if (gridSize <= 100) return 0.3;
    if (gridSize <= 500) return 0.6;
    if (gridSize <= 2000) return 1.0;
    return 1.4;
  }

  /// 특정 셀로 줌 인
  void _zoomToCell(
    int row,
    int col,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    final targetZoom = gridState.zoom * 2.0;
    final block = BlockModel.fromPosition(row, col);

    _zoomAnimation = Tween<double>(
      begin: gridState.zoom,
      end: targetZoom,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _animationController.forward(from: 0).then((_) {
      gridNotifier.focusOnBlock(block, targetZoom: targetZoom);
    });
  }

  /// 스케일 시작 (핀치 투 줌 + 팬)
  void _handleScaleStart(
    ScaleStartDetails details,
    GridState gridState,
  ) {
    _initialFocalPoint = details.focalPoint;
    _initialZoom = gridState.zoom;
    _isDragging = false;
    ref.read(gridStateProvider.notifier).setDragging(false);
  }

  /// 스케일 업데이트
  void _handleScaleUpdate(
    ScaleUpdateDetails details,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    if (_initialZoom != null && _initialFocalPoint != null) {
      // 스케일이 1이 아니면 핀치 줌
      if (details.scale != 1.0) {
        final newZoom = (_initialZoom! * details.scale).clamp(
          AppConstants.minZoom,
          AppConstants.maxZoom,
        );

        gridNotifier.setZoom(newZoom);
      }

      // 팬 처리 (그리드 + 배경 이미지 함께 이동)
      final delta = details.focalPoint - _initialFocalPoint!;

      // 드래그 임계값 확인
      if (delta.distance > AppConstants.dragThreshold) {
        _isDragging = true;
        gridNotifier.setDragging(true);
      }

      gridNotifier.addPan(delta.dx, delta.dy);
      _initialFocalPoint = details.focalPoint;
    }
  }

  /// 스케일 종료
  void _handleScaleEnd(GridStateNotifier gridNotifier) {
    _initialFocalPoint = null;
    _initialZoom = null;
    gridNotifier.setDragging(false);

    // 약간의 지연 후 드래깅 상태 초기화 (탭 무시를 위해)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }
}
