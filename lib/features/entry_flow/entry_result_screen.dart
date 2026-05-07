import 'package:flutter/material.dart';
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
              if (entry.status == BlockpickEntryStatus.lost) ...[
                const SizedBox(height: 20),
                _MoreChanceSection(context: context),
              ],
              const SizedBox(height: 40),
              _CtaButtons(entry: entry),
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

class _MoreChanceSection extends StatelessWidget {
  final BuildContext context;

  const _MoreChanceSection({required this.context});

  @override
  Widget build(BuildContext context) {
    const items = [
      (Icons.group_add, '친구초대'),
      (Icons.play_circle_outline, '광고 시청'),
      (Icons.assignment_turned_in, '미션 참여'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '추가 참여 방법',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ...items.map((item) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(item.$1, color: Theme.of(context).colorScheme.primary),
              title: Text(item.$2),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${item.$2} 화면으로 진입 — 준비 중')),
                );
              },
            )),
      ],
    );
  }
}

class _CtaButtons extends StatelessWidget {
  final BlockpickEntry entry;

  const _CtaButtons({required this.entry});

  @override
  Widget build(BuildContext context) {
    if (entry.status == BlockpickEntryStatus.won) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilledButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('당첨 정보 확인 — 준비 중')),
              );
            },
            child: const Text('당첨 정보 확인'),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('내 참여내역 보기'),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('내 참여내역 보기'),
        ),
        const SizedBox(height: 10),
        OutlinedButton(
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
          child: const Text('다른 블록픽 보러가기'),
        ),
      ],
    );
  }
}
