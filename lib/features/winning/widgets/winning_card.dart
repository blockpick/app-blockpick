import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/winning/winning_models.dart';

/// WinningStatus → 아이콘/색상 정보
_StatusMeta _statusMeta(WinningStatus status) {
  switch (status) {
    case WinningStatus.pending:
      return _StatusMeta(
        icon: Icons.hourglass_empty,
        color: AppColors.gray500,
        label: '대기 중',
      );
    case WinningStatus.claimRequired:
      return _StatusMeta(
        icon: Icons.assignment_late,
        color: AppColors.orange,
        label: '정보 입력 필요',
        highlight: true,
      );
    case WinningStatus.processing:
      return _StatusMeta(
        icon: Icons.local_shipping_outlined,
        color: AppColors.blue,
        label: '처리 중',
      );
    case WinningStatus.delivered:
      return _StatusMeta(
        icon: Icons.check_circle_outline,
        color: AppColors.green500,
        label: '배송 완료',
      );
    case WinningStatus.completed:
      return _StatusMeta(
        icon: Icons.check_circle,
        color: AppColors.green500,
        label: '수령 완료',
      );
    case WinningStatus.failed:
      return _StatusMeta(
        icon: Icons.error_outline,
        color: AppColors.error,
        label: '실패',
      );
  }
}

class _StatusMeta {
  final IconData icon;
  final Color color;
  final String label;
  final bool highlight;

  const _StatusMeta({
    required this.icon,
    required this.color,
    required this.label,
    this.highlight = false,
  });
}

class WinningCard extends StatelessWidget {
  final WinningRecord winning;
  final VoidCallback onTap;

  const WinningCard({
    super.key,
    required this.winning,
    required this.onTap,
  });

  String get _prizeShortId => winning.blockpickPrizeId.length >= 8
      ? winning.blockpickPrizeId.substring(0, 8)
      : winning.blockpickPrizeId;

  String get _issuedDate {
    final raw = winning.issuedAt;
    if (raw.length >= 10) return raw.substring(0, 10);
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final meta = _statusMeta(winning.status);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: meta.highlight
              ? Border.all(color: AppColors.orange.withValues(alpha: 0.4), width: 1.5)
              : Border.all(color: AppColors.gray200, width: 1),
        ),
        child: Row(
          children: [
            // 상태 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: meta.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Icon(meta.icon, color: meta.color, size: 22),
            ),
            const SizedBox(width: 12),
            // 제목/부제
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '블록픽 #$_prizeShortId',
                    style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '당첨일: $_issuedDate',
                    style: AppTextStyles.caption1.copyWith(color: AppColors.gray500),
                  ),
                  if (meta.highlight) ...[
                    const SizedBox(height: 4),
                    Text(
                      meta.label,
                      style: AppTextStyles.caption2.copyWith(color: AppColors.orange),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            // 상태 칩 + 화살표
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!meta.highlight)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                    ),
                    child: Text(
                      meta.label,
                      style: AppTextStyles.caption2.copyWith(color: meta.color),
                    ),
                  ),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: AppColors.gray400, size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
