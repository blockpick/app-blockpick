import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/blockpick/blockpick_models.dart';
import '../../providers/blockpick_provider.dart';
import 'widgets/blockpick_card.dart';

/// 블록픽 리스트 화면 (기획 3-1)
/// 검색 / 카테고리 칩 / 정렬 / 필터 / 카드 리스트
class BlockpickListScreen extends ConsumerStatefulWidget {
  const BlockpickListScreen({super.key});

  @override
  ConsumerState<BlockpickListScreen> createState() =>
      _BlockpickListScreenState();
}

class _BlockpickListScreenState extends ConsumerState<BlockpickListScreen> {
  final _searchCtrl = TextEditingController();
  String? _categoryCode;
  BlockpickSortBy _sortBy = BlockpickSortBy.popular;
  bool _onlyOngoing = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = BlockpickFilterInput(
      keyword: _searchCtrl.text.trim().isEmpty ? null : _searchCtrl.text.trim(),
      categoryCode: _categoryCode,
      onlyOngoing: _onlyOngoing,
      sortBy: _sortBy,
    );
    final listAsync = ref.watch(blockpickListProvider(filter));
    final categoriesAsync = ref.watch(blockpickCategoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('블록픽'),
        actions: [
          IconButton(
            tooltip: '검색',
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
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
          _SearchBar(controller: _searchCtrl, onSubmit: () => setState(() {})),
          categoriesAsync.when(
            loading: () => const SizedBox(height: 44),
            error: (e, st) => const SizedBox(height: 44),
            data: (cats) => _CategoryChips(
              categories: cats,
              selectedCode: _categoryCode,
              onChanged: (code) => setState(() => _categoryCode = code),
            ),
          ),
          _SortAndFilter(
            sortBy: _sortBy,
            onlyOngoing: _onlyOngoing,
            onSortChanged: (s) => setState(() => _sortBy = s),
            onOngoingChanged: (v) => setState(() => _onlyOngoing = v),
          ),
          const Divider(height: 1),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(blockpickListProvider);
              },
              child: listAsync.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  onRetry: () => ref.invalidate(blockpickListProvider),
                ),
                data: (page) {
                  if (page.items.isEmpty) {
                    return _EmptyState(
                      hasActiveFilter: _searchCtrl.text.isNotEmpty ||
                          _categoryCode != null ||
                          !_onlyOngoing,
                      onResetFilter: () => setState(() {
                        _searchCtrl.clear();
                        _categoryCode = null;
                        _onlyOngoing = true;
                        _sortBy = BlockpickSortBy.popular;
                      }),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: page.items.length,
                    itemBuilder: (_, i) => BlockpickCard(
                      item: page.items[i],
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '블록픽 상세는 준비 중입니다 (id=${page.items[i].id.substring(0, 8)}…)',
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

  void _showSearch(BuildContext context) {
    showSearch<String>(
      context: context,
      delegate: _BlockpickSearchDelegate(initial: _searchCtrl.text),
    ).then((value) {
      if (value != null) {
        setState(() => _searchCtrl.text = value);
      }
    });
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const _SearchBar({required this.controller, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => onSubmit(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    controller.clear();
                    onSubmit();
                  },
                ),
          hintText: '브랜드명, 이벤트명으로 검색',
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor:
              Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<Category> categories;
  final String? selectedCode;
  final ValueChanged<String?> onChanged;

  const _CategoryChips({
    required this.categories,
    required this.selectedCode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _chip(context, label: '전체', code: null),
          for (final c in categories) _chip(context, label: c.name, code: c.code),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context,
      {required String label, required String? code}) {
    final selected = selectedCode == code;
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onChanged(code),
        shape: const StadiumBorder(),
      ),
    );
  }
}

class _SortAndFilter extends StatelessWidget {
  final BlockpickSortBy sortBy;
  final bool onlyOngoing;
  final ValueChanged<BlockpickSortBy> onSortChanged;
  final ValueChanged<bool> onOngoingChanged;

  const _SortAndFilter({
    required this.sortBy,
    required this.onlyOngoing,
    required this.onSortChanged,
    required this.onOngoingChanged,
  });

  static const _sortLabels = {
    BlockpickSortBy.popular: '인기순',
    BlockpickSortBy.latest: '최신순',
    BlockpickSortBy.deadlineSoon: '마감임박순',
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          DropdownButton<BlockpickSortBy>(
            value: sortBy,
            underline: const SizedBox.shrink(),
            isDense: true,
            items: [
              for (final s in _sortLabels.keys)
                DropdownMenuItem(value: s, child: Text(_sortLabels[s]!)),
            ],
            onChanged: (v) {
              if (v != null) onSortChanged(v);
            },
          ),
          const Spacer(),
          FilterChip(
            label: const Text('진행중만'),
            selected: onlyOngoing,
            onSelected: onOngoingChanged,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool hasActiveFilter;
  final VoidCallback? onResetFilter;

  const _EmptyState({
    this.hasActiveFilter = false,
    this.onResetFilter,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.search_off,
            size: 64, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Center(
          child: Text('찾는 블록픽이 없어요', style: theme.textTheme.titleMedium),
        ),
        const SizedBox(height: 6),
        Center(
          child: Text(
            '검색어나 필터를 변경해 보세요',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        if (hasActiveFilter && onResetFilter != null) ...[
          const SizedBox(height: 24),
          Center(
            child: OutlinedButton.icon(
              onPressed: onResetFilter,
              icon: const Icon(Icons.filter_alt_off_outlined, size: 16),
              label: const Text('필터 초기화'),
            ),
          ),
        ],
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.error_outline,
            size: 56, color: Theme.of(context).colorScheme.error),
        const SizedBox(height: 12),
        const Center(child: Text('블록픽을 불러오지 못했어요')),
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

class _BlockpickSearchDelegate extends SearchDelegate<String> {
  _BlockpickSearchDelegate({required String initial})
      : super(searchFieldLabel: '브랜드명, 이벤트명으로 검색') {
    query = initial;
  }

  @override
  List<Widget>? buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, ''),
      );

  @override
  Widget buildResults(BuildContext context) {
    close(context, query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('인기 검색어',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: const [
            Chip(label: Text('할인쿠폰')),
            Chip(label: Text('무료참여')),
            Chip(label: Text('신규오픈')),
          ],
        ),
      ],
    );
  }
}
