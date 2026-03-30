import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/pending_transaction.dart';
import '../providers/pending_transaction_provider.dart';

/// 이벤트 홈 하단에 표시되는 트랜잭션 상태 배너
///
/// [PendingTransactionNotifier]를 구독하여 백그라운드 트랜잭션 상태를 표시합니다.
class TransactionFloatingBanner extends ConsumerStatefulWidget {
  const TransactionFloatingBanner({super.key});

  @override
  ConsumerState<TransactionFloatingBanner> createState() =>
      _TransactionFloatingBannerState();
}

class _TransactionFloatingBannerState
    extends ConsumerState<TransactionFloatingBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;
  Timer? _autoHideTimer;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pending = ref.watch(pendingTransactionNotifierProvider);

    if (pending == null) {
      // 배너 숨기기
      if (_slideController.status == AnimationStatus.completed) {
        _slideController.reverse();
      }
      return const SizedBox.shrink();
    }

    // 배너 보이기
    if (_slideController.status != AnimationStatus.completed &&
        _slideController.status != AnimationStatus.forward) {
      _slideController.forward();
    }

    // 완료 시 3초 후 자동 숨기기
    if (pending.isCompleted) {
      _autoHideTimer?.cancel();
      _autoHideTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          ref.read(pendingTransactionNotifierProvider.notifier).clear();
        }
      });
    }

    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GestureDetector(
          onTap: () => _onBannerTap(pending),
          child: _buildBannerContent(pending),
        ),
      ),
    );
  }

  Widget _buildBannerContent(PendingTransaction pending) {
    final (icon, color, text) = _getStatusDisplay(pending);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 상태 아이콘
          _buildStatusIcon(pending, icon, color),
          const SizedBox(width: 12),

          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (pending.gameTitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    pending.gameTitle,
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          // 오른쪽 아이콘
          if (pending.isInProgress)
            Icon(
              LucideIcons.chevronRight,
              color: AppColors.white.withValues(alpha: 0.7),
              size: 20,
            )
          else if (pending.isCompleted)
            Icon(
              LucideIcons.checkCircle2,
              color: AppColors.white,
              size: 20,
            )
          else if (pending.isFailed)
            Icon(
              LucideIcons.alertCircle,
              color: AppColors.white,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(
      PendingTransaction pending, IconData icon, Color color) {
    if (pending.isInProgress) {
      return SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.white),
          value: pending.totalSteps > 0
              ? pending.currentStep / pending.totalSteps
              : null,
        ),
      );
    }

    return Icon(icon, color: AppColors.white, size: 24);
  }

  (IconData, Color, String) _getStatusDisplay(PendingTransaction pending) {
    switch (pending.phase) {
      case TransactionPhase.submitting:
        return (
          LucideIcons.shield,
          AppColors.purple,
          '트랜잭션 생성 중... (${pending.stepDisplay})',
        );
      case TransactionPhase.polling:
        final txInfo = pending.currentTxCount != null && pending.totalTxCount != null
            ? ' (${pending.currentTxCount}/${pending.totalTxCount})'
            : '';
        return (
          LucideIcons.link,
          AppColors.blue,
          '트랜잭션 처리 중...$txInfo',
        );
      case TransactionPhase.confirmed:
        return (
          LucideIcons.checkCircle2,
          AppColors.green500,
          '트랜잭션 완료!',
        );
      case TransactionPhase.failed:
        return (
          LucideIcons.alertCircle,
          AppColors.red,
          '트랜잭션 실패',
        );
    }
  }

  void _onBannerTap(PendingTransaction pending) {
    if (pending.isCompleted || pending.isFailed) {
      ref.read(pendingTransactionNotifierProvider.notifier).clear();
    }
    // 진행 중일 때 탭하면 추가 액션 없음 (향후 상세 정보 표시 가능)
  }
}
