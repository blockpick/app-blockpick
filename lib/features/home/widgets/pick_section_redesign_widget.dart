import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import 'select_carousel_widget.dart';

/// Pick 섹션 위젯 (피그마 디자인 정확히 재현)
class PickSectionRedesignWidget extends StatelessWidget {
  const PickSectionRedesignWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          // SELECT 게임 캐러셀 (좌우 스와이프)
          const SelectCarouselWidget(),

          const SizedBox(height: 16),

          // STAGE & VIBE 카드
          Row(
            children: [
              Expanded(
                child: _buildFeatureCard(
                  context: context,
                  title: 'STAGE',
                  subtitle: 'Join the world',
                  backgroundImage: 'assets/images/home/stage-card-bg.png',
                  foregroundArt: 'assets/images/home/stage-card.png',
                  gradient: const [
                    AppColors.primaryLight,
                    AppColors.primaryMain,
                  ],
                  onTap: () {
                    // TODO: DAILY 탭으로 이동
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFeatureCard(
                  context: context,
                  title: 'VIBE',
                  subtitle: 'Play with Purpose',
                  backgroundImage: 'assets/images/home/vibe-card-bg.png',
                  foregroundArt: 'assets/images/home/vibe-card.png',
                  gradient: const [
                    AppColors.blue,
                    AppColors.blue,
                  ],
                  onTap: () {
                    // TODO: VIBE 탭으로 이동
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 하단 상품 쇼케이스 (Dior, iPhone)
          _buildProductShowcase(),
        ],
      ),
    );
  }

  /// 피처 카드 (STAGE / VIBE 공용)
  Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<Color> gradient,
    required String backgroundImage,
    required String foregroundArt,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: gradient.last.withValues(alpha: 0.26),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 배경 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                backgroundImage,
                fit: BoxFit.cover,
              ),
            ),

            // 그라데이션 오버레이
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gradient.first.withValues(alpha: 0.85),
                    gradient.last.withValues(alpha: 0.95),
                  ],
                ),
              ),
            ),

            // 전경 3D 아트
            Positioned(
              top: 16,
              right: 16,
              child: Image.asset(
                foregroundArt,
                width: 116,
                height: 116,
              ),
            ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'HOT PICK',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 하단 상품 쇼케이스
  Widget _buildProductShowcase() {
    final products = [
      (
        image: 'assets/images/home/dior-tote.png',
        label: 'Select Block',
        name: 'Dior Book Tote',
        gradient: const [
          AppColors.gray800,
          AppColors.gray800,
        ],
      ),
      (
        image: 'assets/images/home/iphone-16.png',
        label: 'Stage Block',
        name: 'IPHONE 16',
        gradient: const [
          AppColors.gray700,
          AppColors.gray600,
        ],
      ),
    ];

    return SizedBox(
      height: 112,
      child: Row(
        children: List.generate(products.length, (index) {
          final product = products[index];
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: index == 0 ? 12 : 0),
              child: _buildProductCard(
                imageAsset: product.image,
                label: product.label,
                productName: product.name,
                gradient: product.gradient,
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 상품 카드
  Widget _buildProductCard({
    required String imageAsset,
    required String label,
    required String productName,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradient,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: [
            // 상품 이미지
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),

            // 텍스트
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.emoji_events,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    productName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
