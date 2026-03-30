import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 당첨자/리뷰 필터 드롭다운
class WinnersFilterDropdown<T> extends StatelessWidget {
  final T? value;
  final List<T?> items;
  final String Function(T?) labelBuilder;
  final ValueChanged<T?> onChanged;

  const WinnersFilterDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T?>(
      onSelected: onChanged,
      offset: Offset(0, 40),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      color: AppColors.white,
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.bgWhite),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              labelBuilder(value),
              style: AppTextStyles.body3.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 20,
              color: AppColors.darkBlue,
            ),
          ],
        ),
      ),
      itemBuilder: (context) {
        return items.map((item) {
          final isSelected = item == value;
          return PopupMenuItem<T?>(
            value: item,
            child: Row(
              children: [
                Text(
                  labelBuilder(item),
                  style: AppTextStyles.body3.copyWith(
                    color: isSelected ? AppColors.blue : AppColors.darkBlue,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                if (isSelected) ...[
                  const Spacer(),
                  const Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.blue,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
