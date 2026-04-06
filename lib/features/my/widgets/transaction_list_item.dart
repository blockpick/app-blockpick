import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/transaction_model.dart';

/// 거래 내역 리스트 아이템
class TransactionListItem extends StatelessWidget {
  final Transaction transaction;

  const TransactionListItem({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('MM/dd HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingMd),
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        border: Border.all(
          color: AppColors.buleGray,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아이콘
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.blueWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Center(
              child: Text(
                transaction.type.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),

          SizedBox(width: AppConstants.spacingMd),

          // 거래 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.type.displayName,
                  style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                ),
                const SizedBox(height: 4),
                if (transaction.description != null)
                  Text(
                    transaction.description!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.navy,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          const SizedBox(width: AppConstants.spacingMd),

          // 금액 및 날짜
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${transaction.isIncrease ? '+' : '-'}₩${formatter.format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: transaction.isIncrease
                      ? AppColors.green500
                      : AppColors.error,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                dateFormatter.format(transaction.createdAt),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.grayBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
