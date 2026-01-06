import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Gacha Pick - 인형뽑기 크로스헤어 스타일
class GachaPickScreen extends StatefulWidget {
  const GachaPickScreen({super.key});

  @override
  State<GachaPickScreen> createState() => _GachaPickScreenState();
}

class _GachaPickScreenState extends State<GachaPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = Color(0xFFEC4899); // Pink
  static const int gridSize = 1000;

  // 샘플 경품 이미지 (실제로는 게임에서 동적으로 받아옴)
  static const String prizeImageUrl =
      'https://images.unsplash.com/photo-1584917865442-de89df76afd3?w=800&q=80';

  late AnimationController _verticalController;
  late AnimationController _horizontalController;
  late AnimationController _clawController;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // 0: 세로축 이동 중, 1: 가로축 이동 중, 2: 완료
  int _phase = 0;
  double _fixedVertical = 0.5; // 고정된 세로 위치 (0~1)
  double _fixedHorizontal = 0.5; // 고정된 가로 위치 (0~1)

  bool _isDescending = false; // 집게 내려가는 애니메이션

  @override
  void initState() {
    super.initState();

    // 세로축 왔다갔다 애니메이션
    _verticalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);

    // 가로축 왔다갔다 애니메이션
    _horizontalController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    // 집게 내려가는 애니메이션
    _clawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 글로우 애니메이션
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _clawController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    HapticFeedback.heavyImpact();

    if (_phase == 0) {
      // 세로축 고정
      setState(() {
        _fixedVertical = _verticalController.value;
        _phase = 1;
      });
      _verticalController.stop();
      _horizontalController.repeat(reverse: true);
    } else if (_phase == 1) {
      // 가로축 고정 → 완료
      setState(() {
        _fixedHorizontal = _horizontalController.value;
        _phase = 2;
        _isDescending = true;
      });
      _horizontalController.stop();

      // 집게 내려가는 애니메이션
      _clawController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          _showResult();
        });
      });
    }
  }

  void _showResult() {
    final row = (_fixedVertical * gridSize).round().clamp(1, gridSize);
    final col = (_fixedHorizontal * gridSize).round().clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Gacha',
      modeColor: modeColor,
      subtitle: 'Claw machine coordinate',
      onRetry: _reset,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    setState(() {
      _phase = 0;
      _fixedVertical = 0.5;
      _fixedHorizontal = 0.5;
      _isDescending = false;
    });
    _clawController.reset();
    _horizontalController.stop();
    _horizontalController.reset();
    _verticalController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'GACHA',
        emoji: '🎮',
        accentColor: modeColor,
        actions: [
          if (_phase > 0)
            GestureDetector(
              onTap: _reset,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
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
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'RESET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _verticalController,
          _horizontalController,
          _clawController,
          _glowAnimation,
        ]),
        builder: (context, _) {
          final currentRow = _phase == 0
              ? (_verticalController.value * gridSize).round().clamp(
                  1,
                  gridSize,
                )
              : (_fixedVertical * gridSize).round().clamp(1, gridSize);
          final currentCol = _phase < 1
              ? null
              : _phase == 1
              ? (_horizontalController.value * gridSize).round().clamp(
                  1,
                  gridSize,
                )
              : (_fixedHorizontal * gridSize).round().clamp(1, gridSize);

          return GameCanvas(
            accentColor: modeColor,
            showCoordinate: true,
            currentRow: currentRow,
            currentCol: currentCol,
            child: Stack(
              children: [
                // 배경
                CustomPaint(
                  size: Size.infinite,
                  painter: _GachaBackgroundPainter(
                    color: modeColor,
                    glowValue: _glowAnimation.value,
                  ),
                ),

                // 메인 게임 영역
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),

                      // 단계 인디케이터 (캔버스 위에 배치)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildPhaseIndicator(),
                      ),

                      // 게임 캔버스
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                modeColor.withValues(alpha: 0.1),
                                Colors.black.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: modeColor.withValues(alpha: 0.5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: modeColor.withValues(alpha: 0.3),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    // 경품 이미지 배경
                                    Positioned.fill(
                                      child: Image.network(
                                        prizeImageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Container(
                                            color: Colors.black,
                                            child: Center(
                                              child: CircularProgressIndicator(
                                                color: modeColor,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                    : null,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.black,
                                                child: Center(
                                                  child: Icon(
                                                    Icons.card_giftcard_rounded,
                                                    size: 80,
                                                    color: modeColor.withValues(
                                                      alpha: 0.3,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                      ),
                                    ),

                                    // 어두운 오버레이 (크로스헤어 가시성을 위해 - 최소화)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.black.withValues(
                                                alpha: 0.1,
                                              ),
                                              Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    // 그리드 오버레이
                                    CustomPaint(
                                      size: Size(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      ),
                                      painter: _GachaGridPainter(
                                        color: modeColor,
                                      ),
                                    ),

                                    // 크로스헤어
                                    CustomPaint(
                                      size: Size(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      ),
                                      painter: _CrosshairPainter(
                                        phase: _phase,
                                        verticalPos: _phase == 0
                                            ? _verticalController.value
                                            : _fixedVertical,
                                        horizontalPos: _phase >= 1
                                            ? (_phase == 1
                                                  ? _horizontalController.value
                                                  : _fixedHorizontal)
                                            : 0.5,
                                        color: modeColor,
                                        glowValue: _glowAnimation.value,
                                        clawProgress: _clawController.value,
                                        isDescending: _isDescending,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // 하단 컨트롤
                      _buildBottomPanel(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhaseChip(0, 'ROW', Icons.swap_vert_rounded),
        const SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: 20,
        ),
        const SizedBox(width: 12),
        _buildPhaseChip(1, 'COL', Icons.swap_horiz_rounded),
        const SizedBox(width: 12),
        Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: 20,
        ),
        const SizedBox(width: 12),
        _buildPhaseChip(2, 'GET!', Icons.catching_pokemon_rounded),
      ],
    );
  }

  Widget _buildPhaseChip(int phaseNum, String label, IconData icon) {
    final isActive = _phase == phaseNum;
    final isDone = _phase > phaseNum;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? modeColor.withValues(alpha: 0.3)
            : isDone
            ? modeColor.withValues(alpha: 0.1)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? modeColor
              : isDone
              ? modeColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: modeColor.withValues(alpha: 0.4),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : icon,
            size: 16,
            color: isActive
                ? Colors.white
                : isDone
                ? modeColor
                : Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : isDone
                  ? modeColor
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
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
              top: BorderSide(color: modeColor.withValues(alpha: 0.3)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상태 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(
                    Icons.grid_on_rounded,
                    'ROW: ${_phase >= 1 ? (_fixedVertical * gridSize).round().clamp(1, gridSize) : "---"}',
                    _phase >= 1,
                  ),
                  const SizedBox(width: 16),
                  _buildStatChip(
                    Icons.grid_on_rounded,
                    'COL: ${_phase >= 2 ? (_fixedHorizontal * gridSize).round().clamp(1, gridSize) : "---"}',
                    _phase >= 2,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 메인 버튼
              GestureDetector(
                onTap: _phase < 2 ? _onButtonPressed : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: _phase < 2
                        ? LinearGradient(
                            colors: [
                              modeColor,
                              modeColor.withValues(alpha: 0.7),
                            ],
                          )
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade700,
                              Colors.grey.shade800,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _phase < 2
                        ? [
                            BoxShadow(
                              color: modeColor.withValues(alpha: 0.5),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _phase == 0
                            ? Icons.swap_vert_rounded
                            : _phase == 1
                            ? Icons.swap_horiz_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _phase == 0
                            ? 'STOP ROW'
                            : _phase == 1
                            ? 'STOP COLUMN'
                            : 'COMPLETE!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 안내 텍스트
              Text(
                _phase == 0
                    ? 'Tap to lock the row position'
                    : _phase == 1
                    ? 'Tap to lock the column position'
                    : 'Coordinate locked!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isActive
            ? modeColor.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? modeColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? modeColor : Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

class _GachaBackgroundPainter extends CustomPainter {
  final Color color;
  final double glowValue;

  _GachaBackgroundPainter({required this.color, required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 그라데이션
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [
          color.withValues(alpha: 0.05 * glowValue),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 코너 장식
    final cornerPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 좌상단
    canvas.drawLine(const Offset(20, 40), const Offset(20, 80), cornerPaint);
    canvas.drawLine(const Offset(20, 40), const Offset(60, 40), cornerPaint);

    // 우상단
    canvas.drawLine(
      Offset(size.width - 20, 40),
      Offset(size.width - 20, 80),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 20, 40),
      Offset(size.width - 60, 40),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GachaBackgroundPainter oldDelegate) => true;
}

class _GachaGridPainter extends CustomPainter {
  final Color color;

  _GachaGridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    // 세로 라인
    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // 가로 라인
    for (int i = 1; i < 10; i++) {
      final y = size.height * i / 10;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // 중앙 십자 강조
    final centerPaint = Paint()
      ..color = color.withValues(alpha: 0.15)
      ..strokeWidth = 1;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CrosshairPainter extends CustomPainter {
  final int phase;
  final double verticalPos;
  final double horizontalPos;
  final Color color;
  final double glowValue;
  final double clawProgress;
  final bool isDescending;

  _CrosshairPainter({
    required this.phase,
    required this.verticalPos,
    required this.horizontalPos,
    required this.color,
    required this.glowValue,
    required this.clawProgress,
    required this.isDescending,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = verticalPos * size.height;
    final x = horizontalPos * size.width;

    // 세로 라인 (가로로 이동하는 라인 = Y 좌표 결정)
    if (phase >= 0) {
      final isMoving = phase == 0;
      final lineColor = isMoving ? Colors.cyan : color;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = lineColor.withValues(
          alpha: 0.3 * (isMoving ? glowValue : 1.0),
        )
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);

      // 메인 라인
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: isMoving ? 0.8 : 1.0)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

      // 라인 끝 마커
      _drawMarker(canvas, Offset(10, y), lineColor, isMoving);
      _drawMarker(canvas, Offset(size.width - 10, y), lineColor, isMoving);
    }

    // 가로 라인 (세로로 이동하는 라인 = X 좌표 결정)
    if (phase >= 1) {
      final isMoving = phase == 1;
      final lineColor = isMoving ? Colors.amber : color;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = lineColor.withValues(
          alpha: 0.3 * (isMoving ? glowValue : 1.0),
        )
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowPaint);

      // 메인 라인
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: isMoving ? 0.8 : 1.0)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

      // 라인 끝 마커
      _drawMarker(canvas, Offset(x, 10), lineColor, isMoving);
      _drawMarker(canvas, Offset(x, size.height - 10), lineColor, isMoving);
    }

    // 교차점 (두 라인이 모두 있을 때)
    if (phase >= 1) {
      final crossPoint = Offset(x, y);

      // 큰 글로우
      final bigGlowPaint = Paint()
        ..color = color.withValues(alpha: 0.2 * glowValue)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

      canvas.drawCircle(crossPoint, 40, bigGlowPaint);

      // 타겟 원
      for (int i = 3; i >= 1; i--) {
        final ringPaint = Paint()
          ..color = color.withValues(alpha: 0.2 + (3 - i) * 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(crossPoint, 15.0 * i, ringPaint);
      }

      // 중앙 점
      final centerPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(crossPoint, 6, centerPaint);

      // 집게 그리기 (완료 시)
      if (isDescending) {
        _drawClaw(canvas, crossPoint, clawProgress);
      }
    }
  }

  void _drawMarker(Canvas canvas, Offset position, Color color, bool animate) {
    final size = animate ? 8 + glowValue * 4 : 10.0;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, size / 2, paint);

    if (animate) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(position, size, glowPaint);
    }
  }

  void _drawClaw(Canvas canvas, Offset center, double progress) {
    final clawColor = Colors.grey.shade400;
    final scale = 0.5 + progress * 0.5;
    final opacity = progress;

    // 집게 몸체
    final bodyPaint = Paint()
      ..color = clawColor.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(center.dx - 15 * scale, center.dy - 60 + progress * 40);
    bodyPath.lineTo(center.dx + 15 * scale, center.dy - 60 + progress * 40);
    bodyPath.lineTo(center.dx + 10 * scale, center.dy - 30 + progress * 40);
    bodyPath.lineTo(center.dx - 10 * scale, center.dy - 30 + progress * 40);
    bodyPath.close();

    canvas.drawPath(bodyPath, bodyPaint);

    // 집게 팔
    final armPaint = Paint()
      ..color = clawColor.withValues(alpha: opacity)
      ..strokeWidth = 4 * scale
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // 왼쪽 팔
    final leftAngle = -0.5 + progress * 0.3;
    canvas.drawLine(
      Offset(center.dx - 8 * scale, center.dy - 30 + progress * 40),
      Offset(
        center.dx - 20 * scale + cos(leftAngle) * 25 * scale,
        center.dy - 10 + progress * 40 + sin(leftAngle).abs() * 15 * scale,
      ),
      armPaint,
    );

    // 오른쪽 팔
    final rightAngle = 0.5 - progress * 0.3;
    canvas.drawLine(
      Offset(center.dx + 8 * scale, center.dy - 30 + progress * 40),
      Offset(
        center.dx + 20 * scale + cos(rightAngle) * 25 * scale,
        center.dy - 10 + progress * 40 + sin(rightAngle).abs() * 15 * scale,
      ),
      armPaint,
    );

    // 줄
    final ropePaint = Paint()
      ..color = Colors.grey.shade600.withValues(alpha: opacity)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(center.dx, 0),
      Offset(center.dx, center.dy - 60 + progress * 40),
      ropePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CrosshairPainter oldDelegate) => true;
}
