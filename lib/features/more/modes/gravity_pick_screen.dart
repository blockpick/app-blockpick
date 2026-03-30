import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Gravity Pick - 폰을 기울여서 구슬 굴리기
class GravityPickScreen extends StatefulWidget {
  const GravityPickScreen({super.key});

  @override
  State<GravityPickScreen> createState() => _GravityPickScreenState();
}

class _GravityPickScreenState extends State<GravityPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.primaryMain;
  static const int gridSize = 1000;

  // 물리 시뮬레이션 변수
  double _ballX = 0.5;
  double _ballY = 0.5;
  double _velocityX = 0;
  double _velocityY = 0;

  // 트레일 효과용
  final List<Offset> _trail = [];
  static const int maxTrailLength = 15;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _physicsTimer;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAccelerometer();
    _startPhysicsLoop();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _initAnimations() {
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _accelerometerSubscription?.cancel();
    _physicsTimer?.cancel();
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startAccelerometer() {
    _accelerometerSubscription = accelerometerEventStream().listen((event) {
      setState(() {
        // 중력 가속도 적용 (더 부드러운 반응)
        _velocityX += event.x * 0.003;
        _velocityY += event.y * 0.003;
      });
    });
  }

  void _startPhysicsLoop() {
    _physicsTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      setState(() {
        // 트레일 업데이트
        _trail.add(Offset(_ballX, _ballY));
        if (_trail.length > maxTrailLength) {
          _trail.removeAt(0);
        }

        // 마찰 적용 (더 자연스러운 감속)
        _velocityX *= 0.97;
        _velocityY *= 0.97;

        // 위치 업데이트
        final newX = (_ballX - _velocityX).clamp(0.02, 0.98);
        final newY = (_ballY + _velocityY).clamp(0.02, 0.98);

        // 벽 충돌 시 약간의 바운스
        if (newX == 0.02 || newX == 0.98) {
          _velocityX *= -0.5;
          HapticFeedback.lightImpact();
        }
        if (newY == 0.02 || newY == 0.98) {
          _velocityY *= -0.5;
          HapticFeedback.lightImpact();
        }

        _ballX = newX;
        _ballY = newY;
      });
    });
  }

  void _confirmPosition() {
    HapticFeedback.heavyImpact();
    final row = (_ballY * gridSize).round().clamp(1, gridSize);
    final col = (_ballX * gridSize).round().clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Gravity',
      modeColor: modeColor,
      onRetry: _resetBall,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _resetBall() {
    HapticFeedback.mediumImpact();
    setState(() {
      _ballX = 0.5;
      _ballY = 0.5;
      _velocityX = 0;
      _velocityY = 0;
      _trail.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRow = (_ballY * gridSize).round().clamp(1, gridSize);
    final currentCol = (_ballX * gridSize).round().clamp(1, gridSize);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'GRAVITY',
        emoji: '📱',
        accentColor: modeColor,
        actions: [
          GestureDetector(
            onTap: _resetBall,
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
        showGrid: true,
        showCoordinate: true,
        currentRow: currentRow,
        currentCol: currentCol,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final ballSize = 50.0;
            final areaWidth = constraints.maxWidth - ballSize;
            final areaHeight = constraints.maxHeight - ballSize - 200;
            final offsetTop = 120.0;

            return Stack(
              children: [
                // 트레일 효과
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxHeight),
                  painter: _TrailPainter(
                    trail: _trail,
                    color: modeColor,
                    areaWidth: areaWidth,
                    areaHeight: areaHeight,
                    offsetTop: offsetTop,
                    ballSize: ballSize,
                  ),
                ),

                // 구슬
                AnimatedBuilder(
                  animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
                  builder: (context, child) {
                    return Positioned(
                      left: _ballX * areaWidth,
                      top: offsetTop + _ballY * areaHeight,
                      child: Transform.scale(
                        scale: _pulseAnimation.value,
                        child: _buildBall(_glowAnimation.value),
                      ),
                    );
                  },
                ),

                // 하단 컨트롤 패널
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: _buildBottomPanel(),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBall(double glowIntensity) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white,
            modeColor.withValues(alpha: 0.9),
            modeColor,
          ],
          center: const Alignment(-0.3, -0.3),
          stops: const [0.0, 0.3, 1.0],
        ),
        boxShadow: [
          // 글로우 효과
          BoxShadow(
            color: modeColor.withValues(alpha: 0.6 * glowIntensity),
            blurRadius: 30 * glowIntensity,
            spreadRadius: 5 * glowIntensity,
          ),
          // 아래 그림자
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                Colors.white.withValues(alpha: 0.8),
                Colors.white.withValues(alpha: 0),
              ],
            ),
          ),
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
            28,
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
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border(
              top: BorderSide(
                color: modeColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 안내 텍스트
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.screen_rotation_rounded,
                      color: modeColor,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    'Tilt your phone to move the ball',
                    style: AppTextStyles.title3.copyWith(color: Colors.white.withValues(alpha: 0.7)),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 확정 버튼
              GestureDetector(
                onTap: _confirmPosition,
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'LOCK POSITION',
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
}

/// 트레일 효과 페인터
class _TrailPainter extends CustomPainter {
  final List<Offset> trail;
  final Color color;
  final double areaWidth;
  final double areaHeight;
  final double offsetTop;
  final double ballSize;

  _TrailPainter({
    required this.trail,
    required this.color,
    required this.areaWidth,
    required this.areaHeight,
    required this.offsetTop,
    required this.ballSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trail.length < 2) return;

    final path = Path();
    bool started = false;

    for (int i = 0; i < trail.length; i++) {
      final x = trail[i].dx * areaWidth + ballSize / 2;
      final y = offsetTop + trail[i].dy * areaHeight + ballSize / 2;

      if (!started) {
        path.moveTo(x, y);
        started = true;
      } else {
        path.lineTo(x, y);
      }
    }

    // 그라데이션 효과의 트레일
    for (int i = 0; i < trail.length - 1; i++) {
      final opacity = (i / trail.length) * 0.5;
      final strokeWidth = (i / trail.length) * 8 + 2;

      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final x1 = trail[i].dx * areaWidth + ballSize / 2;
      final y1 = offsetTop + trail[i].dy * areaHeight + ballSize / 2;
      final x2 = trail[i + 1].dx * areaWidth + ballSize / 2;
      final y2 = offsetTop + trail[i + 1].dy * areaHeight + ballSize / 2;

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TrailPainter oldDelegate) => true;
}
