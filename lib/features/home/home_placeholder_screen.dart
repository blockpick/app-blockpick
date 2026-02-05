import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../data/mock_event_cash_data.dart';
import '../../data/mock_event_banner_data.dart';
import '../../data/mock_participation_feed_data.dart';
import '../../data/mock_announcement_data.dart';
import '../../models/event_cash_model.dart';
import 'widgets/event_cash_widget.dart';
import 'widgets/event_banner_carousel.dart';
import 'widgets/tutorial_link_widget.dart';
import 'widgets/participation_feed_widget.dart';
import 'widgets/announcements_widget.dart';

/// Home 화면
class HomePlaceholderScreen extends ConsumerWidget {
  const HomePlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;

    // 사용자 실제 데이터로 EventCashModel 생성
    final eventCashData = EventCashModel(
      totalAmount: user?.eventPoint ?? 0.0,
      currency: 'KRW',
      todayChange: 0.0, // TODO: 백엔드에서 제공되면 변경
      todayChangePercent: 0.0, // TODO: 백엔드에서 제공되면 변경
      history: MockEventCashData.getEventCash().history, // 히스토리는 목 데이터 사용
    );

    return SingleChildScrollView(
        child: Column(
          children: [
            // 1. 이벤트 캐시 (실제 사용자 데이터)
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

            // 3. 튜토리얼 링크
            Container(
              color: AppColors.white,
              child: const TutorialLinkWidget(),
            ),

            const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

            // 4. 실시간 참가 현황
            ParticipationFeedWidget(
              participations: MockParticipationFeedData.getRecentParticipations(),
            ),

            const Divider(height: 1, thickness: 8, color: AppColors.deepWhite),

            // 5. 공지사항
            AnnouncementsWidget(
              announcements: MockAnnouncementData.getAnnouncements(),
            ),

            const SizedBox(height: 20),
          ],
        ),
    );
  }
}
