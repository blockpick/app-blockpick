import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../models/block_model.dart';
import '../../providers/grid_state_provider.dart';
import '../../utils/zoom_calculator.dart';
import 'block_pick_painter.dart';

/// BlockPick 공통 캔버스 위젯
///
/// BuzzCanvas의 렌더링 파이프라인(CustomPaint + RepaintBoundary + 수동 좌표 계산)을
/// 기반으로 하되, Riverpod Provider 연동과 BlockModel 기반 블록 렌더링을 지원합니다.
///
/// [useProvider]가 true이면 gridStateProvider와 동기화하고,
/// false이면 자체 State로 동작합니다 (BuzzCanvas 호환 모드).
class BlockPickCanvas extends ConsumerStatefulWidget {
  /// 게임 ID (라운드별 상태 분리, Provider 모드에서 사용)
  final String gameId;

  /// 그리드 가로 크기
  final int gridWidth;

  /// 그리드 세로 크기
  final int gridHeight;

  /// 블록 탭 콜백 (false 반환 시 블록 선택 취소)
  final bool Function(BlockModel)? onBlockTap;

  /// 배경 이미지 경로 (네트워크 URL 또는 로컬 asset)
  final String? backgroundImagePath;

  /// 튜토리얼 목표 블록에 할당할 GlobalKey
  final GlobalKey? tutorialBlockKey;

  /// 무한 점 패턴 표시 여부
  final bool showDotPattern;

  /// 다크 모드 여부
  final bool darkMode;

  /// Riverpod Provider 연동 여부 (false이면 자체 State)
  final bool useProvider;

  const BlockPickCanvas({
    super.key,
    required this.gameId,
    required this.gridWidth,
    required this.gridHeight,
    this.onBlockTap,
    this.backgroundImagePath,
    this.tutorialBlockKey,
    this.showDotPattern = true,
    this.darkMode = true,
    this.useProvider = true,
  });

  @override
  ConsumerState<BlockPickCanvas> createState() => BlockPickCanvasState();
}

class BlockPickCanvasState extends ConsumerState<BlockPickCanvas>
    with SingleTickerProviderStateMixin {
  // === 자체 State (useProvider=false 모드) ===
  double _localZoom = 1.0;
  Offset _localPan = Offset.zero;
  final List<BlockModel> _localSelectedBlocks = [];

  // === 공통 ===
  bool _initialized = false;
  ui.Image? _bgImage;
  bool _imageLoading = false;

  // 제스처
  double? _gestureStartZoom;
  Offset? _gestureFocalPoint;
  Offset? _gestureStartPan;
  Offset? _lastFocalPoint;
  bool _isDragging = false;

  // 줌 애니메이션
  late AnimationController _animController;
  Animation<double>? _zoomAnim;
  Animation<Offset>? _panAnim;

  // 셀 상수
  static const double _gridStep = BlockPickPainter.gridStep;
  static const double _minZoom = 0.015;
  static const double _maxZoom = 6.0;

  // GridConfig (Provider 모드)
  GridConfig? _gridConfig;

  // 미니맵용 상태 노출
  double get currentZoom {
    if (widget.useProvider && _gridConfig != null) {
      return ref.read(gridStateProvider(_gridConfig!)).zoom;
    }
    return _localZoom;
  }

  Offset get currentPan {
    if (widget.useProvider && _gridConfig != null) {
      final s = ref.read(gridStateProvider(_gridConfig!));
      return Offset(s.panX, s.panY);
    }
    return _localPan;
  }

  ui.Image? get bgImage => _bgImage;

  /// 외부에서 줌 인
  void zoomIn() {
    if (widget.useProvider && _gridConfig != null) {
      final size = context.size;
      ref.read(gridStateProvider(_gridConfig!).notifier).zoomIn(
            screenWidth: size?.width,
            screenHeight: size?.height,
          );
      return;
    }
    final size = context.size;
    if (size == null) return;
    final focal = Offset(size.width / 2, size.height / 2);
    final targetZoom = (_localZoom * 1.8).clamp(_minZoom, _maxZoom);
    final zoomDelta = targetZoom / _localZoom;
    final targetPan = Offset(
      focal.dx - (focal.dx - _localPan.dx) * zoomDelta,
      focal.dy - (focal.dy - _localPan.dy) * zoomDelta,
    );
    _animateTo(targetZoom, targetPan);
  }

  /// 외부에서 줌 아웃
  void zoomOut() {
    if (widget.useProvider && _gridConfig != null) {
      final size = context.size;
      ref.read(gridStateProvider(_gridConfig!).notifier).zoomOut(
            screenWidth: size?.width,
            screenHeight: size?.height,
          );
      return;
    }
    final size = context.size;
    if (size == null) return;
    final focal = Offset(size.width / 2, size.height / 2);
    final targetZoom = (_localZoom / 1.8).clamp(_minZoom, _maxZoom);
    final zoomDelta = targetZoom / _localZoom;
    final targetPan = Offset(
      focal.dx - (focal.dx - _localPan.dx) * zoomDelta,
      focal.dy - (focal.dy - _localPan.dy) * zoomDelta,
    );
    _animateTo(targetZoom, targetPan);
  }

  /// 미니맵 탭 → 해당 위치로 이동
  void navigateTo(double gridFractionX, double gridFractionY) {
    final size = context.size;
    if (size == null) return;
    final gridSize = math.max(widget.gridWidth, widget.gridHeight);
    final totalGrid = gridSize * _gridStep;

    if (widget.useProvider && _gridConfig != null) {
      final zoom = ref.read(gridStateProvider(_gridConfig!)).zoom;
      // Provider 모드의 zoom은 AppConstants.cellSize 기반이므로 변환
      final targetPan = Offset(
        size.width / 2 - gridFractionX * totalGrid * zoom,
        size.height / 2 - gridFractionY * totalGrid * zoom,
      );
      ref.read(gridStateProvider(_gridConfig!).notifier).setPan(
            targetPan.dx,
            targetPan.dy,
          );
      return;
    }

    final targetPan = Offset(
      size.width / 2 - gridFractionX * totalGrid * _localZoom,
      size.height / 2 - gridFractionY * totalGrid * _localZoom,
    );
    _animateTo(_localZoom, targetPan);
  }

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_zoomAnim != null && _panAnim != null) {
          setState(() {
            _localZoom = _zoomAnim!.value;
            _localPan = _panAnim!.value;
          });
        }
      });

    if (widget.backgroundImagePath != null) {
      _loadBackgroundImage();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;

    if (widget.useProvider) {
      final size = MediaQuery.of(context).size;
      final baseZoom = ZoomCalculator.calculateBaseZoom(
        gridWidth: widget.gridWidth,
        gridHeight: widget.gridHeight,
        screenWidth: size.width,
        screenHeight: size.height,
      );
      _gridConfig = GridConfig(
        gameId: widget.gameId,
        gridWidth: widget.gridWidth,
        gridHeight: widget.gridHeight,
        baseZoom: baseZoom,
      );
    }

    _initialized = true;
  }

  @override
  void didUpdateWidget(covariant BlockPickCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundImagePath != widget.backgroundImagePath) {
      if (widget.backgroundImagePath != null) {
        _loadBackgroundImage();
      } else {
        setState(() => _bgImage = null);
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// 배경 이미지 로드 (네트워크 URL + 로컬 asset 경로 지원)
  Future<void> _loadBackgroundImage() async {
    if (_imageLoading) return;
    setState(() => _imageLoading = true);

    try {
      final imagePath = widget.backgroundImagePath!;

      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // 네트워크 이미지
        final encodedPath = imagePath.replaceAll(' ', '%20');
        final networkImage = NetworkImage(encodedPath);
        final stream = networkImage.resolve(const ImageConfiguration());
        final completer = Completer<ui.Image>();

        late ImageStreamListener listener;
        listener = ImageStreamListener((ImageInfo info, bool _) {
          completer.complete(info.image);
          stream.removeListener(listener);
        }, onError: (dynamic exception, StackTrace? stackTrace) {
          completer.completeError(exception);
          stream.removeListener(listener);
        });

        stream.addListener(listener);
        final image = await completer.future;

        if (mounted) {
          setState(() {
            _bgImage = image;
            _imageLoading = false;
          });
        }
      } else {
        // 로컬 asset
        final data = await rootBundle.load(imagePath);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();

        if (mounted) {
          setState(() {
            _bgImage = frame.image;
            _imageLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _imageLoading = false);
      }
    }
  }

  // === 뷰 초기화 (자체 State 모드) ===

  void _initializeLocalView(Size size) {
    if (_initialized && _localPan != Offset.zero) return;
    _localZoom = 0.8;
    final gridSize = math.max(widget.gridWidth, widget.gridHeight);
    final centerGrid = gridSize * _gridStep / 2;
    _localPan = Offset(
      size.width / 2 - centerGrid * _localZoom,
      size.height / 2 - centerGrid * _localZoom,
    );
  }

  // === 제스처 (자체 State 모드) ===

  void _onLocalScaleStart(ScaleStartDetails details) {
    _gestureStartZoom = _localZoom;
    _gestureFocalPoint = details.localFocalPoint;
    _lastFocalPoint = details.localFocalPoint;
    _gestureStartPan = _localPan;
    _isDragging = false;
    _animController.stop();
  }

  void _onLocalScaleUpdate(ScaleUpdateDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    setState(() {
      if (details.pointerCount >= 2) {
        final newZoom = (_gestureStartZoom! * details.scale).clamp(_minZoom, _maxZoom);
        final focal = _gestureFocalPoint!;
        final zoomDelta = newZoom / _localZoom;
        _localPan = Offset(
          focal.dx - (focal.dx - _localPan.dx) * zoomDelta,
          focal.dy - (focal.dy - _localPan.dy) * zoomDelta,
        );
        _localZoom = newZoom;
      } else {
        final delta = details.localFocalPoint - _gestureFocalPoint!;
        if (delta.distance > AppConstants.dragThreshold) {
          _isDragging = true;
        }
        _localPan = _gestureStartPan! + delta;
      }
    });
  }

  void _onLocalScaleEnd(ScaleEndDetails details) {
    final dragDist = (_lastFocalPoint! - _gestureFocalPoint!).distance;
    if (dragDist < 8 && !_isDragging) {
      _handleLocalTap(_gestureFocalPoint!);
    }
    _gestureStartZoom = null;
    _gestureFocalPoint = null;
    _gestureStartPan = null;
    _isDragging = false;
  }

  void _handleLocalTap(Offset pos) {
    final gridX = ((pos.dx - _localPan.dx) / (_localZoom * _gridStep)).floor();
    final gridY = ((pos.dy - _localPan.dy) / (_localZoom * _gridStep)).floor();
    if (gridX >= 0 && gridX < widget.gridWidth && gridY >= 0 && gridY < widget.gridHeight) {
      // 1-based BlockModel
      final block = BlockModel.fromPosition(gridY + 1, gridX + 1, state: BlockState.selected);
      if (widget.onBlockTap != null && !widget.onBlockTap!(block)) {
        return;
      }
      setState(() {
        final existingIdx = _localSelectedBlocks.indexWhere((b) => b.id == block.id);
        if (existingIdx >= 0) {
          _localSelectedBlocks.removeAt(existingIdx);
        } else {
          _localSelectedBlocks.add(block);
        }
      });
    }
  }

  void _onLocalDoubleTapDown(TapDownDetails details) {
    final focal = details.localPosition;
    final targetZoom = _localZoom < 1.0 ? 2.0 : 0.15;
    final zoomDelta = targetZoom / _localZoom;
    final targetPan = Offset(
      focal.dx - (focal.dx - _localPan.dx) * zoomDelta,
      focal.dy - (focal.dy - _localPan.dy) * zoomDelta,
    );
    _animateTo(targetZoom, targetPan);
  }

  void _animateTo(double zoom, Offset pan) {
    _zoomAnim = Tween(begin: _localZoom, end: zoom).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _panAnim = Tween(begin: _localPan, end: pan).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0);
  }

  // === 제스처 (Provider 모드) ===

  Offset? _providerInitialFocalPoint;
  double? _providerInitialZoom;

  void _onProviderScaleStart(ScaleStartDetails details, GridState gridState) {
    _providerInitialFocalPoint = details.focalPoint;
    _providerInitialZoom = gridState.zoom;
    _isDragging = false;
    if (_gridConfig != null) {
      ref.read(gridStateProvider(_gridConfig!).notifier).setDragging(false);
    }
  }

  void _onProviderScaleUpdate(
    ScaleUpdateDetails details,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    if (_providerInitialZoom == null || _providerInitialFocalPoint == null) return;

    if (details.scale != 1.0) {
      final newZoom = (_providerInitialZoom! * details.scale).clamp(
        AppConstants.minZoom,
        AppConstants.maxZoom,
      );
      gridNotifier.zoomAtPoint(
        newZoom: newZoom,
        focalPointX: details.focalPoint.dx,
        focalPointY: details.focalPoint.dy,
      );
    } else {
      final delta = details.focalPoint - _providerInitialFocalPoint!;
      if (delta.distance > AppConstants.dragThreshold) {
        _isDragging = true;
        gridNotifier.setDragging(true);
      }
      gridNotifier.addPan(delta.dx, delta.dy);
    }

    _providerInitialFocalPoint = details.focalPoint;
  }

  void _onProviderScaleEnd(GridStateNotifier gridNotifier) {
    _providerInitialFocalPoint = null;
    _providerInitialZoom = null;
    gridNotifier.setDragging(false);

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() => _isDragging = false);
      }
    });
  }

  void _handleProviderTap(
    Offset position,
    Size size,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    if (_isDragging) return;

    final cellSize = AppConstants.cellSize * gridState.zoom;
    final gridX = (position.dx - gridState.panX) / cellSize;
    final gridY = (position.dy - gridState.panY) / cellSize;

    final col = (gridX + 1).floor();
    final row = (gridY + 1).floor();

    if (row >= 1 && row <= widget.gridHeight && col >= 1 && col <= widget.gridWidth) {
      final block = BlockModel.fromPosition(row, col, state: BlockState.selected);
      if (widget.onBlockTap != null && !widget.onBlockTap!(block)) {
        return;
      }
      gridNotifier.toggleBlock(block);
    }
  }

  // === 빌드 ===

  @override
  Widget build(BuildContext context) {
    if (widget.useProvider) {
      return _buildProviderMode();
    }
    return _buildLocalMode();
  }

  /// Provider 모드 빌드
  Widget _buildProviderMode() {
    if (_gridConfig == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final gridState = ref.watch(gridStateProvider(_gridConfig!));
    final gridNotifier = ref.read(gridStateProvider(_gridConfig!).notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        gridNotifier.setViewportSize(
          constraints.biggest.width,
          constraints.biggest.height,
        );

        // Provider의 zoom/pan을 BuzzCanvas 좌표계로 변환
        // Provider: AppConstants.cellSize(30) 기반, BlockPickPainter: gridStep(26) 기반
        final providerZoom = gridState.zoom;
        final providerPanX = gridState.panX;
        final providerPanY = gridState.panY;

        // 좌표 변환: provider 좌표계 → painter 좌표계
        // provider에서 col의 화면 X = (col-1) * cellSize * zoom + panX
        // painter에서 col의 화면 X = pan.dx + (col-1) * gridStep * painterZoom
        // 동일 화면 위치를 위해:
        //   painterZoom = providerZoom * AppConstants.cellSize / gridStep
        //   painterPan.dx = providerPanX
        final painterZoom = providerZoom * AppConstants.cellSize / BlockPickPainter.gridStep;
        final painterPan = Offset(providerPanX, providerPanY);

        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onTapUp: (details) => _handleProviderTap(
            details.localPosition,
            constraints.biggest,
            gridState,
            gridNotifier,
          ),
          onScaleStart: (details) => _onProviderScaleStart(details, gridState),
          onScaleUpdate: (details) =>
              _onProviderScaleUpdate(details, gridState, gridNotifier),
          onScaleEnd: (details) => _onProviderScaleEnd(gridNotifier),
          child: RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: BlockPickPainter(
                gridWidth: widget.gridWidth,
                gridHeight: widget.gridHeight,
                zoom: painterZoom,
                pan: painterPan,
                selectedBlocks: gridState.selectedBlocks,
                backgroundImage: _bgImage,
                showDotPattern: widget.showDotPattern,
                darkMode: widget.darkMode,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 자체 State 모드 빌드 (BuzzCanvas 호환)
  Widget _buildLocalMode() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initializeLocalView(size);

        return GestureDetector(
          onScaleStart: _onLocalScaleStart,
          onScaleUpdate: _onLocalScaleUpdate,
          onScaleEnd: _onLocalScaleEnd,
          onDoubleTapDown: _onLocalDoubleTapDown,
          onDoubleTap: () {},
          child: RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: BlockPickPainter(
                gridWidth: widget.gridWidth,
                gridHeight: widget.gridHeight,
                zoom: _localZoom,
                pan: _localPan,
                selectedBlocks: _localSelectedBlocks,
                backgroundImage: _bgImage,
                showDotPattern: widget.showDotPattern,
                darkMode: widget.darkMode,
              ),
            ),
          ),
        );
      },
    );
  }
}
