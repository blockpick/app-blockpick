import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../widgets/horizontal_game_card.dart';
import '../optimal/optimal_game_list_screen.dart';
import '../../components/common/common_app_bar.dart';

/// 게임 화면 (SC-009 디자인)
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  bool _isFabExpanded = true;

  final List<Map<String, dynamic>> _tabs = [
    {'label': 'Daily', 'type': GameType.daily, 'isPrime': false},
    {'label': 'Select', 'type': GameType.select, 'isPrime': false},
    {'label': 'Vibe', 'type': GameType.vibe, 'isPrime': false},
    {'label': 'Prime', 'type': null, 'isPrime': true}, // Prime은 OptimalGameListScreen 사용
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // 스크롤하면 FAB 축소
    if (_scrollController.offset > 100 && _isFabExpanded) {
      setState(() => _isFabExpanded = false);
    } else if (_scrollController.offset <= 100 && !_isFabExpanded) {
      setState(() => _isFabExpanded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final userBalance = authState.valueOrNull?.user?.balance?.toInt() ?? 0;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더 - "Event" + 포인트
            CommonAppBar(
              title: 'Event',
              trailing: PointBadge(
                balance: userBalance,
                onTap: () {
                  // TODO: 포인트 충전 화면으로 이동
                },
              ),
            ),

            // 탭
            _buildTabs(),

          // 콘텐츠
          Expanded(
            child: _buildContent(),
          ),
        ],
        ),
      ),
      // FAB - 당첨자 내역
      floatingActionButton: _buildFAB(),
    );
  }

  /// 탭 - 필 스타일
  Widget _buildTabs() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          final isSelected = _selectedTabIndex == index;
          return Padding(
            padding: EdgeInsets.only(right: index < _tabs.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTabIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkBlue : AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.darkBlue : AppColors.gray300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  _tabs[index]['label'] as String,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.white : AppColors.gray700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  /// 콘텐츠
  Widget _buildContent() {
    final selectedTab = _tabs[_selectedTabIndex];
    final isPrime = selectedTab['isPrime'] as bool;

    // Prime 탭은 OptimalGameListScreen 사용
    if (isPrime) {
      return const OptimalGameListScreen();
    }

    final gameType = selectedTab['type'] as GameType?;
    if (gameType == null) {
      return _buildEmptyState();
    }

    final gamesAsync = ref.watch(gamesByTypeProvider(gameType));

    return gamesAsync.when(
      data: (games) {
        if (games.isEmpty) {
          return _buildEmptyState();
        }
        return _buildGameList(games);
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
        ),
      ),
      error: (error, _) => _buildErrorState(error),
    );
  }

  /// 게임 리스트
  Widget _buildGameList(List<GameRound> games) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: games.length + 1, // +1 for AD banner
      itemBuilder: (context, index) {
        // 첫 번째는 AD 배너
        if (index == 0) {
          return _buildAdBanner();
        }

        final game = games[index - 1];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: HorizontalGameCard(
            game: game,
            onTap: () => context.go('/game/${game.id}'),
          ),
        );
      },
    );
  }

  /// AD 배너
  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Center(
        child: Text(
          'AD Banner',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
      ),
    );
  }

  /// FAB - 당첨자 내역 (부드러운 애니메이션)
  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        // TODO: 당첨자 내역 화면으로 이동
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: _isFabExpanded ? 20 : 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(_isFabExpanded ? 28 : 28),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.emoji_events_outlined,
              color: AppColors.white,
              size: 22,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: _isFabExpanded
                  ? const Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          '당첨자 내역',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
          ],
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
            Icons.inbox_rounded,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '게임이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
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
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.red,
          ),
          const SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              ref.invalidate(gamesByTypeProvider);
            },
            child: Text(
              '다시 시도',
              style: TextStyle(color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
