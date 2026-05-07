import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/point/point_models.dart';

/// 포인트 지갑 잔액 요약 카드
class WalletSummaryCard extends StatelessWidget {
  final PointWallet wallet;

  const WalletSummaryCard({super.key, required this.wallet});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.gradientDarkPurple,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryMain.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 라벨
          Text(
            '보유 포인트',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.white.withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 8),
          // 잔액
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(wallet.balance),
                style: AppTextStyles.display1.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'P',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.white.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 구분선
          Divider(color: AppColors.white.withValues(alpha: 0.2), height: 1),
          const SizedBox(height: 16),
          // 총 적립 / 총 사용
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  label: '총 적립',
                  value: '${formatter.format(wallet.totalEarned)}P',
                ),
              ),
              Container(
                width: 1,
                height: 32,
                color: AppColors.white.withValues(alpha: 0.2),
              ),
              Expanded(
                child: _buildStatItem(
                  label: '총 사용',
                  value: '${formatter.format(wallet.totalConsumed)}P',
                  align: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    TextAlign align = TextAlign.left,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: align == TextAlign.right
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption2.copyWith(
              color: AppColors.white.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTextStyles.body2.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
