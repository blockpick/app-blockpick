import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Mall 미리보기 위젯
class MallPreviewWidget extends StatefulWidget {
  const MallPreviewWidget({super.key});

  @override
  State<MallPreviewWidget> createState() => _MallPreviewWidgetState();
}

class _MallPreviewWidgetState extends State<MallPreviewWidget> {
  String _selectedCategory = 'ALL';

  @override
  Widget build(BuildContext context) {
    final products = _getFilteredProducts();

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'BLOCK',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.pink,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: '\nPICK MALL',
                          style: AppTextStyles.heading1.copyWith(
                            color: AppColors.darkBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Shop the Future.\nExperience the Exclusive.',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.navy,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  // MALL 전체 보기
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

          const SizedBox(height: 20),

          // 카테고리 필터
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildCategoryChip('ALL'),
                const SizedBox(width: 8),
                _buildCategoryChip('Digital'),
                const SizedBox(width: 8),
                _buildCategoryChip('Gift'),
                const SizedBox(width: 8),
                _buildCategoryChip('Food'),
                const SizedBox(width: 8),
                _buildCategoryChip('Fashion'),
                const SizedBox(width: 8),
                _buildCategoryChip('Coupon'),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 상품 그리드 (2x2)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length > 4 ? 4 : products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product);
            },
          ),
        ],
      ),
    );
  }

  /// 카테고리 칩
  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = category;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.pink : AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.pink : AppColors.pink.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          category,
          style: AppTextStyles.body3.copyWith(
            color: isSelected ? AppColors.white : AppColors.pink,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 상품 카드
  Widget _buildProductCard(MallProduct product) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.buleGray),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상품 이미지
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Icon(
                  product.icon,
                  size: 60,
                  color: AppColors.blue,
                ),
              ),
            ),
          ),

          // 상품 정보
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        '\$${product.price.toStringAsFixed(2)}',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.originalPrice != null) ...[
                        Text(
                          '\$${product.originalPrice!.toStringAsFixed(2)}',
                          style: AppTextStyles.body4.copyWith(
                            color: AppColors.light,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 필터링된 상품 목록
  List<MallProduct> _getFilteredProducts() {
    final allProducts = _getMockProducts();

    if (_selectedCategory == 'ALL') {
      return allProducts;
    }

    return allProducts
        .where((product) => product.category == _selectedCategory)
        .toList();
  }

  /// 목 상품 데이터
  List<MallProduct> _getMockProducts() {
    return [
      MallProduct(
        name: 'Louis Vuitton Neonoe',
        price: 5.00,
        originalPrice: 365.00,
        category: 'Fashion',
        icon: Icons.shopping_bag,
      ),
      MallProduct(
        name: 'Twitch Gift Card',
        price: 0.10,
        originalPrice: 1.50,
        category: 'Digital',
        icon: Icons.card_giftcard,
      ),
      MallProduct(
        name: 'Airpods Pro 2',
        price: 1.50,
        originalPrice: 5.00,
        category: 'Digital',
        icon: Icons.headphones,
      ),
      MallProduct(
        name: 'Cartier Love Bracelet',
        price: 5.00,
        originalPrice: 365.50,
        category: 'Fashion',
        icon: Icons.favorite,
      ),
      MallProduct(
        name: 'Starbucks Gift Card',
        price: 0.50,
        originalPrice: 5.00,
        category: 'Gift',
        icon: Icons.local_cafe,
      ),
      MallProduct(
        name: 'Nike Air Jordan',
        price: 3.00,
        originalPrice: 200.00,
        category: 'Fashion',
        icon: Icons.directions_run,
      ),
    ];
  }
}

/// Mall 상품 모델
class MallProduct {
  final String name;
  final double price;
  final double? originalPrice;
  final String category;
  final IconData icon;

  MallProduct({
    required this.name,
    required this.price,
    this.originalPrice,
    required this.category,
    required this.icon,
  });
}
