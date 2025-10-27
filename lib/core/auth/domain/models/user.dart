import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';
part 'user.g.dart';

@freezed
class User with _$User {
  const factory User({
    String? id,
    required String email,
    String? nickname,
    String? profileImageUrl,
    @Default(0) int point,
    @Default(0) int cash,
    @Default(true) bool isPushNotification,
    @Default(true) bool isMarketingNotification,
    @Default(false) bool isBan,
    @Default('USER') String userRole,
    @Default(false) bool isSocialAccount,
    String? socialProvider,
    String? socialName,
    // 레거시 필드 (하위 호환성)
    String? name,
    String? role,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
