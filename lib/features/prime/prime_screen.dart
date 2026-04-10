import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../optimal/optimal_game_list_screen.dart';

/// 프라임 탭 메인 화면 — 역경매 상품 목록
class PrimeScreen extends ConsumerWidget {
  const PrimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 앱바
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
              child: Row(
                children: [
                  Text(
                    '💎 프라임',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // TODO: 알림 화면
                    },
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.gray600,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
            // 역경매 게임 리스트
            const Expanded(
              child: OptimalGameListScreen(),
            ),
          ],
        ),
      ),
    );
  }
}
