import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/wish_model.dart';
import '../../providers/wish_provider.dart';
import '../../providers/current_tab_provider.dart';
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

enum WishViewMode { swipe, list, gallery }

class _WishScreenState extends ConsumerState<WishScreen> {
  WishViewMode _viewMode = WishViewMode.swipe;

  void _setViewMode(WishViewMode mode) {
    setState(() => _viewMode = mode);
    ref.read(wishSwipeModeProvider.notifier).state = mode == WishViewMode.swipe;
  }

  @override
  Widget build(BuildContext context) {
    final wishes = ref.watch(wishListProvider);
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Stack(
        children: [
          // 콘텐츠
          wishes.isEmpty ? _buildEmptyState() : _buildContent(wishes),
          // 플로팅 헤더
          _buildFloatingHeader(),
        ],
      ),
    );
  }

  /// 플로팅 투명 헤더 (모든 뷰모드 공통)
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
              if (_viewMode == WishViewMode.swipe)
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
                '위시',
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

  Widget _buildContent(List<Wish> wishes) {
    switch (_viewMode) {
      case WishViewMode.swipe:
        return _buildSwipeView(wishes);
      case WishViewMode.list:
        return _buildWishList(wishes);
      case WishViewMode.gallery:
        return _buildGalleryView(wishes);
    }
  }

  Widget _buildViewModeToggle() {
    Widget btn(IconData icon, WishViewMode mode) {
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
          btn(Icons.style_rounded, WishViewMode.swipe),
          btn(Icons.view_list_rounded, WishViewMode.list),
          btn(Icons.grid_view_rounded, WishViewMode.gallery),
        ],
      ),
    );
  }

  /// 위시 리스트
  Widget _buildWishList(List<Wish> wishes) {
    final topPad = MediaQuery.of(context).padding.top + 52;
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 100),
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

  /// 틴더 스타일 카드 스택 (무한 순환, 버리기 없음)
  Widget _buildSwipeView(List<Wish> wishes) {
    return _SwipeDeck(
      key: ValueKey('deck_${wishes.length}'),
      wishes: wishes,
      onTap: (w) => _navigateToDetail(context, w.id),
      onBuzz: (w) => _showBuzzConfirm(context, ref, w),
    );
  }

  /// 갤러리 (그리드) 뷰
  Widget _buildGalleryView(List<Wish> wishes) {
    final topPad = MediaQuery.of(context).padding.top + 52;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(16, topPad + 12, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: wishes.length,
      itemBuilder: (context, index) {
        final wish = wishes[index];
        return GestureDetector(
          onTap: () => _navigateToDetail(context, wish.id),
          child: Container(
            decoration: BoxDecoration(
              color: wish.isEmpathyReached ? const Color(0xFFF8F6FF) : AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              border: wish.isEmpathyReached
                  ? Border.all(color: AppColors.primaryMain.withValues(alpha: 0.3), width: 1.5)
                  : wish.isBusinessWish
                      ? Border.all(color: AppColors.primaryMain.withValues(alpha: 0.15))
                      : null,
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
                        child: Image.network(
                          wish.productImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.gray100,
                            child: Center(child: Text(wish.category.emoji, style: const TextStyle(fontSize: 36))),
                          ),
                        ),
                      ),
                      if (wish.isEmpathyReached)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryMain,
                              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            ),
                            child: const Text(
                              '달성',
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
                        wish.oneLiner,
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
                        '${_formatPriceShort(wish.productPrice)}원',
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

  String _formatPriceShort(int price) {
    if (price >= 10000) {
      final man = (price / 10000);
      return man == man.truncate() ? '${man.toInt()}만' : '${man.toStringAsFixed(1)}만';
    }
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
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

/// 틴더 스타일 카드 스택 — 무한 순환, 버리기 없음
class _SwipeDeck extends StatefulWidget {
  final List<Wish> wishes;
  final void Function(Wish) onTap;
  final void Function(Wish) onBuzz;

  const _SwipeDeck({
    super.key,
    required this.wishes,
    required this.onTap,
    required this.onBuzz,
  });

  @override
  State<_SwipeDeck> createState() => _SwipeDeckState();
}

class _SwipeDeckState extends State<_SwipeDeck> with SingleTickerProviderStateMixin {
  int _index = 0;
  Offset _drag = Offset.zero;
  late final AnimationController _snapCtrl;
  Offset _snapFrom = Offset.zero;
  bool _showHint = true;

  @override
  void initState() {
    super.initState();
    _snapCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300))
      ..addListener(() {
        setState(() {
          _drag = Offset.lerp(_snapFrom, Offset.zero, Curves.easeOut.transform(_snapCtrl.value))!;
        });
      });
    // 2초 후 힌트 페이드아웃
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _showHint = false);
    });
  }

  @override
  void dispose() {
    _snapCtrl.dispose();
    super.dispose();
  }

  /// 다음 카드로 이동 (무한 순환)
  void _goNext() {
    setState(() {
      _index = (_index + 1) % widget.wishes.length;
      _drag = Offset.zero;
    });
  }

  /// 스냅백 (제자리로 돌아오기)
  void _snapBack() {
    _snapFrom = _drag;
    _snapCtrl.forward(from: 0);
  }

  int _realIndex(int offset) => (_index + offset) % widget.wishes.length;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 52;

    return LayoutBuilder(builder: (context, c) {
      final w = c.maxWidth;
      final threshold = w * 0.3;

      // 스택에 보일 카드 (최대 3장)
      final stackCount = widget.wishes.length.clamp(1, 3);

      return Padding(
        padding: EdgeInsets.only(top: topPad, left: 20, right: 20, bottom: 20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            for (int i = stackCount - 1; i >= 0; i--)
              _buildCard(widget.wishes[_realIndex(i)], i, threshold),
            // 스와이프 힌트 오버레이 (처음 한번만)
            if (_showHint)
              AnimatedOpacity(
                opacity: _showHint ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.textBlack.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 16, color: AppColors.white),
                      const SizedBox(width: 4),
                      Text('넘기기', style: AppTextStyles.caption2.copyWith(color: AppColors.white)),
                      Container(
                        width: 1,
                        height: 14,
                        margin: const EdgeInsets.symmetric(horizontal: 14),
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                      Text('소문내기', style: AppTextStyles.caption2.copyWith(color: AppColors.white)),
                      const SizedBox(width: 4),
                      const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.white),
                    ],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildCard(Wish wish, int stackIndex, double threshold) {
    final isTop = stackIndex == 0;
    Widget card = _SwipeCardContent(wish: wish);

    if (isTop) {
      final angle = (_drag.dx / 400) * 0.15;
      card = GestureDetector(
        onTap: () => widget.onTap(wish),
        onPanUpdate: (d) {
          if (_snapCtrl.isAnimating) return;
          setState(() => _drag += d.delta);
        },
        onPanEnd: (d) {
          if (_drag.dx < -threshold) {
            // 왼쪽 스와이프 → 다음 카드
            _goNext();
          } else if (_drag.dx > threshold) {
            // 오른쪽 스와이프 → 소문내기
            _goNext();
            widget.onBuzz(wish);
          } else {
            // 스냅백
            _snapBack();
          }
        },
        child: Transform.translate(
          offset: _drag,
          child: Transform.rotate(angle: angle, child: card),
        ),
      );
    }

    return card;
  }
}

/// 스와이프 카드 콘텐츠
class _SwipeCardContent extends StatelessWidget {
  final Wish wish;
  const _SwipeCardContent({required this.wish});

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
                  Image.network(
                    wish.productImageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: AppColors.gray100,
                      child: Center(
                        child: Text(wish.category.emoji, style: const TextStyle(fontSize: 80)),
                      ),
                    ),
                  ),
                  if (wish.isEmpathyReached)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryMain,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.white),
                            const SizedBox(width: 4),
                            Text(
                              '공감 달성',
                              style: AppTextStyles.caption2.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
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
                  Row(
                    children: [
                      Text(
                        '${wish.category.emoji} ${wish.category.label.split('/').first}',
                        style: AppTextStyles.caption4.copyWith(color: AppColors.gray400),
                      ),
                      if (wish.isBusinessWish) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                          ),
                          child: Text(
                            wish.businessName ?? 'AD',
                            style: AppTextStyles.caption4.copyWith(
                              color: AppColors.primaryMain,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wish.oneLiner,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title1.copyWith(
                      fontWeight: FontWeight.w800,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    wish.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption1.copyWith(color: AppColors.gray400),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Text(
                        _formatPrice(wish.productPrice),
                        style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(width: 4),
                      Text('원',
                          style: AppTextStyles.title3.copyWith(
                              fontWeight: FontWeight.w700, color: AppColors.gray600)),
                      const Spacer(),
                      const Icon(Icons.people_outline_rounded, size: 14, color: AppColors.gray400),
                      const SizedBox(width: 3),
                      Text('${wish.participantCount}',
                          style: AppTextStyles.caption4.copyWith(color: AppColors.gray400)),
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

  String _formatPrice(int price) {
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
