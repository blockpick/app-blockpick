import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wish_model.dart';

/// Step 5: 미리보기 + 등록 확인
class WishStepPreview extends StatelessWidget {
  final String productName;
  final int productPrice;
  final String? productImageUrl;
  final String oneLiner;
  final WishCategory? category;
  final String purchaseUrl;
  final VoidCallback onSubmit;
  final VoidCallback onEdit;

  const WishStepPreview({
    super.key,
    required this.productName,
    required this.productPrice,
    this.productImageUrl,
    required this.oneLiner,
    this.category,
    required this.purchaseUrl,
    required this.onSubmit,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '소원을 확인해주세요',
            style: AppTextStyles.heading2,
          ),
          const SizedBox(height: 24),
          // 미리보기 카드
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              border: Border.all(color: AppColors.gray200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이미지
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
                  child: AspectRatio(
                    aspectRatio: 1.2,
                    child: productImageUrl != null
                        ? Image.network(
                            productImageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _imagePlaceholder(),
                          )
                        : _imagePlaceholder(),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리
                      if (category != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.gray100,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          ),
                          child: Text(
                            '${category!.emoji} ${category!.label}',
                            style: const TextStyle(fontSize: 11, color: AppColors.gray600),
                          ),
                        ),
                      SizedBox(height: 10),
                      // 한줄평
                      Text(
                        '"$oneLiner"',
                        style: AppTextStyles.buttonLarge.copyWith(color: AppColors.textBlack),
                      ),
                      const SizedBox(height: 10),
                      // 상품명
                      Text(
                        productName,
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                      const SizedBox(height: 4),
                      // 가격
                      Text(
                        '💰 ${_formatPrice(productPrice)}원',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 필요 공감
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, size: 14, color: AppColors.primary),
                            SizedBox(width: 6),
                            Text(
                              '필요 공감: ${_calculateThreshold(productPrice)}명',
                              style: AppTextStyles.caption2.copyWith(color: AppColors.primary),
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
          const SizedBox(height: 16),
          // 주의 사항
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: AppColors.gray600),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '등록 후에는 상품 정보를 수정할 수 없어요',
                    style: TextStyle(fontSize: 13, color: AppColors.gray600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 등록 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
                elevation: 0,
              ),
              child: const Text(
                '⭐ 소원 등록하기',
                style: AppTextStyles.buttonLarge,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // 수정 버튼
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: onEdit,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.gray600,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                '← 수정하기',
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 48, color: AppColors.gray400),
      ),
    );
  }

  int _calculateThreshold(int price) {
    if (price <= 10000) return 5;
    if (price <= 50000) return 10;
    if (price <= 200000) return 20;
    if (price <= 500000) return 30;
    if (price <= 1000000) return 50;
    return 100;
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
