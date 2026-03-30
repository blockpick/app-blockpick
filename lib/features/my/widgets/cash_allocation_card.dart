import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 캐시 배분 카드 위젯 (충전캐시, 이벤트 캐시, 쇼핑 캐시)
class CashAllocationCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int amount;
  final String status;
  final bool isRefundable;

  const CashAllocationCard({
    super.key,
    required this.icon,
    required this.title,
    required this.amount,
    required this.status,
    required this.isRefundable,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Container(
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
            color: AppColors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(AppConstants.spacingSm),
            decoration: BoxDecoration(
              color: AppColors.blueWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),

          const SizedBox(height: AppConstants.spacingMd),

          // 제목
          Text(
            title,
            style: AppTextStyles.body4.copyWith(color: AppColors.grayBlue),
          ),

          const SizedBox(height: AppConstants.spacingXs),

          // 금액
          Text(
            '₩${formatter.format(amount)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),

          const SizedBox(height: AppConstants.spacingSm),

          // 상태 (환불 가능 / 사용 가능)
          Row(
            children: [
              Icon(
                isRefundable ? Icons.lock_open : Icons.lock,
                size: 12,
                color: isRefundable ? AppColors.green500 : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: AppTextStyles.caption4.copyWith(color: isRefundable ? AppColors.green500 : AppColors.error),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
