/// 사용자 프로필 모델
class UserProfile {
  final String userId;
  final String nickname;
  final String email;
  final String? profileImageUrl;
  final UserTier tier;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    required this.nickname,
    required this.email,
    this.profileImageUrl,
    required this.tier,
    required this.createdAt,
    required this.updatedAt,
  });

  UserProfile copyWith({
    String? userId,
    String? nickname,
    String? email,
    String? profileImageUrl,
    UserTier? tier,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      nickname: nickname ?? this.nickname,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      tier: tier ?? this.tier,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'nickname': nickname,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'tier': tier.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      nickname: json['nickname'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      tier: UserTier.values.firstWhere(
        (e) => e.name == json['tier'],
        orElse: () => UserTier.bronze,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}

/// 사용자 등급
enum UserTier {
  bronze,
  silver,
  gold,
  vip;

  String get displayName {
    switch (this) {
      case UserTier.bronze:
        return 'BRONZE';
      case UserTier.silver:
        return 'SILVER';
      case UserTier.gold:
        return 'GOLD';
      case UserTier.vip:
        return 'VIP';
    }
  }

  String get emoji {
    switch (this) {
      case UserTier.bronze:
        return '🥉';
      case UserTier.silver:
        return '🥈';
      case UserTier.gold:
        return '🥇';
      case UserTier.vip:
        return '💎';
    }
  }
}
