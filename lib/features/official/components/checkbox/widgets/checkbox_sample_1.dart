import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 체크박스 샘플 #1 - 기본 스타일 + 체크 애니메이션
class CheckboxSample1 extends StatefulWidget {
  const CheckboxSample1({super.key});

  @override
  State<CheckboxSample1> createState() => _CheckboxSample1State();
}

class _CheckboxSample1State extends State<CheckboxSample1> {
  final List<bool> _checkedStates = List.generate(8, (index) => index % 2 == 0);

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
          'Checkbox #1',
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
              color: AppColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '기본 체크박스 스타일\n• 부드러운 체크 애니메이션\n• 다양한 색상 지원',
              style: AppTextStyles.body.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 체크박스 리스트
          ...List.generate(8, (index) {
            final colors = [
              AppColors.blue,
              AppColors.green,
              AppColors.yellow,
              AppColors.purple,
              AppColors.pink,
              AppColors.darkBlue,
              AppColors.navy,
              AppColors.blue,
            ];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCheckboxItem(
                index: index,
                label: '옵션 ${index + 1}',
                color: colors[index],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required int index,
    required String label,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: _checkedStates[index] ? color : AppColors.buleGray,
        ),
      ),
      child: CheckboxListTile(
        value: _checkedStates[index],
        onChanged: (value) {
          setState(() {
            _checkedStates[index] = value ?? false;
          });
        },
        title: Text(
          label,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: _checkedStates[index] ? FontWeight.bold : FontWeight.normal,
            color: _checkedStates[index] ? color : AppColors.darkBlue,
          ),
        ),
        subtitle: Text(
          _checkedStates[index] ? '선택됨' : '선택 안 됨',
          style: AppTextStyles.body.copyWith(
            color: AppColors.medium,
          ),
        ),
        activeColor: color,
        checkColor: AppColors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }
}
