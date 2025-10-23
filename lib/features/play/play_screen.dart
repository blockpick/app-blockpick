import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// PLAY 화면 (현재 진행 중인 게임)
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'PLAY\n(현재 진행 중인 게임)',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: AppColors.medium,
        ),
      ),
    );
  }
}
