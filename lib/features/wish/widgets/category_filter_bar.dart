import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/wish_model.dart';

/// 소원 카테고리 필터 바 (수평 스크롤)
class CategoryFilterBar extends StatelessWidget {
  final WishCategory? selected;
  final ValueChanged<WishCategory?> onSelected;

  const CategoryFilterBar({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip(
            label: '전체',
            emoji: '✨',
            isSelected: selected == null,
            onTap: () => onSelected(null),
          ),
          ...WishCategory.values.map((cat) => _FilterChip(
                label: cat.label.split('/').first, // "식품/음료" → "식품"
                emoji: cat.emoji,
                isSelected: selected == cat,
                onTap: () => onSelected(cat),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.gray100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.white : AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
