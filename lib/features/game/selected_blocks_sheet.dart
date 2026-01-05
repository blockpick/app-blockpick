import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/block_model.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/grid_state_provider.dart';
import '../../providers/game_participation_provider.dart';
import '../../components/cards/block_item_card.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';
import 'widgets/game_join_loading_overlay.dart';
import 'widgets/game_join_result_overlay.dart';

/// 선택된 블록 목록을 보여주는 바텀시트 (토스 스타일 애니메이션)
class SelectedBlocksSheet extends ConsumerStatefulWidget {
  final GridConfig gridConfig;
  final GameRound? game;
  final Game? fullGame; // 전체 게임 정보 (contract address, gameProducts)

  const SelectedBlocksSheet({
    super.key,
    required this.gridConfig,
    this.game,
    this.fullGame,
  });

  @override
  ConsumerState<SelectedBlocksSheet> createState() => _SelectedBlocksSheetState();
}

class _SelectedBlocksSheetState extends ConsumerState<SelectedBlocksSheet> {
  @override
  Widget build(BuildContext context) {
    final selectedBlocks = ref.watch(gridStateProvider(widget.gridConfig)).selectedBlocks;
    final gridNotifier = ref.read(gridStateProvider(widget.gridConfig).notifier);
    final screenSize = MediaQuery.of(context).size;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    // 블록이 비었으면 모달 닫기
    if (selectedBlocks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.7,
      snap: true,
      snapSizes: const [0.4, 0.7],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 핸들
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.buleGray,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // 토스 스타일 헤더: 선택된 블록 수 + CLEAR 버튼
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${selectedBlocks.length}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: AppColors.darkBlue,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '블록 선택됨',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        gridNotifier.clearBlocks();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '전체 삭제',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 스크롤 가능한 블록 리스트
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: selectedBlocks.length,
                  itemBuilder: (context, index) {
                    final block = selectedBlocks[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: BlockItemCard(
                        block: block,
                        onRemove: () => gridNotifier.toggleBlock(block),
                        isFocused: ref.watch(gridStateProvider(widget.gridConfig)).focusedBlockId == block.id,
                        onTap: () {
                          // 블록 위치로 이동 (토글)
                          gridNotifier.navigateToBlock(
                            block,
                            screenWidth: screenSize.width,
                            screenHeight: screenSize.height,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // 토스 스타일 하단 제출 버튼
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.gray200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () async {
                      // 로그인 체크
                      if (!isAuthenticated) {
                        await showLoginDialog(context);
                        return;
                      }
                      // 게임 참가 프로세스 시작
                      await _handleJoinGame(context, ref, selectedBlocks);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkBlue.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 22,
                            color: AppColors.white,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedBlocks.length}개 블록으로 참가하기',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 게임 참가 처리 (Toss 스타일 애니메이션)
  Future<void> _handleJoinGame(
    BuildContext context,
    WidgetRef ref,
    List<BlockModel> selectedBlocks,
  ) async {
    // 게임 정보 확인
    if (widget.game == null || widget.fullGame == null) {
      _showError(context, '게임 정보를 불러올 수 없습니다');
      return;
    }

    // 컨트랙트 주소 가져오기
    final contractAddress = widget.fullGame!.onchainContractAddr;
    if (contractAddress == null || contractAddress.isEmpty) {
      _showError(context, '컨트랙트 주소가 없습니다');
      return;
    }

    // 첫 번째 블록만 사용 (단일 좌표)
    if (selectedBlocks.isEmpty) {
      _showError(context, '블록을 선택해주세요');
      return;
    }

    final firstBlock = selectedBlocks.first;
    final row = firstBlock.row;
    final col = firstBlock.col;

    // 상품 ID (첫 번째 상품 사용)
    String? productId;
    if (widget.fullGame!.gameProducts != null && widget.fullGame!.gameProducts!.isNotEmpty) {
      productId = widget.fullGame!.gameProducts!.first.id;
    }

    if (productId == null) {
      _showError(context, '게임 상품 정보가 없습니다');
      return;
    }

    print('\\n🎮 게임 참가 시작:');
    print('   • 게임 ID: ${widget.game!.id}');
    print('   • 선택 블록: ($row, $col)');
    print('   • 컨트랙트: $contractAddress');
    print('   • 상품 ID: $productId');

    try {
      // 1. 로딩 오버레이 표시
      if (!context.mounted) return;
      GameJoinLoadingOverlay.show(context);

      // 2. 게임 참가 실행
      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: widget.game!.id,
            selectedGameProductId: productId,
            row: row,
            col: col,
            contractAddress: contractAddress,
          );

      // 3. 로딩 숨김
      if (!context.mounted) return;
      GameJoinLoadingOverlay.hide(context);
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. 결과 표시
      if (!context.mounted) return;

      if (result.success) {
        GameJoinResultOverlay.showSuccess(
          context,
          entryId: result.entryId,
          txHash: result.txHash,
          onConfirm: () {
            print('✅ 게임 참가 완료!');
            // 선택 초기화
            ref.read(gridStateProvider(widget.gridConfig).notifier).clearBlocks();
          },
        );
      } else {
        GameJoinResultOverlay.showError(
          context,
          errorMessage: result.message,
          onRetry: () {
            _handleJoinGame(context, ref, selectedBlocks);
          },
        );
      }
    } catch (e) {
      print('❌ 게임 참가 에러: $e');

      if (!context.mounted) return;
      GameJoinLoadingOverlay.hide(context);
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;
      GameJoinResultOverlay.showError(
        context,
        errorMessage: e.toString(),
        onRetry: () {
          _handleJoinGame(context, ref, selectedBlocks);
        },
      );
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
    );
  }
}
