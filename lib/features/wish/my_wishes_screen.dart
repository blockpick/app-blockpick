import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wish_model.dart';
import '../../providers/wish_provider.dart';
import 'wish_create_screen.dart';
import 'wish_detail_screen.dart';

/// 내 소원 관리 화면 (MY 탭에서 진입)
class MyWishesScreen extends ConsumerWidget {
  const MyWishesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myWishes = ref.watch(myWishesProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: AppColors.textBlack,
        title: const Text(
          '내 소원',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: myWishes.isEmpty
          ? _buildEmpty(context)
          : _buildContent(context, myWishes),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.auto_awesome, size: 48, color: AppColors.gray400),
          const SizedBox(height: 16),
          const Text(
            '등록한 소원이 없어요',
            style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 번째 소원을 등록해보세요!',
            style: TextStyle(fontSize: 14, color: AppColors.gray400),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishCreateScreen()));
            },
            icon: const Icon(Icons.edit_outlined, size: 16),
            label: const Text('소원 등록하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Wish> wishes) {
    // 요약 통계 계산
    final totalEmpathy = wishes.fold<int>(0, (sum, w) => sum + w.empathyCount);
    final totalParticipants = wishes.fold<int>(0, (sum, w) => sum + w.participantCount);
    final wonCount = wishes.where((w) => w.wonCount > 0).length;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // 소원 요약
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                '나의 소원 현황',
                style: TextStyle(fontSize: 14, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(label: '등록', value: '${wishes.length}개'),
                  _StatItem(label: '총 공감', value: '$totalEmpathy개'),
                  _StatItem(label: '참여자', value: _formatCount(totalParticipants)),
                  _StatItem(label: '당첨', value: '$wonCount회'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // 소원 목록
        ...wishes.map((wish) => _WishListItem(
              wish: wish,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => WishDetailScreen(wishId: wish.id)),
                );
              },
            )),
        const SizedBox(height: 16),
        // 새 소원 등록 버튼
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const WishCreateScreen()));
            },
            icon: const Icon(Icons.add, size: 18),
            label: const Text('새 소원 등록하기'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }
}

class _WishListItem extends StatelessWidget {
  final Wish wish;
  final VoidCallback onTap;
  const _WishListItem({required this.wish, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          children: [
            // 상태 배지
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _statusColor(wish.status),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                wish.productImageUrl,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 50,
                  height: 50,
                  color: AppColors.gray100,
                  child: const Icon(Icons.image, size: 20, color: AppColors.gray400),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _statusColor(wish.status).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _statusLabel(wish.status),
                          style: AppTextStyles.caption4.copyWith(color: _statusColor(wish.status)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    wish.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title3,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '❤️${wish.empathyCount} · 👥${wish.participantCount}명',
                    style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20, color: AppColors.gray400),
          ],
        ),
      ),
    );
  }

  Color _statusColor(WishStatus status) {
    switch (status) {
      case WishStatus.inGame:
      case WishStatus.active:
        return const Color(0xFF04D94F); // green
      case WishStatus.pending:
        return const Color(0xFFFFC107); // yellow
      case WishStatus.won:
      case WishStatus.fulfilled:
        return AppColors.primary;
      case WishStatus.expired:
      case WishStatus.rejected:
        return AppColors.red;
    }
  }

  String _statusLabel(WishStatus status) {
    switch (status) {
      case WishStatus.pending:
        return '공감 수집 중';
      case WishStatus.active:
        return '활성화';
      case WishStatus.inGame:
        return '게임 진행 중';
      case WishStatus.won:
        return '당첨!';
      case WishStatus.fulfilled:
        return '상품 수령';
      case WishStatus.expired:
        return '만료';
      case WishStatus.rejected:
        return '거부됨';
    }
  }
}
