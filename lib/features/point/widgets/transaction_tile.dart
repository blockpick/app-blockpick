import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/point/point_models.dart';

/// 포인트 거래 내역 단일 항목
class TransactionTile extends StatelessWidget {
  final PointTransaction transaction;

  const TransactionTile({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isGrant = transaction.type == PointType.grant;
    final amountColor = isGrant ? AppColors.green500 : AppColors.red;
    final amountPrefix = isGrant ? '+' : '-';
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('MM.dd HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPaddingH,
        vertical: 12,
      ),
      child: Row(
        children: [
          // 사유 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _iconBgColor(transaction.reason),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Center(
              child: Text(
                _reasonEmoji(transaction.reason),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 사유 라벨 + 날짜
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pointReasonLabel(transaction.reason),
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateFormatter.format(transaction.createdAt.toLocal()),
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          // 포인트 + 잔액
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$amountPrefix${formatter.format(transaction.amount)}P',
                style: AppTextStyles.body2.copyWith(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '잔액 ${formatter.format(transaction.balanceAfter)}P',
                style: AppTextStyles.caption2.copyWith(
                  color: AppColors.gray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _iconBgColor(PointReason reason) {
    switch (reason) {
      case PointReason.checkIn:
        return AppColors.yellow200;
      case PointReason.miniGame:
        return AppColors.blue200;
      case PointReason.adReward:
        return AppColors.green200;
      case PointReason.referral:
        return AppColors.primaryBg;
      case PointReason.blockpickJoin:
        return AppColors.primaryBg;
      case PointReason.offerwall:
        return AppColors.green200;
      case PointReason.adminGrant:
        return AppColors.gray100;
    }
  }

  String _reasonEmoji(PointReason reason) {
    switch (reason) {
      case PointReason.checkIn:
        return '📅';
      case PointReason.miniGame:
        return '🎮';
      case PointReason.adReward:
        return '📺';
      case PointReason.referral:
        return '👥';
      case PointReason.blockpickJoin:
        return '🎯';
      case PointReason.offerwall:
        return '📋';
      case PointReason.adminGrant:
        return '🎁';
    }
  }
}
