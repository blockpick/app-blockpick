import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wish_model.dart';

/// Step 4: 카테고리 선택
class WishStepCategory extends StatefulWidget {
  final WishCategory? selected;
  final void Function(WishCategory category) onNext;

  const WishStepCategory({
    super.key,
    this.selected,
    required this.onNext,
  });

  @override
  State<WishStepCategory> createState() => _WishStepCategoryState();
}

class _WishStepCategoryState extends State<WishStepCategory> {
  WishCategory? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '카테고리를 선택해주세요',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),
          // 카테고리 그리드
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: WishCategory.values.length,
              itemBuilder: (context, index) {
                final cat = WishCategory.values[index];
                final isSelected = _selected == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selected = cat),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBg : AppColors.gray100,
                      borderRadius: BorderRadius.circular(16),
                      border: isSelected
                          ? Border.all(color: AppColors.primary, width: 2)
                          : Border.all(color: AppColors.gray200, width: 1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          cat.emoji,
                          style: const TextStyle(fontSize: 28),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          cat.label.split('/').first,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.primary : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 16),
          // 선택된 카테고리 표시
          if (_selected != null)
            Center(
              child: Text(
                '선택: ${_selected!.emoji} ${_selected!.label}',
                style: AppTextStyles.title3.copyWith(color: AppColors.primary),
              ),
            ),
          const SizedBox(height: 16),
          // 다음 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected != null ? () => widget.onNext(_selected!) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                disabledBackgroundColor: AppColors.gray200,
                disabledForegroundColor: AppColors.gray400,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: const Text(
                '다음 →',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
