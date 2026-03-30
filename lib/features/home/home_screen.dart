import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/ad_reward_provider.dart';
import '../../services/ad_reward_service.dart';
import '../../widgets/horizontal_game_card.dart';
import '../../widgets/transaction_floating_banner.dart';
import '../../providers/pending_transaction_provider.dart';
import '../optimal/optimal_game_list_screen.dart';
import '../more/more_screen.dart';
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
    {'label': 'Daily', 'type': GameType.daily, 'isPrime': false, 'isMore': false},
    {'label': 'Select', 'type': GameType.select, 'isPrime': false, 'isMore': false},
    {'label': 'Vibe', 'type': GameType.vibe, 'isPrime': false, 'isMore': false},
    {'label': 'Prime', 'type': null, 'isPrime': true, 'isMore': false},
    {'label': 'More', 'type': null, 'isPrime': false, 'isMore': true}, // 10가지 좌표 선택 모드 체험
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 광고 미리 로드 (build 후 실행)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _preloadAd();
    });
  }

  /// 광고 미리 로드
  void _preloadAd() {
    // adRewardServiceProvider를 미리 초기화하여 광고 로드
    ref.read(adRewardServiceProvider.future).then((_) {
      debugPrint('✅ 광고 서비스 초기화 완료');
    }).catchError((e) {
      debugPrint('⚠️ 광고 서비스 초기화 실패: $e');
    });
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
    final userBalance = authState.valueOrNull?.user?.eventPoint.toInt() ?? 0;

    final pendingTx = ref.watch(pendingTransactionNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 - "Event" + 포인트
                CommonAppBar(
                  title: 'Event',
                  trailing: PointBadge(
                    balance: userBalance,
                    onTap: () {
                      final isAuth = authState.valueOrNull?.isAuthenticated ?? false;
                      if (isAuth) {
                        context.push('/my/charge');
                      } else {
                        context.push('/login');
                      }
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

            // 트랜잭션 상태 배너 (하단)
            if (pendingTx != null)
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TransactionFloatingBanner(),
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
                  style: AppTextStyles.title3,
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
    final isMore = selectedTab['isMore'] as bool? ?? false;

    // Prime 탭은 OptimalGameListScreen 사용
    if (isPrime) {
      return const OptimalGameListScreen();
    }

    // More 탭은 MoreScreen 사용
    if (isMore) {
      return const MoreScreen();
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

  /// 보상형 광고 배너
  Widget _buildAdBanner() {
    final adRewardState = ref.watch(adRewardNotifierProvider);
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final userId = authState.valueOrNull?.user?.id ?? '';

    return GestureDetector(
      onTap: () async {
        if (!isAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('로그인이 필요합니다')),
          );
          context.push('/login');
          return;
        }

        if (adRewardState.isLoading || adRewardState.isShowingAd) {
          return;
        }

        final notifier = ref.read(adRewardNotifierProvider.notifier);
        final result = await notifier.showAdAndGetReward(
          contextType: AdContextType.homeDaily,
          userId: userId,
        );

        if (!mounted) return;

        if (result?.isSuccess == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${result!.grantedAmount}P 획득!'),
              backgroundColor: AppColors.green500,
            ),
          );
          // 유저 정보 새로고침
          ref.read(authProvider.notifier).refreshUser();
        } else if (result != null && result.reasonCode != null) {
          final message = switch (result.reasonCode) {
            'LIMIT_DAILY' => '오늘은 이미 보상을 받으셨습니다',
            'LIMIT_COOLDOWN' => '잠시 후 다시 시도해주세요',
            _ => '보상을 받을 수 없습니다',
          };
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        } else if (adRewardState.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('광고를 불러올 수 없습니다'),
              backgroundColor: AppColors.red,
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBlue,
              AppColors.darkBlue.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 아이콘
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: adRewardState.isLoading || adRewardState.isShowingAd
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      ),
                    )
                  : const Icon(
                      Icons.play_circle_filled_rounded,
                      color: AppColors.white,
                      size: 28,
                    ),
            ),
            SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '광고 보고 포인트 받기',
                    style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1일 5회 · 회당 20P',
                    style: AppTextStyles.body4.copyWith(color: AppColors.white.withValues(alpha: 0.8)),
                  ),
                ],
              ),
            ),
            // 보상 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '+20P',
                style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// FAB - 당첨자 내역 (부드러운 애니메이션)
  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        context.push('/winners');
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
                  ? Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          '당첨자 내역',
                          style: AppTextStyles.title3.copyWith(color: AppColors.white),
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
          SizedBox(height: 16),
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
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.red,
          ),
          SizedBox(height: 16),
          Text(
            '오류가 발생했습니다',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray700),
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
