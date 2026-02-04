import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/pending_transaction.dart';
import '../../../providers/pending_transaction_provider.dart';
import '../../../providers/ad_reward_provider.dart';
import '../../../core/auth/domain/providers/auth_provider.dart';
import '../../../services/ad_reward_service.dart';
import 'game_join_result_overlay.dart';

/// 트랜잭션 생성/확인 모달
///
/// 게임 참여 후 블록체인 트랜잭션의 생성/확인 과정을 보여줍니다.
/// 모든 게임 타입(Daily, Select, Vibe, Prime)에서 공통으로 사용됩니다.
class TransactionProgressModal extends ConsumerStatefulWidget {
  final String gameId;
  final String gameTitle;

  const TransactionProgressModal({
    super.key,
    required this.gameId,
    required this.gameTitle,
  });

  /// 모달 표시
  static void show(BuildContext context, {
    required String gameId,
    required String gameTitle,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => TransactionProgressModal(
        gameId: gameId,
        gameTitle: gameTitle,
      ),
    );
  }

  @override
  ConsumerState<TransactionProgressModal> createState() => _TransactionProgressModalState();
}

class _TransactionProgressModalState extends ConsumerState<TransactionProgressModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _hasNavigatedToResult = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingTransactionNotifierProvider);

    // 완료/실패 시 결과 화면으로 전환
    if (pending != null && !_hasNavigatedToResult) {
      if (pending.isCompleted) {
        _hasNavigatedToResult = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pop();
          GameJoinResultOverlay.showSuccess(
            context,
            entryId: pending.entryId,
            txHash: pending.txHash,
            onConfirm: () {
              ref.read(pendingTransactionNotifierProvider.notifier).clear();
              context.go('/');
            },
          );
        });
      } else if (pending.isFailed) {
        _hasNavigatedToResult = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).pop();
          GameJoinResultOverlay.showError(
            context,
            errorMessage: pending.errorMessage ?? '트랜잭션 처리에 실패했습니다.',
            onRetry: () {
              ref.read(pendingTransactionNotifierProvider.notifier).clear();
            },
          );
        });
      }
    }

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withValues(alpha: 0.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 진행 상태 아이콘 + 카운터
              _buildProgressHeader(pending),

              const SizedBox(height: 24),

              // 상태 메시지
              _buildStatusMessage(pending),

              const SizedBox(height: 16),

              // TX Hash 표시
              if (pending?.txHash != null) ...[
                _buildTxHashCard(pending!.txHash!),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 8),

              // 하단 버튼들
              _buildActionButtons(pending),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressHeader(PendingTransaction? pending) {
    final step = pending?.currentStep ?? 1;
    final total = pending?.totalSteps ?? 6;
    final isPolling = pending?.phase == TransactionPhase.polling;

    return Column(
      children: [
        // 프로그레스 링 + 카운터
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: step / total,
                strokeWidth: 4,
                backgroundColor: AppColors.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isPolling ? AppColors.blue : AppColors.purple,
                ),
              ),
            ),
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Opacity(
                  opacity: 0.7 + (_pulseController.value * 0.3),
                  child: child,
                );
              },
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPolling
                      ? AppColors.blue.withValues(alpha: 0.1)
                      : AppColors.purple.withValues(alpha: 0.1),
                ),
                child: Icon(
                  isPolling ? LucideIcons.link : LucideIcons.shield,
                  color: isPolling ? AppColors.blue : AppColors.purple,
                  size: 24,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 제목 + 카운터
        Text(
          isPolling ? '트랜잭션 확인 중' : '트랜잭션 생성 중',
          style: AppTextStyles.medium.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '($step/$total)',
          style: AppTextStyles.body.copyWith(
            color: AppColors.grayBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusMessage(PendingTransaction? pending) {
    final message = pending?.message ?? '준비 중...';
    final txCount = pending?.currentTxCount;
    final totalTx = pending?.totalTxCount;

    return Column(
      children: [
        Text(
          message,
          style: AppTextStyles.body.copyWith(color: AppColors.navy),
          textAlign: TextAlign.center,
        ),
        if (txCount != null && totalTx != null && totalTx > 0) ...[
          const SizedBox(height: 8),
          // TX 처리 진행 바
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: totalTx > 0 ? txCount / totalTx : 0,
              backgroundColor: AppColors.gray200,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
              minHeight: 6,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTxHashCard(String txHash) {
    final displayHash = txHash.length > 20
        ? '${txHash.substring(0, 10)}...${txHash.substring(txHash.length - 10)}'
        : txHash;

    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: txHash));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('TX Hash가 복사되었습니다'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            Icon(LucideIcons.link, size: 14, color: AppColors.grayBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayHash,
                style: AppTextStyles.bodySmall.copyWith(
                  fontFamily: 'monospace',
                  color: AppColors.navy,
                ),
              ),
            ),
            Icon(LucideIcons.copy, size: 14, color: AppColors.grayBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(PendingTransaction? pending) {
    return Column(
      children: [
        // 푸시 알림 받기 → 이벤트 홈으로 이동
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/');
            },
            icon: const Icon(LucideIcons.bell, size: 18),
            label: const Text('푸시 알림 받기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: AppTextStyles.button.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 광고 시청하고 이벤트 포인트 받기
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _showAdAndNavigate(),
            icon: const Icon(LucideIcons.play, size: 18),
            label: const Text('광고 시청하고 이벤트 포인트 받기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.blue,
              side: const BorderSide(color: AppColors.blue, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: AppTextStyles.button.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showAdAndNavigate() async {
    final authState = ref.read(authProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final userId = authState.valueOrNull?.user?.id ?? '';

    if (!isAuthenticated) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다')),
      );
      return;
    }

    final notifier = ref.read(adRewardNotifierProvider.notifier);
    final result = await notifier.showAdAndGetReward(
      contextType: AdContextType.homeDaily,
      userId: userId,
      gameId: widget.gameId,
    );

    if (!mounted) return;

    Navigator.of(context).pop();

    if (result?.isSuccess == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${result!.grantedAmount}P 적립 완료!'),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      ref.read(authProvider.notifier).refreshUser();
    } else if (result != null && result.reasonCode != null) {
      final message = switch (result.reasonCode) {
        'LIMIT_DAILY' => '오늘은 이미 보상을 받으셨습니다',
        'LIMIT_COOLDOWN' => '잠시 후 다시 시도해주세요',
        _ => '보상을 받을 수 없습니다',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    context.go('/');
  }
}
