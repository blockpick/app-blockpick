import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/block_model.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/grid_state_provider.dart';
import '../../providers/game_participation_provider.dart';
import '../../components/cards/block_item_card.dart';
import '../../components/buttons/gradient_button.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';
import 'widgets/game_join_loading_overlay.dart';
import 'widgets/game_join_result_overlay.dart';

/// 선택된 블록 목록을 보여주는 바텀시트
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
  final DraggableScrollableController _controller = DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.isAttached) {
        _controller.addListener(_onSheetSizeChanged);
      }
    });
  }

  @override
  void dispose() {
    if (_controller.isAttached) {
      _controller.removeListener(_onSheetSizeChanged);
    }
    _controller.dispose();
    super.dispose();
  }

  void _onSheetSizeChanged() {
    if (!mounted || !_controller.isAttached) return;

    // minChildSize보다 작아지면 바텀시트 닫기
    if (_controller.size < 0.15) {
      final gridNotifier = ref.read(gridStateProvider(widget.gridConfig).notifier);
      gridNotifier.hideBottomSheet();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedBlocks = ref.watch(gridStateProvider(widget.gridConfig)).selectedBlocks;
    final gridNotifier = ref.read(gridStateProvider(widget.gridConfig).notifier);
    final screenSize = MediaQuery.of(context).size;
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    if (selectedBlocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: 0.4,
      minChildSize: 0.05,
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

              // 헤더: 선택된 블록 수 + CLEAR 버튼
              Padding(
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

              // 하단 제출 버튼
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.buleGray.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                  ),
                  child: GradientButton(
                    label: 'Select blocks (${selectedBlocks.length}/pick)',
                    icon: Icons.bolt,
                    onPressed: () async {
                      // 로그인 체크
                      if (!isAuthenticated) {
                        // 다이얼로그로 로그인 표시
                        await showLoginDialog(context);
                        return;
                      }

                      // 게임 참가 프로세스 시작
                      await _handleJoinGame(context, ref, selectedBlocks);
                    },
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
