import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/analytics/analytics_service.dart';
import '../../data/entry/entry_models.dart';
import '../../data/blockpick/blockpick_models.dart';

/// 6-1. 참여 결과 화면 (당첨/미당첨/대기 분기)
class EntryResultScreen extends StatelessWidget {
  final BlockpickEntry entry;
  final BlockpickDetail detail;

  const EntryResultScreen({
    super.key,
    required this.entry,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('참여 결과'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusSection(entry: entry, colorScheme: colorScheme),
              const SizedBox(height: 24),
              _InfoCard(entry: entry, colorScheme: colorScheme),
              // 당첨 시 보상 안내 카드
              if (entry.status == BlockpickEntryStatus.won) ...[
                const SizedBox(height: 20),
                _RewardInfoCard(colorScheme: colorScheme),
              ],
              // 미당첨 / 대기 시 추가 참여 방법
              if (entry.status != BlockpickEntryStatus.won) ...[
                const SizedBox(height: 20),
                _MoreChanceSection(
                  blockpickId: detail.id,
                  isPending: entry.status != BlockpickEntryStatus.lost,
                ),
              ],
              const SizedBox(height: 40),
              _CtaButtons(entry: entry, detail: detail),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  final BlockpickEntry entry;
  final ColorScheme colorScheme;

  const _StatusSection({required this.entry, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    switch (entry.status) {
      case BlockpickEntryStatus.won:
        return Column(
          children: [
            Icon(Icons.emoji_events, size: 72, color: Colors.amber.shade600),
            const SizedBox(height: 16),
            Text(
              '🎉 당첨되었어요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade700,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      case BlockpickEntryStatus.lost:
        return Column(
          children: [
            Icon(Icons.mood, size: 72, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              '아쉽지만 다음 기회에',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
      default:
        return Column(
          children: [
            Icon(Icons.hourglass_empty,
                size: 72, color: colorScheme.secondary),
            const SizedBox(height: 16),
            Text(
              '참여가 완료되었어요\n결과는 추첨 후 알려드려요',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        );
    }
  }
}

class _InfoCard extends StatelessWidget {
  final BlockpickEntry entry;
  final ColorScheme colorScheme;

  const _InfoCard({required this.entry, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final createdAtShort = entry.createdAt.length > 16
        ? entry.createdAt.substring(0, 16).replaceAll('T', ' ')
        : entry.createdAt;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoRow(
              label: '선택 좌표',
              value:
                  'R${entry.selectedRow + 1}-C${entry.selectedCol + 1}',
            ),
            const SizedBox(height: 10),
            _InfoRow(label: '참여 시간', value: createdAtShort),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'Tx',
              value: entry.txHash ?? '대기 중',
              isMonospace: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isMonospace;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontFamily: isMonospace ? 'monospace' : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _RewardInfoCard extends StatelessWidget {
  final ColorScheme colorScheme;

  const _RewardInfoCard({required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.emoji_events, size: 18, color: Colors.amber),
              const SizedBox(width: 8),
              Text(
                '보상 안내',
                style: tt.labelLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '• 당첨 내역에서 배송지를 입력해주세요\n'
            '• 배송지 입력 후 파트너가 발송합니다\n'
            '• 문의사항은 당첨 상세 화면에서 고객센터로 연락해주세요',
            style: tt.bodySmall?.copyWith(
              color: colorScheme.onSurface,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}

class _MoreChanceSection extends StatelessWidget {
  final String blockpickId;
  final bool isPending;

  const _MoreChanceSection({
    required this.blockpickId,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = [
      (
        icon: Icons.group_add,
        label: '친구 초대',
        subtitle: '초대 성공 시 참여권 1개',
        action: 'invite_friends',
        onTap: () {
          AnalyticsService.track(
            'result_screen_cta_clicked',
            {'action': 'invite_friends'},
          );
          context.push('/referral');
        },
      ),
      (
        icon: Icons.play_circle_outline,
        label: '광고 시청',
        subtitle: '광고 1회로 참여권 획득',
        action: 'watch_ad',
        onTap: () {
          AnalyticsService.track(
            'result_screen_cta_clicked',
            {'action': 'watch_ad'},
          );
          context.push('/ad-reward/$blockpickId');
        },
      ),
      (
        icon: Icons.assignment_turned_in_outlined,
        label: '미션 참여',
        subtitle: '미션 완료로 참여권 지급',
        action: 'mission',
        onTap: () {
          AnalyticsService.track(
            'result_screen_cta_clicked',
            {'action': 'mission'},
          );
          context.push('/mission?blockpickId=$blockpickId');
        },
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isPending ? '추가 참여 기회 얻기' : '다시 도전해볼까요?',
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: cs.outlineVariant),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(item.icon, color: cs.primary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label,
                                style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600)),
                            Text(item.subtitle,
                                style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right,
                          color: cs.onSurfaceVariant, size: 18),
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _CtaButtons extends StatelessWidget {
  final BlockpickEntry entry;
  final BlockpickDetail detail;

  const _CtaButtons({required this.entry, required this.detail});

  @override
  Widget build(BuildContext context) {
    if (entry.status == BlockpickEntryStatus.won) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () => context.push('/winnings'),
            child: const Text('당첨 내역 확인'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () => context.go('/participation'),
            child: const Text('내 참여내역 보기'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () => context.go('/participation'),
          child: const Text('내 참여내역 보기'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            AnalyticsService.track(
              'result_screen_cta_clicked',
              {'action': 'browse_other_blockpicks'},
            );
            context.go('/blockpicks');
          },
          child: const Text('다른 블록픽 보러가기'),
        ),
      ],
    );
  }
}
