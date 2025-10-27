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
  String? get profileImageUrl => throw _privateConstructorUsedError;
  int get point => throw _privateConstructorUsedError;
  int get cash => throw _privateConstructorUsedError;
  bool get isPushNotification => throw _privateConstructorUsedError;
  bool get isMarketingNotification => throw _privateConstructorUsedError;
  bool get isBan => throw _privateConstructorUsedError;
  String get userRole => throw _privateConstructorUsedError;
  bool get isSocialAccount => throw _privateConstructorUsedError;
  String? get socialProvider => throw _privateConstructorUsedError;
  String? get socialName =>
      throw _privateConstructorUsedError; // 레거시 필드 (하위 호환성)
  String? get name => throw _privateConstructorUsedError;
  String? get role => throw _privateConstructorUsedError;

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
    int point,
    int cash,
    bool isPushNotification,
    bool isMarketingNotification,
    bool isBan,
    String userRole,
    bool isSocialAccount,
    String? socialProvider,
    String? socialName,
    String? name,
    String? role,
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
    Object? point = null,
    Object? cash = null,
    Object? isPushNotification = null,
    Object? isMarketingNotification = null,
    Object? isBan = null,
    Object? userRole = null,
    Object? isSocialAccount = null,
    Object? socialProvider = freezed,
    Object? socialName = freezed,
    Object? name = freezed,
    Object? role = freezed,
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
            point: null == point
                ? _value.point
                : point // ignore: cast_nullable_to_non_nullable
                      as int,
            cash: null == cash
                ? _value.cash
                : cash // ignore: cast_nullable_to_non_nullable
                      as int,
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
            name: freezed == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String?,
            role: freezed == role
                ? _value.role
                : role // ignore: cast_nullable_to_non_nullable
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
    int point,
    int cash,
    bool isPushNotification,
    bool isMarketingNotification,
    bool isBan,
    String userRole,
    bool isSocialAccount,
    String? socialProvider,
    String? socialName,
    String? name,
    String? role,
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
    Object? point = null,
    Object? cash = null,
    Object? isPushNotification = null,
    Object? isMarketingNotification = null,
    Object? isBan = null,
    Object? userRole = null,
    Object? isSocialAccount = null,
    Object? socialProvider = freezed,
    Object? socialName = freezed,
    Object? name = freezed,
    Object? role = freezed,
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
        point: null == point
            ? _value.point
            : point // ignore: cast_nullable_to_non_nullable
                  as int,
        cash: null == cash
            ? _value.cash
            : cash // ignore: cast_nullable_to_non_nullable
                  as int,
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
        name: freezed == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String?,
        role: freezed == role
            ? _value.role
            : role // ignore: cast_nullable_to_non_nullable
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
    this.point = 0,
    this.cash = 0,
    this.isPushNotification = true,
    this.isMarketingNotification = true,
    this.isBan = false,
    this.userRole = 'USER',
    this.isSocialAccount = false,
    this.socialProvider,
    this.socialName,
    this.name,
    this.role,
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
  @override
  @JsonKey()
  final int point;
  @override
  @JsonKey()
  final int cash;
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
  // 레거시 필드 (하위 호환성)
  @override
  final String? name;
  @override
  final String? role;

  @override
  String toString() {
    return 'User(id: $id, email: $email, nickname: $nickname, profileImageUrl: $profileImageUrl, point: $point, cash: $cash, isPushNotification: $isPushNotification, isMarketingNotification: $isMarketingNotification, isBan: $isBan, userRole: $userRole, isSocialAccount: $isSocialAccount, socialProvider: $socialProvider, socialName: $socialName, name: $name, role: $role)';
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
            (identical(other.point, point) || other.point == point) &&
            (identical(other.cash, cash) || other.cash == cash) &&
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
                other.socialName == socialName) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.role, role) || other.role == role));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    email,
    nickname,
    profileImageUrl,
    point,
    cash,
    isPushNotification,
    isMarketingNotification,
    isBan,
    userRole,
    isSocialAccount,
    socialProvider,
    socialName,
    name,
    role,
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
    final int point,
    final int cash,
    final bool isPushNotification,
    final bool isMarketingNotification,
    final bool isBan,
    final String userRole,
    final bool isSocialAccount,
    final String? socialProvider,
    final String? socialName,
    final String? name,
    final String? role,
  }) = _$UserImpl;

  factory _User.fromJson(Map<String, dynamic> json) = _$UserImpl.fromJson;

  @override
  String? get id;
  @override
  String get email;
  @override
  String? get nickname;
  @override
  String? get profileImageUrl;
  @override
  int get point;
  @override
  int get cash;
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
  String? get socialName; // 레거시 필드 (하위 호환성)
  @override
  String? get name;
  @override
  String? get role;

  /// Create a copy of User
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserImplCopyWith<_$UserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
