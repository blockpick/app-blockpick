import 'package:flutter/material.dart';
import '../../../data/referral/referral_models.dart';

/// 내 초대 요약 카드 — 총 초대 수 / 초대 성공 수 / 획득한 참여권
class InviteSummaryCard extends StatelessWidget {
  final MyInviteCodeInfo codeInfo;
  final List<Referral> referrals;

  const InviteSummaryCard({
    super.key,
    required this.codeInfo,
    required this.referrals,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final totalInvitees = codeInfo.totalInvitees.toInt();
    final successCount = referrals
        .where((r) =>
            r.status == ReferralStatus.rewarded ||
            r.status == ReferralStatus.participated)
        .length;
    final rewardCount =
        referrals.where((r) => r.status == ReferralStatus.rewarded).length;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: cs.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _StatItem(
              label: '총 초대 수',
              value: '$totalInvitees',
              cs: cs,
              tt: tt,
            ),
            _Divider(),
            _StatItem(
              label: '초대 성공 수',
              value: '$successCount',
              cs: cs,
              tt: tt,
            ),
            _Divider(),
            _StatItem(
              label: '획득한 참여권',
              value: '$rewardCount개',
              cs: cs,
              tt: tt,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  final TextTheme tt;

  const _StatItem({
    required this.label,
    required this.value,
    required this.cs,
    required this.tt,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: tt.headlineMedium?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: cs.onPrimaryContainer.withValues(alpha: 0.7)),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: VerticalDivider(
        color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.3),
        thickness: 1,
      ),
    );
  }
}
