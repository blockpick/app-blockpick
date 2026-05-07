// Notification 도메인 DTO + enum

enum NotificationType {
  win,
  reward,
  inviteSuccess,
  missionComplete,
  deadline,
  announcement,
}

NotificationType notificationTypeFromString(String? s) {
  if (s == null) return NotificationType.announcement;
  switch (s) {
    case 'WIN':
      return NotificationType.win;
    case 'REWARD':
      return NotificationType.reward;
    case 'INVITE_SUCCESS':
      return NotificationType.inviteSuccess;
    case 'MISSION_COMPLETE':
      return NotificationType.missionComplete;
    case 'DEADLINE':
      return NotificationType.deadline;
    case 'ANNOUNCEMENT':
      return NotificationType.announcement;
    default:
      return NotificationType.announcement;
  }
}

class NotificationItem {
  final String id;
  final NotificationType notificationType;
  final String title;
  final String? body;
  final String? dataJson;
  final String? readAt;
  final String createdAt;

  const NotificationItem({
    required this.id,
    required this.notificationType,
    required this.title,
    this.body,
    this.dataJson,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) =>
      NotificationItem(
        id: json['id'] as String,
        notificationType:
            notificationTypeFromString(json['notificationType'] as String?),
        title: json['title'] as String,
        body: json['body'] as String?,
        dataJson: json['dataJson'] as String?,
        readAt: json['readAt'] as String?,
        createdAt: json['createdAt'] as String,
      );
}

class NotificationSetting {
  final bool pushWinning;
  final bool pushReward;
  final bool pushReferral;
  final bool pushDeadline;
  final bool pushMarketing;

  const NotificationSetting({
    required this.pushWinning,
    required this.pushReward,
    required this.pushReferral,
    required this.pushDeadline,
    required this.pushMarketing,
  });

  factory NotificationSetting.fromJson(Map<String, dynamic> json) =>
      NotificationSetting(
        pushWinning: json['pushWinning'] as bool? ?? false,
        pushReward: json['pushReward'] as bool? ?? false,
        pushReferral: json['pushReferral'] as bool? ?? false,
        pushDeadline: json['pushDeadline'] as bool? ?? false,
        pushMarketing: json['pushMarketing'] as bool? ?? false,
      );
}

// 페이지 응답 wrapper (unreadCount 포함)
class MyNotificationsPage {
  final List<NotificationItem> items;
  final double totalCount;
  final double unreadCount;
  final int page;
  final int size;
  final bool hasNext;

  const MyNotificationsPage({
    required this.items,
    required this.totalCount,
    required this.unreadCount,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  factory MyNotificationsPage.fromJson(Map<String, dynamic> json) =>
      MyNotificationsPage(
        items: ((json['items'] as List?) ?? const [])
            .map((e) => NotificationItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toDouble() ?? 0,
        unreadCount: (json['unreadCount'] as num?)?.toDouble() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 0,
        size: (json['size'] as num?)?.toInt() ?? 0,
        hasNext: json['hasNext'] as bool? ?? false,
      );
}
