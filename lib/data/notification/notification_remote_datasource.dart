import 'package:graphql_flutter/graphql_flutter.dart';
import 'notification_models.dart';

class NotificationRemoteDataSource {
  final GraphQLClient _client;

  NotificationRemoteDataSource(this._client);

  static const String myNotificationsQuery = r'''
    query MyNotifications($input: MyNotificationsInput) {
      myNotifications(input: $input) {
        success
        code
        message
        items {
          id
          notificationType
          title
          body
          dataJson
          readAt
          createdAt
        }
        totalCount
        unreadCount
        page
        size
        hasNext
      }
    }
  ''';

  static const String markNotificationReadMutation = r'''
    mutation MarkNotificationRead($id: String!) {
      markNotificationRead(id: $id) {
        success
        code
        message
        notification {
          id
          notificationType
          title
          body
          dataJson
          readAt
          createdAt
        }
      }
    }
  ''';

  static const String notificationSettingQuery = r'''
    query NotificationSetting {
      notificationSetting {
        success
        code
        message
        setting {
          pushWinning
          pushReward
          pushReferral
          pushDeadline
          pushMarketing
        }
      }
    }
  ''';

  static const String updateNotificationSettingMutation = r'''
    mutation UpdateNotificationSetting($input: UpdateNotificationSettingInput!) {
      updateNotificationSetting(input: $input) {
        success
        code
        message
        setting {
          pushWinning
          pushReward
          pushReferral
          pushDeadline
          pushMarketing
        }
      }
    }
  ''';

  Future<MyNotificationsPage> fetchMyNotifications({
    bool? onlyUnread,
    int? page,
    int? size,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myNotificationsQuery),
        variables: {
          'input': {
            if (onlyUnread != null) 'onlyUnread': onlyUnread,
            if (page != null) 'page': page,
            if (size != null) 'size': size,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myNotifications'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myNotifications');
    }
    return MyNotificationsPage.fromJson(data as Map<String, dynamic>);
  }

  Future<NotificationItem?> markNotificationRead({required String id}) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(markNotificationReadMutation),
        variables: {'id': id},
      ),
    );

    final data = result.data?['markNotificationRead'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: markNotificationRead');
    }
    final n = data['notification'];
    if (n == null) return null;
    return NotificationItem.fromJson(n as Map<String, dynamic>);
  }

  Future<NotificationSetting> fetchNotificationSetting() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(notificationSettingQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['notificationSetting'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: notificationSetting');
    }
    final setting = data['setting'];
    if (setting == null) {
      throw Exception('Failed: notificationSetting (setting null)');
    }
    return NotificationSetting.fromJson(setting as Map<String, dynamic>);
  }

  Future<NotificationSetting> updateNotificationSetting({
    bool? pushWinning,
    bool? pushReward,
    bool? pushReferral,
    bool? pushDeadline,
    bool? pushMarketing,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateNotificationSettingMutation),
        variables: {
          'input': {
            if (pushWinning != null) 'pushWinning': pushWinning,
            if (pushReward != null) 'pushReward': pushReward,
            if (pushReferral != null) 'pushReferral': pushReferral,
            if (pushDeadline != null) 'pushDeadline': pushDeadline,
            if (pushMarketing != null) 'pushMarketing': pushMarketing,
          },
        },
      ),
    );

    final data = result.data?['updateNotificationSetting'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(
          data?['message'] ?? 'Failed: updateNotificationSetting');
    }
    final setting = data['setting'];
    if (setting == null) {
      throw Exception('Failed: updateNotificationSetting (setting null)');
    }
    return NotificationSetting.fromJson(setting as Map<String, dynamic>);
  }
}
