import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import 'widgets/checkbox_sample_1.dart';
import 'widgets/checkbox_sample_2.dart';
import 'widgets/checkbox_sample_3.dart';

/// 체크박스 샘플 리스트 화면
class CheckboxSamplesScreen extends StatelessWidget {
  const CheckboxSamplesScreen({super.key});

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
          'Checkbox Samples',
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
          _buildSampleCard(
            context,
            number: 1,
            title: 'Standard Checkbox',
            description: '기본 체크박스 + 체크 애니메이션',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckboxSample1(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 2,
            title: 'Card Checkbox',
            description: '카드형 체크박스 + 스케일 애니메이션',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckboxSample2(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 3,
            title: 'Custom Icon Checkbox',
            description: '커스텀 아이콘 + 리플 애니메이션',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckboxSample3(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSampleCard(
    BuildContext context, {
    required int number,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.buleGray),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.green500,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Center(
                child: Text(
                  '#$number',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppColors.medium,
            ),
          ],
        ),
      ),
    );
  }
}
