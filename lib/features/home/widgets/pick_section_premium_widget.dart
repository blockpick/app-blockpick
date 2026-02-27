import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'select_carousel_premium_widget.dart';
import 'feature_cards_premium_widget.dart';
import 'product_showcase_premium_widget.dart';

/// Pick 섹션 위젯 (프리미엄 디자인 - 훨씬 더 화려함)
class PickSectionPremiumWidget extends StatelessWidget {
  const PickSectionPremiumWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            AppColors.gray100,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
      child: Column(
        children: [
          // SELECT 게임 캐러셀 (프리미엄)
          const SelectCarouselPremiumWidget(),

          const SizedBox(height: 18),

          // STAGE & VIBE 카드 (프리미엄)
          const FeatureCardsPremiumWidget(),

          const SizedBox(height: 18),

          // 하단 상품 쇼케이스 (프리미엄)
          const ProductShowcasePremiumWidget(),
        ],
      ),
    );
  }
}
