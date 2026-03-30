import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/wish_model.dart';

/// 소원 카드 위젯 — 위시 탭 그리드용
class WishCard extends StatelessWidget {
  final Wish wish;
  final VoidCallback onTap;
  final VoidCallback onBuzzTap;

  const WishCard({
    super.key,
    required this.wish,
    required this.onTap,
    required this.onBuzzTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: wish.isBusinessWish
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 1.5)
              : Border.all(color: AppColors.gray200.withValues(alpha: 0.6), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 2,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품 이미지
            _buildImage(),
            // 내용 — Expanded로 남은 공간 채움
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 한줄평
                    Text(
                      wish.oneLiner,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption2.copyWith(color: AppColors.textBlack),
                    ),
                    const SizedBox(height: 6),
                    // 상품명
                    Text(
                      wish.productName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // 가격
                    Text(
                      '${_formatPrice(wish.productPrice)}원',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // 공감/참여 정보
                    _buildStats(),
                    // 업체 경품 + 프로그레스
                    if (wish.isBusinessWish) ...[
                      if (wish.prizeDescription != null) ...[
                        const SizedBox(height: 8),
                        _buildPrizeInfo(),
                      ],
                      const SizedBox(height: 8),
                      _buildExposureProgress(),
                    ],
                    // Spacer로 CTA를 항상 하단에 배치
                    const Spacer(),
                    const SizedBox(height: 10),
                    // CTA 버튼
                    _buildCTA(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
          child: AspectRatio(
            aspectRatio: 1.1,
            child: Image.network(
              wish.productImageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildImagePlaceholder(),
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return _buildImagePlaceholder(isLoading: true);
              },
            ),
          ),
        ),
        // 카테고리 배지
        Positioned(
          right: 8,
          bottom: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15), width: 0.5),
            ),
            child: Text(
              '${wish.category.emoji} ${wish.category.label.split('/').first}',
              style: AppTextStyles.caption4.copyWith(color: AppColors.white),
            ),
          ),
        ),
        // 업체 배지
        if (wish.isBusinessWish)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), AppColors.primary],
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.campaign, size: 12, color: AppColors.white),
                  const SizedBox(width: 4),
                  Text(
                    wish.businessName ?? 'BRAND',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// 이미지 로딩/에러 시 그라데이션 플레이스홀더
  Widget _buildImagePlaceholder({bool isLoading = false}) {
    // 카테고리별 색상
    final colors = _categoryColors;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0].withValues(alpha: 0.15), colors[1].withValues(alpha: 0.08)],
        ),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors[0].withValues(alpha: 0.4),
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    wish.category.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wish.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.caption4.copyWith(color: colors[0].withValues(alpha: 0.6)),
                  ),
                ],
              ),
      ),
    );
  }

  List<Color> get _categoryColors {
    switch (wish.category) {
      case WishCategory.food:
        return [const Color(0xFFFF6B6B), const Color(0xFFFFE66D)];
      case WishCategory.beauty:
        return [const Color(0xFFE91E63), const Color(0xFFFF80AB)];
      case WishCategory.fashion:
        return [const Color(0xFF1A237E), const Color(0xFF5C6BC0)];
      case WishCategory.electronics:
        return [const Color(0xFF37474F), const Color(0xFF78909C)];
      case WishCategory.figure:
        return [const Color(0xFF5941F2), const Color(0xFFB39DDB)];
      case WishCategory.travel:
        return [const Color(0xFF00BCD4), const Color(0xFF80DEEA)];
      case WishCategory.lifestyle:
        return [const Color(0xFF4CAF50), const Color(0xFFA5D6A7)];
      case WishCategory.etc:
        return [const Color(0xFF9E9E9E), const Color(0xFFE0E0E0)];
    }
  }

  Widget _buildStats() {
    return Row(
      children: [
        if (!wish.isBusinessWish) ...[
          Icon(Icons.favorite, size: 12, color: Colors.red.shade300),
          const SizedBox(width: 3),
          Text(
            '${wish.empathyCount}',
            style: AppTextStyles.caption4.copyWith(color: AppColors.gray600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 10),
        ],
        const Icon(Icons.people_outline, size: 12, color: AppColors.gray400),
        const SizedBox(width: 3),
        Text(
          _formatCount(wish.participantCount),
          style: AppTextStyles.caption4.copyWith(color: AppColors.gray600, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          '@${wish.userName ?? ''}',
          style: const TextStyle(fontSize: 10, color: AppColors.gray400),
        ),
      ],
    );
  }

  Widget _buildPrizeInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFCC80), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🎁', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              '경품: ${_formatPrice(wish.prizeValue ?? 0)}원 상당',
              style: AppTextStyles.caption4.copyWith(color: Color(0xFFE65100)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExposureProgress() {
    final progress = wish.exposureProgress;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.people_outline, size: 11, color: AppColors.gray400),
            const SizedBox(width: 4),
            Text(
              '${_formatCount(wish.currentExposures ?? 0)} / ${_formatCount(wish.maxExposures ?? 0)}명',
              style: const TextStyle(fontSize: 10, color: AppColors.gray600),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toInt()}%',
              style: AppTextStyles.caption4.copyWith(color: AppColors.primary),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation(
              progress > 0.7 ? AppColors.primary : const Color(0xFF7C3AED),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCTA() {
    final isBusinessFree = wish.isBusinessWish;
    return SizedBox(
      width: double.infinity,
      height: 38,
      child: ElevatedButton(
        onPressed: onBuzzTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
        ).copyWith(
          backgroundColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: isBusinessFree
                ? const LinearGradient(
                    colors: [Color(0xFF7C3AED), AppColors.primary],
                  )
                : const LinearGradient(
                    colors: [Color(0xFF2D3436), Color(0xFF191F28)],
                  ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            alignment: Alignment.center,
            child: Text(
              isBusinessFree ? '✨ 소문내기 무료' : '✨ 소문내기 10원',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final remainder = price % 10000;
      if (remainder == 0) return '$man만';
      return '$man만${_numberWithComma(remainder)}';
    }
    return _numberWithComma(price);
  }

  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}만';
    }
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return '$count';
  }

  String _numberWithComma(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
