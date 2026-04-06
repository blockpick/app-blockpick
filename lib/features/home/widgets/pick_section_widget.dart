import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Pick 섹션 위젯 (SELECT 강조, DAILY/VIBE, PRIME)
class PickSectionWidget extends StatelessWidget {
  const PickSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SELECT - 큰 강조 카드
          _buildSelectCard(context),

          const SizedBox(height: 16),

          // DAILY & VIBE - 2열 카드
          Row(
            children: [
              Expanded(child: _buildDailyCard(context)),
              const SizedBox(width: 12),
              Expanded(child: _buildVibeCard(context)),
            ],
          ),

          const SizedBox(height: 24),

          // PRIME - 슬라이더 섹션
          _buildPrimeSection(context),
        ],
      ),
    );
  }

  /// SELECT 카드 (큰 강조)
  Widget _buildSelectCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // HomeScreen의 SELECT 탭으로 이동 (탭 인덱스 1)
        // TODO: 네비게이션 구현 필요
      },
      child: Container(
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          gradient: AppColors.gradientBluePurplePink,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.blue.withOpacity(0.3),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 배경 장식
            Positioned(
              right: -20,
              bottom: -20,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'SELECT',
                    style: AppTextStyles.display1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 36,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join now and claim yours!',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'JOIN NOW',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.blue,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward,
                          color: AppColors.blue,
                          size: 18,
                        ),
                      ],
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

  /// DAILY 카드
  Widget _buildDailyCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // HomeScreen의 DAILY 탭으로 이동
        // TODO: 네비게이션 구현
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBg, AppColors.primaryBg],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.blue.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  color: AppColors.blue,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'DAILY',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Join the world',
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// VIBE 카드
  Widget _buildVibeCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // HomeScreen의 VIBE 탭으로 이동
        // TODO: 네비게이션 구현
      },
      child: Container(
        height: 180,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.pink.withValues(alpha: 0.15), AppColors.primaryBg],
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.pink.withOpacity(0.2)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.pink.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: const Icon(
                  Icons.music_note,
                  color: AppColors.pink,
                  size: 32,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'VIBE',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.pink,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Play with Purpose',
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// PRIME 섹션 (슬라이더)
  Widget _buildPrimeSection(BuildContext context) {
    final primeItems = _getMockPrimeItems();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PRIME',
              style: AppTextStyles.heading1.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                // PRIME 전체 보기
                // TODO: 네비게이션 구현
              },
              child: Row(
                children: [
                  Text(
                    'View more',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.blue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    color: AppColors.blue,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 슬라이더
        SizedBox(
          height: 140,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: primeItems.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = primeItems[index];
              return _buildPrimeItem(context, item);
            },
          ),
        ),
      ],
    );
  }

  /// PRIME 아이템 카드
  Widget _buildPrimeItem(BuildContext context, PrimeItem item) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.buleGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지 영역
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusLg),
              ),
            ),
            child: Center(
              child: Icon(
                item.icon,
                size: 40,
                color: AppColors.blue,
              ),
            ),
          ),

          // 상품 정보
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  '\$${item.price.toStringAsFixed(2)}',
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 목 PRIME 아이템 데이터
  List<PrimeItem> _getMockPrimeItems() {
    return [
      PrimeItem(
        name: 'Dior Book Tote',
        price: 5.00,
        icon: Icons.shopping_bag,
      ),
      PrimeItem(
        name: 'iPhone 16',
        price: 10.00,
        icon: Icons.phone_iphone,
      ),
      PrimeItem(
        name: 'AirPods Pro',
        price: 3.00,
        icon: Icons.headphones,
      ),
      PrimeItem(
        name: 'Apple Watch',
        price: 8.00,
        icon: Icons.watch,
      ),
      PrimeItem(
        name: 'MacBook Pro',
        price: 15.00,
        icon: Icons.laptop_mac,
      ),
      PrimeItem(
        name: 'iPad Air',
        price: 7.00,
        icon: Icons.tablet_mac,
      ),
    ];
  }
}

/// PRIME 아이템 모델
class PrimeItem {
  final String name;
  final double price;
  final IconData icon;

  PrimeItem({
    required this.name,
    required this.price,
    required this.icon,
  });
}
