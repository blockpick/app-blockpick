import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../models/block_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 선택된 블록 아이템 카드 컴포넌트
///
/// 바텀시트나 리스트에서 선택된 블록을 표시할 때 재사용
class BlockItemCard extends StatelessWidget {
  final BlockModel block;
  final VoidCallback onRemove;
  final VoidCallback? onTap;
  final bool isFocused;

  const BlockItemCard({
    super.key,
    required this.block,
    required this.onRemove,
    this.onTap,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.blueWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.buleGray),
          ),
          child: Row(
            children: [
              // 블록 아이콘 (상태별)
              _buildBlockIcon(block.state),

              const SizedBox(width: 12),

              // 블록 위치 정보
              Expanded(
                child: Text(
                  '${block.row} Row, ${block.col} Column',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              // 삭제 버튼
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                color: AppColors.medium,
                onPressed: onRemove,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 블록 상태별 아이콘
  Widget _buildBlockIcon(BlockState state) {
    String iconPath;

    // 🎯 포커스된 블록이면 list-selected.svg 사용
    if (isFocused) {
      iconPath = 'assets/icons/pick/list-selected.svg';
    } else {
      switch (state) {
        case BlockState.selected:
          iconPath = 'assets/icons/pick/selected.svg';
          break;
        case BlockState.past:
          iconPath = 'assets/icons/pick/past.svg';
          break;
        default:
          iconPath = 'assets/icons/pick/selected.svg';
      }
    }

    return SizedBox(
      width: 24,
      height: 24,
      child: SvgPicture.asset(
        iconPath,
        width: 24,
        height: 24,
      ),
    );
  }
}
