import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import 'widgets/tabbar_sample_1.dart';
import 'widgets/tabbar_sample_2.dart';
import 'widgets/tabbar_sample_3.dart';
import 'widgets/tabbar_sample_4.dart';
import 'widgets/tabbar_sample_5.dart';
import 'widgets/tabbar_sample_6.dart';
import 'widgets/tabbar_sample_7.dart';

/// 탭바 샘플 리스트 화면
class TabBarSamplesScreen extends StatelessWidget {
  const TabBarSamplesScreen({super.key});

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
          'TabBar Samples',
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
          _buildSampleCard(
            context,
            number: 1,
            title: 'Neon Glow TabBar',
            description: '(실험) 네온 글로우 효과',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample1(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 2,
            title: '3D Floating TabBar',
            description: '(실험) 3D 플로팅 효과',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample2(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 3,
            title: 'Liquid Swipe TabBar',
            description: '(실험) 액체 애니메이션',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample3(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 4,
            title: 'iOS Segmented Control',
            description: 'iOS 스타일 세그먼트 컨트롤',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample4(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 5,
            title: 'Material 3 TabBar',
            description: 'Material Design 3 스타일',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample5(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 6,
            title: '카카오톡 스타일',
            description: '하단 탭바 + 뱃지',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample6(),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildSampleCard(
            context,
            number: 7,
            title: '네이버 스타일',
            description: 'Underline TabBar',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TabBarSample7(),
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
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blue.withValues(alpha: 0.1),
              AppColors.purple.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            width: 2,
            color: AppColors.blue.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.blue, AppColors.purple],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.5),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  '#$number',
                  style: AppTextStyles.bodyLarge.copyWith(
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
                    style: AppTextStyles.large.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 20,
              color: AppColors.blue,
            ),
          ],
        ),
      ),
    );
  }
}
