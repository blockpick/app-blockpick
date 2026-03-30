import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/event_prize.dart';

/// 이벤트 당첨 팝업
class EventPrizePopup extends StatefulWidget {
  final EventPrize prize;
  final VoidCallback onClose;

  const EventPrizePopup({
    super.key,
    required this.prize,
    required this.onClose,
  });

  /// 팝업 표시
  static Future<void> show(
    BuildContext context, {
    required EventPrize prize,
    required VoidCallback onContinue,
  }) {
    HapticFeedback.heavyImpact();

    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return EventPrizePopup(
          prize: prize,
          onClose: () {
            Navigator.of(context).pop();
            onContinue();
          },
        );
      },
    );
  }

  @override
  State<EventPrizePopup> createState() => _EventPrizePopupState();
}

class _EventPrizePopupState extends State<EventPrizePopup>
    with TickerProviderStateMixin {
  late AnimationController _shineController;
  late AnimationController _bounceController;
  late AnimationController _particleController;
  late List<_Particle> _particles;
  final _random = Random();
  final _priceFormatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _particles = List.generate(30, (_) => _createParticle());
  }

  _Particle _createParticle() {
    return _Particle(
      x: _random.nextDouble(),
      y: _random.nextDouble(),
      size: _random.nextDouble() * 6 + 2,
      speed: _random.nextDouble() * 0.5 + 0.2,
      angle: _random.nextDouble() * 2 * pi,
    );
  }

  @override
  void dispose() {
    _shineController.dispose();
    _bounceController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  Color get _gradeColor {
    final (r, g, b) = EventPrize.getGradeColor(widget.prize.grade);
    return Color.fromRGBO(r, g, b, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 파티클 효과
          AnimatedBuilder(
            animation: _particleController,
            builder: (context, _) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _ParticlePainter(
                  particles: _particles,
                  progress: _particleController.value,
                  color: _gradeColor,
                ),
              );
            },
          ),

          // 메인 팝업
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 축하 텍스트
                  _buildCongratulationsText(),
                  const SizedBox(height: 24),

                  // 상품 카드
                  _buildPrizeCard(),

                  const SizedBox(height: 24),

                  // 확인 버튼
                  _buildConfirmButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationsText() {
    return AnimatedBuilder(
      animation: _bounceController,
      builder: (context, child) {
        final scale = 1.0 + _bounceController.value * 0.05;
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Column(
        children: [
          // 이모지 애니메이션
          Text(
            '🎉',
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                colors: [
                  _gradeColor,
                  _gradeColor.withValues(alpha: 0.7),
                  _gradeColor,
                ],
                stops: [
                  0.0,
                  _shineController.value,
                  1.0,
                ],
              ).createShader(bounds);
            },
            child: const Text(
              '보너스 당첨!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCard() {
    return AnimatedBuilder(
      animation: _shineController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: _gradeColor.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // 카드 배경
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        _gradeColor.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      // 등급 배지 (기본값 common이 아닌 경우에만 표시)
                      if (widget.prize.grade != PrizeGrade.common) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _gradeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            EventPrize.getGradeName(widget.prize.grade),
                            style: AppTextStyles.caption3.copyWith(color: Colors.white),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // 상품 이미지 또는 이모지 (폴백)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _gradeColor.withValues(alpha: 0.1),
                          border: Border.all(
                            color: _gradeColor.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: widget.prize.hasImage
                              ? ClipOval(
                                  child: Image.network(
                                    widget.prize.displayImageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Text(
                                      widget.prize.emoji,
                                      style: const TextStyle(fontSize: 48),
                                    ),
                                  ),
                                )
                              : Text(
                                  widget.prize.emoji,
                                  style: const TextStyle(fontSize: 48),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 상품명
                      Text(
                        widget.prize.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 설명
                      if (widget.prize.description.isNotEmpty)
                        Text(
                          widget.prize.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      if (widget.prize.description.isNotEmpty)
                        const SizedBox(height: 16),

                      // 가치 (0보다 클 때만 표시)
                      if (widget.prize.value > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.monetization_on_rounded,
                                size: 20,
                                color: _gradeColor,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${_priceFormatter.format(widget.prize.value)}원 상당',
                                style: AppTextStyles.buttonLarge.copyWith(color: _gradeColor),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                // 빛나는 효과
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _shineController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _ShinePainter(
                            progress: _shineController.value,
                            color: _gradeColor,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: widget.onClose,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _gradeColor,
              _gradeColor.withValues(alpha: 0.8),
            ],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: _gradeColor.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '계속하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}

/// 파티클 데이터
class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double angle;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.angle,
  });
}

/// 파티클 페인터
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color color;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      final t = (progress + p.speed) % 1.0;
      final x = p.x * size.width + cos(p.angle + t * 2 * pi) * 50;
      final y = (p.y + t) % 1.0 * size.height;
      final alpha = (1 - t).clamp(0.0, 1.0);

      paint.color = color.withValues(alpha: alpha * 0.6);
      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// 빛나는 효과 페인터
class _ShinePainter extends CustomPainter {
  final double progress;
  final Color color;

  _ShinePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final shineX = -size.width * 0.5 + size.width * 2 * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.2),
          Colors.white.withValues(alpha: 0.4),
          color.withValues(alpha: 0.2),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(shineX, 0, size.width * 0.5, size.height));

    canvas.drawRect(
      Rect.fromLTWH(shineX, 0, size.width * 0.5, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _ShinePainter oldDelegate) =>
      oldDelegate.progress != progress;
}
