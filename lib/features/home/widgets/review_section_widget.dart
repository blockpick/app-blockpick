import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 리뷰 섹션 위젯
class ReviewSectionWidget extends StatelessWidget {
  const ReviewSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 리뷰 이벤트 배너
          _buildReviewEventBanner(),

          const SizedBox(height: 20),

          // 리뷰 리스트
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PICK REVIEW',
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 리뷰 전체 보기
                        // TODO: 네비게이션 구현
                      },
                      child: Row(
                        children: [
                          Text(
                            'View more',
                            style: AppTextStyles.body3.copyWith(
                              color: AppColors.blue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward,
                            color: AppColors.blue,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // 리뷰 카드 리스트
                SizedBox(
                  height: 240,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _getMockReviews().length,
                    separatorBuilder: (context, index) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final review = _getMockReviews()[index];
                      return _buildReviewCard(review);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 리뷰 이벤트 배너
  Widget _buildReviewEventBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientPurple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '✨ nice win',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Review Event',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Leave a review, win your spot!',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.rate_review,
              color: AppColors.purple,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  /// 리뷰 카드
  Widget _buildReviewCard(Review review) {
    return Container(
      width: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.gray300.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 사용자 정보
          Row(
            children: [
              // 아바타
              CircleAvatar(
                radius: 20,
                backgroundColor: review.avatarColor,
                child: Text(
                  review.userName[0].toUpperCase(),
                  style: AppTextStyles.body2.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      review.handle,
                      style: AppTextStyles.body4.copyWith(
                        color: AppColors.grayBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 리뷰 내용
          Text(
            review.content,
            style: AppTextStyles.body3.copyWith(
              color: AppColors.navy,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 12),

          // 리뷰 이미지 (있는 경우)
          if (review.hasImage) ...[
            Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.bgWhite,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image,
                  color: AppColors.grayBlue,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 시간
          Text(
            review.timestamp,
            style: AppTextStyles.body4.copyWith(
              color: AppColors.grayBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 목 리뷰 데이터
  List<Review> _getMockReviews() {
    return [
      Review(
        userName: 'Josha Temple',
        handle: '@Obnoxiouson...',
        content: '@Blockpick_official got my 2nd prize',
        timestamp: '6:42 PM · Jun 27, 2025',
        avatarColor: AppColors.pink,
        hasImage: true,
      ),
      Review(
        userName: 'Alex Johnson',
        handle: '@alexj',
        content: 'Amazing experience! Won an iPhone 16 Pro on my first try. BlockPick is legit!',
        timestamp: '3:15 PM · Jun 26, 2025',
        avatarColor: AppColors.blue,
        hasImage: false,
      ),
      Review(
        userName: 'Sarah Kim',
        handle: '@sarahk',
        content: 'Love the fair game mechanics. Finally a platform I can trust!',
        timestamp: '11:30 AM · Jun 26, 2025',
        avatarColor: AppColors.purple,
        hasImage: false,
      ),
      Review(
        userName: 'Mike Chen',
        handle: '@mikec',
        content: 'Got my Airpods Pro delivered super fast. Great customer service!',
        timestamp: '9:22 AM · Jun 25, 2025',
        avatarColor: AppColors.green500,
        hasImage: true,
      ),
    ];
  }
}

/// 리뷰 모델
class Review {
  final String userName;
  final String handle;
  final String content;
  final String timestamp;
  final Color avatarColor;
  final bool hasImage;

  Review({
    required this.userName,
    required this.handle,
    required this.content,
    required this.timestamp,
    required this.avatarColor,
    this.hasImage = false,
  });
}
