import 'package:flutter/material.dart';
import '../../data/ad_reward/ad_reward_models.dart';

/// 9-2. 광고 보상 완료 화면
class AdRewardCompleteScreen extends StatelessWidget {
  const AdRewardCompleteScreen({
    super.key,
    required this.log,
    this.ticketId,
  });

  final AdRewardLog log;
  final String? ticketId;

  String _formatDateTime(String watchedAt) {
    try {
      final dt = DateTime.parse(watchedAt).toLocal();
      final y = dt.year;
      final mo = dt.month.toString().padLeft(2, '0');
      final d = dt.day.toString().padLeft(2, '0');
      final h = dt.hour.toString().padLeft(2, '0');
      final mi = dt.minute.toString().padLeft(2, '0');
      return '$y-$mo-$d $h:$mi';
    } catch (_) {
      return watchedAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('보상 완료'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              // ── 일러스트 아이콘 ──
              Icon(
                Icons.confirmation_num,
                size: 96,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // ── 타이틀 ──
              Text(
                '참여권 1개를 획득했어요',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // ── 부타이틀 ──
              Text(
                '지금 바로 다시 참여할 수 있어요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ── 정보 카드 ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _InfoRow(
                      label: '발급 시각',
                      value: _formatDateTime(log.watchedAt),
                      valueStyle: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 10),
                    _InfoRow(
                      label: '티켓 ID',
                      value: ticketId ?? '발급 처리 중',
                      valueStyle: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── 하단 CTA ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).popUntil((route) => route.isFirst),
                  child: const Text('지금 다시 참여하기',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('내 참여내역 보기'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: valueStyle)),
      ],
    );
  }
}
