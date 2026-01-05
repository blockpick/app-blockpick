import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../components/common/common_app_bar.dart';

/// SC-008 새 홈 화면
class NewHomeScreen extends ConsumerStatefulWidget {
  const NewHomeScreen({super.key});

  @override
  ConsumerState<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends ConsumerState<NewHomeScreen> {
  // 인기 상품 카테고리
  final List<String> _categories = ['Hotel', 'Fashion', 'Electronic', 'Voucher'];
  int _selectedCategoryIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: CustomScrollView(
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

            // 인기 상품 섹션
            _buildPopularItemsSection(),

            // 충전 유도 배너
            _buildPromotionBanner(),

            // 마감임박 이벤트 섹션
            _buildClosingSoonEventsSection(),

            // 최근 당첨자 섹션
            _buildRecentWinnersSection(),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  /// 섹션 헤더 (토스 스타일)
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onMoreTap,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor,
                ),
              ),
              const SizedBox(width: 12),
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
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          GestureDetector(
            onTap: onMoreTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    '더보기',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 인기 상품 섹션
  Widget _buildPopularItemsSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (토스 스타일)
          _buildSectionHeader(
            title: 'Popular Items',
            subtitle: '인기 상품',
            icon: Icons.local_fire_department_rounded,
            iconColor: AppColors.red,
            onMoreTap: () {
              // TODO: 더보기 페이지로 이동
            },
          ),

          // 카테고리 탭
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategoryIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategoryIndex = index;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.darkBlue : AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.darkBlue : AppColors.gray300,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        _categories[index],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppColors.white : AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 상품 카드 가로 스크롤
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5, // Mock 데이터
              itemBuilder: (context, index) {
                return _buildProductCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 상품 카드 (토스 스타일)
  Widget _buildProductCard(int index) {
    final products = [
      {
        'name': '[나트랑] JW 메리어트 깜란 베이 리조트 & 스파',
        'price': '240,000원~',
        'benefit': '캐시 1만원',
        'image': 'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=400&h=300&fit=crop',
      },
      {
        'name': '[다낭] 퓨전 리조트 애빌라스',
        'price': '300,000원~',
        'benefit': '캐시 3만원',
        'image': 'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=400&h=300&fit=crop',
      },
      {
        'name': '[푸켓] 반얀트리 리조트',
        'price': '450,000원~',
        'benefit': '캐시 5만원',
        'image': 'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=400&h=300&fit=crop',
      },
      {
        'name': '[발리] 아야나 리조트',
        'price': '380,000원~',
        'benefit': '캐시 4만원',
        'image': 'https://images.unsplash.com/photo-1537996194471-e657df975ab4?w=400&h=300&fit=crop',
      },
      {
        'name': '[몰디브] 콘래드 리조트',
        'price': '1,200,000원~',
        'benefit': '캐시 10만원',
        'image': 'https://images.unsplash.com/photo-1514282401047-d79a71a590e8?w=400&h=300&fit=crop',
      },
    ];
    final product = products[index % products.length];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 이미지
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Image.network(
              product['image']!,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 100,
                  color: AppColors.gray100,
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.gray400,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  color: AppColors.gray100,
                  child: Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 36,
                      color: AppColors.gray300,
                    ),
                  ),
                );
              },
            ),
          ),
          // 콘텐츠
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 상품명
                  Text(
                    product['name']!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Spacer(),
                  // 혜택 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      product['benefit']!,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.blue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 가격
                  Text(
                    product['price']!,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 충전 유도 배너 (토스 스타일)
  Widget _buildPromotionBanner() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.blue.withValues(alpha: 0.08),
              AppColors.blue.withValues(alpha: 0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '쇼핑 캐시 첫 충전하면,',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBlue,
                      height: 1.4,
                    ),
                  ),
                  const Text(
                    '데일리 이벤트 1회 무료!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkBlue,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '충전하기',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: AppColors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 아이콘
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.card_giftcard_rounded,
                size: 32,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 마감임박 이벤트 섹션
  Widget _buildClosingSoonEventsSection() {
    // 실제 데이터 가져오기
    final dailyGamesAsync = ref.watch(gamesByTypeProvider(GameType.daily));

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (토스 스타일)
          _buildSectionHeader(
            title: 'Closing Soon',
            subtitle: '마감 임박 이벤트',
            icon: Icons.timer_rounded,
            iconColor: AppColors.blue,
            onMoreTap: () {
              // Event 탭으로 이동
            },
          ),

          // 이벤트 카드들
          dailyGamesAsync.when(
            data: (games) {
              if (games.isEmpty) {
                return _buildEmptyEventState();
              }
              return Column(
                children: games.take(3).map((game) => _buildEventCard(game, 'Daily')).toList(),
              );
            },
            loading: () => _buildLoadingState(),
            error: (_, __) => _buildErrorState(),
          ),
        ],
      ),
    );
  }

  /// 이벤트 카드 (토스 스타일)
  Widget _buildEventCard(GameRound game, String type) {
    return GestureDetector(
      onTap: () => context.go('/game/${game.id}'),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Stack(
                children: [
                  // 게임 썸네일
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: game.imageUrl.isNotEmpty
                        ? Image.network(
                            game.imageUrl,
                            width: 88,
                            height: 88,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.gray400,
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Center(
                                child: Icon(
                                  Icons.image_outlined,
                                  size: 32,
                                  color: AppColors.gray300,
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Icon(
                              Icons.image_outlined,
                              size: 32,
                              color: AppColors.gray300,
                            ),
                          ),
                  ),
                  // 타입 뱃지
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeBadgeColor(type),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: _getTypeBadgeColor(type).withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  // 메타 정보
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _buildMetaChip(Icons.monetization_on_rounded, '${game.currentPrice}'),
                      _buildMetaChip(Icons.people_rounded, '${game.participants}명'),
                      _buildMetaChip(Icons.grid_view_rounded, '${game.actualGridWidth}×${game.actualGridHeight}'),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // 진행 바
                  _buildProgressIndicator(game),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTypeBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'daily':
        return AppColors.blue;
      case 'select':
        return AppColors.green;
      case 'prime':
        return AppColors.darkBlue;
      default:
        return AppColors.gray500;
    }
  }

  Widget _buildMetaChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.gray500),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(GameRound game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: 0.6, // Mock 값
            backgroundColor: AppColors.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
            minHeight: 6,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 13,
              color: AppColors.blue,
            ),
            const SizedBox(width: 4),
            Text(
              '03:34:56 남음',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 최근 당첨자 섹션
  Widget _buildRecentWinnersSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (토스 스타일)
          _buildSectionHeader(
            title: 'Recent Winners',
            subtitle: '최근 당첨자',
            icon: Icons.emoji_events_rounded,
            iconColor: AppColors.green,
            onMoreTap: () {
              // TODO: 당첨자 목록 페이지로 이동
            },
          ),

          // 당첨자 카드들
          _buildWinnerCard('yoyoyo_1632', 'Daily', '[Samsung] 정품 갤럭시 버즈3 프로 화이트', 'Just now'),
          _buildWinnerCard('user_394682', 'Select', '[Apple] 에어팟 맥스', '2분 전'),
          _buildWinnerCard('lucky_winner', 'Prime', '[Apple] iMac 2024 M4 실버', '5분 전'),
        ],
      ),
    );
  }

  Widget _buildWinnerCard(String username, String type, String product, String time) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // 아바타 (토스 스타일 - 그라데이션 배경)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getTypeBadgeColor(type).withValues(alpha: 0.2),
                  _getTypeBadgeColor(type).withValues(alpha: 0.08),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Icon(
                Icons.emoji_events_rounded,
                size: 24,
                color: _getTypeBadgeColor(type),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getTypeBadgeColor(type).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _getTypeBadgeColor(type),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  product,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 12,
                      color: AppColors.gray400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 우측 화살표
          Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppColors.gray300,
          ),
        ],
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
