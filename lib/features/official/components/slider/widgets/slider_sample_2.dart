import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 슬라이더 샘플 #2 - 커스텀 트랙 디자인 + 포인터 애니메이션
class SliderSample2 extends StatefulWidget {
  const SliderSample2({super.key});

  @override
  State<SliderSample2> createState() => _SliderSample2State();
}

class _SliderSample2State extends State<SliderSample2> {
  double _progressValue = 60;
  double _ratingValue = 3.5;
  double _priceValue = 50000;

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
          'Slider #2',
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
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '커스텀 트랙 슬라이더\n• 포인터 애니메이션\n• 독특한 디자인',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 프로그레스 슬라이더
          _buildProgressSlider(),
          const SizedBox(height: 24),

          // 별점 슬라이더
          _buildRatingSlider(),
          const SizedBox(height: 24),

          // 가격 범위 슬라이더
          _buildPriceSlider(),
        ],
      ),
    );
  }

  Widget _buildProgressSlider() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.purple],
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '진행률',
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              Text(
                '${_progressValue.toInt()}%',
                style: AppTextStyles.display1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.white,
              inactiveTrackColor: AppColors.white.withValues(alpha: 0.3),
              thumbColor: AppColors.white,
              thumbShape: const _CustomThumbShape(),
              overlayColor: AppColors.white.withValues(alpha: 0.3),
              trackHeight: 12,
            ),
            child: Slider(
              value: _progressValue,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _progressValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSlider() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.buleGray, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '별점',
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < _ratingValue.floor()
                          ? Icons.star
                          : (index < _ratingValue ? Icons.star_half : Icons.star_outline),
                      color: AppColors.yellow500,
                      size: 28,
                    );
                  }),
                  const SizedBox(width: 8),
                  Text(
                    _ratingValue.toStringAsFixed(1),
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.yellow500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.yellow500,
              inactiveTrackColor: AppColors.yellow500.withValues(alpha: 0.2),
              thumbColor: AppColors.yellow500,
              thumbShape: const _StarThumbShape(),
              overlayColor: AppColors.yellow500.withValues(alpha: 0.2),
              trackHeight: 10,
            ),
            child: Slider(
              value: _ratingValue,
              min: 0,
              max: 5,
              divisions: 10,
              onChanged: (value) {
                setState(() {
                  _ratingValue = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSlider() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '가격 범위',
            style: AppTextStyles.heading1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '₩${(_priceValue * 1000).toInt().toString().replaceAllMapped(
                  RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                  (Match m) => '${m[1]},',
                )}',
            style: AppTextStyles.display1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.green500,
            ),
          ),
          const SizedBox(height: 20),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.green500,
              inactiveTrackColor: AppColors.green500.withValues(alpha: 0.2),
              thumbColor: AppColors.green500,
              thumbShape: const _PriceThumbShape(),
              overlayColor: AppColors.green500.withValues(alpha: 0.2),
              trackHeight: 14,
            ),
            child: Slider(
              value: _priceValue,
              min: 0,
              max: 100,
              onChanged: (value) {
                setState(() {
                  _priceValue = value;
                });
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '₩0',
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.medium,
                ),
              ),
              Text(
                '₩100,000',
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// 커스텀 Thumb 모양들
class _CustomThumbShape extends SliderComponentShape {
  const _CustomThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(28, 28);
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

    // 외부 원
    canvas.drawCircle(
      center,
      14,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill,
    );

    // 내부 원
    canvas.drawCircle(
      center,
      8,
      Paint()
        ..color = AppColors.blue
        ..style = PaintingStyle.fill,
    );
  }
}

class _StarThumbShape extends SliderComponentShape {
  const _StarThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(32, 32);
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

    // 별 모양 그리기
    final paint = Paint()
      ..color = AppColors.yellow500
      ..style = PaintingStyle.fill;

    final path = Path();
    const outerRadius = 16.0;
    const innerRadius = 8.0;
    const points = 5;

    for (int i = 0; i < points * 2; i++) {
      final radius = i.isEven ? outerRadius : innerRadius;
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  double cos(double angle) => angle.isFinite ? angle * 180 / 3.14159 : 0;
  double sin(double angle) => angle.isFinite ? angle * 180 / 3.14159 : 0;
}

class _PriceThumbShape extends SliderComponentShape {
  const _PriceThumbShape();

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return const Size(32, 32);
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

    // 다이아몬드 모양
    final paint = Paint()
      ..color = AppColors.green500
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(center.dx, center.dy - 16);
    path.lineTo(center.dx + 16, center.dy);
    path.lineTo(center.dx, center.dy + 16);
    path.lineTo(center.dx - 16, center.dy);
    path.close();

    canvas.drawPath(path, paint);

    // 테두리
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }
}
