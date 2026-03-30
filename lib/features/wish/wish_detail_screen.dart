import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wish_model.dart';
import '../../providers/wish_provider.dart';
import 'widgets/empathy_progress.dart';
import 'widgets/empathy_comment_list.dart';

/// 소원 상세 화면
class WishDetailScreen extends ConsumerWidget {
  final String wishId;

  const WishDetailScreen({super.key, required this.wishId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wish = ref.watch(wishDetailProvider(wishId));

    if (wish == null) {
      return Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(backgroundColor: AppColors.white, elevation: 0),
        body: const Center(
          child: Text('소원을 찾을 수 없어요', style: TextStyle(color: AppColors.gray400)),
        ),
      );
    }

    final empathies = ref.watch(wishEmpathiesProvider(wishId));

    return Scaffold(
      backgroundColor: AppColors.white,
      body: CustomScrollView(
        slivers: [
          // 앱바 + 이미지
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.textBlack,
            actions: [
              IconButton(
                onPressed: () {
                  // TODO: 공유
                },
                icon: const Icon(Icons.share_outlined),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                wish.productImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.gray100,
                  child: const Icon(Icons.image_outlined, size: 60, color: AppColors.gray400),
                ),
              ),
            ),
          ),

          // 본문
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${wish.category.emoji} ${wish.category.label}',
                      style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                    ),
                  ),
                  // 업체 배지
                  if (wish.isBusinessWish) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.campaign, size: 14, color: AppColors.white),
                          const SizedBox(width: 4),
                          Text(
                            wish.businessName ?? 'BRAND',
                            style: AppTextStyles.caption2.copyWith(color: AppColors.white),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // 한줄평
                  Text(
                    '"${wish.oneLiner}"',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 상품 정보 섹션
                  _SectionTitle(title: '상품 정보'),
                  const SizedBox(height: 8),
                  Text(
                    wish.productName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textBlack,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '💰 ${_formatPrice(wish.productPrice)}원',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 쇼핑몰 링크
                  GestureDetector(
                    onTap: () {
                      // TODO: 인앱 웹뷰로 구매 URL 열기
                    },
                    child: const Row(
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 14, color: AppColors.primary),
                        SizedBox(width: 4),
                        Text(
                          '쇼핑몰에서 보기 →',
                          style: AppTextStyles.body4.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // 소원 현황 섹션
                  _SectionTitle(title: '소원 현황'),
                  const SizedBox(height: 8),
                  // 등록자 + 등록일
                  Row(
                    children: [
                      const Icon(Icons.person_outline, size: 14, color: AppColors.gray400),
                      const SizedBox(width: 4),
                      Text(
                        '등록자: @${wish.userName ?? '알 수 없음'}',
                        style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(wish.createdAt),
                        style: const TextStyle(fontSize: 12, color: AppColors.gray400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 공감 프로그레스
                  EmpathyProgress(wish: wish),
                  const SizedBox(height: 8),
                  // 참여자 수
                  if (wish.participantCount > 0)
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatCount(wish.participantCount)}명 소문내기 참여',
                          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                        ),
                      ],
                    ),
                  // 업체 경품
                  if (wish.isBusinessWish && wish.prizeDescription != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🎁 경품 안내',
                            style: AppTextStyles.title3.copyWith(color: AppColors.primary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            wish.prizeDescription!,
                            style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '당첨 시 운영사가 대신 구매!',
                            style: TextStyle(fontSize: 12, color: AppColors.gray400),
                          ),
                        ],
                      ),
                    ),
                  ],
                  // 업체 노출 진행률
                  if (wish.isBusinessWish) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, size: 14, color: AppColors.gray400),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatCount(wish.currentExposures ?? 0)} / ${_formatCount(wish.maxExposures ?? 0)}명',
                          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: wish.exposureProgress,
                        minHeight: 4,
                        backgroundColor: AppColors.gray200,
                        valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  // 댓글 섹션
                  _SectionTitle(title: '댓글 (${empathies.length}개)'),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 댓글 리스트
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: EmpathyCommentList(empathies: empathies),
            ),
          ),

          // 하단 여백 (CTA 버튼 공간)
          const SliverToBoxAdapter(
            child: SizedBox(height: 120),
          ),
        ],
      ),
      // 하단 CTA
      bottomNavigationBar: _buildBottomCTA(context, ref, wish),
    );
  }

  Widget _buildBottomCTA(BuildContext context, WidgetRef ref, Wish wish) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.gray200, width: 1)),
      ),
      child: Row(
        children: [
          // 공감 버튼
          if (!wish.isBusinessWish &&
              (wish.status == WishStatus.pending || wish.status == WishStatus.active))
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _EmpathyButton(
                wish: wish,
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref.read(empathizeWishProvider.notifier).empathize(wishId);
                  messenger.showSnackBar(
                    const SnackBar(
                      content: Text('❤️ 공감했어요!'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          // 메인 CTA
          Expanded(child: _buildMainCTA(context, wish)),
        ],
      ),
    );
  }

  Widget _buildMainCTA(BuildContext context, Wish wish) {
    switch (wish.status) {
      case WishStatus.pending:
        return ElevatedButton(
          onPressed: null,
          style: _ctaStyle(AppColors.gray200),
          child: Text(
            '공감 ${wish.remainingEmpathy}개 더 필요',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        );
      case WishStatus.active:
        return ElevatedButton(
          onPressed: null,
          style: _ctaStyle(AppColors.gray200),
          child: const Text(
            '곧 소문낼 수 있어요',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        );
      case WishStatus.inGame:
        final isFree = wish.isBusinessWish;
        return ElevatedButton(
          onPressed: () {
            // TODO: 소문내기 게임 진입 (Phase 5)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('소문내기 게임은 Phase 5에서 연동됩니다')),
            );
          },
          style: _ctaStyle(AppColors.primary),
          child: Text(
            isFree ? '✨ 소문내기 무료' : '✨ 소문내기 10원',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
        );
      case WishStatus.won:
        return ElevatedButton(
          onPressed: () {},
          style: _ctaStyle(AppColors.primary),
          child: const Text(
            '🎉 당첨! 결과 보기',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
        );
      case WishStatus.expired:
        return ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: _ctaStyle(AppColors.gray600),
          child: const Text(
            '📝 다시 등록하기',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.white),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  ButtonStyle _ctaStyle(Color bg) {
    return ElevatedButton.styleFrom(
      backgroundColor: bg,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0,
    );
  }

  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
  }
}

/// 섹션 타이틀
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.buttonLarge.copyWith(color: AppColors.textBlack),
    );
  }
}

/// 공감 버튼
class _EmpathyButton extends StatelessWidget {
  final Wish wish;
  final VoidCallback onTap;
  const _EmpathyButton({required this.wish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.red.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.favorite_outline, size: 20, color: AppColors.red),
            const SizedBox(height: 2),
            Text(
              '${wish.empathyCount}',
              style: AppTextStyles.caption4.copyWith(color: AppColors.red, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
