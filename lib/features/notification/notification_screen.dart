import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';

/// 토스 스타일 알림 화면
class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // 더미 알림 데이터
  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'type': 'winner',
      'title': '축하합니다! 🎉',
      'message': '[나트랑 JW 메리어트] 이벤트에 당첨되셨습니다.',
      'time': '방금 전',
      'isRead': false,
      'icon': Icons.emoji_events_rounded,
      'iconColor': Colors.amber,
    },
    {
      'id': '2',
      'type': 'event',
      'title': '마감 임박',
      'message': '[다낭 퓨전 리조트] 이벤트가 1시간 후 마감됩니다.',
      'time': '10분 전',
      'isRead': false,
      'icon': Icons.timer_rounded,
      'iconColor': AppColors.red,
    },
    {
      'id': '3',
      'type': 'point',
      'title': '포인트 적립',
      'message': '이벤트 참여 보상으로 500P가 적립되었습니다.',
      'time': '1시간 전',
      'isRead': true,
      'icon': Icons.monetization_on_rounded,
      'iconColor': AppColors.blue,
    },
    {
      'id': '4',
      'type': 'system',
      'title': '새로운 이벤트',
      'message': '[푸켓 반얀트리] 신규 이벤트가 오픈되었습니다.',
      'time': '3시간 전',
      'isRead': true,
      'icon': Icons.campaign_rounded,
      'iconColor': AppColors.green500,
    },
    {
      'id': '5',
      'type': 'shopping',
      'title': '주문 배송 시작',
      'message': '주문하신 상품이 배송 시작되었습니다.',
      'time': '어제',
      'isRead': true,
      'icon': Icons.local_shipping_rounded,
      'iconColor': AppColors.darkBlue,
    },
    {
      'id': '6',
      'type': 'event',
      'title': '참여 완료',
      'message': '[발리 아야나 리조트] 이벤트 참여가 완료되었습니다.',
      'time': '어제',
      'isRead': true,
      'icon': Icons.check_circle_rounded,
      'iconColor': AppColors.green500,
    },
    {
      'id': '7',
      'type': 'system',
      'title': '앱 업데이트',
      'message': '새로운 기능이 추가되었습니다. 지금 확인해보세요!',
      'time': '2일 전',
      'isRead': true,
      'icon': Icons.system_update_rounded,
      'iconColor': AppColors.gray500,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final unreadCount = _notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            _buildHeader(unreadCount),

            // 알림 리스트
            Expanded(
              child: _notifications.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationCard(_notifications[index]);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int unreadCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
      child: Row(
        children: [
          // 뒤로가기 버튼
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 22,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(width: 4),
          // 타이틀
          Text(
            '알림',
            style: AppTextStyles.heading2.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Text(
                '$unreadCount',
                style: AppTextStyles.caption3.copyWith(color: AppColors.white),
              ),
            ),
          ],
          const Spacer(),
          // 모두 읽음 버튼
          if (unreadCount > 0)
            GestureDetector(
              onTap: _markAllAsRead,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '모두 읽음',
                  style: AppTextStyles.caption2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;

    return GestureDetector(
      onTap: () => _onNotificationTap(notification),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.white : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: isRead
              ? null
              : Border.all(color: AppColors.blue.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: isRead ? 0.04 : 0.08),
              blurRadius: isRead ? 8 : 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (notification['iconColor'] as Color).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Icon(
                notification['icon'] as IconData,
                size: 22,
                color: notification['iconColor'] as Color,
              ),
            ),
            const SizedBox(width: 14),
            // 내용
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification['title'] as String,
                          style: AppTextStyles.title2.copyWith(
                            fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                            color: AppColors.darkBlue,
                          ),
                        ),
                      ),
                      // 안읽음 표시
                      if (!isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification['message'] as String,
                    style: AppTextStyles.body3,
                  ),
                  SizedBox(height: 8),
                  Text(
                    notification['time'] as String,
                    style: AppTextStyles.body4.copyWith(color: AppColors.gray400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 40,
              color: AppColors.gray400,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '알림이 없습니다',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 소식이 있으면 알려드릴게요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
  }

  void _onNotificationTap(Map<String, dynamic> notification) {
    // 읽음 처리
    setState(() {
      notification['isRead'] = true;
    });

    // TODO: 알림 타입에 따라 적절한 화면으로 이동
    final type = notification['type'] as String;
    switch (type) {
      case 'winner':
        // 당첨 내역으로 이동
        break;
      case 'event':
        // 이벤트 상세로 이동
        break;
      case 'shopping':
        // 주문 내역으로 이동
        break;
      default:
        break;
    }
  }
}
