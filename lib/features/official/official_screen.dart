import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import 'components/accordion/accordion_samples_screen.dart';
import 'components/checkbox/checkbox_samples_screen.dart';
import 'components/slider/slider_samples_screen.dart';
import 'components/list/list_samples_screen.dart';
import 'components/tabbar/tabbar_samples_screen.dart';

/// OFFICIAL 플랫폼 화면 (컴포넌트 라이브러리)
class OfficialScreen extends StatelessWidget {
  const OfficialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.buleGray),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.language,
                    size: 64,
                    color: AppColors.blue,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'OFFICIAL WEB',
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Service introduction & resources',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),

            // 컴포넌트 리스트
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildComponentCard(
                    context,
                    icon: Icons.tab,
                    title: 'TabBar',
                    description: '7가지 탭바 (iOS/Material/카카오/네이버)',
                    color: AppColors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TabBarSamplesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildComponentCard(
                    context,
                    icon: Icons.expand_more,
                    title: 'Accordion',
                    description: '접고 펼치는 아코디언 컴포넌트',
                    color: AppColors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AccordionSamplesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildComponentCard(
                    context,
                    icon: Icons.check_box,
                    title: 'Checkbox',
                    description: '다양한 스타일의 체크박스',
                    color: AppColors.green500,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CheckboxSamplesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildComponentCard(
                    context,
                    icon: Icons.tune,
                    title: 'Slider',
                    description: '값을 조절하는 슬라이더',
                    color: AppColors.yellow500,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SliderSamplesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildComponentCard(
                    context,
                    icon: Icons.list,
                    title: 'List',
                    description: '다양한 형태의 리스트',
                    color: AppColors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ListSamplesScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.medium,
            ),
          ],
        ),
      ),
    );
  }
}
