import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 쇼핑 주문 내역 화면
class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 실제 주문 내역 API 연동
    final orders = _mockOrders;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: const Text(
            '쇼핑 주문 내역',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: orders.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return _OrderItem(order: order);
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
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '주문 내역이 없습니다',
            style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 8),
          Text(
            'MALL에서 쇼핑을 즐겨보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderItem extends StatelessWidget {
  final Map<String, dynamic> order;

  const _OrderItem({required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order['status'] as String;
    Color statusColor;
    String statusText;

    switch (status) {
      case 'shipping':
        statusColor = AppColors.blue;
        statusText = '배송중';
        break;
      case 'delivered':
        statusColor = AppColors.green500;
        statusText = '배송완료';
        break;
      case 'preparing':
        statusColor = AppColors.purple;
        statusText = '상품준비중';
        break;
      default:
        statusColor = AppColors.gray500;
        statusText = '주문확인';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text(
                  order['date'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    statusText,
                    style: AppTextStyles.caption2.copyWith(color: statusColor),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.gray100,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image_outlined,
                    color: AppColors.gray400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['productName'] as String,
                        style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${order['price']}원',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 임시 데이터
final _mockOrders = [
  {
    'id': '1',
    'date': '2025.01.05',
    'productName': 'Apple AirPods Pro 2세대',
    'price': '329,000',
    'status': 'shipping',
  },
  {
    'id': '2',
    'date': '2025.01.03',
    'productName': '삼성 갤럭시 버즈3 프로',
    'price': '289,000',
    'status': 'delivered',
  },
  {
    'id': '3',
    'date': '2025.01.01',
    'productName': 'LG 스탠바이미',
    'price': '899,000',
    'status': 'preparing',
  },
];
