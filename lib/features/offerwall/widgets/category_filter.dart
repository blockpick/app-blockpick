import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/offerwall/offerwall_models.dart';

/// 오퍼월 카테고리 필터 탭 바
class OfferwallCategoryFilter extends StatelessWidget {
  final OfferwallCategory? selected;
  final ValueChanged<OfferwallCategory?> onChanged;

  const OfferwallCategoryFilter({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final categories = [null, ...OfferwallCategory.values];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selected == cat;
          final label = cat == null
              ? '전체'
              : '${offerwallCategoryLabel(cat)} ${offerwallCategoryPointRange(cat)}';

          return _FilterChip(
            label: label,
            isSelected: isSelected,
            onTap: () => onChanged(cat),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryMain : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? AppColors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }
}
