import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'package:intl/intl.dart';

/// 토스 스타일 잔액 카드
class TossBalanceCard extends StatelessWidget {
  final double balance;
  final bool isAuthenticated;
  final VoidCallback? onTap;

  const TossBalanceCard({
    super.key,
    required this.balance,
    required this.isAuthenticated,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 라벨
            Row(
              children: [
                Text(
                  '내 자산',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.gray400,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 금액
            if (isAuthenticated) ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatCurrency(balance),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '원',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              // 비로그인 상태
              Text(
                '로그인하고 자산을 확인하세요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.blue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(amount.toInt());
  }
}
