import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// History 화면 (종료된 게임 히스토리)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'History\n(종료된 게임)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: AppColors.medium,
        ),
      ),
    );
  }
}
