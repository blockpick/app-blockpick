import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// OFFICIAL 플랫폼 화면 (서비스 소개, 게임 안내, 리소스 등)
class OfficialScreen extends StatelessWidget {
  const OfficialScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.language,
            size: 64,
            color: AppColors.blue,
          ),
          SizedBox(height: 16),
          Text(
            'OFFICIAL WEB',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Service introduction & resources',
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
