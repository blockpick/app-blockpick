import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/entry/entry_models.dart';
import '../../providers/entry_provider.dart';
import 'widgets/entry_card.dart';

/// 참여내역 메인 화면 (기획 7-1)
/// 세그먼트: 전체 / 진행중 / 종료됨 / 당첨 / 미당첨
class ParticipationHistoryScreen extends ConsumerStatefulWidget {
  const ParticipationHistoryScreen({super.key});

  @override
  ConsumerState<ParticipationHistoryScreen> createState() =>
      _ParticipationHistoryScreenState();
}

enum _Segment { all, ongoing, ended, won, lost }

const _segmentLabels = {
  _Segment.all: '전체',
  _Segment.ongoing: '진행중',
  _Segment.ended: '종료됨',
  _Segment.won: '당첨',
  _Segment.lost: '미당첨',
};

class _ParticipationHistoryScreenState
    extends ConsumerState<ParticipationHistoryScreen> {
  _Segment _selected = _Segment.all;

  @override
  Widget build(BuildContext context) {
    // 참여 내역은 클라이언트에서 5탭 필터링하므로 전체 1회 호출
    final entriesAsync = ref.watch(myEntriesProvider(const MyEntriesInput()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('참여내역'),
        actions: [
          IconButton(
            tooltip: '알림함',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림함은 준비 중입니다.')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _SegmentBar(
            selected: _selected,
            onChanged: (s) => setState(() => _selected = s),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(myEntriesProvider);
              },
              child: entriesAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  message: '참여 내역을 불러오지 못했어요',
                  onRetry: () => ref.invalidate(myEntriesProvider),
                ),
                data: (page) {
                  final filtered = _filter(page.items, _selected);
                  if (filtered.isEmpty) {
                    return _EmptyState(segment: _selected);
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => EntryCard(
                      entry: filtered[i],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '참여 상세는 준비 중입니다 (entryId=${filtered[i].id.substring(0, 8)}…)',
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  static List<BlockpickEntry> _filter(
    List<BlockpickEntry> all,
    _Segment seg,
  ) {
    return switch (seg) {
      _Segment.all => all,
      _Segment.ongoing => all
          .where((e) =>
              e.status == BlockpickEntryStatus.pending ||
              e.status == BlockpickEntryStatus.confirmed)
          .toList(),
      _Segment.ended => all
          .where((e) =>
              e.status == BlockpickEntryStatus.settled ||
              e.status == BlockpickEntryStatus.won ||
              e.status == BlockpickEntryStatus.lost)
          .toList(),
      _Segment.won =>
        all.where((e) => e.status == BlockpickEntryStatus.won).toList(),
      _Segment.lost =>
        all.where((e) => e.status == BlockpickEntryStatus.lost).toList(),
    };
  }
}

class _SegmentBar extends StatelessWidget {
  final _Segment selected;
  final ValueChanged<_Segment> onChanged;

  const _SegmentBar({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          for (final seg in _Segment.values) ...[
            ChoiceChip(
              label: Text(_segmentLabels[seg]!),
              selected: selected == seg,
              onSelected: (_) => onChanged(seg),
              selectedColor: scheme.primaryContainer,
              labelStyle: TextStyle(
                color: selected == seg
                    ? scheme.onPrimaryContainer
                    : scheme.onSurfaceVariant,
                fontWeight:
                    selected == seg ? FontWeight.w700 : FontWeight.w500,
              ),
              shape: const StadiumBorder(),
            ),
            const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final _Segment segment;
  const _EmptyState({required this.segment});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (title, subtitle) = switch (segment) {
      _Segment.all => ('아직 참여한 블록픽이 없어요', '지금 참여 가능한 이벤트를 둘러보세요'),
      _Segment.ongoing => ('진행 중인 참여가 없어요', '새 블록픽에 참여해 보세요'),
      _Segment.ended => ('종료된 참여 내역이 없어요', '마감된 블록픽이 여기에 모여요'),
      _Segment.won => ('아직 당첨된 내역이 없어요', '지금 바로 참여해 보세요'),
      _Segment.lost => ('미당첨 내역이 없어요', '재참여로 다음 기회를 노려 보세요'),
    };
    final showBlockpickCta = segment == _Segment.all || segment == _Segment.ongoing;

    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.inbox_outlined,
            size: 64, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Center(
          child: Text(title, style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (showBlockpickCta) ...[
          const SizedBox(height: 24),
          Center(
            child: FilledButton.icon(
              onPressed: () => context.go('/blockpicks'),
              icon: const Icon(Icons.grid_view_outlined, size: 18),
              label: const Text('블록픽 보러가기'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline,
            size: 56, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        Center(child: Text(message)),
        const SizedBox(height: 16),
        Center(
          child: OutlinedButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ),
      ],
    );
  }
}
