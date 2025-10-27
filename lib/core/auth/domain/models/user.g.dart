// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
  id: json['id'] as String?,
  email: json['email'] as String,
  nickname: json['nickname'] as String?,
  profileImageUrl: json['profileImageUrl'] as String?,
  point: (json['point'] as num?)?.toInt() ?? 0,
  cash: (json['cash'] as num?)?.toInt() ?? 0,
  isPushNotification: json['isPushNotification'] as bool? ?? true,
  isMarketingNotification: json['isMarketingNotification'] as bool? ?? true,
  isBan: json['isBan'] as bool? ?? false,
  userRole: json['userRole'] as String? ?? 'USER',
  isSocialAccount: json['isSocialAccount'] as bool? ?? false,
  socialProvider: json['socialProvider'] as String?,
  socialName: json['socialName'] as String?,
  name: json['name'] as String?,
  role: json['role'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'point': instance.point,
      'cash': instance.cash,
      'isPushNotification': instance.isPushNotification,
      'isMarketingNotification': instance.isMarketingNotification,
      'isBan': instance.isBan,
      'userRole': instance.userRole,
      'isSocialAccount': instance.isSocialAccount,
      'socialProvider': instance.socialProvider,
      'socialName': instance.socialName,
      'name': instance.name,
      'role': instance.role,
    };
