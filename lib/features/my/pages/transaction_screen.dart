import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 거래내역 화면
class TransactionScreen extends ConsumerWidget {
  const TransactionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 실제 거래내역 API 연동
    final transactions = _mockTransactions;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: Text(
            '거래내역',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: transactions.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final tx = transactions[index];
                  return _TransactionItem(transaction: tx);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: 16),
          Text(
            '거래내역이 없습니다',
            style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Map<String, dynamic> transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final type = transaction['type'] as String;
    final amount = transaction['amount'] as int;
    final isPositive = amount > 0;

    IconData icon;
    Color iconColor;
    String typeText;

    switch (type) {
      case 'charge':
        icon = Icons.add_circle_outline;
        iconColor = AppColors.green500;
        typeText = '충전';
        break;
      case 'refund':
        icon = Icons.remove_circle_outline;
        iconColor = AppColors.red;
        typeText = '환불';
        break;
      case 'game':
        icon = Icons.videogame_asset_outlined;
        iconColor = AppColors.blue;
        typeText = '게임 참여';
        break;
      case 'winning':
        icon = Icons.emoji_events_outlined;
        iconColor = AppColors.purple;
        typeText = '당첨금';
        break;
      case 'shopping':
        icon = Icons.shopping_bag_outlined;
        iconColor = AppColors.pink;
        typeText = '쇼핑';
        break;
      default:
        icon = Icons.swap_horiz;
        iconColor = AppColors.gray500;
        typeText = '기타';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction['description'] as String,
                  style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                ),
                const SizedBox(height: 4),
                Text(
                  '${transaction['date']} · $typeText',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}${_formatNumber(amount)}원',
            style: AppTextStyles.title2,
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    return number.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

// 임시 데이터
final _mockTransactions = [
  {
    'id': '1',
    'type': 'charge',
    'description': '캐시 충전',
    'amount': 50000,
    'date': '2025.01.05 14:30',
  },
  {
    'id': '2',
    'type': 'game',
    'description': '데일리 게임 #123 참여',
    'amount': -1000,
    'date': '2025.01.05 12:00',
  },
  {
    'id': '3',
    'type': 'winning',
    'description': '상품 픽 게임 #45 당첨',
    'amount': 100000,
    'date': '2025.01.04 15:30',
  },
  {
    'id': '4',
    'type': 'shopping',
    'description': '쇼핑몰 구매',
    'amount': -32900,
    'date': '2025.01.03 18:20',
  },
  {
    'id': '5',
    'type': 'refund',
    'description': '환불 신청',
    'amount': -20000,
    'date': '2025.01.02 10:00',
  },
];
