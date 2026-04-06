import 'dart:async';
import '../../../core/constants/app_constants.dart';
import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Wave Pick - 파동이 퍼져나가는 곳이 좌표
class WavePickScreen extends StatefulWidget {
  const WavePickScreen({super.key});

  @override
  State<WavePickScreen> createState() => _WavePickScreenState();
}

class _WavePickScreenState extends State<WavePickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.blue;
  static const int gridSize = 1000;

  final List<_Wave> _waves = [];
  Timer? _updateTimer;
  Size? _canvasSize;
  Offset? _lastTapPosition;
  final _random = Random();
  int _waveCount = 0;

  @override
  void initState() {
    super.initState();
    _startUpdateLoop();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    for (final wave in _waves) {
      wave.controller.dispose();
    }
    super.dispose();
  }

  void _startUpdateLoop() {
    _updateTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        _waves.removeWhere((wave) => wave.controller.isCompleted);
      });
    });
  }

  void _onTap(TapDownDetails details) {
    HapticFeedback.lightImpact();

    final controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500 + _random.nextInt(1000)),
    );

    final wave = _Wave(
      center: details.localPosition,
      controller: controller,
      maxRadius: 350 + _random.nextDouble() * 150,
      color: HSLColor.fromColor(modeColor)
          .withHue(180 + _random.nextDouble() * 40)
          .toColor(),
    );

    setState(() {
      _waves.add(wave);
      _lastTapPosition = details.localPosition;
      _waveCount++;
    });

    controller.forward();
  }

  void _confirmWave() {
    if (_lastTapPosition == null || _canvasSize == null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tap to create waves first!'),
          backgroundColor: modeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    final row = ((_lastTapPosition!.dy / _canvasSize!.height) * gridSize)
        .round()
        .clamp(1, gridSize);
    final col = ((_lastTapPosition!.dx / _canvasSize!.width) * gridSize)
        .round()
        .clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Wave',
      modeColor: modeColor,
      subtitle: 'Created from $_waveCount waves',
      onRetry: _clearWaves,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _clearWaves() {
    HapticFeedback.mediumImpact();
    for (final wave in _waves) {
      wave.controller.dispose();
    }
    setState(() {
      _waves.clear();
      _lastTapPosition = null;
      _waveCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRow = _lastTapPosition != null && _canvasSize != null
        ? ((_lastTapPosition!.dy / _canvasSize!.height) * gridSize)
            .round()
            .clamp(1, gridSize)
        : null;
    final currentCol = _lastTapPosition != null && _canvasSize != null
        ? ((_lastTapPosition!.dx / _canvasSize!.width) * gridSize)
            .round()
            .clamp(1, gridSize)
        : null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'WAVE',
        emoji: '🌊',
        accentColor: modeColor,
        actions: [
          if (_waves.isNotEmpty || _lastTapPosition != null)
            GestureDetector(
              onTap: _clearWaves,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusBottomSheet),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'RESET',
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
        showCoordinate: currentRow != null && currentCol != null,
        currentRow: currentRow,
        currentCol: currentCol,
        child: Column(
          children: [
            // 파동 캔버스
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      modeColor.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.5),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  border: Border.all(
                    color: modeColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  child: Stack(
                    children: [
                      // 배경 패턴
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return CustomPaint(
                            size: Size(constraints.maxWidth, constraints.maxHeight),
                            painter: _WaterBackgroundPainter(modeColor),
                          );
                        },
                      ),

                      // 파동 영역
                      LayoutBuilder(
                        builder: (context, constraints) {
                          _canvasSize =
                              Size(constraints.maxWidth, constraints.maxHeight);
                          return GestureDetector(
                            onTapDown: _onTap,
                            behavior: HitTestBehavior.opaque,
                            child: AnimatedBuilder(
                              animation: Listenable.merge(
                                _waves.map((w) => w.controller).toList(),
                              ),
                              builder: (context, child) {
                                return CustomPaint(
                                  size: Size(
                                      constraints.maxWidth, constraints.maxHeight),
                                  painter: _WavePainter(
                                    waves: _waves,
                                    primaryColor: modeColor,
                                    lastTap: _lastTapPosition,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),

                      // 안내 텍스트
                      if (_waves.isEmpty && _lastTapPosition == null)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.touch_app_rounded,
                                size: 64,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tap to create ripples',
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
      borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radius2Xl)),
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
                  _buildStatChip(
                    Icons.waves_rounded,
                    '$_waveCount waves',
                  ),
                  const SizedBox(width: 16),
                  _buildStatChip(
                    Icons.radio_button_checked_rounded,
                    '${_waves.length} active',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 확정 버튼
              GestureDetector(
                onTap: _confirmWave,
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
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: modeColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.water_drop_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'LOCK RIPPLE CENTER',
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
        borderRadius: BorderRadius.circular(AppConstants.radiusBottomSheet),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: modeColor),
          SizedBox(width: 8),
          Text(
            text,
            style: AppTextStyles.caption2.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}

class _Wave {
  final Offset center;
  final AnimationController controller;
  final double maxRadius;
  final Color color;

  _Wave({
    required this.center,
    required this.controller,
    required this.maxRadius,
    required this.color,
  });

  double get radius => controller.value * maxRadius;
  double get opacity => (1 - controller.value).clamp(0.0, 1.0);
}

class _WaterBackgroundPainter extends CustomPainter {
  final Color color;

  _WaterBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // 물결 배경 패턴
    final paint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (double y = 0; y < size.height; y += 40) {
      final path = Path();
      path.moveTo(0, y);
      for (double x = 0; x < size.width; x += 20) {
        path.quadraticBezierTo(
          x + 10,
          y + (x ~/ 40 % 2 == 0 ? 5 : -5),
          x + 20,
          y,
        );
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _WavePainter extends CustomPainter {
  final List<_Wave> waves;
  final Color primaryColor;
  final Offset? lastTap;

  _WavePainter({
    required this.waves,
    required this.primaryColor,
    required this.lastTap,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 파동 그리기
    for (final wave in waves) {
      // 여러 개의 동심원
      for (int i = 0; i < 3; i++) {
        final radiusOffset = wave.radius - (i * 30);
        if (radiusOffset <= 0) continue;

        final opacity = wave.opacity * (1 - i * 0.3);
        final strokeWidth = 3.0 - i * 0.8;

        final paint = Paint()
          ..color = wave.color.withValues(alpha: opacity * 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth;

        canvas.drawCircle(wave.center, radiusOffset, paint);
      }

      // 글로우 효과
      if (wave.opacity > 0.5) {
        final glowPaint = Paint()
          ..color = wave.color.withValues(alpha: wave.opacity * 0.2)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

        canvas.drawCircle(wave.center, wave.radius * 0.3, glowPaint);
      }
    }

    // 마지막 탭 위치 표시
    if (lastTap != null) {
      // 외부 글로우
      final glowPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(lastTap!, 20, glowPaint);

      // 외부 원
      final outerPaint = Paint()
        ..color = primaryColor.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(lastTap!, 12, outerPaint);

      // 내부 원
      final innerPaint = Paint()
        ..color = primaryColor
        ..style = PaintingStyle.fill;

      canvas.drawCircle(lastTap!, 6, innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) => true;
}
