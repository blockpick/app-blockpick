import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/notification/notification_models.dart';
import '../data/notification/notification_remote_datasource.dart';

/// NotificationRemoteDataSource provider — 인증 필요
final notificationRemoteDataSourceProvider =
    FutureProvider<NotificationRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return NotificationRemoteDataSource(client);
});

/// myNotifications family input
class MyNotificationsInput {
  final bool? onlyUnread;
  final int? page;
  final int? size;

  const MyNotificationsInput({this.onlyUnread, this.page, this.size});

  @override
  bool operator ==(Object other) =>
      other is MyNotificationsInput &&
      onlyUnread == other.onlyUnread &&
      page == other.page &&
      size == other.size;

  @override
  int get hashCode => Object.hash(onlyUnread, page, size);
}

/// 내 알림 목록 (페이지)
final myNotificationsProvider = FutureProvider.autoDispose
    .family<MyNotificationsPage, MyNotificationsInput?>((ref, input) async {
  final ds = await ref.watch(notificationRemoteDataSourceProvider.future);
  return ds.fetchMyNotifications(
    onlyUnread: input?.onlyUnread,
    page: input?.page,
    size: input?.size,
  );
});

/// 내 알림 설정 — 자주 갱신되지 않으므로 autoDispose 사용
final notificationSettingProvider =
    FutureProvider.autoDispose<NotificationSetting>((ref) async {
  final ds = await ref.watch(notificationRemoteDataSourceProvider.future);
  return ds.fetchNotificationSetting();
});
