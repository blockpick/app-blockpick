import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import 'daily_buzz_game_screen.dart';

/// 데일리 탭 — 위시 화면 완전 복제 (GameRound 데이터 사용)
class DailyScreen extends ConsumerStatefulWidget {
  const DailyScreen({super.key});

  @override
  ConsumerState<DailyScreen> createState() => _DailyScreenState();
}

enum DailyViewMode { list, gallery }

class _DailyScreenState extends ConsumerState<DailyScreen> {
  DailyViewMode _viewMode = DailyViewMode.list;

  void _setViewMode(DailyViewMode mode) {
    setState(() => _viewMode = mode);
  }

  @override
  Widget build(BuildContext context) {
    final gamesAsync = ref.watch(gamesByTypeProvider(GameType.daily));
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: gamesAsync.when(
        data: (games) => Stack(
          children: [
            games.isEmpty ? _buildEmptyState() : _buildContent(games),
            _buildFloatingHeader(),
          ],
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryMain),
          ),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: AppColors.gray400),
              const SizedBox(height: 16),
              Text('오류가 발생했습니다', style: AppTextStyles.title2.copyWith(color: AppColors.gray700)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(gamesByTypeProvider),
                child: Text('다시 시도', style: TextStyle(color: AppColors.blue)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 플로팅 투명 헤더 (위시와 동일)
  Widget _buildFloatingHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
          child: Row(
            children: [
              const SizedBox(width: 16),
              const SizedBox(width: 4),
              Text(
                'Daily',
                style: AppTextStyles.heading2.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(),
              _buildViewModeToggle(),
              const SizedBox(width: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(List<GameRound> games) {
    switch (_viewMode) {
      case DailyViewMode.list:
        return _buildGameList(games);
      case DailyViewMode.gallery:
        return _buildGalleryView(games);
    }
  }

  Widget _buildViewModeToggle() {
    Widget btn(IconData icon, DailyViewMode mode) {
      final selected = _viewMode == mode;
      return GestureDetector(
        onTap: () => _setViewMode(mode),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: selected ? AppColors.textBlack : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Icon(
            icon,
            size: 16,
            color: selected ? AppColors.white : AppColors.gray400,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn(Icons.view_list_rounded, DailyViewMode.list),
          btn(Icons.grid_view_rounded, DailyViewMode.gallery),
        ],
      ),
    );
  }

  /// 리스트 뷰 (위시와 동일 구조)
  Widget _buildGameList(List<GameRound> games) {
    final topPad = MediaQuery.of(context).padding.top + 52;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 100),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _DailyListCard(
            game: game,
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DailyBuzzGameScreen(game: game))),
          ),
        );
      },
    );
  }

  /// 갤러리 (그리드) 뷰 (위시와 동일 구조)
  Widget _buildGalleryView(List<GameRound> games) {
    final topPad = MediaQuery.of(context).padding.top + 52;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => DailyBuzzGameScreen(game: game))),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
                        child: _gameImage(game),
                      ),
                      // 상태 배지
                      if (game.status.isJoinable)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.green500,
                              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textBlack,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatPrice(game.currentPrice)}P',
                        style: AppTextStyles.caption2.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 빈 상태 (위시와 동일 구조)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inbox_rounded, size: 36, color: AppColors.gray400),
          ),
          const SizedBox(height: 20),
          Text(
            '진행 중인 이벤트가 없어요',
            style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '새로운 이벤트가 곧 시작됩니다',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  static Widget _gameImage(GameRound game) {
    if (game.imageUrl.isEmpty) {
      return Container(
        color: AppColors.gray100,
        child: const Center(child: Icon(Icons.image_rounded, size: 32, color: AppColors.gray400)),
      );
    }
    return Image.network(
      game.imageUrl.replaceAll(' ', '%20'),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.gray100,
        child: const Center(child: Icon(Icons.image_rounded, size: 32, color: AppColors.gray400)),
      ),
    );
  }

  static String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final rem = price % 10000;
      if (rem == 0) return '$man만';
      return '$man만${rem.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
    }
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  static String _formatGridSize(int totalBlocks) {
    final size = math.sqrt(totalBlocks).round();
    return '$size×$size';
  }
}

// ============================================================
// 리스트 카드 — 위시 WishCard 구조 복제 (간소화)
// ============================================================

class _DailyListCard extends StatelessWidget {
  final GameRound game;
  final VoidCallback? onTap;

  const _DailyListCard({required this.game, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              child: SizedBox(
                width: 100,
                height: 100,
                child: _DailyScreenState._gameImage(game),
              ),
            ),
            const SizedBox(width: 14),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상태 배지
                  Row(
                    children: [
                      if (game.status.isJoinable)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: AppColors.green500,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.white),
                          ),
                        ),
                      Text(
                        game.status.badgeText,
                        style: AppTextStyles.caption4.copyWith(color: AppColors.gray400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    game.title,
                    style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_DailyScreenState._formatPrice(game.currentPrice)}P',
                    style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Text('${game.participants}',
                          style: AppTextStyles.caption4.copyWith(color: AppColors.gray500)),
                      if (game.timeLeft.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.timer_outlined, size: 13, color: AppColors.gray400),
                        const SizedBox(width: 3),
                        Text('${game.timeLeft} 남음',
                            style: AppTextStyles.caption4.copyWith(color: AppColors.gray500)),
                      ],
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
}
