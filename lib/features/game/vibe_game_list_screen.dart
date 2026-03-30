import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// VIBE 게임 리스트 화면 (세로 스크롤 카드 방식)
class VibeGameListScreen extends ConsumerStatefulWidget {
  const VibeGameListScreen({super.key});

  @override
  ConsumerState<VibeGameListScreen> createState() => _VibeGameListScreenState();
}

class _VibeGameListScreenState extends ConsumerState<VibeGameListScreen> {
  String _selectedTheme = 'ALL';

  final List<Map<String, dynamic>> _themes = [
    {'label': 'All', 'value': 'ALL'},
    {'label': 'Tribute', 'value': 'Tribute'},
    {'label': 'Charity', 'value': 'Charity'},
    {'label': 'Art', 'value': 'Art'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: CustomScrollView(
        slivers: [
          // 테마 필터
          SliverToBoxAdapter(
            child: SafeArea(
              bottom: false,
              child: _buildThemeFilter(),
            ),
          ),

          // 콘텐츠
          _buildContent(),
        ],
      ),
    );
  }

  /// 테마 필터 (미니멀한 탭 스타일)
  Widget _buildThemeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      color: AppColors.gray100,
      child: Row(
        children: _themes.map((theme) {
          final isSelected = _selectedTheme == theme['value'];
          final index = _themes.indexOf(theme);

          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTheme = theme['value'] as String;
                });
              },
              child: Container(
                margin: EdgeInsets.only(
                  right: index < _themes.length - 1 ? 8 : 0,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.red
                      : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.red.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  theme['label'] as String,
                  style: AppTextStyles.body4.copyWith(
                    color: isSelected ? Colors.white : AppColors.medium,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 콘텐츠
  Widget _buildContent() {
    final gamesAsync = ref.watch(gamesByTypeProvider(GameType.vibe));

    return gamesAsync.when(
      data: (games) {
        var filteredGames = games;

        // 테마 필터
        if (_selectedTheme != 'ALL') {
          filteredGames = filteredGames
              .where((game) => game.category == _selectedTheme)
              .toList();
        }

        if (filteredGames.isEmpty) {
          return SliverFillRemaining(child: _buildEmptyState());
        }

        return SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildGameCard(filteredGames[index]),
                );
              },
              childCount: filteredGames.length,
            ),
          ),
        );
      },
      loading: () => const SliverFillRemaining(
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
          ),
        ),
      ),
      error: (error, stack) => SliverFillRemaining(
        child: _buildErrorState(error),
      ),
    );
  }

  /// 게임 카드 (새로운 미니멀 디자인)
  Widget _buildGameCard(GameRound game) {
    return GestureDetector(
      onTap: () {
        context.go('/game/${game.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: AspectRatio(
                aspectRatio: 16 / 10,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    game.imageUrl.isNotEmpty
                        ? Image.network(
                            game.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),

                    // 카테고리 배지
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          game.category,
                          style: AppTextStyles.caption1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 정보
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 타이틀
                  Text(
                    game.title,
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppColors.dark,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 8),

                  // 설명
                  if (game.description.isNotEmpty)
                    Text(
                      game.description,
                      style: AppTextStyles.body3.copyWith(
                        color: AppColors.medium,
                        height: 1.5,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 16),

                  // 하단 정보
                  Row(
                    children: [
                      // 참여자 수
                      Icon(LucideIcons.users, size: 16, color: AppColors.medium),
                      SizedBox(width: 4),
                      Text(
                        '${game.participants}명',
                        style: AppTextStyles.body4.copyWith(
                          color: AppColors.medium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(width: 16),

                      // 남은 시간
                      if (game.timeLeft.isNotEmpty) ...[
                        Icon(LucideIcons.clock, size: 16, color: AppColors.medium),
                        SizedBox(width: 4),
                        Text(
                          game.timeLeft,
                          style: AppTextStyles.body4.copyWith(
                            color: AppColors.medium,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],

                      const Spacer(),

                      // Join 버튼
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.red,
                              AppColors.yellow500,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Join',
                              style: AppTextStyles.body4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              LucideIcons.arrowRight,
                              size: 14,
                              color: Colors.white,
                            ),
                          ],
                        ),
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

  /// 이미지 플레이스홀더
  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.buleGray.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          LucideIcons.image,
          size: 80,
          color: AppColors.medium,
        ),
      ),
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.heart,
            size: 80,
            color: AppColors.buleGray,
          ),
          SizedBox(height: 24),
          Text(
            'No VIBE games yet',
            style: AppTextStyles.heading1.copyWith(
              color: AppColors.medium,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Check back soon for new experiences',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.medium,
            ),
            textAlign: TextAlign.center,
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
          const Icon(
            LucideIcons.alertCircle,
            size: 64,
            color: AppColors.red,
          ),
          SizedBox(height: 16),
          Text(
            'Error loading games',
            style: AppTextStyles.title1.copyWith(
              color: AppColors.red,
            ),
          ),
          SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.body4.copyWith(
              color: AppColors.medium,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(gamesByTypeProvider);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}
