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
    // 재화 필드 (GraphQL 스키마)
    @Default(0) double shoppingCash,
    @Default(0) double eventPoint,
    @Default(0) double participationPoint,
    // 설정 필드
    @Default(true) bool isPushNotification,
    @Default(true) bool isMarketingNotification,
    @Default(false) bool isBan,
    @Default('USER') String userRole,
    @Default(false) bool isSocialAccount,
    String? socialProvider,
    String? socialName,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
