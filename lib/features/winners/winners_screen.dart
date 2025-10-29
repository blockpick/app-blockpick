import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/winner_model.dart';
import '../../data/mock_winner_data.dart';

/// Winners 화면 (당첨자 발표)
class WinnersScreen extends StatefulWidget {
  const WinnersScreen({super.key});

  @override
  State<WinnersScreen> createState() => _WinnersScreenState();
}

class _WinnersScreenState extends State<WinnersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PrizeType? _selectedPrizeType; // null = 전체

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // 메인 탭바 (역대 당첨 / 내 당첨)
            Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                border: Border(
                  bottom: BorderSide(color: AppColors.buleGray),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: AppColors.blue,
                indicatorWeight: 3,
                labelColor: AppColors.blue,
                unselectedLabelColor: AppColors.medium,
                labelStyle: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.button,
                tabs: const [
                  Tab(text: '역대 당첨'),
                  Tab(text: '내 당첨'),
                ],
              ),
            ),

            // 필터 칩 (스와이프 가능)
            _buildFilterChips(),

            // 탭 뷰
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWinnerList(isMyWins: false),
                  _buildWinnerList(isMyWins: true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 필터 칩 빌드 (스와이프 가능)
  Widget _buildFilterChips() {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            _buildFilterChip(
              label: '전체',
              isSelected: _selectedPrizeType == null,
              onTap: () {
                setState(() {
                  _selectedPrizeType = null;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '💎 프리미엄',
              isSelected: _selectedPrizeType == PrizeType.premium,
              onTap: () {
                setState(() {
                  _selectedPrizeType = PrizeType.premium;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: '🛒 쇼핑몰',
              isSelected: _selectedPrizeType == PrizeType.shop,
              onTap: () {
                setState(() {
                  _selectedPrizeType = PrizeType.shop;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  /// 개별 필터 칩
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.blue : AppColors.bgWhite,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.blue : AppColors.medium.withOpacity(0.2),
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.body.copyWith(
            color: isSelected ? AppColors.white : AppColors.medium,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  /// 당첨자 리스트 빌드
  Widget _buildWinnerList({required bool isMyWins}) {
    final winners = isMyWins
        ? MockWinnerData.filterMyWins(_selectedPrizeType)
        : MockWinnerData.filterByType(_selectedPrizeType);

    if (winners.isEmpty) {
      return _buildEmptyState(isMyWins: isMyWins);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: winners.length,
      itemBuilder: (context, index) {
        final winner = winners[index];
        return _buildWinnerCard(winner);
      },
    );
  }

  /// 당첨자 카드
  Widget _buildWinnerCard(WinnerModel winner) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusLg),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                winner.prizeImage,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.bgWhite,
                    child: const Center(
                      child: Icon(
                        Icons.image_outlined,
                        size: 48,
                        color: AppColors.medium,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // 당첨 정보
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품 타입 배지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: winner.prizeType == PrizeType.premium
                        ? AppColors.blue.withOpacity(0.1)
                        : AppColors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    winner.prizeTypeBadge,
                    style: AppTextStyles.small.copyWith(
                      color: winner.prizeType == PrizeType.premium
                          ? AppColors.blue
                          : AppColors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // 상품명
                Text(
                  winner.prizeName,
                  style: AppTextStyles.large.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 8),

                // 당첨자 정보
                Row(
                  children: [
                    // 아바타
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.bgWhite,
                      backgroundImage: NetworkImage(winner.userAvatar.replaceAll(' ', '%20')),
                      onBackgroundImageError: (_, __) {},
                      child: const Icon(
                        Icons.person,
                        size: 20,
                        color: AppColors.medium,
                      ),
                    ),
                    const SizedBox(width: 8),

                    // 이름과 날짜
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            winner.userName,
                            style: AppTextStyles.body.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          Text(
                            dateFormat.format(winner.winDate),
                            style: AppTextStyles.small.copyWith(
                              color: AppColors.medium,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 내 당첨 표시
                    if (winner.isMyWin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.yellow.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusSm,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              size: 16,
                              color: AppColors.yellow,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '내 당첨',
                              style: AppTextStyles.small.copyWith(
                                color: AppColors.yellow,
                                fontWeight: FontWeight.bold,
                              ),
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
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState({required bool isMyWins}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMyWins ? Icons.emoji_events_outlined : Icons.inbox_outlined,
            size: 80,
            color: AppColors.medium.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            isMyWins ? '아직 당첨 내역이 없습니다' : '당첨자가 없습니다',
            style: AppTextStyles.large.copyWith(
              color: AppColors.medium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMyWins
                ? '블록픽 게임에 참여하여 상품을 획득하세요!'
                : '곧 당첨자가 발표될 예정입니다',
            style: AppTextStyles.body.copyWith(
              color: AppColors.medium,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
