import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/current_tab_provider.dart';
import '../../components/common/common_app_bar.dart';
import '../../components/cards/promotion_card.dart';
import '../../components/cards/coming_soon_item_card.dart';
import '../../components/cards/coming_soon_overlay_card.dart';
import 'widgets/daily_checkin_modal.dart';

/// SC-008 새 홈 화면 (오픈 버전)
class NewHomeScreen extends ConsumerStatefulWidget {
  const NewHomeScreen({super.key});

  @override
  ConsumerState<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends ConsumerState<NewHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _showTopButton = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 300;
    if (showButton != _showTopButton) {
      setState(() {
        _showTopButton = showButton;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final user = authState.valueOrNull?.user;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              controller: _scrollController,
              slivers: [
                // 앱바 (로고 + 알림)
                SliverToBoxAdapter(
                  child: CommonAppBar(
                    showLogo: true,
                    trailing: NotificationButton(
                      hasNotification: true,
                      onTap: () => context.push('/notifications'),
                    ),
                  ),
                ),

                // ① 상단 배너 (노란색 브랜딩 배너)
                _buildBrandingBanner(),

                // ② 이벤트 포인트 버튼
                _buildEventPointButton(isAuthenticated, user),

                // ②-1 출석체크 버튼
                _buildCheckinButton(isAuthenticated),

                // ③ 프로모션 리스트 (LIVE/DAILY 이벤트)
                _buildPromotionListSection(),

                // ③-1 Coming Soon 이벤트 섹션
                _buildComingSoonSection(),

                // ④ AD 배너 영역
                _buildAdBanner(),

                // ⑤ 마감임박 이벤트 섹션
                _buildClosingSoonEventsSection(),

                // ⑥ 최근 당첨자 섹션
                _buildRecentWinnersSection(),

                // ⑦ 최근 리뷰 섹션
                _buildRecentReviewsSection(),

                // 하단 푸터
                _buildFooter(),

                // 하단 여백
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100),
                ),
              ],
            ),

            // Top 버튼 (플로팅)
            if (_showTopButton)
              Positioned(
                right: 20,
                bottom: 100,
                child: _buildTopButton(),
              ),
          ],
        ),
      ),
    );
  }

  /// ① 상단 배너 (노란색 브랜딩 배너)
  Widget _buildBrandingBanner() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          // Blockpick 브랜딩 페이지로 이동 (Web view)
          context.push('/webview', extra: {
            'url': 'https://blockpick.io',
            'title': 'Blockpick 서비스 알아보기',
          });
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.yellow500.withValues(alpha: 0.35),
                AppColors.yellow500.withValues(alpha: 0.6),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.yellow500.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '전 세계 어디서나,',
                      style: AppTextStyles.title3.copyWith(color: Color(0xFF664D03), height: 1.4),
                    ),
                    Text(
                      '나를 위한 맞춤 경품 Event',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF664D03),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          'Blockpick 서비스 알아보기',
                          style: AppTextStyles.caption2.copyWith(color: Color(0xFF664D03).withValues(alpha: 0.7)),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: const Color(0xFF664D03).withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // 아이콘
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  size: 28,
                  color: Color(0xFF664D03),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ② 이벤트 포인트 버튼
  Widget _buildEventPointButton(bool isAuthenticated, dynamic user) {
    final points = user?.eventPoint.toInt() ?? 0;

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          if (isAuthenticated) {
            // 이벤트 포인트 화면으로 이동
            ref.read(currentTabProvider.notifier).setTab(1); // Event 탭으로 이동
          } else {
            context.push('/login');
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.monetization_on_rounded,
                      size: 18,
                      color: AppColors.blue,
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    '이벤트 포인트',
                    style: AppTextStyles.title2.copyWith(color: AppColors.gray700),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isAuthenticated)
                    Text(
                      '${_formatNumber(points)} P',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlue,
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '로그인 필요',
                        style: AppTextStyles.body4.copyWith(color: AppColors.gray500),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ②-1 출석체크 버튼
  Widget _buildCheckinButton(bool isAuthenticated) {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          if (isAuthenticated) {
            DailyCheckinScreen.show(context);
          } else {
            context.push('/login');
          }
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.yellow500.withValues(alpha: 0.15), AppColors.yellow500.withValues(alpha: 0.35)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.yellow500.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.yellow500,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: Color(0xFF664D03),
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '출석체크',
                        style: AppTextStyles.title2.copyWith(color: Color(0xFF664D03)),
                      ),
                      Text(
                        '매일 10P 적립',
                        style: AppTextStyles.caption1.copyWith(color: Color(0xFF664D03).withValues(alpha: 0.7)),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF664D03),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'CHECK-IN',
                  style: AppTextStyles.caption3.copyWith(color: AppColors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ③ 프로모션 리스트 섹션 (LIVE/DAILY 이벤트)
  Widget _buildPromotionListSection() {
    final dailyGamesAsync = ref.watch(gamesByTypeProvider(GameType.daily));

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로모션 카드 리스트
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: dailyGamesAsync.when(
              data: (games) {
                if (games.isEmpty) {
                  return _buildEmptyEventState();
                }
                return Column(
                  children: games.asMap().entries.take(3).map((entry) {
                    final index = entry.key;
                    final game = entry.value;
                    return PromotionCard(
                      game: game,
                      gameType: _getGameTypeString(game),
                      isLive: index == 0 && game.status.isJoinable, // 진행중인 첫 번째 카드만 LIVE
                      rankNumber: index < 5 ? index + 1 : null, // 1~5까지 숫자 뱃지
                      onTap: () => context.go('/game/${game.id}'),
                    );
                  }).toList(),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(),
            ),
          ),
        ],
      ),
    );
  }

  /// ③-1 Coming Soon 이벤트 섹션
  Widget _buildComingSoonSection() {
    final dailyGamesAsync = ref.watch(gamesByTypeProvider(GameType.daily));

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: 'Coming Soon',
            subtitle: '곧 시작되는 이벤트',
            onMoreTap: () {
              ref.read(currentTabProvider.notifier).setTab(1);
            },
          ),

          // Coming Soon 카드 리스트 (오버레이 디자인)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: dailyGamesAsync.when(
              data: (games) {
                if (games.isEmpty) {
                  return _buildEmptyEventState();
                }
                return Column(
                  children: games.take(2).map((game) {
                    return ComingSoonOverlayCard(
                      game: game,
                      gameType: _getGameTypeString(game),
                      onTap: () => context.go('/game/${game.id}'),
                    );
                  }).toList(),
                );
              },
              loading: () => _buildLoadingState(),
              error: (error, stack) => _buildErrorState(),
            ),
          ),
        ],
      ),
    );
  }

  /// ④ AD 배너 영역
  Widget _buildAdBanner() {
    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () {
          // 광고 시청 로직
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 시청하면 포인트를 받을 수 있습니다'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gray300, width: 1),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_circle_outline_rounded,
                  size: 24,
                  color: AppColors.gray500,
                ),
                SizedBox(width: 8),
                Text(
                  'AD Banner',
                  style: AppTextStyles.title3.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ⑤ 마감임박 이벤트 섹션 (DAILY/SELECT/VIBE/PRIME 모두 포함)
  Widget _buildClosingSoonEventsSection() {
    final dailyGamesAsync = ref.watch(gamesByTypeProvider(GameType.daily));
    final selectGamesAsync = ref.watch(gamesByTypeProvider(GameType.select));
    final primeGamesAsync = ref.watch(gamesByTypeProvider(GameType.prime));

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: 'Closing Soon',
            subtitle: '마감 임박 이벤트',
            onMoreTap: () {
              ref.read(currentTabProvider.notifier).setTab(1); // Event 탭으로 이동
            },
          ),

          // 이벤트 카드들 (DAILY/SELECT/VIBE + PRIME)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Builder(
              builder: (context) {
                final dailyGames = dailyGamesAsync.valueOrNull ?? [];
                final selectGames = selectGamesAsync.valueOrNull ?? [];
                final primeGames = primeGamesAsync.valueOrNull ?? [];

                final allGames = [...dailyGames, ...selectGames, ...primeGames];
                if (allGames.isEmpty) {
                  return _buildEmptyEventState();
                }

                return Column(
                  children: allGames.take(5).map((game) {
                    if (game.type == GameType.prime) {
                      return _buildPrimeEventCard(game);
                    }
                    return ComingSoonItemCard(
                      game: game,
                      gameType: _getGameTypeString(game),
                      isLastChance: _isLastChance(game),
                      onTap: () => context.go('/game/${game.id}'),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// PRIME 이벤트 카드 (최저가 단독 입찰 방식)
  Widget _buildPrimeEventCard(GameRound game) {
    return GestureDetector(
      onTap: () => context.go('/game/${game.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 80,
                height: 80,
                child: game.imageUrl.isEmpty
                    ? Container(
                        color: AppColors.gray100,
                        child: const Icon(Icons.image_rounded,
                            size: 32, color: AppColors.gray400),
                      )
                    : Image.network(
                        game.imageUrl.replaceAll(' ', '%20'),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.gray100,
                          child: const Icon(Icons.image_rounded,
                              size: 32, color: AppColors.gray400),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 14),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 배지 행
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.yellow500,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'PRIME',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      if (_isNew(game)) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.green500.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: AppColors.green500.withValues(alpha: 0.3)),
                          ),
                          child: const Text(
                            'NEW',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.green500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 6),
                  // 상품명
                  Text(
                    game.title,
                    style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue, height: 1.3),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  // 참여 인원 / 입찰 금액
                  Row(
                    children: [
                      // 참여 인원
                      Text(
                        '👥 ${game.participants}/${game.maxParticipants}',
                        style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
                      ),
                      SizedBox(width: 12),
                      // 입찰 금액 범위
                      Text(
                        '${_formatPrice(game.currentPrice)}원 ~ ${_formatPrice(game.originalPrice)}원',
                        style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // 남은 시간
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 12, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        '${game.timeLeft} 남음',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gray400,
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

  /// 가격 포맷 (만원 단위)
  String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final remainder = price % 10000;
      if (remainder == 0) return '${man}만';
      return '${man}만${remainder}';
    }
    return '$price';
  }

  /// ⑥ 최근 당첨자 섹션
  Widget _buildRecentWinnersSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: 'Recent Winners',
            subtitle: '최근 당첨자',
            onMoreTap: () {
              context.push('/winners');
            },
          ),

          // 당첨자 카드들 (하드코딩 - 추후 API 연동)
          _buildWinnerCard(
            username: 'yoyoyo_1632',
            type: 'Daily',
            product: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
            time: 'Just now',
            hasImage: true,
          ),
          _buildWinnerCard(
            username: 'epiktiger_34',
            type: 'Vibe',
            product: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
            time: '15 minutes ago',
            hasImage: false,
          ),
          _buildWinnerCard(
            username: 'kor_cowking238',
            type: 'Vibe',
            product: '[Samsung] 정품 갤럭시 버즈3 프로 화이트',
            time: '1 days ago',
            hasImage: true,
          ),
        ],
      ),
    );
  }

  Widget _buildWinnerCard({
    required String username,
    required String type,
    required String product,
    required String time,
    required bool hasImage,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          // 프로필 이미지 (원형)
          if (hasImage)
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.network(
                  'https://i.pravatar.cc/100?u=$username',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildCircleInitialAvatar(username);
                  },
                ),
              ),
            )
          else
            _buildCircleInitialAvatar(username),
          SizedBox(width: 12),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  username,
                  style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                ),
                SizedBox(height: 2),
                Text(
                  product,
                  style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$type • $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleInitialAvatar(String username) {
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
    ];
    final textColors = [
      const Color(0xFF1976D2),
      const Color(0xFFC2185B),
      const Color(0xFF7B1FA2),
      const Color(0xFF388E3C),
      const Color(0xFFF57C00),
    ];
    final colorIndex = username.hashCode.abs() % colors.length;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColors[colorIndex],
          ),
        ),
      ),
    );
  }

  Widget _buildInitialAvatar(String username) {
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
    ];
    final textColors = [
      const Color(0xFF1976D2),
      const Color(0xFFC2185B),
      const Color(0xFF7B1FA2),
      const Color(0xFF388E3C),
      const Color(0xFFF57C00),
    ];
    final colorIndex = username.hashCode.abs() % colors.length;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: textColors[colorIndex],
          ),
        ),
      ),
    );
  }

  /// ⑦ 최근 리뷰 섹션
  Widget _buildRecentReviewsSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildSectionHeader(
            title: 'Recent Reviews',
            subtitle: '최근 리뷰',
            onMoreTap: () {
              // 리뷰 목록 페이지로 이동
            },
          ),

          // 리뷰 카드들 (가로 스크롤)
          SizedBox(
            height: 140,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildReviewCard(
                  username: 'asiaguy238',
                  review: 'Great!! I won an iPhone 16 Pro last night. Siuuuu...',
                  time: 'Just now',
                  hasImage: true,
                ),
                _buildReviewCard(
                  username: 'Jacob_Scott',
                  review: 'Got my Airpods Pro delivered super fast. So ni...',
                  time: '15 minutes ago',
                  hasImage: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard({
    required String username,
    required String review,
    required String time,
    required bool hasImage,
  }) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (hasImage)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://i.pravatar.cc/100?u=$username',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildSmallInitialAvatar(username);
                      },
                    ),
                  ),
                )
              else
                _buildSmallInitialAvatar(username),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  username,
                  style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: Text(
              review,
              style: AppTextStyles.body4.copyWith(color: AppColors.gray700, height: 1.4),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallInitialAvatar(String username) {
    final colors = [
      const Color(0xFFE3F2FD),
      const Color(0xFFFCE4EC),
      const Color(0xFFF3E5F5),
      const Color(0xFFE8F5E9),
      const Color(0xFFFFF3E0),
    ];
    final textColors = [
      const Color(0xFF1976D2),
      const Color(0xFFC2185B),
      const Color(0xFF7B1FA2),
      const Color(0xFF388E3C),
      Color(0xFFF57C00),
    ];
    final colorIndex = username.hashCode.abs() % colors.length;

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: colors[colorIndex],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          username.isNotEmpty ? username[0].toUpperCase() : '?',
          style: AppTextStyles.title3.copyWith(color: textColors[colorIndex]),
        ),
      ),
    );
  }

  /// 하단 푸터
  Widget _buildFooter() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            '© 2025 Blockpick, Inc',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }

  /// Top 버튼
  Widget _buildTopButton() {
    return GestureDetector(
      onTap: _scrollToTop,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          size: 24,
          color: AppColors.darkBlue,
        ),
      ),
    );
  }

  /// 섹션 헤더
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onMoreTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.body4.copyWith(color: AppColors.gray500),
              ),
            ],
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: Row(
              children: [
                Text(
                  'More',
                  style: AppTextStyles.caption2,
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: AppColors.gray500,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)},${(number % 1000).toString().padLeft(3, '0')}';
    }
    return number.toString();
  }

  String _formatParticipants(int count) {
    if (count >= 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }

  String _getGameTypeString(GameRound game) {
    switch (game.type) {
      case GameType.daily:
        return 'daily';
      case GameType.select:
        return 'select';
      case GameType.vibe:
        return 'vibe';
      case GameType.prime:
        return 'prime';
    }
  }

  Color _getTypeBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return AppColors.blue;
      case 'select':
        return AppColors.green500;
      case 'vibe':
        return AppColors.primaryLight;
      case 'prime':
        return AppColors.darkBlue;
      default:
        return AppColors.gray500;
    }
  }

  bool _isLastChance(GameRound game) {
    // 종료 30분 미만
    return true; // 임시
  }

  bool _isHot(GameRound game) {
    // 데일리 기준 최소 모집인원의 2배
    return game.participants > 100;
  }

  bool _isNew(GameRound game) {
    // 이벤트 등록 24h 이내
    return false; // 임시
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildEmptyEventState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.event_busy_rounded, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(
              '진행 중인 이벤트가 없습니다',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: AppColors.red),
            const SizedBox(height: 12),
            Text(
              '데이터를 불러오는데 실패했습니다',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}
