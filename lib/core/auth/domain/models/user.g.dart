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
  shoppingCash: (json['shoppingCash'] as num?)?.toDouble() ?? 0,
  eventPoint: (json['eventPoint'] as num?)?.toDouble() ?? 0,
  participationPoint: (json['participationPoint'] as num?)?.toDouble() ?? 0,
  isPushNotification: json['isPushNotification'] as bool? ?? true,
  isMarketingNotification: json['isMarketingNotification'] as bool? ?? true,
  isBan: json['isBan'] as bool? ?? false,
  userRole: json['userRole'] as String? ?? 'USER',
  isSocialAccount: json['isSocialAccount'] as bool? ?? false,
  socialProvider: json['socialProvider'] as String?,
  socialName: json['socialName'] as String?,
);

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'nickname': instance.nickname,
      'profileImageUrl': instance.profileImageUrl,
      'shoppingCash': instance.shoppingCash,
      'eventPoint': instance.eventPoint,
      'participationPoint': instance.participationPoint,
      'isPushNotification': instance.isPushNotification,
      'isMarketingNotification': instance.isMarketingNotification,
      'isBan': instance.isBan,
      'userRole': instance.userRole,
      'isSocialAccount': instance.isSocialAccount,
      'socialProvider': instance.socialProvider,
      'socialName': instance.socialName,
    };
