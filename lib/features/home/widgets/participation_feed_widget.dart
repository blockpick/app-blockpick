import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/participation_feed_model.dart';

/// 실시간 참가 현황 위젯
class ParticipationFeedWidget extends StatelessWidget {
  final List<ParticipationFeedModel> participations;
  final VoidCallback? onViewMore;

  const ParticipationFeedWidget({
    super.key,
    required this.participations,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    // 최대 5개만 표시
    final displayList = participations.take(5).toList();

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Recent Participation',
              style: AppTextStyles.heading1.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),

          const Divider(height: 1),

          // 참가 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildParticipationItem(displayList[index]);
            },
          ),

          const Divider(height: 1),

          // View More 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: onViewMore ?? () {
                // TODO: 전체 리스트 페이지로 이동
              },
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Center(
                  child: Text(
                    'View more',
                    style: AppTextStyles.body3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 참가 아이템
  Widget _buildParticipationItem(ParticipationFeedModel participation) {
    // 각 게임마다 다른 색상 지정
    final colors = [
      AppColors.primaryMain,
      AppColors.primaryLight,
      AppColors.red,
      AppColors.green500,
      AppColors.yellow500,
    ];
    final colorIndex = participation.id.hashCode % colors.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // 상품 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colors[colorIndex].withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.card_giftcard,
                color: colors[colorIndex],
                size: 24,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participation.gameName,
                  style: AppTextStyles.body3.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  participation.userName,
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.medium,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // 시간 박스 (초록색)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.green500.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              participation.relativeTime,
              style: AppTextStyles.body4.copyWith(
                color: AppColors.green500,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
