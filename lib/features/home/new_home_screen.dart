import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../data/mock_event_cash_data.dart';
import '../../data/mock_event_banner_data.dart';
import '../../data/mock_announcement_data.dart';
import '../../models/event_cash_model.dart';
import 'widgets/event_cash_widget.dart';
import 'widgets/event_banner_carousel.dart';
import 'widgets/rolling_announcements_widget.dart';
import 'widgets/pick_section_premium_widget.dart';
import 'widgets/blockpick_guide_widget.dart';
import 'widgets/tutorial_button_widget.dart';
import 'widgets/participation_feed_widget.dart';
import 'widgets/mall_preview_widget.dart';
import 'widgets/review_section_widget.dart';
import '../../data/mock_participation_feed_data.dart';

/// 새로운 홈 화면 (피그마 디자인 기반)
class NewHomeScreen extends ConsumerWidget {
  const NewHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;

    // 사용자 실제 데이터로 EventCashModel 생성
    final eventCashData = EventCashModel(
      totalAmount: user?.balance ?? 0.0,
      currency: 'KRW',
      todayChange: 0.0,
      todayChangePercent: 0.0,
      history: MockEventCashData.getEventCash().history,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. 이벤트 캐시
          EventCashWidget(
            cashData: eventCashData,
          ),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 2. 배너 슬라이드
          Container(
            color: AppColors.white,
            child: EventBannerCarousel(
              banners: MockEventBannerData.getBanners(),
            ),
          ),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 3. 롤링 공지사항
          RollingAnnouncementsWidget(
            announcements: MockAnnouncementData.getAnnouncements(),
            onTap: () {
              // TODO: 공지사항 상세 또는 목록으로 이동
            },
          ),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 4. Pick 섹션 (프리미엄 디자인 - 화려한 효과)
          const PickSectionPremiumWidget(),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 5. BlockPick 가이드
          const BlockPickGuideWidget(),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 6. 튜토리얼 버튼
          const TutorialButtonWidget(),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 7. 실시간 참가 현황
          ParticipationFeedWidget(
            participations: MockParticipationFeedData.getRecentParticipations(),
          ),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 8. Mall 미리보기
          const MallPreviewWidget(),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 9. 리뷰 섹션
          const ReviewSectionWidget(),

          const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

          // 10. Footer
          _buildFooter(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// Footer
  Widget _buildFooter() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 로고 또는 브랜드명
          Text(
            'BLOCKPICK',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.blue,
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 16),

          // 링크들
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterLink('About'),
              _buildFooterLink('Terms'),
              _buildFooterLink('Privacy'),
              _buildFooterLink('Help'),
              _buildFooterLink('Contact'),
            ],
          ),

          const SizedBox(height: 16),

          // 저작권
          Text(
            '© 2025 BlockPick. All rights reserved.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grayBlue,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return InkWell(
      onTap: () {
        // TODO: 각 페이지로 이동
      },
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.navy,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
