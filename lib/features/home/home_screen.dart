import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../models/game_round_model.dart';
import '../../providers/blockpick_provider.dart';
import '../../providers/ad_reward_provider.dart';
import '../../providers/current_tab_provider.dart';
import '../../providers/wish_provider.dart';

/// 데일리 게임 화면 — 위시 스타일 UI/UX
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum GameViewMode { swipe, list, gallery }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  GameViewMode _viewMode = GameViewMode.swipe;

  void _setViewMode(GameViewMode mode) {
    setState(() => _viewMode = mode);
    ref.read(gameSwipeModeProvider.notifier).state = mode == GameViewMode.swipe;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adRewardServiceProvider.future).then((_) {}).catchError((_) {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // game_provider → blockpick_provider 마이그레이션 (S22)
    final gamesAsync = ref.watch(blockpicksByGameTypeProvider(GameType.daily));

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
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
          ),
        ),
        error: (error, _) => _buildErrorState(error),
      ),
    );
  }

  /// 플로팅 투명 헤더
  Widget _buildFloatingHeader() {
    final authState = ref.watch(authProvider);
    final userBalance = authState.valueOrNull?.user?.eventPoint.toInt() ?? 0;

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
              if (_viewMode == GameViewMode.swipe)
                IconButton(
                  onPressed: () {
                    ref.read(currentTabProvider.notifier).goToHome();
                  },
                  icon: const Icon(Icons.close_rounded, color: AppColors.gray600, size: 24),
                )
              else
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
              // 포인트 뱃지
              GestureDetector(
                onTap: () {
                  final isAuth = authState.valueOrNull?.isAuthenticated ?? false;
                  if (isAuth) {
                    context.push('/my/charge');
                  } else {
                    context.push('/login');
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.darkBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text('P', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.white)),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$userBalance',
                        style: AppTextStyles.caption1.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
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
      case GameViewMode.swipe:
        return _buildSwipeView(games);
      case GameViewMode.list:
        return _buildGameList(games);
      case GameViewMode.gallery:
        return _buildGalleryView(games);
    }
  }

  Widget _buildViewModeToggle() {
    Widget btn(IconData icon, GameViewMode mode) {
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
          btn(Icons.style_rounded, GameViewMode.swipe),
          btn(Icons.view_list_rounded, GameViewMode.list),
          btn(Icons.grid_view_rounded, GameViewMode.gallery),
        ],
      ),
    );
  }

  /// 틴더 스타일 카드 스택 (무한 순환)
  Widget _buildSwipeView(List<GameRound> games) {
    return _GameSwipeDeck(
      key: ValueKey('deck_${games.length}'),
      games: games,
      onTap: (g) => context.go('/game/${g.id}'),
    );
  }

  /// 리스트 뷰
  Widget _buildGameList(List<GameRound> games) {
    final topPad = MediaQuery.of(context).padding.top + 52;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 100),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _GameListCard(
            game: game,
            onTap: () => context.go('/game/${game.id}'),
          ),
        );
      },
    );
  }

  /// 갤러리 (그리드) 뷰
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
          onTap: () => context.go('/game/${game.id}'),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusLg)),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: _gameImage(game),
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

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_rounded, size: 64, color: AppColors.gray400),
          const SizedBox(height: 16),
          Text(
            '게임이 없습니다',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
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
          Icon(Icons.error_outline_rounded, size: 64, color: AppColors.red),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray700),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => ref.invalidate(blockpicksByGameTypeProvider),
            child: Text('다시 시도', style: TextStyle(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }

  static Widget _gameImage(GameRound game) {
    if (game.imageUrl.isEmpty) {
      return Container(
        color: AppColors.gray100,
        child: Center(child: Icon(Icons.image_rounded, size: 32, color: AppColors.gray400)),
      );
    }
    return Image.network(
      game.imageUrl.replaceAll(' ', '%20'),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.gray100,
        child: Center(child: Icon(Icons.image_rounded, size: 32, color: AppColors.gray400)),
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
}

// ============================================================
// 틴더 스타일 카드 스택 — 무한 순환
// ============================================================

class _GameSwipeDeck extends StatefulWidget {
  final List<GameRound> games;
  final void Function(GameRound) onTap;

  const _GameSwipeDeck({
    super.key,
    required this.games,
    required this.onTap,
  });

  @override
  State<_GameSwipeDeck> createState() => _GameSwipeDeckState();
}

class _GameSwipeDeckState extends State<_GameSwipeDeck> with SingleTickerProviderStateMixin {
  int _index = 0;
  Offset _drag = Offset.zero;
  late final AnimationController _snapCtrl;
  Offset _snapFrom = Offset.zero;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        setState(() {
          _drag = Offset.lerp(_snapFrom, Offset.zero, Curves.easeOut.transform(_snapCtrl.value))!;
        });
      });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  void _goNext() {
    setState(() {
      _index = (_index + 1) % widget.games.length;
      _drag = Offset.zero;
    });
  }

  void _snapBack() {
    _snapFrom = _drag;
    _snapCtrl.forward(from: 0);
  }

  int _realIndex(int offset) => (_index + offset) % widget.games.length;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 52;

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final threshold = w * 0.3;
      final stackCount = widget.games.length.clamp(1, 3);

      return Column(
        children: [
          SizedBox(height: topPad),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  for (int i = stackCount - 1; i >= 0; i--)
                    _buildCard(widget.games[_realIndex(i)], i, threshold),
                ],
              ),
            ),
          ),
          // 하단: 인디케이터
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.games.length.clamp(0, 8),
                (i) {
                  final isActive = _index % widget.games.length == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.textBlack : AppColors.gray300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildCard(GameRound game, int stackIndex, double threshold) {
    final isTop = stackIndex == 0;
    final scale = 1.0 - (stackIndex * 0.04);
    final yOffset = stackIndex * 10.0;

    Widget card = _GameSwipeCard(game: game);

    if (isTop) {
      final angle = (_drag.dx / 400) * 0.15;
      card = GestureDetector(
        onTap: () => widget.onTap(game),
        onPanUpdate: (d) {
          if (_snapCtrl.isAnimating) return;
          setState(() => _drag += d.delta);
        },
        onPanEnd: (d) {
          if (_drag.dx.abs() > threshold) {
            _goNext();
          } else {
            _snapBack();
          }
        },
        child: Transform.translate(
          offset: _drag,
          child: Transform.rotate(angle: angle, child: card),
        ),
      );
    } else {
      card = Transform.translate(
        offset: Offset(0, yOffset),
        child: Transform.scale(scale: scale, child: card),
      );
    }

    return card;
  }
}

// ============================================================
// 스와이프 카드 콘텐츠
// ============================================================

class _GameSwipeCard extends StatelessWidget {
  final GameRound game;
  const _GameSwipeCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.12),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HomeScreenState._gameImage(game),
                  // 타입 배지
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Text(
                        'Daily',
                        style: AppTextStyles.caption4.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  // 상태 배지
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: game.status.isJoinable
                            ? AppColors.green500.withValues(alpha: 0.9)
                            : AppColors.gray600.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Text(
                        game.status.badgeText,
                        style: AppTextStyles.caption4.copyWith(color: AppColors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title1.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  if (game.description.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      game.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.caption1.copyWith(color: AppColors.gray400),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // 가격
                      Text(
                        '${_HomeScreenState._formatPrice(game.currentPrice)}P',
                        style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const Spacer(),
                      // 참여자
                      const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Text('${game.participants}',
                          style: AppTextStyles.caption4.copyWith(color: AppColors.gray400)),
                      const SizedBox(width: 12),
                      // 그리드
                      const Icon(Icons.grid_view_rounded, size: 14, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Text(_formatGridSize(game.totalBlocks),
                          style: AppTextStyles.caption4.copyWith(color: AppColors.gray400)),
                    ],
                  ),
                  if (game.timeLeft.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    // 남은 시간
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Text(
                          '${game.timeLeft} 남음',
                          style: AppTextStyles.caption2.copyWith(color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatGridSize(int totalBlocks) {
    final size = math.sqrt(totalBlocks).round();
    return '$size×$size';
  }
}

// ============================================================
// 리스트 카드 (기존 HorizontalGameCard 스타일 간소화)
// ============================================================

class _GameListCard extends StatelessWidget {
  final GameRound game;
  final VoidCallback? onTap;

  const _GameListCard({required this.game, this.onTap});

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
                child: _HomeScreenState._gameImage(game),
              ),
            ),
            const SizedBox(width: 14),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.title,
                    style: AppTextStyles.title3.copyWith(fontWeight: FontWeight.w700),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_HomeScreenState._formatPrice(game.currentPrice)}P',
                    style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Text('${game.participants}',
                          style: AppTextStyles.caption4.copyWith(color: AppColors.gray500)),
                      const SizedBox(width: 10),
                      const Icon(Icons.timer_outlined, size: 13, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Text('${game.timeLeft} 남음',
                          style: AppTextStyles.caption4.copyWith(color: AppColors.gray500)),
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
