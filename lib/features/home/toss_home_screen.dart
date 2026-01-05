import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../providers/current_tab_provider.dart';
import '../../data/mock_game_data.dart';
import 'widgets/toss_balance_card.dart';
import 'widgets/toss_quick_actions.dart';
import 'widgets/toss_game_section.dart';
import 'widgets/toss_announcement_card.dart';

/// 토스 스타일 홈 화면
class TossHomeScreen extends ConsumerStatefulWidget {
  const TossHomeScreen({super.key});

  @override
  ConsumerState<TossHomeScreen> createState() => _TossHomeScreenState();
}

class _TossHomeScreenState extends ConsumerState<TossHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

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
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        body: RefreshIndicator(
          onRefresh: () async {
            // Pull to refresh
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.blue,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              // 앱바
              _buildAppBar(context, user?.nickname, isAuthenticated),

              // 본문
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // 1. 잔액 카드
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TossBalanceCard(
                        balance: user?.balance ?? 0,
                        isAuthenticated: isAuthenticated,
                        onTap: () {
                          if (!isAuthenticated) {
                            context.push('/auth/login-select');
                          }
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 2. 퀵 액션
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TossQuickActions(),
                    ),

                    const SizedBox(height: 24),

                    // 3. 공지사항
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: TossAnnouncementCard(),
                    ),

                    const SizedBox(height: 24),

                    // 4. 게임 섹션 - SELECT
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TossGameSection(
                        title: '오늘의 픽',
                        subtitle: '상품을 선택하고 당첨되세요',
                        games: MockGameData.selectGames.take(3).toList(),
                        onViewAll: () {
                          // TODO: 전체보기
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 5. 게임 섹션 - DAILY
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TossGameSection(
                        title: '데일리 게임',
                        subtitle: '매일 새로운 기회',
                        games: MockGameData.dailyGames.take(3).toList(),
                        onViewAll: () {
                          // TODO: 전체보기
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 6. 게임 섹션 - VIBE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TossGameSection(
                        title: '바이브',
                        subtitle: '감각적인 선택',
                        games: MockGameData.vibeGames.take(3).toList(),
                        isVibe: true,
                        onViewAll: () {
                          // TODO: 전체보기
                        },
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Footer
                    _buildFooter(),

                    const SizedBox(height: 100), // 바텀 네비게이션 여백
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, String? nickname, bool isAuthenticated) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: _isScrolled ? AppColors.white : AppColors.gray100,
      surfaceTintColor: Colors.transparent,
      title: Row(
        children: [
          // 로고
          Text(
            'BlockPick',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        // 알림
        IconButton(
          onPressed: () {
            // TODO: 알림
          },
          icon: Stack(
            children: [
              Icon(
                Icons.notifications_none_rounded,
                color: AppColors.darkBlue,
                size: 26,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        // 프로필
        IconButton(
          onPressed: () {
            if (isAuthenticated) {
              // MY 페이지로 이동
              ref.read(currentTabProvider.notifier).goToMy();
            } else {
              context.push('/auth/login-select');
            }
          },
          icon: CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.gray300,
            child: Icon(
              Icons.person_rounded,
              size: 18,
              color: AppColors.gray600,
            ),
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            'BLOCKPICK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.gray500,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '블록을 선택하고 행운을 잡으세요',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFooterLink('이용약관'),
              _buildDot(),
              _buildFooterLink('개인정보처리방침'),
              _buildDot(),
              _buildFooterLink('고객센터'),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '© 2025 BlockPick. All rights reserved.',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterLink(String text) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.gray600,
        ),
      ),
    );
  }

  Widget _buildDot() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '·',
        style: TextStyle(color: AppColors.gray400),
      ),
    );
  }
}
