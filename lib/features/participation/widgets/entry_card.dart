import 'package:flutter/material.dart';
import '../../../data/entry/entry_models.dart';

class EntryCard extends StatelessWidget {
  final BlockpickEntry entry;
  final VoidCallback? onTap;

  const EntryCard({super.key, required this.entry, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.grid_4x4, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '블록픽 #${entry.blockpickId.substring(0, entry.blockpickId.length.clamp(0, 8))}',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '선택 좌표 R${entry.selectedRow}-C${entry.selectedCol}',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        _StatusBadge(status: entry.status),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(entry.createdAt),
                          style: theme.textTheme.bodySmall
                              ?.copyWith(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(String iso) {
    if (iso.length < 16) return iso;
    return iso.substring(0, 16).replaceAll('T', ' ');
  }
}

class _StatusBadge extends StatelessWidget {
  final BlockpickEntryStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (label, fg, bg) = switch (status) {
      BlockpickEntryStatus.pending => ('대기 중', scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      BlockpickEntryStatus.confirmed => ('진행중', scheme.primary, scheme.primaryContainer),
      BlockpickEntryStatus.settled => ('종료', scheme.onSurfaceVariant, scheme.surfaceContainerHighest),
      BlockpickEntryStatus.won => ('당첨', Colors.white, Colors.green.shade600),
      BlockpickEntryStatus.lost => ('미당첨', scheme.onErrorContainer, scheme.errorContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
