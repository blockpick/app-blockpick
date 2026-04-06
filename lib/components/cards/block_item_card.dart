import 'package:flutter/material.dart';
import '../../models/block_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// 선택된 블록 아이템 카드 (기획 SC-009-17)
///
/// 체크박스(○/✓) + "X NNNN | Y NNNN" 좌표 + 삭제 아이콘
class BlockItemCard extends StatelessWidget {
  final BlockModel block;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool isFocused;
  final bool isChecked;
  final ValueChanged<bool>? onCheckedChanged;

  const BlockItemCard({
    super.key,
    required this.block,
    required this.onRemove,
    this.onTap,
    this.isFocused = false,
    this.isChecked = false,
    this.onCheckedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingMd,
          ),
          decoration: BoxDecoration(
            color: isChecked
                ? AppColors.blue.withValues(alpha: 0.05)
                : AppColors.primaryBg,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isChecked
                  ? AppColors.blue.withValues(alpha: 0.3)
                  : AppColors.gray200,
            ),
          ),
          child: Row(
            children: [
              // 체크박스 (원형)
              GestureDetector(
                onTap: () => onCheckedChanged?.call(!isChecked),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isChecked ? AppColors.blue : Colors.transparent,
                    border: Border.all(
                      color: isChecked ? AppColors.blue : AppColors.gray400,
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check, size: 16, color: AppColors.white)
                      : null,
                ),
              ),

              const SizedBox(width: AppConstants.spacingMd),

              // 좌표 정보 "X NNNN | Y NNNN"
              Expanded(
                child: Text(
                  'X ${block.col.toString().padLeft(4, '0')}  |  Y ${block.row.toString().padLeft(4, '0')}',
                  style: AppTextStyles.title2.copyWith(color: AppColors.textBlack),
                ),
              ),

              // 삭제 버튼 (휴지통 아이콘)
              GestureDetector(
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingXs),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppColors.gray400,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
