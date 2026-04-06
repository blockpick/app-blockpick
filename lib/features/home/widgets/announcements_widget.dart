import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/announcement_model.dart';

/// 공지사항 위젯
class AnnouncementsWidget extends StatelessWidget {
  final List<AnnouncementModel> announcements;
  final Function(AnnouncementModel)? onTapItem;
  final VoidCallback? onViewMore;

  AnnouncementsWidget({
    super.key,
    required this.announcements,
    this.onTapItem,
    this.onViewMore,
  });

  @override
  Widget build(BuildContext context) {
    // 최대 3개만 표시
    final displayList = announcements.take(3).toList();

    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Text(
              'Announcements',
              style: AppTextStyles.heading1.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 22,
              ),
            ),
          ),

          const Divider(height: 1),

          // 공지 리스트
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _buildAnnouncementItem(displayList[index]);
            },
          ),

          Divider(height: 1),

          // View More 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: InkWell(
              onTap: onViewMore ?? () {
                // TODO: 전체 리스트 페이지로 이동
              },
              borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
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

  /// 공지사항 아이템
  Widget _buildAnnouncementItem(AnnouncementModel announcement) {
    return InkWell(
      onTap: () {
        if (onTapItem != null) {
          onTapItem!(announcement);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              announcement.title,
              style: AppTextStyles.body3.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: AppColors.navy,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6),
            Text(
              announcement.formattedDate,
              style: AppTextStyles.body4.copyWith(
                color: AppColors.medium,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
