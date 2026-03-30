import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 슬라이더 샘플 #3 - 그라데이션 + 글로우 효과
class SliderSample3 extends StatefulWidget {
  const SliderSample3({super.key});

  @override
  State<SliderSample3> createState() => _SliderSample3State();
}

class _SliderSample3State extends State<SliderSample3>
    with SingleTickerProviderStateMixin {
  double _energyValue = 80;
  double _moodValue = 70;
  double _focusValue = 55;

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Slider #3',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.buleGray,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 설명
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.gradientBluePurplePink,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '그라데이션 슬라이더\n• 글로우 효과\n• 화려한 애니메이션',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Energy 슬라이더
          _buildGradientSlider(
            label: 'Energy',
            icon: Icons.bolt,
            value: _energyValue,
            gradient: LinearGradient(
              colors: [AppColors.yellow500, AppColors.pink],
            ),
            onChanged: (value) {
              setState(() {
                _energyValue = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Mood 슬라이더
          _buildGradientSlider(
            label: 'Mood',
            icon: Icons.sentiment_satisfied_alt,
            value: _moodValue,
            gradient: LinearGradient(
              colors: [AppColors.blue, AppColors.purple],
            ),
            onChanged: (value) {
              setState(() {
                _moodValue = value;
              });
            },
          ),
          const SizedBox(height: 24),

          // Focus 슬라이더
          _buildGradientSlider(
            label: 'Focus',
            icon: Icons.center_focus_strong,
            value: _focusValue,
            gradient: LinearGradient(
              colors: [AppColors.green500, AppColors.blue],
            ),
            onChanged: (value) {
              setState(() {
                _focusValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGradientSlider({
    required String label,
    required IconData icon,
    required double value,
    required Gradient gradient,
    required ValueChanged<double> onChanged,
  }) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            boxShadow: [
              BoxShadow(
                color: (gradient as LinearGradient)
                    .colors
                    .first
                    .withValues(alpha: 0.3 + (_glowController.value * 0.3)),
                blurRadius: 20 + (_glowController.value * 10),
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // 글로우 아이콘
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white
                              .withValues(alpha: 0.5 + (_glowController.value * 0.3)),
                          blurRadius: 12 + (_glowController.value * 8),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      label,
                      style: AppTextStyles.heading1.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  // 값 표시 with 글로우
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white
                              .withValues(alpha: 0.4 + (_glowController.value * 0.2)),
                          blurRadius: 8 + (_glowController.value * 4),
                        ),
                      ],
                    ),
                    child: Text(
                      '${value.toInt()}%',
                      style: AppTextStyles.display1.copyWith(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // 커스텀 슬라이더
              Stack(
                children: [
                  // 배경 트랙
                  Container(
                    height: 16,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  // 활성 트랙
                  FractionallySizedBox(
                    widthFactor: value / 100,
                    child: Container(
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white
                                .withValues(alpha: 0.6 + (_glowController.value * 0.2)),
                            blurRadius: 12 + (_glowController.value * 6),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 슬라이더
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.transparent,
                      inactiveTrackColor: Colors.transparent,
                      thumbColor: AppColors.white,
                      thumbShape: _GlowThumbShape(_glowController),
                      overlayColor: AppColors.white.withValues(alpha: 0.2),
                      trackHeight: 16,
                    ),
                    child: Slider(
                      value: value,
                      min: 0,
                      max: 100,
                      onChanged: onChanged,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // 진행 바 인디케이터
              Row(
                children: List.generate(10, (index) {
                  final isActive = (value / 10) > index;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GlowThumbShape extends SliderComponentShape {
  final AnimationController glowController;

  const _GlowThumbShape(this.glowController);

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(36, 36);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;
    final glowValue = glowController.value;

    // 외부 글로우
    canvas.drawCircle(
      center,
      18 + (glowValue * 6),
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.3 - (glowValue * 0.2))
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          8 + (glowValue * 4),
        ),
    );

    // 메인 원
    canvas.drawCircle(
      center,
      18,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill,
    );

    // 내부 원
    canvas.drawCircle(
      center,
      12,
      Paint()
        ..color = AppColors.white.withValues(alpha: 0.5)
        ..style = PaintingStyle.fill,
    );

    // 중심점
    canvas.drawCircle(
      center,
      6,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill,
    );
  }
}
