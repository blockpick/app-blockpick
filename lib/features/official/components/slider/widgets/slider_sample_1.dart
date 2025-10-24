import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 슬라이더 샘플 #1 - 기본 스타일 + 값 표시
class SliderSample1 extends StatefulWidget {
  const SliderSample1({super.key});

  @override
  State<SliderSample1> createState() => _SliderSample1State();
}

class _SliderSample1State extends State<SliderSample1> {
  double _volumeValue = 50;
  double _brightnessValue = 75;
  double _temperatureValue = 22;
  double _speedValue = 30;

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
          'Slider #1',
          style: AppTextStyles.large.copyWith(
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
              color: AppColors.yellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '기본 슬라이더 스타일\n• 실시간 값 표시\n• 다양한 색상 지원',
              style: AppTextStyles.body.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 볼륨 슬라이더
          _buildSliderCard(
            icon: Icons.volume_up,
            label: '볼륨',
            value: _volumeValue,
            color: AppColors.blue,
            unit: '%',
            onChanged: (value) {
              setState(() {
                _volumeValue = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 밝기 슬라이더
          _buildSliderCard(
            icon: Icons.brightness_6,
            label: '밝기',
            value: _brightnessValue,
            color: AppColors.yellow,
            unit: '%',
            onChanged: (value) {
              setState(() {
                _brightnessValue = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 온도 슬라이더
          _buildSliderCard(
            icon: Icons.thermostat,
            label: '온도',
            value: _temperatureValue,
            color: AppColors.pink,
            unit: '°C',
            min: 16,
            max: 30,
            onChanged: (value) {
              setState(() {
                _temperatureValue = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 속도 슬라이더
          _buildSliderCard(
            icon: Icons.speed,
            label: '속도',
            value: _speedValue,
            color: AppColors.green,
            unit: 'km/h',
            max: 120,
            onChanged: (value) {
              setState(() {
                _speedValue = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required String unit,
    double min = 0,
    double max = 100,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.buleGray),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.large.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              // 값 표시
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Text(
                  '${value.toInt()}$unit',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor: color.withValues(alpha: 0.2),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.2),
              trackHeight: 8,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              onChanged: onChanged,
            ),
          ),
          // Min/Max 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${min.toInt()}$unit',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.medium,
                ),
              ),
              Text(
                '${max.toInt()}$unit',
                style: AppTextStyles.body.copyWith(
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
