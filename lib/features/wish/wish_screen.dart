import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/wish_model.dart';
import '../../providers/wish_provider.dart';
import 'widgets/wish_card.dart';
import 'wish_create_screen.dart';
import 'wish_detail_screen.dart';
import 'buzz_game_screen.dart';

/// 위시 탭 메인 화면
class WishScreen extends ConsumerStatefulWidget {
  const WishScreen({super.key});

  @override
  ConsumerState<WishScreen> createState() => _WishScreenState();
}

class _WishScreenState extends ConsumerState<WishScreen> {
  @override
  Widget build(BuildContext context) {
    final wishes = ref.watch(wishListProvider);
    final selectedCategory = ref.watch(wishCategoryFilterProvider);
    final selectedSort = ref.watch(wishSortProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // 필터 섹션 (흰 배경)
          _buildFilterSection(selectedCategory, selectedSort, wishes.length),
          // 콘텐츠
          Expanded(
            child: wishes.isEmpty
                ? _buildEmptyState()
                : _buildWishList(wishes),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  /// 필터 섹션 — 앱 디자인 패턴 통일
  Widget _buildFilterSection(
    WishCategory? selectedCategory,
    WishSort selectedSort,
    int totalCount,
  ) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타이틀 바
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 8, 0),
              child: Row(
                children: [
                  Text(
                    '위시',
                    style: AppTextStyles.heading2.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.search, color: AppColors.gray600, size: 22),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.gray600, size: 22),
                  ),
                ],
              ),
            ),
            // 카테고리 필터
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  _buildFilterChip(
                    label: '전체',
                    isSelected: selectedCategory == null,
                    onTap: () => ref.read(wishCategoryFilterProvider.notifier).state = null,
                  ),
                  ...WishCategory.values.map((cat) => _buildFilterChip(
                        label: '${cat.emoji} ${cat.label.split('/').first}',
                        isSelected: selectedCategory == cat,
                        onTap: () => ref.read(wishCategoryFilterProvider.notifier).state = cat,
                      )),
                ],
              ),
            ),
            // 정렬 + 카운트
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  ...WishSort.values.map((sort) {
                    final isSelected = selectedSort == sort;
                    return GestureDetector(
                      onTap: () => ref.read(wishSortProvider.notifier).state = sort,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          sort.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected ? AppColors.textBlack : AppColors.gray400,
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  Text(
                    '총 $totalCount개',
                    style: AppTextStyles.caption4.copyWith(color: AppColors.gray400),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 필터 칩 — 게임 리스트와 동일 스타일
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.textBlack : AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
            border: Border.all(
              color: isSelected ? AppColors.textBlack : AppColors.gray200,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.white : AppColors.gray600,
            ),
          ),
        ),
      ),
    );
  }

  /// 위시 리스트
  Widget _buildWishList(List<Wish> wishes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final wish = wishes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: WishCard(
            wish: wish,
            onTap: () => _navigateToDetail(context, wish.id),
            onBuzzTap: () => _showBuzzConfirm(context, ref, wish),
            showSwipeHint: index == 0,
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, size: 36, color: AppColors.gray400),
          ),
          const SizedBox(height: 20),
          Text(
            '아직 소원이 없어요',
            style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            '갖고 싶은 상품의 링크만 있으면 OK!',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => _navigateToCreate(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.textBlack,
                borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
              ),
              child: Text(
                '첫 소원 등록하기',
                style: AppTextStyles.button.copyWith(color: AppColors.white),
              ),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  /// FAB
  Widget _buildFAB() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.textBlack,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          onTap: () => _navigateToCreate(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_rounded, size: 16, color: AppColors.white),
                const SizedBox(width: 6),
                Text(
                  '소원 등록',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToCreate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const WishCreateScreen()),
    );
  }

  void _navigateToDetail(BuildContext context, String wishId) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => WishDetailScreen(wishId: wishId)),
    );
  }

  void _showBuzzConfirm(BuildContext context, WidgetRef ref, Wish wish) {
    final isFree = wish.isBusinessWish;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusBottomSheet)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '소문내기에 참여할까요?',
              style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 20),
            // 상품 정보
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    child: Image.network(
                      wish.productImageUrl,
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 52,
                        height: 52,
                        color: AppColors.gray200,
                        child: Center(child: Text(wish.category.emoji, style: const TextStyle(fontSize: 20))),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          wish.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.title3.copyWith(color: AppColors.textBlack),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '참여비 ${isFree ? "무료" : "10원"}',
                          style: AppTextStyles.caption2.copyWith(
                            color: isFree ? AppColors.primaryMain : AppColors.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // CTA
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BuzzGameScreen(wish: wish),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.textBlack,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Text(
                  isFree ? '✨ 무료로 소문내기' : '✨ 10원으로 소문내기',
                  style: AppTextStyles.button.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
