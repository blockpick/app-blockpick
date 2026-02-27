import 'dart:math';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// 팡팡 터지는 축하 효과 위젯
class ConfettiCelebration extends StatefulWidget {
  final VoidCallback? onComplete;
  final Duration duration;
  final int particleCount;

  const ConfettiCelebration({
    super.key,
    this.onComplete,
    this.duration = const Duration(milliseconds: 3000),
    this.particleCount = 100,
  });

  @override
  State<ConfettiCelebration> createState() => _ConfettiCelebrationState();

  /// 화면에 축하 효과 표시
  static OverlayEntry show(BuildContext context, {VoidCallback? onComplete}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => ConfettiCelebration(
        onComplete: () {
          entry.remove();
          onComplete?.call();
        },
      ),
    );

    overlay.insert(entry);
    return entry;
  }
}

class _ConfettiCelebrationState extends State<ConfettiCelebration>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _particles = List.generate(widget.particleCount, (_) => _createParticle());

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

    _controller.forward();
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble() * 0.3,
      vx: (_random.nextDouble() - 0.5) * 2,
      vy: -_random.nextDouble() * 3 - 1,
      rotation: _random.nextDouble() * 360,
      rotationSpeed: (_random.nextDouble() - 0.5) * 720,
      color: _colors[_random.nextInt(_colors.length)],
      size: _random.nextDouble() * 8 + 4,
      shape: _random.nextInt(3),
    );
  }

  static const _colors = [
    AppColors.red,
    AppColors.yellow,
    AppColors.mint,
    AppColors.blue,
    AppColors.mint,
    AppColors.primaryLight,
    AppColors.yellow,
    AppColors.mint,
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(
              particles: _particles,
              progress: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double rotation;
  double rotationSpeed;
  Color color;
  double size;
  int shape; // 0: circle, 1: square, 2: star

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.rotation,
    required this.rotationSpeed,
    required this.color,
    required this.size,
    required this.shape,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ConfettiPainter({
    required this.particles,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gravity = 2.0;
    final friction = 0.98;

    for (final p in particles) {
      // 물리 시뮬레이션
      final t = progress;
      final x = p.x + p.vx * t * friction;
      final y = p.y + p.vy * t + gravity * t * t;
      final rotation = p.rotation + p.rotationSpeed * t;

      // 화면 밖이면 스킵
      if (y > 1.2) continue;

      final px = x * size.width;
      final py = y * size.height;

      // 페이드 아웃
      final alpha = (1 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.save();
      canvas.translate(px, py);
      canvas.rotate(rotation * pi / 180);

      switch (p.shape) {
        case 0: // 원
          canvas.drawCircle(Offset.zero, p.size / 2, paint);
          break;
        case 1: // 사각형
          canvas.drawRect(
            Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size),
            paint,
          );
          break;
        case 2: // 별
          _drawStar(canvas, p.size / 2, paint);
          break;
      }

      canvas.restore();
    }
  }

  void _drawStar(Canvas canvas, double radius, Paint paint) {
    final path = Path();
    final innerRadius = radius * 0.4;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final r = i.isEven ? radius : innerRadius;
      final angle = (i * pi / points) - pi / 2;
      final x = r * cos(angle);
      final y = r * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
