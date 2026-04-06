import 'dart:math' as math;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';

/// Google Stitch 스타일 무한 캔버스
/// - 다크 배경 + 무한 점 패턴
/// - Viewport Culling + LOD
/// - 핀치 줌/팬/더블탭/블록 선택
class BuzzCanvas extends StatefulWidget {
  final int gridSize;
  final Set<(int, int)> selectedBlocks;
  final String? backgroundImageUrl;
  final void Function(int x, int y) onBlockTap;

  const BuzzCanvas({
    super.key,
    this.gridSize = 1000,
    this.selectedBlocks = const {},
    this.backgroundImageUrl,
    required this.onBlockTap,
  });

  @override
  State<BuzzCanvas> createState() => BuzzCanvasState();
}

class BuzzCanvasState extends State<BuzzCanvas> with SingleTickerProviderStateMixin {
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  bool _initialized = false;
  ui.Image? _bgImage;

  // 제스처
  double? _gestureStartZoom;
  Offset? _gestureFocalPoint;
  Offset? _gestureStartPan;

  // 줌 애니메이션
  late AnimationController _animController;
  Animation<double>? _zoomAnim;
  Animation<Offset>? _panAnim;

  // 상수
  static const double _cellSize = 24.0;
  static const double _cellGap = 2.0;
  static const double _gridStep = _cellSize + _cellGap;
  static const double _minZoom = 0.015;
  static const double _maxZoom = 6.0;

  // 미니맵용 상태 노출
  double get currentZoom => _zoom;
  Offset get currentPan => _pan;
  double get gridStepValue => _gridStep;
  ui.Image? get bgImage => _bgImage;

  /// 미니맵 탭 → 해당 위치로 이동
  void navigateTo(double gridFractionX, double gridFractionY) {
    final size = context.size;
    if (size == null) return;
    final totalGrid = widget.gridSize * _gridStep;
    final targetPan = Offset(
      size.width / 2 - gridFractionX * totalGrid * _zoom,
      size.height / 2 - gridFractionY * totalGrid * _zoom,
    );
    _animateTo(_zoom, targetPan);
  }

  Future<void> _loadBackgroundImage() async {
    final url = widget.backgroundImageUrl;
    if (url == null || url.isEmpty) return;
    try {
      final completer = Completer<ui.Image>();
      final stream = NetworkImage(url).resolve(ImageConfiguration.empty);
      stream.addListener(ImageStreamListener((info, _) {
        completer.complete(info.image);
      }, onError: (error, _) {
        // 이미지 로드 실패 시 무시
      }));
      final image = await completer.future;
      if (mounted) {
        setState(() => _bgImage = image);
      }
    } catch (_) {
      // 무시
    }
  }

  // 배경색
  static const Color bgColor = Color(0xFF1B1D21);
  static const Color dotColor = Color(0xFF3A3D44);
  static const Color blockColor = Color(0xFF2A2D33);
  static const Color blockBorder = Color(0xFF3E4149);

  /// 외부에서 줌 인/아웃 호출
  void zoomIn() {
    final size = context.size;
    if (size == null) return;
    final focal = Offset(size.width / 2, size.height / 2);
    final targetZoom = (_zoom * 1.8).clamp(_minZoom, _maxZoom);
    final zoomDelta = targetZoom / _zoom;
    final targetPan = Offset(
      focal.dx - (focal.dx - _pan.dx) * zoomDelta,
      focal.dy - (focal.dy - _pan.dy) * zoomDelta,
    );
    _animateTo(targetZoom, targetPan);
  }

  void zoomOut() {
    final size = context.size;
    if (size == null) return;
    final focal = Offset(size.width / 2, size.height / 2);
    final targetZoom = (_zoom / 1.8).clamp(_minZoom, _maxZoom);
    final zoomDelta = targetZoom / _zoom;
    final targetPan = Offset(
      focal.dx - (focal.dx - _pan.dx) * zoomDelta,
      focal.dy - (focal.dy - _pan.dy) * zoomDelta,
    );
    _animateTo(targetZoom, targetPan);
  }

  @override
  void initState() {
    super.initState();
    _loadBackgroundImage();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addListener(() {
        if (_zoomAnim != null && _panAnim != null) {
          setState(() {
            _zoom = _zoomAnim!.value;
            _pan = _panAnim!.value;
          });
        }
      });
  }

  @override
  void didUpdateWidget(covariant BuzzCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.backgroundImageUrl != widget.backgroundImageUrl) {
      _loadBackgroundImage();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _initializeView(Size size) {
    if (_initialized) return;
    _initialized = true;
    // 그리드 중앙에서 시작, 블록이 보일 정도로 줌인
    _zoom = 0.8;
    final centerGrid = widget.gridSize * _gridStep / 2;
    _pan = Offset(
      size.width / 2 - centerGrid * _zoom,
      size.height / 2 - centerGrid * _zoom,
    );
  }

  // === 제스처 ===

  Offset? _lastFocalPoint;

  void _onScaleStart(ScaleStartDetails details) {
    _gestureStartZoom = _zoom;
    _gestureFocalPoint = details.localFocalPoint;
    _lastFocalPoint = details.localFocalPoint;
    _gestureStartPan = _pan;
    _animController.stop();
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    _lastFocalPoint = details.localFocalPoint;
    setState(() {
      if (details.pointerCount >= 2) {
        final newZoom = (_gestureStartZoom! * details.scale).clamp(_minZoom, _maxZoom);
        final focal = _gestureFocalPoint!;
        final zoomDelta = newZoom / _zoom;
        _pan = Offset(
          focal.dx - (focal.dx - _pan.dx) * zoomDelta,
          focal.dy - (focal.dy - _pan.dy) * zoomDelta,
        );
        _zoom = newZoom;
      } else {
        final delta = details.localFocalPoint - _gestureFocalPoint!;
        _pan = _gestureStartPan! + delta;
      }
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    // 드래그 거리가 짧으면 탭으로 처리
    final dragDist = (_lastFocalPoint! - _gestureFocalPoint!).distance;
    if (dragDist < 8) {
      _handleTap(_gestureFocalPoint!);
    }
    _gestureStartZoom = null;
    _gestureFocalPoint = null;
    _gestureStartPan = null;
  }

  void _handleTap(Offset pos) {
    final gridX = ((pos.dx - _pan.dx) / (_zoom * _gridStep)).floor();
    final gridY = ((pos.dy - _pan.dy) / (_zoom * _gridStep)).floor();
    if (gridX >= 0 && gridX < widget.gridSize && gridY >= 0 && gridY < widget.gridSize) {
      widget.onBlockTap(gridX, gridY);
    }
  }

  void _onDoubleTapDown(TapDownDetails details) {
    final focal = details.localPosition;
    final targetZoom = _zoom < 1.0 ? 2.0 : 0.15;
    final zoomDelta = targetZoom / _zoom;
    final targetPan = Offset(
      focal.dx - (focal.dx - _pan.dx) * zoomDelta,
      focal.dy - (focal.dy - _pan.dy) * zoomDelta,
    );
    _animateTo(targetZoom, targetPan);
  }

  void _animateTo(double zoom, Offset pan) {
    _zoomAnim = Tween(begin: _zoom, end: zoom).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _panAnim = Tween(begin: _pan, end: pan).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _initializeView(size);

        return GestureDetector(
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          onTapUp: (details) => _handleTap(details.localPosition),
          onDoubleTapDown: _onDoubleTapDown,
          onDoubleTap: () {},
          child: RepaintBoundary(
            child: CustomPaint(
              size: size,
              painter: _StitchGridPainter(
                gridSize: widget.gridSize,
                zoom: _zoom,
                pan: _pan,
                selectedBlocks: widget.selectedBlocks,
                backgroundImage: _bgImage,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Stitch 스타일 페인터
class _StitchGridPainter extends CustomPainter {
  final int gridSize;
  final double zoom;
  final Offset pan;
  final Set<(int, int)> selectedBlocks;
  final ui.Image? backgroundImage;

  static const double _cellSize = 24.0;
  static const double _cellGap = 2.0;
  static const double _gridStep = _cellSize + _cellGap;

  _StitchGridPainter({
    required this.gridSize,
    required this.zoom,
    required this.pan,
    this.selectedBlocks = const {},
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. 다크 배경
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = BuzzCanvasState.bgColor,
    );

    // 2. 무한 점 패턴 (그리드 영역 밖에도 표시)
    _drawInfiniteDots(canvas, size);

    // 2.5. 배경 이미지 (그리드 영역에 맞춰 그리기)
    if (backgroundImage != null) {
      _drawBackgroundImage(canvas, size);
    }

    // 3. 그리드 블록
    final scaledStep = _gridStep * zoom;
    final scaledCell = _cellSize * zoom;

    if (backgroundImage != null) {
      // 이미지 있으면 격자선만 (이미지가 잘 보이도록)
      if (scaledCell >= 6) {
        _drawGridLines(canvas, size, scaledStep, scaledCell);
      }
    } else {
      // 이미지 없으면 채워진 블록
      if (scaledCell >= 2) {
        _drawBlocks(canvas, size, scaledStep, scaledCell);
      }
    }

    // 4. 선택된 블록들
    if (selectedBlocks.isNotEmpty) {
      for (final block in selectedBlocks) {
        _drawSelected(canvas, scaledStep, scaledCell, block.$1, block.$2);
      }
    }

    // 5. 줌 레벨 표시
    _drawZoomIndicator(canvas, size);
  }

  /// 배경 이미지 — 그리드 영역에 맞춰 그리기
  void _drawBackgroundImage(Canvas canvas, Size size) {
    final img = backgroundImage!;
    final totalGrid = gridSize * _gridStep;
    final dstRect = Rect.fromLTWH(
      pan.dx,
      pan.dy,
      totalGrid * zoom,
      totalGrid * zoom,
    );
    // 화면과 겹치는 부분만 그리기
    final screenRect = Rect.fromLTWH(0, 0, size.width, size.height);
    if (!dstRect.overlaps(screenRect)) return;

    final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
    canvas.drawImageRect(
      img,
      srcRect,
      dstRect,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  /// 무한 점 패턴 — 화면 전체에 일정 간격으로 점 찍기
  void _drawInfiniteDots(Canvas canvas, Size size) {
    // 줌에 따라 점 간격 조절
    double dotSpacing = _gridStep * zoom;

    // 너무 촘촘하면 간격 늘림
    while (dotSpacing < 12) dotSpacing *= 2;
    // 너무 넓으면 간격 줄임
    while (dotSpacing > 80) dotSpacing /= 2;

    final dotPaint = Paint()
      ..color = BuzzCanvasState.dotColor
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    // 화면 전체를 커버하는 점 좌표 계산
    final offsetX = pan.dx % dotSpacing;
    final offsetY = pan.dy % dotSpacing;

    final points = <Offset>[];
    for (double y = offsetY; y < size.height; y += dotSpacing) {
      for (double x = offsetX; x < size.width; x += dotSpacing) {
        points.add(Offset(x, y));
      }
    }

    canvas.drawPoints(ui.PointMode.points, points, dotPaint);
  }

  /// 이미지 위 격자선만 그리기 (이미지가 잘 보이도록)
  void _drawGridLines(Canvas canvas, Size size, double step, double cellPx) {
    final startCol = math.max(0, (-pan.dx / step).floor());
    final endCol = math.min(gridSize, ((-pan.dx + size.width) / step).ceil());
    final startRow = math.max(0, (-pan.dy / step).floor());
    final endRow = math.min(gridSize, ((-pan.dy + size.height) / step).ceil());

    final linePaint = Paint()
      ..color = const Color(0x33FFFFFF)
      ..strokeWidth = 0.5;

    // 세로선
    for (int col = startCol; col <= endCol; col++) {
      final x = pan.dx + col * step;
      final yStart = pan.dy + startRow * step;
      final yEnd = pan.dy + endRow * step;
      canvas.drawLine(Offset(x, yStart), Offset(x, yEnd), linePaint);
    }
    // 가로선
    for (int row = startRow; row <= endRow; row++) {
      final y = pan.dy + row * step;
      final xStart = pan.dx + startCol * step;
      final xEnd = pan.dx + endCol * step;
      canvas.drawLine(Offset(xStart, y), Offset(xEnd, y), linePaint);
    }
  }

  /// 그리드 블록 렌더링 (Viewport Culling)
  void _drawBlocks(Canvas canvas, Size size, double step, double cellPx) {
    final startCol = math.max(0, (-pan.dx / step).floor());
    final endCol = math.min(gridSize, ((-pan.dx + size.width) / step).ceil());
    final startRow = math.max(0, (-pan.dy / step).floor());
    final endRow = math.min(gridSize, ((-pan.dy + size.height) / step).ceil());

    if (cellPx < 4) {
      // LOD 0: 작은 사각형만
      final paint = Paint()..color = backgroundImage != null
          ? BuzzCanvasState.blockColor.withValues(alpha: 0.7)
          : BuzzCanvasState.blockColor;
      for (int row = startRow; row < endRow; row++) {
        for (int col = startCol; col < endCol; col++) {
          canvas.drawRect(
            Rect.fromLTWH(pan.dx + col * step, pan.dy + row * step, cellPx, cellPx),
            paint,
          );
        }
      }
    } else if (cellPx < 14) {
      // LOD 1: 약간 디테일
      final fill = Paint()..color = BuzzCanvasState.blockColor;
      final border = Paint()
        ..color = BuzzCanvasState.blockBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5;
      for (int row = startRow; row < endRow; row++) {
        for (int col = startCol; col < endCol; col++) {
          final rect = Rect.fromLTWH(pan.dx + col * step, pan.dy + row * step, cellPx, cellPx);
          canvas.drawRect(rect, fill);
          canvas.drawRect(rect, border);
        }
      }
    } else {
      // LOD 2: 둥근 사각형 + border
      final fill = Paint()..color = BuzzCanvasState.blockColor;
      final border = Paint()
        ..color = BuzzCanvasState.blockBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8;
      final radius = Radius.circular(math.min(4.0, cellPx * 0.12));

      for (int row = startRow; row < endRow; row++) {
        for (int col = startCol; col < endCol; col++) {
          final rect = Rect.fromLTWH(pan.dx + col * step, pan.dy + row * step, cellPx, cellPx);
          final rrect = RRect.fromRectAndRadius(rect, radius);
          canvas.drawRRect(rrect, fill);
          canvas.drawRRect(rrect, border);
        }
      }
    }
  }

  /// 선택 블록 강조
  void _drawSelected(Canvas canvas, double step, double cellPx, int x, int y) {
    final rect = Rect.fromLTWH(pan.dx + x * step, pan.dy + y * step, cellPx, cellPx);
    final radius = Radius.circular(math.min(4.0, cellPx * 0.12));
    final rrect = RRect.fromRectAndRadius(rect, radius);

    // 글로우
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(6 * (cellPx / 24).clamp(0.5, 2.0)), radius),
      Paint()
        ..color = AppColors.primaryMain.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
    // 블록
    canvas.drawRRect(rrect, Paint()..color = AppColors.primaryMain);
    // 테두리
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.primaryLight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
    // 별 아이콘 (충분히 클 때만)
    if (cellPx > 18) {
      _drawStar(canvas, rect.center, math.min(cellPx * 0.4, 16.0));
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size) {
    final paint = Paint()..color = AppColors.white;
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size * 0.25, height: size),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: center, width: size, height: size * 0.25),
      paint,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(0.785);
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size * 0.2, height: size * 0.7),
      paint,
    );
    canvas.drawRect(
      Rect.fromCenter(center: Offset.zero, width: size * 0.7, height: size * 0.2),
      paint,
    );
    canvas.restore();
  }

  /// 줌 퍼센트 표시
  void _drawZoomIndicator(Canvas canvas, Size size) {
    final percent = (zoom * 100).toInt();
    final tp = TextPainter(
      text: TextSpan(
        text: '$percent%',
        style: const TextStyle(
          color: Color(0xFF6B7684),
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final bgRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width - tp.width - 20,
        12,
        tp.width + 12,
        tp.height + 8,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(bgRect, Paint()..color = const Color(0xFF2A2D33));
    tp.paint(canvas, Offset(size.width - tp.width - 14, 16));
  }

  @override
  bool shouldRepaint(covariant _StitchGridPainter old) {
    return old.zoom != zoom ||
        old.pan != pan ||
        old.selectedBlocks != selectedBlocks ||
        old.backgroundImage != backgroundImage;
  }
}
