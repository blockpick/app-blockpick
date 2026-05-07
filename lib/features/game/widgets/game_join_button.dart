// ⚠️ DEPRECATED: 옛 game_participation_provider.joinGame() 사용. 새 entry_flow(BlockSelectScreen+joinBlockpick)로 마이그레이션 예정.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/auth/domain/providers/auth_provider.dart';
import '../../auth/presentation/dialogs/auth_dialogs.dart';
import '../../../providers/game_participation_provider.dart';
import '../../../providers/game_join_progress_provider.dart';
import 'game_join_result_overlay.dart';
import 'game_join_progress_overlay.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';

/// 게임 참가 버튼 (토스 스타일 애니메이션)
class GameJoinButton extends ConsumerStatefulWidget {
  final String gameId;
  final String selectedGameProductId;
  final int selectedRow;
  final int selectedCol;
  final String contractAddress;
  final VoidCallback? onSuccess;

  const GameJoinButton({
    super.key,
    required this.gameId,
    required this.selectedGameProductId,
    required this.selectedRow,
    required this.selectedCol,
    required this.contractAddress,
    this.onSuccess,
  });

  @override
  ConsumerState<GameJoinButton> createState() => _GameJoinButtonState();
}

class _GameJoinButtonState extends ConsumerState<GameJoinButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()
            ..scale(_isHovered ? 1.02 : 1.0),
          child: Container(
            width: double.infinity,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.blue,
                  AppColors.purple,
                ],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _handleJoinGame,
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        LucideIcons.zap,
                        color: AppColors.white,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        '게임 참가하기',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        LucideIcons.arrowRight,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .shimmer(
                duration: 2000.ms,
                color: AppColors.white.withValues(alpha: 0.3),
              ),
        ),
      ),
    );
  }

  Future<void> _handleJoinGame() async {
    // 로그인 체크
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      if (mounted) await showLoginDialog(context);
      return;
    }

    OverlayEntry? progressOverlay;

    try {
      // 1. 진행 오버레이 표시
      progressOverlay = GameJoinProgressOverlay.show(
        context,
        currentStep: GameJoinStep.walletCheck,
        statusMessage: '게임 참여를 준비하고 있습니다...',
      );

      // 2. 게임 참가 실행 (자동으로 폴링 포함)
      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: widget.gameId,
            selectedGameProductId: widget.selectedGameProductId,
            row: widget.selectedRow,
            col: widget.selectedCol,
            contractAddress: widget.contractAddress,
          );

      // 3. 오버레이 제거
      progressOverlay?.remove();
      progressOverlay = null;

      // 잠깐 대기 (애니메이션 전환)
      await Future.delayed(const Duration(milliseconds: 300));

      // 4. 결과 표시
      if (mounted) {
        if (result.success) {
          GameJoinResultOverlay.showSuccess(
            context,
            entryId: result.entryId,
            txHash: result.txHash,
            onConfirm: () {
              widget.onSuccess?.call();
            },
          );
        } else {
          GameJoinResultOverlay.showError(
            context,
            errorMessage: result.message,
            onRetry: () {
              _handleJoinGame();
            },
          );
        }
      }
    } catch (e) {
      // 에러 처리
      progressOverlay?.remove();
      progressOverlay = null;

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));

        GameJoinResultOverlay.showError(
          context,
          errorMessage: '알 수 없는 오류가 발생했습니다.\n$e',
          onRetry: () {
            _handleJoinGame();
          },
        );
      }
    } finally {
      // 진행 상태 초기화
      ref.read(gameJoinProgressNotifierProvider.notifier).reset();
    }
  }
}

/// 게임 참가 플로팅 버튼 (화면 하단 고정)
class GameJoinFloatingButton extends ConsumerWidget {
  final String gameId;
  final String selectedGameProductId;
  final int? selectedRow;
  final int? selectedCol;
  final String contractAddress;
  final VoidCallback? onSuccess;

  const GameJoinFloatingButton({
    super.key,
    required this.gameId,
    required this.selectedGameProductId,
    this.selectedRow,
    this.selectedCol,
    required this.contractAddress,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasSelection = selectedRow != null && selectedCol != null;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: hasSelection ? 24 : -100,
      left: 24,
      right: 24,
      child: SafeArea(
        child: hasSelection
            ? GameJoinButton(
                gameId: gameId,
                selectedGameProductId: selectedGameProductId,
                selectedRow: selectedRow!,
                selectedCol: selectedCol!,
                contractAddress: contractAddress,
                onSuccess: onSuccess,
              )
                  .animate()
                  .slideY(begin: 1, end: 0, curve: Curves.easeOut)
                  .fadeIn()
            : const SizedBox.shrink(),
      ),
    );
  }
}

/// 게임 참가 정보 카드
class GameJoinInfoCard extends StatelessWidget {
  final int? selectedRow;
  final int? selectedCol;
  final int entryFee;
  final int maxEntries;
  final int currentEntries;

  const GameJoinInfoCard({
    super.key,
    this.selectedRow,
    this.selectedCol,
    required this.entryFee,
    required this.maxEntries,
    required this.currentEntries,
  });

  @override
  Widget build(BuildContext context) {
    final hasSelection = selectedRow != null && selectedCol != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 선택된 좌표
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasSelection
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Icon(
                  LucideIcons.mapPin,
                  color: hasSelection ? AppColors.blue : AppColors.gray400,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '선택한 위치',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    hasSelection
                        ? '($selectedRow, $selectedCol)'
                        : '위치를 선택해주세요',
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: hasSelection ? AppColors.gray900 : AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(color: AppColors.gray200),

          const SizedBox(height: 16),

          // 참가 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoItem(
                icon: LucideIcons.coins,
                label: '참가 비용',
                value: '$entryFee P',
                color: AppColors.yellow500,
              ),
              _buildInfoItem(
                icon: LucideIcons.users,
                label: '참가자',
                value: '$currentEntries/$maxEntries',
                color: AppColors.purple,
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Icon(
            icon,
            color: color,
            size: 16,
          ),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.gray500,
              ),
            ),
            Text(
              value,
              style: AppTextStyles.body3.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
