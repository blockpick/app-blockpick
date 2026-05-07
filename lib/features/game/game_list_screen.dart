import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../../providers/blockpick_provider.dart';
// sortedGamesProvider는 순수 정렬 함수로 game_provider에서만 유지
import '../../providers/game_provider.dart' show sortedGamesProvider;
import '../../widgets/game_card.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_constants.dart';
import '../../components/common/common_empty_state.dart';

/// 게임 리스트 화면
class GameListScreen extends ConsumerStatefulWidget {
  final GameType gameType;

  const GameListScreen({
    super.key,
    required this.gameType,
  });

  @override
  ConsumerState<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends ConsumerState<GameListScreen> {
  String _selectedCategory = 'ALL';
  String _selectedSort = 'popular';

  final List<Map<String, dynamic>> _categories = [
    {'label': 'ALL', 'value': 'ALL', 'icon': null},
    {'label': 'Digital', 'value': 'Digital', 'icon': LucideIcons.cpu},
    {'label': 'Fashion', 'value': 'Fashion', 'icon': LucideIcons.shirt},
    {'label': 'Gift', 'value': 'Gift', 'icon': LucideIcons.gift},
    {'label': 'Food', 'value': 'Food', 'icon': LucideIcons.utensilsCrossed},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'label': '인기순', 'value': 'popular'},
    {'label': '최신순', 'value': 'newest'},
    {'label': '마감임박', 'value': 'ending_soon'},
    {'label': '가격 낮은순', 'value': 'price_low'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // 필터 바
          _buildFilterBar(),

          // 게임 리스트
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 필터 바
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.buleGray),
        ),
      ),
      child: Column(
        children: [
          // 카테고리 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];
                final icon = category['icon'] as IconData?;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(
                            icon,
                            size: 16,
                            color: isSelected ? AppColors.white : AppColors.navy,
                          ),
                          SizedBox(width: 6),
                        ],
                        Text(category['label'] as String),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category['value'] as String;
                      });
                    },
                    selectedColor: AppColors.blue,
                    backgroundColor: AppColors.white,
                    labelStyle: AppTextStyles.body4.copyWith(
                      color: isSelected ? AppColors.white : AppColors.navy,
                      fontWeight: FontWeight.w600,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppColors.blue : AppColors.buleGray,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 12),

          // 정렬 드롭다운
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  // game_provider → blockpick_provider 마이그레이션 (S22)
                  final gamesAsync = ref.watch(blockpicksByGameTypeProvider(widget.gameType));
                  final count = gamesAsync.when(
                    data: (games) {
                      if (_selectedCategory == 'ALL') {
                        return games.length;
                      }
                      return games.where((g) => g.category == _selectedCategory).length;
                    },
                    loading: () => 0,
                    error: (_, __) => 0,
                  );

                  return Text(
                    '총 $count개',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.medium,
                    ),
                  );
                },
              ),
              PopupMenuButton<String>(
                initialValue: _selectedSort,
                onSelected: (value) {
                  setState(() {
                    _selectedSort = value;
                  });
                },
                itemBuilder: (context) => _sortOptions.map((option) {
                  return PopupMenuItem<String>(
                    value: option['value'],
                    child: Text(option['label']!),
                  );
                }).toList(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.buleGray),
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sortOptions.firstWhere(
                          (opt) => opt['value'] == _selectedSort,
                        )['label']!,
                        style: AppTextStyles.body4.copyWith(
                          color: AppColors.navy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        LucideIcons.chevronDown,
                        size: 16,
                        color: AppColors.navy,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 콘텐츠
  Widget _buildContent() {
    // game_provider → blockpick_provider 마이그레이션 (S22)
    final gamesAsync = ref.watch(blockpicksByGameTypeProvider(widget.gameType));

    return gamesAsync.when(
      data: (games) {
        var filteredGames = games;

        // 카테고리 필터
        if (_selectedCategory != 'ALL') {
          filteredGames = filteredGames
              .where((game) => game.category == _selectedCategory)
              .toList();
        }

        // 정렬
        final sortedGames = ref.watch(
          sortedGamesProvider(filteredGames, _selectedSort),
        );

        if (sortedGames.isEmpty) {
          return _buildEmptyState();
        }

        return _buildGameGrid(sortedGames);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
        ),
      ),
      error: (error, stack) => CommonEmptyState(
        icon: LucideIcons.alertCircle,
        message: '게임을 불러올 수 없습니다',
        buttonText: '다시 시도',
        onButtonPressed: () {
          ref.invalidate(blockpicksByGameTypeProvider);
        },
      ),
    );
  }

  /// 게임 그리드
  Widget _buildGameGrid(List<GameRound> games) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWeb = screenWidth > 600;

    if (isWeb) {
      // 웹: 2열 그리드 with Wrap
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH, vertical: 16),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: games.map((game) {
            return SizedBox(
              width: (screenWidth - 64) / 2, // 패딩과 간격 고려
              child: GameCard(
                game: game,
                onTap: () {
                  debugPrint('🎯 게임 카드 탭:');
                  debugPrint('   - game.id: ${game.id}');
                  debugPrint('   - game.imageUrl: ${game.imageUrl}');
                  debugPrint('   - 이동: /game/${game.id}');
                  context.go('/game/${game.id}');
                },
              ),
            );
          }).toList(),
        ),
      );
    } else {
      // 모바일: 1열 리스트
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH, vertical: 16),
        itemCount: games.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final game = games[index];
          return GameCard(
            game: game,
            onTap: () {
              debugPrint('🎯 게임 카드 탭:');
              debugPrint('   - game.id: ${game.id}');
              debugPrint('   - game.imageUrl: ${game.imageUrl}');
              debugPrint('   - 이동: /game/${game.id}');
              context.go('/game/${game.id}');
            },
          );
        },
      );
    }
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return const CommonEmptyState(
      icon: LucideIcons.inbox,
      message: '게임이 없습니다',
      subMessage: '필터를 변경해보세요',
    );
  }

}
