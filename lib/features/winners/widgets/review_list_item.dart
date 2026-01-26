import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/review_model.dart';
import '../../../utils/time_utils.dart';

/// 리뷰 리스트 아이템
class ReviewListItem extends StatelessWidget {
  final ReviewModel review;
  final VoidCallback? onTap;

  const ReviewListItem({
    super.key,
    required this.review,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            _buildProfileImage(),
            const SizedBox(width: 12),

            // 리뷰 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임
                  Text(
                    review.nickName,
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // 리뷰 내용 (최대 2줄)
                  Text(
                    review.content,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.navy,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // 출처 + 시간
                  Row(
                    children: [
                      Text(
                        review.source.displayName,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '•',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        TimeUtils.getRelativeTime(review.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 프로필 이미지
  Widget _buildProfileImage() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgWhite,
        border: Border.all(color: AppColors.bgWhite, width: 2),
      ),
      child: ClipOval(
        child: review.hasProfileImage
            ? Image.network(
                review.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialAvatar();
                },
              )
            : _buildInitialAvatar(),
      ),
    );
  }

  /// 초성 아바타
  Widget _buildInitialAvatar() {
    return Container(
      color: _getSourceColor(),
      alignment: Alignment.center,
      child: Text(
        review.initial,
        style: AppTextStyles.medium.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 리뷰 출처별 색상
  Color _getSourceColor() {
    switch (review.source) {
      case ReviewSource.x:
        return AppColors.darkBlue;
      case ReviewSource.thread:
        return AppColors.purple;
      case ReviewSource.blockpick:
        return AppColors.blue;
    }
  }
}
