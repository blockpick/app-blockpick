import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../components/common/common_empty_state.dart';

/// PLAY 화면 (현재 진행 중인 게임)
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const CommonEmptyState(
      icon: Icons.sports_esports_outlined,
      message: '진행 중인 게임이 없습니다',
      subMessage: '게임에 참여해보세요',
    );
  }
}
