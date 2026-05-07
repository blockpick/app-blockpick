// ⚠️ DEPRECATED: 옛 game_participation_provider.joinGame() 사용. 새 entry_flow(BlockSelectScreen+joinBlockpick)로 마이그레이션 예정.
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
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';
import 'widgets/game_join_loading_overlay.dart';
import 'widgets/game_join_result_overlay.dart';
import '../../core/constants/app_constants.dart';

/// 참여하기 모달 바텀시트 (기획 SC-009-17)
///
/// - 헤더: 체크 아이콘 + "선택한 좌표로 이벤트에 참여하시겠어요?"
/// - 컨트롤: "N개 좌표" 배지 + "전체선택 | 선택삭제"
/// - 블록 리스트: 체크박스 + "X NNNN | Y NNNN" + 삭제 아이콘
/// - 하단: "참여하기 (NNNP)" 버튼 + "취소"
class SelectedBlocksSheet extends ConsumerStatefulWidget {
  final GridConfig gridConfig;
  final GameRound? game;
  final Game? fullGame;

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
  /// 체크된 블록 ID 목록
  final Set<String> _checkedBlockIds = {};

  @override
  Widget build(BuildContext context) {
    final selectedBlocks = ref.watch(gridStateProvider(widget.gridConfig)).selectedBlocks;
    final gridNotifier = ref.read(gridStateProvider(widget.gridConfig).notifier);
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final entryFee = widget.fullGame?.entryFee ?? 0;
    final totalCost = entryFee * selectedBlocks.length;

    // 블록이 비었으면 모달 닫기
    if (selectedBlocks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
      return const SizedBox.shrink();
    }

    // 현재 유효한 체크 수 (삭제된 블록 제외)
    final checkedCount = _checkedBlockIds.where(
      (id) => selectedBlocks.any((b) => b.id == id),
    ).length;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      snap: true,
      snapSizes: const [0.55, 0.8],
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radius2Xl)),
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
                      borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                    ),
                  ),
                ),
              ),

              // 헤더: 체크 아이콘 + 안내 문구
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '선택한 좌표로 이벤트에\n참여하시겠어요?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),

              // 좌표 개수 배지 + 전체선택/선택삭제 컨트롤
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // N개 좌표 배지
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      ),
                      child: Text(
                        '${selectedBlocks.length}개 좌표',
                        style: AppTextStyles.caption2.copyWith(color: AppColors.blue),
                      ),
                    ),
                    Spacer(),
                    // 전체선택
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (checkedCount == selectedBlocks.length) {
                            _checkedBlockIds.clear();
                          } else {
                            _checkedBlockIds.clear();
                            for (final block in selectedBlocks) {
                              _checkedBlockIds.add(block.id);
                            }
                          }
                        });
                      },
                      child: Text(
                        '전체선택',
                        style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        '|',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray300,
                        ),
                      ),
                    ),
                    // 선택삭제
                    GestureDetector(
                      onTap: checkedCount > 0
                          ? () {
                              // 체크된 블록을 선택 해제 (그리드에서 제거)
                              final blocksToRemove = selectedBlocks
                                  .where((b) => _checkedBlockIds.contains(b.id))
                                  .toList();
                              for (final block in blocksToRemove) {
                                gridNotifier.toggleBlock(block);
                              }
                              setState(() {
                                _checkedBlockIds.clear();
                              });
                            }
                          : null,
                      child: Text(
                        '선택삭제',
                        style: AppTextStyles.body4.copyWith(color: checkedCount > 0 ? AppColors.red : AppColors.gray400),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // 스크롤 가능한 블록 리스트
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: selectedBlocks.length,
                  itemBuilder: (context, index) {
                    final block = selectedBlocks[index];
                    final isChecked = _checkedBlockIds.contains(block.id);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: BlockItemCard(
                        block: block,
                        isChecked: isChecked,
                        onCheckedChanged: (checked) {
                          setState(() {
                            if (checked) {
                              _checkedBlockIds.add(block.id);
                            } else {
                              _checkedBlockIds.remove(block.id);
                            }
                          });
                        },
                        onRemove: () => gridNotifier.toggleBlock(block),
                        onTap: () {
                          setState(() {
                            if (isChecked) {
                              _checkedBlockIds.remove(block.id);
                            } else {
                              _checkedBlockIds.add(block.id);
                            }
                          });
                        },
                      ),
                    );
                  },
                ),
              ),

              // 하단 버튼 영역
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    border: Border(
                      top: BorderSide(
                        color: AppColors.gray200,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 참여하기 버튼
                      GestureDetector(
                        onTap: () async {
                          if (!isAuthenticated) {
                            await showLoginDialog(context);
                            return;
                          }
                          await _handleJoinGame(context, ref, selectedBlocks);
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.darkBlue,
                            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.darkBlue.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              totalCost > 0
                                  ? '참여하기 (${_formatNumber(totalCost)}P)'
                                  : '참여하기',
                              style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      // 취소 버튼
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: Text(
                              '취소',
                              style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 숫자 포맷 (천 단위 콤마)
  String _formatNumber(int number) {
    if (number < 1000) return number.toString();
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
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

    print('\n🎮 게임 참가 시작:');
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
