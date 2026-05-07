import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/offerwall/offerwall_models.dart';

/// 오퍼월 개별 오퍼 카드
///
/// 썸네일 + 제목 + 보상 P + 카테고리 배지 + "시작하기" CTA
class OfferCard extends StatelessWidget {
  final OfferwallOffer offer;
  final VoidCallback onTap;

  const OfferCard({
    super.key,
    required this.offer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = offer.status == OfferwallOfferStatus.completed;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // 스폰서 로고 / 플레이스홀더
            _SponsorLogo(logoUrl: offer.sponsorLogoUrl, category: offer.category),
            const SizedBox(width: 14),

            // 제목 + 설명 + 배지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _CategoryBadge(category: offer.category),
                      if (isCompleted) ...[
                        const SizedBox(width: 6),
                        _CompletedBadge(),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textBlack,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    offer.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.gray600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  // 보상 포인트
                  Text(
                    '+${offer.pointReward}P',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AppColors.gray400
                          : AppColors.primaryMain,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // 시작하기 CTA
            _StartButton(
              onTap: isCompleted ? null : onTap,
              isCompleted: isCompleted,
            ),
          ],
        ),
      ),
    );
  }
}

class _SponsorLogo extends StatelessWidget {
  final String? logoUrl;
  final OfferwallCategory category;

  const _SponsorLogo({this.logoUrl, required this.category});

  Color get _bgColor {
    switch (category) {
      case OfferwallCategory.small:
        return AppColors.blue200;
      case OfferwallCategory.medium:
        return AppColors.green200;
      case OfferwallCategory.large:
        return AppColors.primaryBg;
      case OfferwallCategory.event:
        return AppColors.yellow200;
    }
  }

  IconData get _icon {
    switch (category) {
      case OfferwallCategory.small:
        return Icons.apps_rounded;
      case OfferwallCategory.medium:
        return Icons.shopping_bag_rounded;
      case OfferwallCategory.large:
        return Icons.account_balance_rounded;
      case OfferwallCategory.event:
        return Icons.celebration_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          logoUrl!,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (context, error, trace) => _placeholder(),
        ),
      );
    }
    return _placeholder();
  }

  Widget _placeholder() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(_icon, color: AppColors.primaryMain, size: 28),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  final OfferwallCategory category;

  const _CategoryBadge({required this.category});

  Color get _color {
    switch (category) {
      case OfferwallCategory.small:
        return AppColors.blue;
      case OfferwallCategory.medium:
        return AppColors.green500;
      case OfferwallCategory.large:
        return AppColors.primaryMain;
      case OfferwallCategory.event:
        return AppColors.yellow500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        offerwallCategoryLabel(category),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    );
  }
}

class _CompletedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        '완료',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.gray600,
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isCompleted;

  const _StartButton({this.onTap, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.gray100 : AppColors.primaryMain,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          isCompleted ? '완료됨' : '시작하기',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isCompleted ? AppColors.gray400 : AppColors.white,
          ),
        ),
      ),
    );
  }
}
