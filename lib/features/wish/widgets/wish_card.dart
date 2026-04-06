import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/wish_model.dart';

/// 소원 카드 — 업체/일반 동일 구조, 풀 너비 가로형
class WishCard extends StatefulWidget {
  final Wish wish;
  final VoidCallback onTap;
  final VoidCallback onBuzzTap;
  final bool showSwipeHint;

  const WishCard({
    super.key,
    required this.wish,
    required this.onTap,
    required this.onBuzzTap,
    this.showSwipeHint = false,
  });

  @override
  State<WishCard> createState() => _WishCardState();
}

class _WishCardState extends State<WishCard> with SingleTickerProviderStateMixin {
  late final AnimationController _peekController;
  late final Animation<Offset> _peekAnim;

  @override
  void initState() {
    super.initState();
    _peekController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _peekAnim = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(begin: Offset.zero, end: const Offset(-0.08, 0))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: const Offset(-0.08, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 60,
      ),
    ]).animate(_peekController);

    if (widget.showSwipeHint) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _peekController.forward();
      });
    }
  }

  @override
  void dispose() {
    _peekController.dispose();
    super.dispose();
  }

  Wish get wish => widget.wish;

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _peekAnim,
      child: Dismissible(
      key: ValueKey('wish_${wish.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        widget.onBuzzTap();
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: wish.isBusinessWish ? AppColors.primaryMain : AppColors.textBlack,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.auto_awesome, size: 22, color: AppColors.white),
            const SizedBox(height: 4),
            Text(
              '소문내기',
              style: AppTextStyles.caption2.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
      child: GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: wish.isBusinessWish
              ? Border.all(color: AppColors.primaryMain.withValues(alpha: 0.15), width: 1)
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상단: 썸네일 + 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThumbnail(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 카테고리 + 업체 배지
                      Row(
                        children: [
                          Text(
                            '${wish.category.emoji} ${wish.category.label.split('/').first}',
                            style: AppTextStyles.caption4.copyWith(color: AppColors.gray400),
                          ),
                          if (wish.isBusinessWish) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBg,
                                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                              ),
                              child: Text(
                                wish.businessName ?? 'AD',
                                style: AppTextStyles.caption4.copyWith(
                                  color: AppColors.primaryMain,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      // 한줄평
                      Text(
                        wish.oneLiner,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title3.copyWith(
                          color: AppColors.textBlack,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 상품명
                      Text(
                        wish.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption1.copyWith(color: AppColors.gray400),
                      ),
                      const SizedBox(height: 6),
                      // 가격
                      Text(
                        '${_formatPrice(wish.productPrice)}원',
                        style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 하단: 통계 + CTA
            Row(
              children: [
                // 공감
                if (!wish.isBusinessWish) ...[
                  Icon(Icons.favorite_rounded, size: 13, color: AppColors.red.withValues(alpha: 0.6)),
                  const SizedBox(width: 3),
                  Text('${wish.empathyCount}', style: AppTextStyles.caption4.copyWith(color: AppColors.gray400)),
                  const SizedBox(width: 10),
                ],
                // 참여자
                const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.gray400),
                const SizedBox(width: 3),
                Text(_formatCount(wish.participantCount), style: AppTextStyles.caption4.copyWith(color: AppColors.gray400)),
                // 업체: 경품
                if (wish.isBusinessWish && wish.prizeDescription != null) ...[
                  const SizedBox(width: 10),
                  Text('🎁', style: AppTextStyles.caption4),
                  const SizedBox(width: 2),
                  Text(
                    '${_formatPrice(wish.prizeValue ?? 0)}원',
                    style: AppTextStyles.caption4.copyWith(color: AppColors.orange, fontWeight: FontWeight.w600),
                  ),
                ],
                const Spacer(),
                // CTA 버튼
                GestureDetector(
                  onTap: widget.onBuzzTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: wish.isBusinessWish ? AppColors.primaryMain : AppColors.textBlack,
                      borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                    ),
                    child: Text(
                      wish.isBusinessWish ? '무료 소문내기' : '소문내기 10원',
                      style: AppTextStyles.caption2.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 업체: 프로그레스 바
            if (wish.isBusinessWish) ...[
              const SizedBox(height: 12),
              _buildProgress(),
            ],
          ],
        ),
      ),
    ),  // GestureDetector
    ),  // Dismissible
    );  // SlideTransition
  }

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: SizedBox(
        width: 88,
        height: 88,
        child: Image.network(
          wish.productImageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return _buildPlaceholder(isLoading: true);
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    final colors = _categoryColors(wish.category);
    return Container(
      color: colors[1].withValues(alpha: 0.15),
      child: Center(
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: colors[0].withValues(alpha: 0.4)),
              )
            : Text(wish.category.emoji, style: const TextStyle(fontSize: 28)),
      ),
    );
  }

  Widget _buildProgress() {
    final progress = wish.exposureProgress;
    return Row(
      children: [
        Text(
          '달성률',
          style: AppTextStyles.caption4.copyWith(color: AppColors.gray400),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 4,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation(
                progress > 0.7 ? AppColors.primaryMain : AppColors.primaryLight,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTextStyles.caption2.copyWith(
            color: AppColors.primaryMain,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
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
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  String _numberWithComma(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

List<Color> _categoryColors(WishCategory category) {
  switch (category) {
    case WishCategory.food:
      return [AppColors.orange, AppColors.yellow500];
    case WishCategory.beauty:
      return [AppColors.pink, AppColors.red200];
    case WishCategory.fashion:
      return [AppColors.primaryDark, AppColors.primaryLight];
    case WishCategory.electronics:
      return [AppColors.gray800, AppColors.gray600];
    case WishCategory.figure:
      return [AppColors.primaryMain, AppColors.primaryBg];
    case WishCategory.travel:
      return [AppColors.blue, AppColors.blue200];
    case WishCategory.lifestyle:
      return [AppColors.green500, AppColors.green200];
    case WishCategory.etc:
      return [AppColors.gray400, AppColors.gray200];
  }
}
