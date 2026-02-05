// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

User _$UserFromJson(Map<String, dynamic> json) {
  return _User.fromJson(json);
}

/// @nodoc
mixin _$User {
  String? get id => throw _privateConstructorUsedError;
  String get email => throw _privateConstructorUsedError;
  String? get nickname => throw _privateConstructorUsedError;
  String? get profileImageUrl =>
      throw _privateConstructorUsedError; // 재화 필드 (GraphQL 스키마)
  double get shoppingCash => throw _privateConstructorUsedError;
  double get eventPoint => throw _privateConstructorUsedError;
  double get participationPoint => throw _privateConstructorUsedError; // 설정 필드
  bool get isPushNotification => throw _privateConstructorUsedError;
  bool get isMarketingNotification => throw _privateConstructorUsedError;
  bool get isBan => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;
  bool get isSocialAccount => throw _privateConstructorUsedError;
  String? get socialProvider => throw _privateConstructorUsedError;
  String? get socialName => throw _privateConstructorUsedError;

  /// Serializes this User to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserCopyWith<User> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserCopyWith<$Res> {
  factory $UserCopyWith(User value, $Res Function(User) then) =
      _$UserCopyWithImpl<$Res, User>;
  @useResult
  $Res call({
    String? id,
    String email,
    String? nickname,
    String? profileImageUrl,
    double shoppingCash,
    double eventPoint,
    double participationPoint,
    bool isPushNotification,
    bool isMarketingNotification,
    bool isBan,
    String userRole,
    bool isSocialAccount,
    String? socialProvider,
    String? socialName,
  });
}

/// @nodoc
class _$UserCopyWithImpl<$Res, $Val extends User>
    implements $UserCopyWith<$Res> {
  _$UserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = null,
    Object? nickname = freezed,
    Object? profileImageUrl = freezed,
    Object? shoppingCash = null,
    Object? eventPoint = null,
    Object? participationPoint = null,
    Object? isPushNotification = null,
    Object? isMarketingNotification = null,
    Object? isBan = null,
    Object? userRole = null,
    Object? isSocialAccount = null,
    Object? socialProvider = freezed,
    Object? socialName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: freezed == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String?,
            email: null == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                      as String,
            nickname: freezed == nickname
                ? _value.nickname
                : nickname // ignore: cast_nullable_to_non_nullable
                      as String?,
            profileImageUrl: freezed == profileImageUrl
                ? _value.profileImageUrl
                : profileImageUrl // ignore: cast_nullable_to_non_nullable
                      as String?,
            shoppingCash: null == shoppingCash
                ? _value.shoppingCash
                : shoppingCash // ignore: cast_nullable_to_non_nullable
                      as double,
            eventPoint: null == eventPoint
                ? _value.eventPoint
                : eventPoint // ignore: cast_nullable_to_non_nullable
                      as double,
            participationPoint: null == participationPoint
                ? _value.participationPoint
                : participationPoint // ignore: cast_nullable_to_non_nullable
                      as double,
            isPushNotification: null == isPushNotification
                ? _value.isPushNotification
                : isPushNotification // ignore: cast_nullable_to_non_nullable
                      as bool,
            isMarketingNotification: null == isMarketingNotification
                ? _value.isMarketingNotification
                : isMarketingNotification // ignore: cast_nullable_to_non_nullable
                      as bool,
            isBan: null == isBan
                ? _value.isBan
                : isBan // ignore: cast_nullable_to_non_nullable
                      as bool,
            userRole: null == userRole
                ? _value.userRole
                : userRole // ignore: cast_nullable_to_non_nullable
                      as String,
            isSocialAccount: null == isSocialAccount
                ? _value.isSocialAccount
                : isSocialAccount // ignore: cast_nullable_to_non_nullable
                      as bool,
            socialProvider: freezed == socialProvider
                ? _value.socialProvider
                : socialProvider // ignore: cast_nullable_to_non_nullable
                      as String?,
            socialName: freezed == socialName
                ? _value.socialName
                : socialName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$UserImplCopyWith<$Res> implements $UserCopyWith<$Res> {
  factory _$$UserImplCopyWith(
    _$UserImpl value,
    $Res Function(_$UserImpl) then,
  ) = __$$UserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String? id,
    String email,
    String? nickname,
    String? profileImageUrl,
    double shoppingCash,
    double eventPoint,
    double participationPoint,
    bool isPushNotification,
    bool isMarketingNotification,
    bool isBan,
    String userRole,
    bool isSocialAccount,
    String? socialProvider,
    String? socialName,
  });
}

/// @nodoc
class __$$UserImplCopyWithImpl<$Res>
    extends _$UserCopyWithImpl<$Res, _$UserImpl>
    implements _$$UserImplCopyWith<$Res> {
  __$$UserImplCopyWithImpl(_$UserImpl _value, $Res Function(_$UserImpl) _then)
    : super(_value, _then);

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? email = null,
    Object? nickname = freezed,
    Object? profileImageUrl = freezed,
    Object? shoppingCash = null,
    Object? eventPoint = null,
    Object? participationPoint = null,
    Object? isPushNotification = null,
    Object? isMarketingNotification = null,
    Object? isBan = null,
    Object? userRole = null,
    Object? isSocialAccount = null,
    Object? socialProvider = freezed,
    Object? socialName = freezed,
  }) {
    return _then(
      _$UserImpl(
        id: freezed == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String?,
        email: null == email
            ? _value.email
            : email // ignore: cast_nullable_to_non_nullable
                  as String,
        nickname: freezed == nickname
            ? _value.nickname
            : nickname // ignore: cast_nullable_to_non_nullable
                  as String?,
        profileImageUrl: freezed == profileImageUrl
            ? _value.profileImageUrl
            : profileImageUrl // ignore: cast_nullable_to_non_nullable
                  as String?,
        shoppingCash: null == shoppingCash
            ? _value.shoppingCash
            : shoppingCash // ignore: cast_nullable_to_non_nullable
                  as double,
        eventPoint: null == eventPoint
            ? _value.eventPoint
            : eventPoint // ignore: cast_nullable_to_non_nullable
                  as double,
        participationPoint: null == participationPoint
            ? _value.participationPoint
            : participationPoint // ignore: cast_nullable_to_non_nullable
                  as double,
        isPushNotification: null == isPushNotification
            ? _value.isPushNotification
            : isPushNotification // ignore: cast_nullable_to_non_nullable
                  as bool,
        isMarketingNotification: null == isMarketingNotification
            ? _value.isMarketingNotification
            : isMarketingNotification // ignore: cast_nullable_to_non_nullable
                  as bool,
        isBan: null == isBan
            ? _value.isBan
            : isBan // ignore: cast_nullable_to_non_nullable
                  as bool,
        userRole: null == userRole
            ? _value.userRole
            : userRole // ignore: cast_nullable_to_non_nullable
                  as String,
        isSocialAccount: null == isSocialAccount
            ? _value.isSocialAccount
            : isSocialAccount // ignore: cast_nullable_to_non_nullable
                  as bool,
        socialProvider: freezed == socialProvider
            ? _value.socialProvider
            : socialProvider // ignore: cast_nullable_to_non_nullable
                  as String?,
        socialName: freezed == socialName
            ? _value.socialName
            : socialName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$UserImpl implements _User {
  const _$UserImpl({
    this.id,
    required this.email,
    this.nickname,
    this.profileImageUrl,
    this.shoppingCash = 0,
    this.eventPoint = 0,
    this.participationPoint = 0,
    this.isPushNotification = true,
    this.isMarketingNotification = true,
    this.isBan = false,
    this.userRole = 'USER',
    this.isSocialAccount = false,
    this.socialProvider,
    this.socialName,
  });

  factory _$UserImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserImplFromJson(json);

  @override
  final String? id;
  @override
  final String email;
  @override
  final String? nickname;
  @override
  final String? profileImageUrl;
  // 재화 필드 (GraphQL 스키마)
  @override
  @JsonKey()
  final double shoppingCash;
  @override
  @JsonKey()
  final double eventPoint;
  @override
  @JsonKey()
  final double participationPoint;
  // 설정 필드
  @override
  @JsonKey()
  final bool isPushNotification;
  @override
  @JsonKey()
  final bool isMarketingNotification;
  @override
  @JsonKey()
  final bool isBan;
  @override
  @JsonKey()
  final String userRole;
  @override
  @JsonKey()
  final bool isSocialAccount;
  @override
  final String? socialProvider;
  @override
  final String? socialName;

  @override
  String toString() {
    return 'User(id: $id, email: $email, nickname: $nickname, profileImageUrl: $profileImageUrl, shoppingCash: $shoppingCash, eventPoint: $eventPoint, participationPoint: $participationPoint, isPushNotification: $isPushNotification, isMarketingNotification: $isMarketingNotification, isBan: $isBan, userRole: $userRole, isSocialAccount: $isSocialAccount, socialProvider: $socialProvider, socialName: $socialName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.profileImageUrl, profileImageUrl) ||
                other.profileImageUrl == profileImageUrl) &&
            (identical(other.shoppingCash, shoppingCash) ||
                other.shoppingCash == shoppingCash) &&
            (identical(other.eventPoint, eventPoint) ||
                other.eventPoint == eventPoint) &&
            (identical(other.participationPoint, participationPoint) ||
                other.participationPoint == participationPoint) &&
            (identical(other.isPushNotification, isPushNotification) ||
                other.isPushNotification == isPushNotification) &&
            (identical(
                  other.isMarketingNotification,
                  isMarketingNotification,
                ) ||
                other.isMarketingNotification == isMarketingNotification) &&
            (identical(other.isBan, isBan) || other.isBan == isBan) &&
            (identical(other.userRole, userRole) ||
                other.userRole == userRole) &&
            (identical(other.isSocialAccount, isSocialAccount) ||
                other.isSocialAccount == isSocialAccount) &&
            (identical(other.socialProvider, socialProvider) ||
                other.socialProvider == socialProvider) &&
            (identical(other.socialName, socialName) ||
                other.socialName == socialName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    nickname,
    profileImageUrl,
    shoppingCash,
    eventPoint,
    participationPoint,
    isPushNotification,
    isMarketingNotification,
    isBan,
    userRole,
    isSocialAccount,
    socialProvider,
    socialName,
  );

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      __$$UserImplCopyWithImpl<_$UserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserImplToJson(this);
  }
}

abstract class _User implements User {
  const factory _User({
    final String? id,
    required final String email,
    final String? nickname,
    final String? profileImageUrl,
    final double shoppingCash,
    final double eventPoint,
    final double participationPoint,
    final bool isPushNotification,
    final bool isMarketingNotification,
    final bool isBan,
    final String userRole,
    final bool isSocialAccount,
    final String? socialProvider,
    final String? socialName,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String? get id;
  @override
  String get email;
  @override
  String? get nickname;
  @override
  String? get profileImageUrl; // 재화 필드 (GraphQL 스키마)
  @override
  double get shoppingCash;
  @override
  double get eventPoint;
  @override
  double get participationPoint; // 설정 필드
  @override
  bool get isPushNotification;
  @override
  bool get isMarketingNotification;
  @override
  bool get isBan;
  @override
  String get userRole;
  @override
  bool get isSocialAccount;
  @override
  String? get socialProvider;
  @override
  String? get socialName;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
