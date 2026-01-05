import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// 토스 스타일 공지사항 카드
class TossAnnouncementCard extends StatelessWidget {
  final VoidCallback? onTap;

  const TossAnnouncementCard({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.campaign_rounded,
                size: 22,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: 12),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '신규 회원 이벤트 진행 중!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkBlue,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '첫 참여 시 500 포인트 즉시 지급',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }
}
