import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

/// 내 초대 링크 카드 — 링크 표시, 복사 / 공유 버튼
class InviteLinkCard extends StatelessWidget {
  final String? inviteCode;

  const InviteLinkCard({super.key, required this.inviteCode});

  String get _inviteUrl =>
      'https://blockpick.app/invite/${inviteCode ?? ''}';

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 링크가 복사되었어요')),
    );
  }

  void _shareInvite(BuildContext context) {
    if (inviteCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드가 아직 발급되지 않았어요')),
      );
      return;
    }
    Share.share(
      '친구가 BlockPick으로 초대했어요!\n블록 하나 고르고 추첨 기회 받기 → https://blockpick.app/invite/$inviteCode',
      subject: 'BlockPick 초대',
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (inviteCode == null) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            '초대 코드를 불러오지 못했어요',
            style: tt.bodyMedium?.copyWith(color: cs.error),
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('내 초대 링크', style: tt.titleSmall),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _inviteUrl,
                      style: tt.bodySmall?.copyWith(color: cs.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _copyLink(context),
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('링크 복사'),
              ),
            ),
            const SizedBox(height: 16),
            Text('공유하기', style: tt.titleSmall),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareButton(
                  icon: Icons.chat_bubble_outline,
                  label: '카카오톡',
                  onTap: () => _shareInvite(context),
                ),
                _ShareButton(
                  icon: Icons.sms_outlined,
                  label: '문자',
                  onTap: () => _shareInvite(context),
                ),
                _ShareButton(
                  icon: Icons.link,
                  label: '링크 복사',
                  onTap: () => _copyLink(context),
                ),
                _ShareButton(
                  icon: Icons.more_horiz,
                  label: '더보기',
                  onTap: () => _shareInvite(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ShareButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: cs.primaryContainer,
            child: Icon(icon, color: cs.onPrimaryContainer, size: 20),
          ),
          const SizedBox(height: 6),
          Text(label, style: tt.labelSmall),
        ],
      ),
    );
  }
}
