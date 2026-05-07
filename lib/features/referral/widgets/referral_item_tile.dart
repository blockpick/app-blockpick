import 'package:flutter/material.dart';
import '../../../data/referral/referral_models.dart';

String _statusLabel(ReferralStatus status) {
  switch (status) {
    case ReferralStatus.pending:
      return '링크 클릭';
    case ReferralStatus.signedUp:
      return '회원가입 완료';
    case ReferralStatus.participated:
      return '참여 완료';
    case ReferralStatus.rewarded:
      return '보상 지급됨';
  }
}

Color _statusColor(ReferralStatus status, ColorScheme cs) {
  switch (status) {
    case ReferralStatus.pending:
      return cs.outline;
    case ReferralStatus.signedUp:
      return cs.tertiary;
    case ReferralStatus.participated:
      return cs.secondary;
    case ReferralStatus.rewarded:
      return cs.primary;
  }
}

/// 초대 실적 리스트 아이템
class ReferralItemTile extends StatelessWidget {
  final Referral referral;

  const ReferralItemTile({super.key, required this.referral});

  String _displayDate() {
    final raw = referral.rewardedAt ?? referral.signedUpAt ?? referral.createdAt;
    if (raw.length >= 16) {
      return '${raw.substring(0, 10).replaceAll('-', '.')} ${raw.substring(11, 16)}';
    }
    return raw;
  }

  String _inviteeName() {
    final id = referral.inviteeId;
    if (id == null || id.isEmpty) return '미가입 친구';
    final prefix = id.length >= 6 ? id.substring(0, 6) : id;
    return 'user-$prefix';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: cs.primaryContainer,
        child: Icon(Icons.person_outline, color: cs.onPrimaryContainer, size: 20),
      ),
      title: Text(_inviteeName(), style: tt.bodyMedium),
      subtitle: Text(_displayDate(), style: tt.bodySmall?.copyWith(color: cs.outline)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _statusColor(referral.status, cs).withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _statusLabel(referral.status),
          style: tt.labelSmall?.copyWith(color: _statusColor(referral.status, cs)),
        ),
      ),
    );
  }
}
