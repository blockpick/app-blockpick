// Referral 도메인 DTO + enum

enum ReferralStatus { pending, signedUp, participated, rewarded }

ReferralStatus referralStatusFromString(String? s) {
  if (s == null) return ReferralStatus.pending;
  switch (s) {
    case 'PENDING':
      return ReferralStatus.pending;
    case 'SIGNED_UP':
      return ReferralStatus.signedUp;
    case 'PARTICIPATED':
      return ReferralStatus.participated;
    case 'REWARDED':
      return ReferralStatus.rewarded;
    default:
      return ReferralStatus.pending;
  }
}

class Referral {
  final String id;
  final String inviterId;
  final String? inviteeId;
  final String inviteCode;
  final ReferralStatus status;
  final String? signedUpAt;
  final String? rewardedAt;
  final String createdAt;

  const Referral({
    required this.id,
    required this.inviterId,
    this.inviteeId,
    required this.inviteCode,
    required this.status,
    this.signedUpAt,
    this.rewardedAt,
    required this.createdAt,
  });

  factory Referral.fromJson(Map<String, dynamic> json) => Referral(
        id: json['id'] as String,
        inviterId: json['inviterId'] as String,
        inviteeId: json['inviteeId'] as String?,
        inviteCode: json['inviteCode'] as String,
        status: referralStatusFromString(json['status'] as String?),
        signedUpAt: json['signedUpAt'] as String?,
        rewardedAt: json['rewardedAt'] as String?,
        createdAt: json['createdAt'] as String,
      );
}

// myInviteCode Query 응답 wrapper
class MyInviteCodeInfo {
  final String? inviteCode;
  final double totalInvitees;

  const MyInviteCodeInfo({
    this.inviteCode,
    required this.totalInvitees,
  });

  factory MyInviteCodeInfo.fromJson(Map<String, dynamic> json) =>
      MyInviteCodeInfo(
        inviteCode: json['inviteCode'] as String?,
        totalInvitees: (json['totalInvitees'] as num?)?.toDouble() ?? 0,
      );
}
