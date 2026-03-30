import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 체크박스 샘플 #2 - 카드형 + 스케일 애니메이션
class CheckboxSample2 extends StatefulWidget {
  const CheckboxSample2({super.key});

  @override
  State<CheckboxSample2> createState() => _CheckboxSample2State();
}

class _CheckboxSample2State extends State<CheckboxSample2> {
  final List<bool> _checkedStates = List.generate(6, (_) => false);

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
          'Checkbox #2',
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
              '카드형 체크박스\n• 선택 시 스케일 애니메이션\n• 그림자 효과',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 카드형 체크박스 그리드
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildCardCheckbox(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCardCheckbox(int index) {
    final isChecked = _checkedStates[index];
    final icons = [
      Icons.home,
      Icons.favorite,
      Icons.star,
      Icons.notifications,
      Icons.settings,
      Icons.person,
    ];
    final labels = ['홈', '좋아요', '별점', '알림', '설정', '프로필'];
    final colors = [
      AppColors.blue,
      AppColors.pink,
      AppColors.yellow500,
      AppColors.purple,
      AppColors.green500,
      AppColors.darkBlue,
    ];

    return GestureDetector(
      onTap: () {
        setState(() {
          _checkedStates[index] = !_checkedStates[index];
        });
      },
      child: AnimatedScale(
        scale: isChecked ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isChecked ? colors[index].withValues(alpha: 0.1) : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isChecked ? colors[index] : AppColors.buleGray,
              width: isChecked ? 2 : 1,
            ),
            boxShadow: isChecked
                ? [
                    BoxShadow(
                      color: colors[index].withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icons[index],
                size: 48,
                color: isChecked ? colors[index] : AppColors.medium,
              ),
              const SizedBox(height: 12),
              Text(
                labels[index],
                style: AppTextStyles.body2.copyWith(
                  fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                  color: isChecked ? colors[index] : AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isChecked ? colors[index] : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isChecked ? colors[index] : AppColors.medium,
                    width: 2,
                  ),
                ),
                child: isChecked
                    ? const Icon(
                        Icons.check,
                        size: 16,
                        color: AppColors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
