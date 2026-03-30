import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/winner_model.dart';
import '../../../utils/time_utils.dart';

/// 당첨자 리스트 아이템
class WinnerListItem extends StatelessWidget {
  final WinnerModel winner;
  final VoidCallback? onTap;

  const WinnerListItem({
    super.key,
    required this.winner,
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
            SizedBox(width: 12),

            // 당첨 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 닉네임 + 뱃지
                  Row(
                    children: [
                      Text(
                        winner.nickName,
                        style: AppTextStyles.body3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      const SizedBox(width: 6),
                      _buildEventBadge(),
                    ],
                  ),
                  SizedBox(height: 4),

                  // 상품명
                  Text(
                    winner.productName,
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.medium,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),

                  // 이벤트 타입 + 시간
                  Row(
                    children: [
                      Text(
                        winner.eventType.displayName,
                        style: AppTextStyles.body4.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '•',
                        style: AppTextStyles.body4.copyWith(
                          color: AppColors.medium,
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        TimeUtils.getRelativeTime(winner.winDate),
                        style: AppTextStyles.body4.copyWith(
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
        child: winner.hasProfileImage
            ? Image.network(
                winner.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildInitialAvatar();
                },
              )
            : _buildInitialAvatar(),
      ),
    );
  }

  /// 초성 아바타 (프로필 이미지가 없을 때)
  Widget _buildInitialAvatar() {
    return Container(
      color: AppColors.blue,
      alignment: Alignment.center,
      child: Text(
        winner.initial,
        style: AppTextStyles.title1.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 이벤트 배지
  Widget _buildEventBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getBadgeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        winner.eventType.displayName,
        style: AppTextStyles.caption1.copyWith(
          color: _getBadgeColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  /// 이벤트 타입별 배지 색상
  Color _getBadgeColor() {
    switch (winner.eventType) {
      case EventType.daily:
        return AppColors.blue;
      case EventType.select:
        return AppColors.purple;
      case EventType.vibe:
        return AppColors.pink;
      case EventType.prime:
        return AppColors.yellow500;
    }
  }
}
