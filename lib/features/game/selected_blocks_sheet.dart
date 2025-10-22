import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/block_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/grid_state_provider.dart';
import '../../components/sheets/draggable_bottom_sheet.dart';
import '../../components/cards/block_item_card.dart';
import '../../components/buttons/gradient_button.dart';

/// 선택된 블록 목록을 보여주는 바텀시트
class SelectedBlocksSheet extends ConsumerWidget {
  const SelectedBlocksSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBlocks = ref.watch(gridStateProvider).selectedBlocks;
    final gridNotifier = ref.read(gridStateProvider.notifier);

    if (selectedBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return DraggableBottomSheet(
      // 헤더: 선택된 블록 수 + CLEAR 버튼
      header: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  '${selectedBlocks.length} Blocks',
                  style: AppTextStyles.large.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'selected',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.medium,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () {
                gridNotifier.clearBlocks();
              },
              child: Text(
                'CLEAR',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.red,
                ),
              ),
            ),
          ],
        ),
      ),

      // 스크롤 가능한 블록 리스트
      children: selectedBlocks
          .map((block) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: BlockItemCard(
                  block: block,
                  onRemove: () => gridNotifier.toggleBlock(block),
                ),
              ))
          .toList(),

      // 하단 제출 버튼
      footer: GradientButton(
        label: 'Select blocks (${selectedBlocks.length}/pick)',
        icon: Icons.bolt,
        onPressed: () {
          // TODO: 블록 선택 제출
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${selectedBlocks.length} blocks submitted!'),
              backgroundColor: AppColors.green,
            ),
          );
        },
      ),

      // 바텀시트 설정
      initialChildSize: 0.4,
      minChildSize: 0.1,
      maxChildSize: 0.7,
      snapSizes: const [0.4, 0.7],

      // 바텀시트 닫힐 때 콜백
      onClose: () {
        gridNotifier.hideBottomSheet();
      },
    );
  }
}
