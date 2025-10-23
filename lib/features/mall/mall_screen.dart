import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// MALL 플랫폼 화면 (쇼핑몰)
class MallScreen extends StatelessWidget {
  const MallScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag,
            size: 64,
            color: AppColors.blue,
          ),
          SizedBox(height: 16),
          Text(
            'SHOPPING MALL',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Shop products & marketplace',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.medium,
            ),
          ),
        ],
      ),
    );
  }
}
