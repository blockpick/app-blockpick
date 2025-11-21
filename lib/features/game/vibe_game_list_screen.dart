import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// VIBE 게임 리스트 화면 (풀스크린 스와이프 방식)
class VibeGameListScreen extends ConsumerStatefulWidget {
  const VibeGameListScreen({super.key});

  @override
  ConsumerState<VibeGameListScreen> createState() => _VibeGameListScreenState();
}

class _VibeGameListScreenState extends ConsumerState<VibeGameListScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  String _selectedTheme = 'ALL';

  final List<Map<String, dynamic>> _themes = [
    {'label': 'ALL', 'value': 'ALL', 'icon': LucideIcons.sparkles},
    {'label': 'Tribute', 'value': 'Tribute', 'icon': LucideIcons.heart},
    {'label': 'Charity', 'value': 'Charity', 'icon': LucideIcons.gift},
    {'label': 'Art', 'value': 'Art', 'icon': LucideIcons.palette},
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      body: Stack(
        children: [
          // 메인 콘텐츠
          Column(
            children: [
              // 배너
              _buildBanner(),

              // 테마 필터
              _buildThemeFilter(),

              // 스와이프 카드
              Expanded(
                child: _buildContent(),
              ),
            ],
          ),

          // 상단 세이프 에어리어
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).padding.top,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFFF6B6B), // 따뜻한 핑크/레드
                    Color(0xFFFFB347), // 오렌지
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 배너 (따뜻한 오렌지/핑크 그라데이션)
  Widget _buildBanner() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF6B6B), // 따뜻한 핑크/레드
            Color(0xFFFFB347), // 오렌지
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const Icon(
              LucideIcons.heart,
              size: 48,
              color: AppColors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'VIBE',
              style: AppTextStyles.xlarge.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share your heart, make a difference',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white.withValues(alpha: 0.95),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 테마 필터
  Widget _buildThemeFilter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: _themes.map((theme) {
          final isSelected = _selectedTheme == theme['value'];
          final icon = theme['icon'] as IconData;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTheme = theme['value'] as String;
                _currentIndex = 0;
                _pageController.jumpToPage(0);
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFFF6B6B).withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFF6B6B)
                      : AppColors.buleGray,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isSelected
                        ? const Color(0xFFFF6B6B)
                        : AppColors.medium,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    theme['label'] as String,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isSelected
                          ? const Color(0xFFFF6B6B)
                          : AppColors.medium,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
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
          return _buildEmptyState();
        }

        return _buildSwipeableCards(filteredGames);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B6B)),
        ),
      ),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  /// 스와이프 가능한 카드 스택
  Widget _buildSwipeableCards(List<GameRound> games) {
    return Stack(
      children: [
        // 페이지뷰로 스와이프 구현
        PageView.builder(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _buildGameCard(game);
          },
        ),

        // 인디케이터
        Positioned(
          bottom: 20,
          left: 0,
          right: 0,
          child: _buildPageIndicator(games.length),
        ),
      ],
    );
  }

  /// 게임 카드
  Widget _buildGameCard(GameRound game) {
    return GestureDetector(
      onTap: () {
        context.go('/game/${game.id}');
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            children: [
              // 이미지 (상단 60%)
              Expanded(
                flex: 6,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 메인 이미지
                    game.imageUrl.isNotEmpty
                        ? Image.network(
                            game.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _buildImagePlaceholder();
                            },
                          )
                        : _buildImagePlaceholder(),

                    // 그라데이션 오버레이
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 120,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // 카테고리 배지
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          game.category,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFFFF6B6B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 정보 (하단 40%)
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 타이틀
                      Text(
                        game.title,
                        style: AppTextStyles.xlarge.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 12),

                      // 설명
                      if (game.description.isNotEmpty)
                        Expanded(
                          child: Text(
                            game.description,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.medium,
                              height: 1.5,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                      const SizedBox(height: 16),

                      // 하단 정보
                      Row(
                        children: [
                          // 참여자 수
                          _buildInfoChip(
                            icon: LucideIcons.users,
                            label: '${game.participants}명',
                            color: const Color(0xFFFF6B6B),
                          ),

                          const SizedBox(width: 12),

                          // 남은 시간
                          if (game.timeLeft.isNotEmpty)
                            _buildInfoChip(
                              icon: LucideIcons.clock,
                              label: game.timeLeft,
                              color: AppColors.blue,
                            ),

                          const Spacer(),

                          // 참여 버튼
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFF6B6B),
                                  Color(0xFFFFB347),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Join',
                                  style: AppTextStyles.body.copyWith(
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  LucideIcons.arrowRight,
                                  size: 18,
                                  color: AppColors.white,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 정보 칩
  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
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

  /// 페이지 인디케이터
  Widget _buildPageIndicator(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final isActive = index == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFF6B6B)
                : AppColors.buleGray.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
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
          const SizedBox(height: 24),
          Text(
            'No VIBE games yet',
            style: AppTextStyles.large.copyWith(
              color: AppColors.medium,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Check back soon for new experiences',
            style: AppTextStyles.body.copyWith(
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
          const SizedBox(height: 16),
          Text(
            'Error loading games',
            style: AppTextStyles.medium.copyWith(
              color: AppColors.red,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: AppTextStyles.bodySmall.copyWith(
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
              backgroundColor: const Color(0xFFFF6B6B),
              foregroundColor: AppColors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

}
