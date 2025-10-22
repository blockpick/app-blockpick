import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../../data/mock_game_data.dart';
import '../../widgets/game_card.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 게임 리스트 화면
class GameListScreen extends StatefulWidget {
  final GameType gameType;

  const GameListScreen({
    super.key,
    required this.gameType,
  });

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
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
    {'label': 'Most Popular', 'value': 'popular'},
    {'label': 'Newest', 'value': 'newest'},
    {'label': 'Ending Soon', 'value': 'ending_soon'},
    {'label': 'Price Low to High', 'value': 'price_low'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      body: Column(
        children: [
          // 배너
          _buildBanner(),

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

  /// 배너
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.purple,
            AppColors.blue,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Text(
              'PICK YOUR PRIZE, MAKE IT YOURS',
              style: AppTextStyles.large.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Choose your favorite items and participate in exciting games',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
                          const SizedBox(width: 6),
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
                    labelStyle: AppTextStyles.bodySmall.copyWith(
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

          const SizedBox(height: 12),

          // 정렬 드롭다운
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_getFilteredGames().length} games',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.medium,
                ),
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _sortOptions.firstWhere(
                          (opt) => opt['value'] == _selectedSort,
                        )['label']!,
                        style: AppTextStyles.bodySmall.copyWith(
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
    final games = _getFilteredGames();

    if (games.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGameGrid(games);
  }

  /// 게임 그리드
  Widget _buildGameGrid(List<GameRound> games) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GameCard(
          game: game,
          onTap: () {
            // TODO: Navigate to game detail
            Navigator.pushNamed(
              context,
              '/game-detail',
              arguments: game.id,
            );
          },
        );
      },
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.inbox,
            size: 64,
            color: AppColors.buleGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No games found',
            style: AppTextStyles.medium.copyWith(
              color: AppColors.medium,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters',
            style: AppTextStyles.body.copyWith(
              color: AppColors.medium,
            ),
          ),
        ],
      ),
    );
  }

  /// 필터링된 게임 가져오기
  List<GameRound> _getFilteredGames() {
    var games = MockGameData.getGamesByType(widget.gameType);

    // 카테고리 필터
    if (_selectedCategory != 'ALL') {
      games = games.where((game) => game.category == _selectedCategory).toList();
    }

    // 정렬
    switch (_selectedSort) {
      case 'popular':
        games.sort((a, b) => b.participants.compareTo(a.participants));
        break;
      case 'newest':
        // TODO: 실제로는 created_at으로 정렬
        break;
      case 'ending_soon':
        // TODO: 실제로는 end_time으로 정렬
        break;
      case 'price_low':
        games.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
    }

    return games;
  }
}
