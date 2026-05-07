import 'package:flutter/material.dart';
import '../../../data/blockpick/blockpick_models.dart';

class BlockpickCard extends StatelessWidget {
  final BlockpickSummary item;
  final VoidCallback? onTap;

  const BlockpickCard({super.key, required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: item.thumbnailUrl != null && item.thumbnailUrl!.isNotEmpty
                  ? Image.network(
                      item.thumbnailUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _placeholder(scheme),
                    )
                  : _placeholder(scheme),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _StatusBadge(status: item.status),
                      if (item.isRecommended) ...[
                        const SizedBox(width: 6),
                        _Badge(label: '추천', color: scheme.tertiary),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.partner.name,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          size: 14, color: scheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                        _remaining(item.endTime),
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                      const Spacer(),
                      Text(
                        '참여 ${item.totalEntryCount.toInt()}',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(ColorScheme scheme) => Container(
        color: scheme.surfaceContainerHighest,
        child: Icon(Icons.image_outlined,
            size: 56, color: scheme.onSurfaceVariant),
      );

  static String _remaining(String iso) {
    try {
      final end = DateTime.parse(iso);
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) return '종료됨';
      if (diff.inDays >= 1) return '${diff.inDays}일 남음';
      if (diff.inHours >= 1) return '${diff.inHours}시간 남음';
      if (diff.inMinutes >= 1) return '${diff.inMinutes}분 남음';
      return '곧 마감';
    } catch (_) {
      return iso;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final BlockpickStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, fg, bg) = switch (status) {
      BlockpickStatus.draft => ('준비중', scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      BlockpickStatus.active => ('진행중', scheme.onPrimaryContainer, scheme.primaryContainer),
      BlockpickStatus.paused => ('일시중지', scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      BlockpickStatus.ended => ('종료', Colors.white, Colors.grey.shade600),
    };
    return _Badge(label: label, fg: fg, color: bg);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color? fg;
  const _Badge({required this.label, required this.color, this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg ?? Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
