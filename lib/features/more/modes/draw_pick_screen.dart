import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Draw Pick - 그림 그려서 좌표 생성
class DrawPickScreen extends StatefulWidget {
  const DrawPickScreen({super.key});

  @override
  State<DrawPickScreen> createState() => _DrawPickScreenState();
}

class _DrawPickScreenState extends State<DrawPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.pink;
  static const int gridSize = 1000;

  final List<List<Offset>> _strokes = [];
  List<Offset> _currentStroke = [];
  Size? _canvasSize;
  Offset? _center;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
      _updateCenter();
    });
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      if (_currentStroke.isNotEmpty) {
        _strokes.add(List.from(_currentStroke));
        _currentStroke = [];
      }
    });
  }

  void _updateCenter() {
    final allPoints = [
      ..._strokes.expand((s) => s),
      ..._currentStroke,
    ];
    if (allPoints.isEmpty) {
      _center = null;
      return;
    }

    double sumX = 0, sumY = 0;
    for (final point in allPoints) {
      sumX += point.dx;
      sumY += point.dy;
    }
    _center = Offset(sumX / allPoints.length, sumY / allPoints.length);
  }

  void _clearCanvas() {
    HapticFeedback.mediumImpact();
    setState(() {
      _strokes.clear();
      _currentStroke = [];
      _center = null;
    });
  }

  void _confirmDrawing() {
    final allPoints = _strokes.expand((s) => s).toList();
    if (allPoints.isEmpty) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Draw something first!'),
          backgroundColor: modeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    final canvasWidth = _canvasSize?.width ?? 300;
    final canvasHeight = _canvasSize?.height ?? 300;

    double sumX = 0, sumY = 0;
    for (final point in allPoints) {
      sumX += point.dx;
      sumY += point.dy;
    }
    final centerX = sumX / allPoints.length;
    final centerY = sumY / allPoints.length;

    final row = ((centerY / canvasHeight) * gridSize).round().clamp(1, gridSize);
    final col = ((centerX / canvasWidth) * gridSize).round().clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Draw',
      modeColor: modeColor,
      subtitle: 'Created from ${allPoints.length} points',
      onRetry: _clearCanvas,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  int get _totalPoints => _strokes.fold(0, (sum, s) => sum + s.length) + _currentStroke.length;

  @override
  Widget build(BuildContext context) {
    final row = _center != null && _canvasSize != null
        ? ((_center!.dy / _canvasSize!.height) * gridSize).round().clamp(1, gridSize)
        : null;
    final col = _center != null && _canvasSize != null
        ? ((_center!.dx / _canvasSize!.width) * gridSize).round().clamp(1, gridSize)
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'DRAW',
        emoji: '🎨',
        accentColor: modeColor,
        actions: [
          if (_strokes.isNotEmpty || _currentStroke.isNotEmpty)
            GestureDetector(
              onTap: _clearCanvas,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.delete_outline_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'CLEAR',
                      style: AppTextStyles.caption2.copyWith(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: row != null && col != null,
        currentRow: row,
        currentCol: col,
        child: Column(
          children: [
            // 캔버스 영역
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: modeColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: modeColor.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      // 배경 그리드
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: _GridBackgroundPainter(modeColor),
                          );
                        },
                      ),

                      // 드로잉 캔버스
                      LayoutBuilder(
                        builder: (context, constraints) {
                          _canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
                          return GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(constraints.maxWidth, constraints.maxHeight),
                                  painter: _DrawingPainter(
                                    strokes: _strokes,
                                    currentStroke: _currentStroke,
                                    center: _center,
                                    color: modeColor,
                                    pulseValue: _pulseAnimation.value,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // 빈 캔버스 안내
                      if (_strokes.isEmpty && _currentStroke.isEmpty)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.gesture,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Draw anywhere',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // 하단 컨트롤
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: modeColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상태 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(Icons.brush_rounded, '${_strokes.length} strokes'),
                  const SizedBox(width: 16),
                  _buildStatChip(Icons.scatter_plot_rounded, '$_totalPoints points'),
                ],
              ),

              const SizedBox(height: 20),

              // 확정 버튼
              GestureDetector(
                onTap: _confirmDrawing,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        modeColor,
                        modeColor.withValues(alpha: 0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: modeColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_fix_high_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'CONFIRM DRAWING',
                        style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: modeColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption2.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _GridBackgroundPainter extends CustomPainter {
  final Color color;

  _GridBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const divisions = 20;
    for (int i = 0; i <= divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DrawingPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> currentStroke;
  final Offset? center;
  final Color color;
  final double pulseValue;

  _DrawingPainter({
    required this.strokes,
    required this.currentStroke,
    required this.center,
    required this.color,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 완료된 선들
    for (final stroke in strokes) {
      _drawStroke(canvas, stroke, 1.0);
    }

    // 현재 그리는 선
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, 1.0);
    }

    // 중심점 표시
    if (center != null) {
      // 글로우 효과
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3 * pulseValue)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center!, 25 * pulseValue, glowPaint);

      // 외부 원
      final outerPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(center!, 15, outerPaint);

      // 내부 원
      final innerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center!, 6, innerPaint);

      // 십자선
      final crossPaint = Paint()
        ..color = color.withValues(alpha: 0.5)
        ..strokeWidth = 1;

      canvas.drawLine(
        Offset(center!.dx - 25, center!.dy),
        Offset(center!.dx - 10, center!.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(center!.dx + 10, center!.dy),
        Offset(center!.dx + 25, center!.dy),
        crossPaint,
      );
      canvas.drawLine(
        Offset(center!.dx, center!.dy - 25),
        Offset(center!.dx, center!.dy - 10),
        crossPaint,
      );
      canvas.drawLine(
        Offset(center!.dx, center!.dy + 10),
        Offset(center!.dx, center!.dy + 25),
        crossPaint,
      );
    }
  }

  void _drawStroke(Canvas canvas, List<Offset> points, double opacity) {
    if (points.isEmpty) return;

    // 글로우 효과
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * opacity)
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    final mainPaint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      final p0 = points[i - 1];
      final p1 = points[i];
      final mid = Offset((p0.dx + p1.dx) / 2, (p0.dy + p1.dy) / 2);
      path.quadraticBezierTo(p0.dx, p0.dy, mid.dx, mid.dy);
    }

    if (points.length > 1) {
      path.lineTo(points.last.dx, points.last.dy);
    }

    canvas.drawPath(path, glowPaint);
    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}
