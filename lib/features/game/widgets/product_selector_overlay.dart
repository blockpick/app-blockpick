import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/game_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// SELECT 게임 상품 선택 오버레이
class ProductSelectorOverlay extends StatefulWidget {
  final List<GameProduct> products;
  final int initialIndex;
  final Function(int index, GameProduct product) onProductSelected;

  const ProductSelectorOverlay({
    super.key,
    required this.products,
    required this.onProductSelected,
    this.initialIndex = 0,
  });

  @override
  State<ProductSelectorOverlay> createState() => _ProductSelectorOverlayState();
}

class _ProductSelectorOverlayState extends State<ProductSelectorOverlay>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.85,
    );

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _close() {
    _animationController.reverse().then((_) {
      Navigator.of(context).pop();
    });
  }

  void _selectProduct() {
    widget.onProductSelected(_currentIndex, widget.products[_currentIndex]);
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _close,
      child: Container(
        color: Colors.black.withValues(alpha: 0.7),
        child: FadeTransition(
          opacity: _animation,
          child: GestureDetector(
            onTap: () {}, // 내부 탭은 무시
            child: Column(
              children: [
                const SizedBox(height: 100),
                // 헤더
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Select Product',
                        style: AppTextStyles.large.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: _close,
                        icon: const Icon(
                          LucideIcons.x,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 상품 캐러셀
                SizedBox(
                  height: 400,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemCount: widget.products.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (_pageController.position.haveDimensions) {
                            value = _pageController.page! - index;
                            value = (1 - (value.abs() * 0.3)).clamp(0.7, 1.0);
                          }
                          return Center(
                            child: Transform.scale(
                              scale: value,
                              child: child,
                            ),
                          );
                        },
                        child: _buildProductCard(widget.products[index], index),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                // 페이지 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.products.length,
                    (index) => Container(
                      width: _currentIndex == index ? 24 : 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: _currentIndex == index
                            ? AppColors.purple
                            : AppColors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                // 선택 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientBluePurplePink,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _selectProduct,
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                LucideIcons.check,
                                size: 24,
                                color: AppColors.white,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Select This Product',
                                style: AppTextStyles.buttonLarge.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(GameProduct gameProduct, int index) {
    final product = gameProduct.product;
    final isSelected = _currentIndex == index;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? AppColors.purple : AppColors.buleGray,
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? AppColors.purple.withValues(alpha: 0.3)
                : AppColors.black.withValues(alpha: 0.1),
            blurRadius: isSelected ? 20 : 10,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 상품 이미지
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: product.defaultImage != null &&
                      product.defaultImage!.isNotEmpty
                  ? Image.network(
                      product.defaultImage!.replaceAll(' ', '%20'),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.blueWhite,
                          child: const Icon(
                            LucideIcons.image,
                            size: 64,
                            color: AppColors.medium,
                          ),
                        );
                      },
                    )
                  : Container(
                      color: AppColors.blueWhite,
                      child: const Icon(
                        LucideIcons.image,
                        size: 64,
                        color: AppColors.medium,
                      ),
                    ),
            ),
          ),
          // 상품 정보
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.blueWhite,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (product.brand != null) ...[
                  Text(
                    product.brand!,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.purple,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  product.name,
                  style: AppTextStyles.medium.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (product.originalPrice != null) ...[
                  Row(
                    children: [
                      Text(
                        'Value: ',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                      Text(
                        '₩${_formatNumber(product.originalPrice!)}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.purple,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
                if (gameProduct.isGrandPrize == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientBluePurplePink,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          LucideIcons.crown,
                          size: 12,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'GRAND PRIZE',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
