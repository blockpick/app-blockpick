import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wish_model.dart';
import '../../providers/wish_provider.dart';
import 'widgets/category_filter_bar.dart';
import 'widgets/wish_card.dart';
import 'wish_create_screen.dart';
import 'wish_detail_screen.dart';

/// 위시 탭 메인 화면
/// 소원 리스트 + 카테고리 필터 + 정렬 + FAB
class WishScreen extends ConsumerWidget {
  const WishScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishes = ref.watch(wishListProvider);
    final selectedCategory = ref.watch(wishCategoryFilterProvider);
    final selectedSort = ref.watch(wishSortProvider);
    final businessBanners = ref.watch(businessWishBannersProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 상단 타이틀
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '위시',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textBlack,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            // TODO: 검색
                          },
                          icon: const Icon(
                            Icons.search,
                            color: AppColors.gray600,
                            size: 22,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: 알림 화면
                          },
                          icon: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.gray600,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 업체 소원 배너 캐러셀
            if (businessBanners.isNotEmpty)
              SliverToBoxAdapter(
                child: Container(
                  color: AppColors.white,
                  child: _BusinessBannerCarousel(banners: businessBanners),
                ),
              ),

            // 카테고리 필터
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.only(top: 16, bottom: 12),
                child: CategoryFilterBar(
                  selected: selectedCategory,
                  onSelected: (cat) {
                    ref.read(wishCategoryFilterProvider.notifier).state = cat;
                  },
                ),
              ),
            ),

            // 정렬 옵션
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.white,
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Row(
                  children: WishSort.values.map((sort) {
                    final isSelected = selectedSort == sort;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(wishSortProvider.notifier).state = sort;
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              sort.label,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                color: isSelected ? AppColors.textBlack : AppColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // 구분선
            const SliverToBoxAdapter(
              child: SizedBox(height: 8),
            ),

            // 소원 카드 그리드
            if (wishes.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _EmptyState(
                  onCreateTap: () => _navigateToCreate(context),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(12, 4, 12, 100),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 10,
                    childAspectRatio: 0.48,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final wish = wishes[index];
                      return WishCard(
                        wish: wish,
                        onTap: () => _navigateToDetail(context, wish.id),
                        onBuzzTap: () => _showBuzzConfirm(context, ref, wish),
                      );
                    },
                    childCount: wishes.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      // FAB 버튼들
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 바로 소문내기
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => _buzzRandom(context, ref),
                child: const Icon(Icons.auto_awesome, size: 20, color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: 10),
          // 소원 등록하기
          Container(
            decoration: BoxDecoration(
              color: AppColors.textBlack,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _navigateToCreate(context),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_outlined, size: 16, color: AppColors.white),
                      SizedBox(width: 6),
                      Text(
                        '소원 등록',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const WishCreateScreen(),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String wishId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => WishDetailScreen(wishId: wishId),
      ),
    );
  }

  void _showBuzzConfirm(BuildContext context, WidgetRef ref, Wish wish) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _BuzzConfirmSheet(wish: wish),
    );
  }

  void _buzzRandom(BuildContext context, WidgetRef ref) {
    final randomWish = ref.read(randomWishProvider);
    _showBuzzConfirm(context, ref, randomWish);
  }
}

/// 업체 소원 배너 캐러셀
class _BusinessBannerCarousel extends StatefulWidget {
  final List<Wish> banners;
  const _BusinessBannerCarousel({required this.banners});

  @override
  State<_BusinessBannerCarousel> createState() => _BusinessBannerCarouselState();
}

class _BusinessBannerCarouselState extends State<_BusinessBannerCarousel> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        children: [
          SizedBox(
            height: 96,
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.banners.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                final wish = widget.banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF5941F2), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                wish.businessName ?? 'BRAND',
                                style: AppTextStyles.caption4.copyWith(color: Colors.white),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              wish.oneLiner,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.title3.copyWith(color: AppColors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          wish.productImageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                wish.category.emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: _currentPage == i ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: _currentPage == i ? AppColors.primary : AppColors.gray200,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 빈 상태
class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateTap;
  const _EmptyState({required this.onCreateTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.15),
                  const Color(0xFF7C3AED).withValues(alpha: 0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          const Text(
            '아직 소원이 없어요',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 번째 소원을 등록해보세요!\n갖고 싶은 상품의 링크만 있으면 OK',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.5),
          ),
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), AppColors.primary],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('소원 등록하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

/// 소문내기 참여 확인 바텀시트
class _BuzzConfirmSheet extends StatelessWidget {
  final Wish wish;
  const _BuzzConfirmSheet({required this.wish});

  @override
  Widget build(BuildContext context) {
    final isFree = wish.isBusinessWish;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '소문내기에 참여할까요?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 20),
          // 상품 정보
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    wish.productImageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          wish.category.emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        wish.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption2.copyWith(color: AppColors.textBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_formatPrice(wish.productPrice)}원',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          // 참여비 안내
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isFree ? AppColors.primaryBg : AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '참여비',
                  style: AppTextStyles.title3.copyWith(color: AppColors.gray600),
                ),
                Text(
                  isFree ? '무료' : '10원',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isFree ? AppColors.primary : AppColors.textBlack,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // CTA 버튼
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Container(
              decoration: BoxDecoration(
                gradient: isFree
                    ? const LinearGradient(
                        colors: [Color(0xFF7C3AED), AppColors.primary],
                      )
                    : const LinearGradient(
                        colors: [Color(0xFF2D3436), Color(0xFF191F28)],
                      ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: (isFree ? AppColors.primary : Colors.black).withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('소문내기 게임 화면은 Phase 5에서 구현됩니다'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                child: Text(
                  isFree ? '✨ 무료로 소문내기' : '✨ 10원으로 소문내기',
                  style: AppTextStyles.buttonLarge,
                ),
              ),
            ),
          ),
          if (!isFree) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('광고 시청 기능은 추후 구현됩니다'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.play_circle_outline, size: 18),
                label: const Text('광고 보고 무료 참여'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.gray600,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
