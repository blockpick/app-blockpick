import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 아코디언 샘플 #1 - 기본 스타일 + 부드러운 애니메이션
class AccordionSample1 extends StatefulWidget {
  const AccordionSample1({super.key});

  @override
  State<AccordionSample1> createState() => _AccordionSample1State();
}

class _AccordionSample1State extends State<AccordionSample1> {
  final List<bool> _expandedStates = List.generate(5, (_) => false);

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
          'Accordion #1',
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
              color: AppColors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '기본적인 아코디언 스타일\n• 부드러운 expand/collapse 애니메이션\n• 심플한 디자인',
              style: AppTextStyles.body.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 아코디언 아이템들
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAccordionItem(
                index: index,
                title: '아코디언 항목 ${index + 1}',
                content: '이것은 아코디언 항목 ${index + 1}의 내용입니다. '
                    '펼쳐지고 접히는 애니메이션이 부드럽게 동작합니다. '
                    'ExpansionTile 위젯을 사용하여 구현되었습니다.',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required String title,
    required String content,
  }) {
    final isExpanded = _expandedStates[index];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: isExpanded ? AppColors.blue : AppColors.buleGray,
          width: isExpanded ? 2 : 1,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: isExpanded ? AppColors.blue : AppColors.darkBlue,
            ),
          ),
          trailing: Icon(
            isExpanded ? Icons.remove : Icons.add,
            color: isExpanded ? AppColors.blue : AppColors.medium,
          ),
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedStates[index] = expanded;
            });
          },
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.radiusMd),
                  bottomRight: Radius.circular(AppConstants.radiusMd),
                ),
              ),
              child: Text(
                content,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.navy,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
