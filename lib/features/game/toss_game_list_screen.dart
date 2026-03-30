import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/toss_game_card.dart';

/// 토스 스타일 게임 리스트 화면
class TossGameListScreen extends ConsumerStatefulWidget {
  final GameType gameType;

  const TossGameListScreen({
    super.key,
    required this.gameType,
  });

  @override
  ConsumerState<TossGameListScreen> createState() => _TossGameListScreenState();
}

class _TossGameListScreenState extends ConsumerState<TossGameListScreen> {
  String _selectedCategory = 'ALL';
  String _selectedSort = 'popular';

  final List<Map<String, dynamic>> _categories = [
    {'label': '전체', 'value': 'ALL'},
    {'label': '디지털', 'value': 'Digital'},
    {'label': '패션', 'value': 'Fashion'},
    {'label': '기프트', 'value': 'Gift'},
    {'label': '푸드', 'value': 'Food'},
  ];

  final List<Map<String, String>> _sortOptions = [
    {'label': '인기순', 'value': 'popular'},
    {'label': '최신순', 'value': 'newest'},
    {'label': '마감임박', 'value': 'ending_soon'},
    {'label': '가격낮은순', 'value': 'price_low'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // 필터 바
          _buildFilterSection(),

          // 게임 리스트
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  /// 필터 섹션
  Widget _buildFilterSection() {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // 카테고리 필터
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category['value'];

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category['value'] as String;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkBlue : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.darkBlue : AppColors.gray300,
                        ),
                      ),
                      child: Text(
                        category['label'] as String,
                        style: AppTextStyles.caption2,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // 구분선
          Container(
            height: 1,
            color: AppColors.gray100,
          ),

          // 게임 수 및 정렬
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer(
                  builder: (context, ref, child) {
                    final gamesAsync = ref.watch(gamesByTypeProvider(widget.gameType));
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
                      style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
                    );
                  },
                ),
                _buildSortDropdown(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<String>(
      initialValue: _selectedSort,
      onSelected: (value) {
        setState(() {
          _selectedSort = value;
        });
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      offset: const Offset(0, 36),
      itemBuilder: (context) => _sortOptions.map((option) {
        final isSelected = option['value'] == _selectedSort;
        return PopupMenuItem<String>(
          value: option['value'],
          child: Row(
            children: [
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: AppColors.blue,
                )
              else
                const SizedBox(width: 18),
              SizedBox(width: 8),
              Text(
                option['label']!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected ? AppColors.blue : AppColors.darkBlue,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _sortOptions.firstWhere(
                (opt) => opt['value'] == _selectedSort,
              )['label']!,
              style: AppTextStyles.body4.copyWith(color: AppColors.gray700),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 18,
              color: AppColors.gray600,
            ),
          ],
        ),
      ),
    );
  }

  /// 콘텐츠
  Widget _buildContent() {
    final gamesAsync = ref.watch(gamesByTypeProvider(widget.gameType));

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

        return _buildGameList(sortedGames);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
        ),
      ),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// 게임 리스트
  Widget _buildGameList(List<GameRound> games) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Padding(
          padding: EdgeInsets.only(bottom: index < games.length - 1 ? 12 : 0),
          child: TossGameCard(
            game: game,
            onTap: () {
              context.go('/game/${game.id}');
            },
          ),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 40,
              color: AppColors.gray500,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '게임이 없습니다',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 카테고리를 선택해보세요',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  /// 에러 상태
  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.red.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '오류가 발생했습니다',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray700),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              error.toString(),
              style: TextStyle(
                fontSize: 13,
                color: AppColors.gray500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(gamesByTypeProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              '다시 시도',
              style: AppTextStyles.title3,
            ),
          ),
        ],
      ),
    );
  }
}
