import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 알림 설정 상태
class NotificationSettings {
  final bool pushEnabled;
  final bool marketingEnabled;

  const NotificationSettings({
    this.pushEnabled = true,
    this.marketingEnabled = false,
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? marketingEnabled,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      marketingEnabled: marketingEnabled ?? this.marketingEnabled,
    );
  }
}

/// 알림 설정 Provider
class NotificationSettingsNotifier extends AsyncNotifier<NotificationSettings> {
  static const _pushKey = 'notification_push_enabled';
  static const _marketingKey = 'notification_marketing_enabled';

  @override
  Future<NotificationSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    return NotificationSettings(
      pushEnabled: prefs.getBool(_pushKey) ?? true,
      marketingEnabled: prefs.getBool(_marketingKey) ?? false,
    );
  }

  Future<void> setPushEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);
    state = AsyncData(state.valueOrNull?.copyWith(pushEnabled: value) ??
        NotificationSettings(pushEnabled: value));
  }

  Future<void> setMarketingEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_marketingKey, value);
    state = AsyncData(state.valueOrNull?.copyWith(marketingEnabled: value) ??
        NotificationSettings(marketingEnabled: value));
  }
}

final notificationSettingsProvider =
    AsyncNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(() {
  return NotificationSettingsNotifier();
});
