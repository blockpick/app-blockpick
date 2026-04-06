import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/game_model.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';

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
    final currentProduct = widget.products[_currentIndex];

    return GestureDetector(
      onTap: _close,
      child: Container(
        color: AppColors.textBlack.withValues(alpha: 0.85),
        child: FadeTransition(
          opacity: _animation,
          child: GestureDetector(
            onTap: () {}, // 내부 탭은 무시
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 닫기 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: _close,
                        icon: const Icon(
                          LucideIcons.x,
                          color: AppColors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // 상품명 (크게)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    currentProduct.product.name,
                    style: AppTextStyles.heading1.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 40),

                // 스와이프 가능한 상품 이미지
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
                      final product = widget.products[index].product;
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 40),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.black.withValues(alpha: 0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                            child: product.defaultImage != null &&
                                    product.defaultImage!.isNotEmpty
                                ? Image.network(
                                    product.defaultImage!.replaceAll(' ', '%20'),
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: AppColors.blueWhite,
                                        child: const Center(
                                          child: Icon(
                                            LucideIcons.image,
                                            size: 80,
                                            color: AppColors.medium,
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: AppColors.blueWhite,
                                    child: const Center(
                                      child: Icon(
                                        LucideIcons.image,
                                        size: 80,
                                        color: AppColors.medium,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 40),

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
                        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                        color: _currentIndex == index
                            ? AppColors.purple
                            : AppColors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // 선택 버튼 (고정)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: AppColors.gradientBluePurplePink,
                      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
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
                        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
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
                              SizedBox(width: 12),
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
              ],
            ),
          ),
        ),
      ),
    );
  }

}
