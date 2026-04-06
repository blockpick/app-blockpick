import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../components/common/common_empty_state.dart';

/// History 화면 (종료된 게임 히스토리)
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonEmptyState(
      icon: Icons.history_outlined,
      message: '종료된 게임이 없습니다',
      subMessage: '게임 기록이 여기에 표시됩니다',
    );
  }
}
