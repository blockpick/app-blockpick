import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import 'widgets/accordion_sample_1.dart';
import 'widgets/accordion_sample_2.dart';
import 'widgets/accordion_sample_3.dart';

/// 아코디언 샘플 리스트 화면
class AccordionSamplesScreen extends StatelessWidget {
  const AccordionSamplesScreen({super.key});

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
          'Accordion Samples',
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
            title: 'Basic Accordion',
            description: '기본적인 아코디언 (부드러운 애니메이션)',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccordionSample1(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 2,
            title: 'Card Style Accordion',
            description: '카드 스타일 + 회전 애니메이션 아이콘',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccordionSample2(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 3,
            title: 'Gradient Accordion',
            description: '그라데이션 + 슬라이드 애니메이션',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AccordionSample3(),
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
                color: AppColors.blue,
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
