import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:async';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// 그리드 미니맵 위젯
///
/// 현재 뷰포트 위치를 미니맵으로 표시하여 사용자가
/// 전체 그리드에서 어디에 있는지 알 수 있게 합니다.
class GridMinimap extends StatefulWidget {
  /// 그리드 가로 크기
  final int gridWidth;

  /// 그리드 세로 크기
  final int gridHeight;

  /// 현재 줌 레벨
  final double zoom;

  /// 현재 팬 X 위치
  final double panX;

  /// 현재 팬 Y 위치
  final double panY;

  /// 화면 크기
  final Size screenSize;

  /// 미니맵 크기 (정사각형)
  final double minimapSize;

  /// 배경 이미지 경로
  final String? backgroundImagePath;

  /// 현재 줌 레벨 (선택적, 구역 분할에 사용)
  final int? currentZoomLevel;

  const GridMinimap({
    super.key,
    required this.gridWidth,
    required this.gridHeight,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.screenSize,
    this.minimapSize = AppConstants.minimapSize,
    this.backgroundImagePath,
    this.currentZoomLevel,
  });

  @override
  State<GridMinimap> createState() => _GridMinimapState();
}

class _GridMinimapState extends State<GridMinimap> {
  ui.Image? _backgroundImage;
  bool _imageLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.backgroundImagePath != null) {
      _loadBackgroundImage();
    }
  }

  @override
  void didUpdateWidget(GridMinimap oldWidget) {
    super.didUpdateWidget(oldWidget);
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

  Future<void> _loadBackgroundImage() async {
    if (_imageLoading) return;

    setState(() {
      _imageLoading = true;
    });

    try {
      final imagePath = widget.backgroundImagePath!;

      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        final encodedPath = imagePath.replaceAll(' ', '%20');
        final NetworkImage networkImage = NetworkImage(encodedPath);
        final ImageStream stream = networkImage.resolve(const ImageConfiguration());
        final completer = Completer<ui.Image>();

        late ImageStreamListener listener;
        listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
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
            _backgroundImage = image;
            _imageLoading = false;
          });
        }
      } else {
        final data = await rootBundle.load(imagePath);
        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();

        if (mounted) {
          setState(() {
            _backgroundImage = frame.image;
            _imageLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load minimap background image: $e');
      if (mounted) {
        setState(() {
          _imageLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.minimapSize,
      height: widget.minimapSize,
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(color: AppColors.buleGray, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd - 2),
        child: CustomPaint(
          painter: _MinimapPainter(
            gridWidth: widget.gridWidth,
            gridHeight: widget.gridHeight,
            zoom: widget.zoom,
            panX: widget.panX,
            panY: widget.panY,
            screenSize: widget.screenSize,
            backgroundImage: _backgroundImage,
            currentZoomLevel: widget.currentZoomLevel,
          ),
        ),
      ),
    );
  }
}

/// 미니맵 Painter
class _MinimapPainter extends CustomPainter {
  final int gridWidth;
  final int gridHeight;
  final double zoom;
  final double panX;
  final double panY;
  final Size screenSize;
  final ui.Image? backgroundImage;
  final int? currentZoomLevel;

  _MinimapPainter({
    required this.gridWidth,
    required this.gridHeight,
    required this.zoom,
    required this.panX,
    required this.panY,
    required this.screenSize,
    this.backgroundImage,
    this.currentZoomLevel,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 그리드 전체 크기
    final gridTotalWidth = gridWidth * AppConstants.cellSize;
    final gridTotalHeight = gridHeight * AppConstants.cellSize;

    // 미니맵 스케일 계산 (그리드 전체가 미니맵에 들어가도록)
    final scaleX = size.width / gridTotalWidth;
    final scaleY = size.height / gridTotalHeight;
    final minimapScale = scaleX < scaleY ? scaleX : scaleY;

    // 미니맵 중앙 정렬을 위한 오프셋
    final minimapOffsetX = (size.width - gridTotalWidth * minimapScale) / 2;
    final minimapOffsetY = (size.height - gridTotalHeight * minimapScale) / 2;

    final gridRect = Rect.fromLTWH(
      minimapOffsetX,
      minimapOffsetY,
      gridTotalWidth * minimapScale,
      gridTotalHeight * minimapScale,
    );

    // 1. 배경 이미지 또는 그리드 영역 그리기
    if (backgroundImage != null) {
      // 배경 이미지가 있으면 이미지 렌더링
      final srcRect = Rect.fromLTWH(
        0,
        0,
        backgroundImage!.width.toDouble(),
        backgroundImage!.height.toDouble(),
      );

      final imagePaint = Paint()
        ..filterQuality = FilterQuality.medium;

      canvas.drawImageRect(
        backgroundImage!,
        srcRect,
        gridRect,
        imagePaint,
      );

      // 약한 오버레이 (뷰포트 가시성 향상)
      final overlayPaint = Paint()
        ..color = AppColors.white.withOpacity(0.3);
      canvas.drawRect(gridRect, overlayPaint);
    } else {
      // 배경 이미지가 없으면 기본 색상
      final gridPaint = Paint()
        ..color = AppColors.blueWhite
        ..style = PaintingStyle.fill;

      canvas.drawRect(gridRect, gridPaint);
    }

    // 2. 현재 뷰포트 영역 계산
    final viewportWidth = screenSize.width / zoom;
    final viewportHeight = screenSize.height / zoom;
    final viewportX = -panX / zoom;
    final viewportY = -panY / zoom;

    // 뷰포트를 미니맵 좌표로 변환
    var viewportMinimapX = minimapOffsetX + viewportX * minimapScale;
    var viewportMinimapY = minimapOffsetY + viewportY * minimapScale;
    var viewportMinimapWidth = viewportWidth * minimapScale;
    var viewportMinimapHeight = viewportHeight * minimapScale;

    // 뷰포트 박스 최소/최대 크기 제한 (가시성 개선)
    const minViewportSize = 8.0; // 최소 8픽셀
    final maxViewportSize = size.width * 0.9; // 미니맵의 90%

    // 너무 작으면 최소 크기로 설정
    if (viewportMinimapWidth < minViewportSize) {
      viewportMinimapWidth = minViewportSize;
      viewportMinimapX = viewportMinimapX.clamp(
        minimapOffsetX,
        minimapOffsetX + gridTotalWidth * minimapScale - minViewportSize,
      );
    }
    if (viewportMinimapHeight < minViewportSize) {
      viewportMinimapHeight = minViewportSize;
      viewportMinimapY = viewportMinimapY.clamp(
        minimapOffsetY,
        minimapOffsetY + gridTotalHeight * minimapScale - minViewportSize,
      );
    }

    // 너무 크면 최대 크기로 제한하고 중앙에 배치
    if (viewportMinimapWidth > maxViewportSize) {
      viewportMinimapWidth = maxViewportSize;
      // 그리드 영역의 중앙에 배치
      final gridMinimapCenterX = minimapOffsetX + (gridTotalWidth * minimapScale) / 2;
      viewportMinimapX = gridMinimapCenterX - viewportMinimapWidth / 2;
    }
    if (viewportMinimapHeight > maxViewportSize) {
      viewportMinimapHeight = maxViewportSize;
      // 그리드 영역의 중앙에 배치
      final gridMinimapCenterY = minimapOffsetY + (gridTotalHeight * minimapScale) / 2;
      viewportMinimapY = gridMinimapCenterY - viewportMinimapHeight / 2;
    }

    final viewportRect = Rect.fromLTWH(
      viewportMinimapX,
      viewportMinimapY,
      viewportMinimapWidth,
      viewportMinimapHeight,
    );

    // 3. 현재 뷰포트 영역 그리기 (반투명 파란색 - 강조)
    final viewportPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawRect(viewportRect, viewportPaint);

    // 4. 뷰포트 테두리 그리기 (강조된 두께)
    final viewportBorderPaint = Paint()
      ..color = AppColors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRect(viewportRect, viewportBorderPaint);

    // 5. 뷰포트 외곽 그림자 효과 (더 명확한 구분)
    final shadowPaint = Paint()
      ..color = AppColors.blue.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0;

    canvas.drawRect(viewportRect, shadowPaint);

    // 6. 그리드 테두리 그리기
    final gridBorderPaint = Paint()
      ..color = AppColors.buleGray
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawRect(
      Rect.fromLTWH(
        minimapOffsetX,
        minimapOffsetY,
        gridTotalWidth * minimapScale,
        gridTotalHeight * minimapScale,
      ),
      gridBorderPaint,
    );
  }

  @override
  bool shouldRepaint(_MinimapPainter oldDelegate) {
    return oldDelegate.zoom != zoom ||
        oldDelegate.panX != panX ||
        oldDelegate.panY != panY ||
        oldDelegate.backgroundImage != backgroundImage;
  }
}
