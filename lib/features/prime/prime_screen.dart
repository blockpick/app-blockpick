import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

/// 💎 프라임 탭 메인 화면
/// 역경매 상품 목록, 입찰 진입점
class PrimeScreen extends ConsumerWidget {
  const PrimeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 상단 앱바
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '💎 프라임',
                      style: AppTextStyles.heading1,
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: 알림 화면
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 준비 중 안내
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.diamond_outlined,
                        size: 40,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '역경매로 득템하세요!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '10원에 입찰하고\n가장 낮은 고유 금액이면 당첨!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      '곧 오픈 예정',
                      style: AppTextStyles.title2.copyWith(color: AppColors.gray400),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
