import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/blockpick/blockpick_models.dart';
import '../../providers/blockpick_provider.dart';
import 'partner_detail_screen.dart';

/// 파트너 이벤트 목록 화면
/// 시안 기반: 상단 배너 + 카테고리 탭 + 2열 그리드
///
/// 데이터 소스: 새 GraphQL 스키마 — blockpicks(input: BlockpickFilterInput)
/// onlyOngoing=true 로 진행중인 블록픽만 가져온다. (스키마에 partner 전용 query 없음)
class PartnerScreen extends ConsumerStatefulWidget {
  const PartnerScreen({super.key});

  @override
  ConsumerState<PartnerScreen> createState() => _PartnerScreenState();
}

class _PartnerScreenState extends ConsumerState<PartnerScreen> {
  int _selectedCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'label': '전체', 'icon': Icons.apps_rounded},
    {'label': '가전', 'icon': Icons.devices_rounded},
    {'label': '패션', 'icon': Icons.checkroom_rounded},
    {'label': '여행', 'icon': Icons.flight_rounded},
    {'label': '맛집', 'icon': Icons.restaurant_rounded},
    {'label': '기프트카드', 'icon': Icons.card_giftcard_rounded},
  ];

  /// BlockpickSummary -> PartnerDetailScreen 호환용 Map 변환
  /// 옛 Game DTO 필드 구조를 흉내내어 partner_detail_screen 위젯이 그대로 동작하게 함.
  Map<String, dynamic> _toLegacyMap(BlockpickSummary bp) {
    return {
      'id': bp.id,
      'title': bp.title,
      'description': '',
      'mainProductName': bp.topPrize?.prize.name ?? '',
      'type': 'PARTNER_GACHA',
      'gameType': 'PARTNER_GACHA',
      'category': bp.category.name,
      'status': _mapStatus(bp.status),
      'hasInstantPrize': false,
      'maxEntries': null,
      'maxEntriesPerUser': bp.maxEntriesPerUser,
      'entryFee': 0,
      'startTime': bp.startTime,
      'endTime': bp.endTime,
      // partner_detail_screen이 game['gameProducts'][0]['product'] 형태를 기대.
      'gameProducts': [
        {
          'product': {
            'name': bp.topPrize?.prize.name ?? bp.title,
            'brand': bp.partner.name,
            'defaultImage': bp.thumbnailUrl ?? bp.topPrize?.prize.imageUrl,
            'price': bp.topPrize?.prize.faceValue,
          }
        }
      ],
    };
  }

  String _mapStatus(BlockpickStatus s) {
    // 옛 화면 코드는 IN_PROGRESS / SCHEDULED 를 본다.
    switch (s) {
      case BlockpickStatus.active:
        return 'IN_PROGRESS';
      case BlockpickStatus.draft:
      case BlockpickStatus.paused:
        return 'SCHEDULED';
      case BlockpickStatus.ended:
        return 'ENDED';
    }
  }

  /// 카테고리 라벨로 클라이언트 필터 (BlockpickSummary.category.name 비교)
  List<BlockpickSummary> _filterByCategory(List<BlockpickSummary> items) {
    if (_selectedCategory == 0) return items;
    final label = _categories[_selectedCategory]['label'] as String;
    return items.where((bp) => bp.category.name == label).toList();
  }

  @override
  Widget build(BuildContext context) {
    final asyncList = ref.watch(
      blockpickListProvider(
        const BlockpickFilterInput(onlyOngoing: true),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: asyncList.when(
          loading: () => const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
            ),
          ),
          error: (err, _) {
            debugPrint('[Partner] 에러: $err');
            return _buildError(() {
              // ignore: unused_result
              ref.refresh(blockpickListProvider(
                const BlockpickFilterInput(onlyOngoing: true),
              ));
            });
          },
          data: (page) {
            final filtered = _filterByCategory(page.items);
            return RefreshIndicator(
              onRefresh: () async {
                // ignore: unused_result
                ref.refresh(blockpickListProvider(
                  const BlockpickFilterInput(onlyOngoing: true),
                ));
                await ref.read(blockpickListProvider(
                  const BlockpickFilterInput(onlyOngoing: true),
                ).future);
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildBanner()),
                  SliverToBoxAdapter(child: _buildCategoryTabs()),
                  filtered.isEmpty
                      ? SliverToBoxAdapter(child: _buildEmpty())
                      : _buildGrid(filtered),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            '파트너 이벤트',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share_outlined, color: AppColors.gray500, size: 22),
          ),
        ],
      ),
    );
  }

  /// 상단 프로모션 배너
  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryMain, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildStoreLogo('CU', const Color(0xFF00A651)),
                    const SizedBox(width: 6),
                    _buildStoreLogo('GS25', const Color(0xFF0066B3)),
                    const SizedBox(width: 6),
                    _buildStoreLogo('7', const Color(0xFFE30613)),
                    const SizedBox(width: 6),
                    _buildStoreLogo('E', const Color(0xFFF5A623)),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  '4대 편의점 사용 가능!\n모바일상품권 10000원 획득하기',
                  style: AppTextStyles.title3.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  ),
                  child: Text(
                    '이벤트 참여하면 +1000P',
                    style: AppTextStyles.caption4.copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreLogo(String text, Color color) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: text.length > 2 ? 8 : 12,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == index;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = index),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryMain.withValues(alpha: 0.1)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    border: isSelected
                        ? Border.all(color: AppColors.primaryMain, width: 1.5)
                        : null,
                  ),
                  child: Icon(
                    cat['icon'] as IconData,
                    size: 22,
                    color: isSelected
                        ? AppColors.primaryMain
                        : AppColors.gray500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected
                        ? AppColors.primaryMain
                        : AppColors.gray500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGrid(List<BlockpickSummary> items) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final bp = items[index];
            return _BlockpickGridCard(
              item: bp,
              onTap: () => _openDetail(bp),
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }

  void _openDetail(BlockpickSummary bp) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PartnerDetailScreen(game: _toLegacyMap(bp)),
      ),
    );
  }

  Widget _buildError(VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: AppColors.gray300),
          const SizedBox(height: 12),
          Text(
            '게임 목록을 불러올 수 없습니다',
            style: TextStyle(fontSize: 14, color: AppColors.gray500),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.card_giftcard_outlined, size: 48, color: AppColors.gray300),
            const SizedBox(height: 12),
            Text(
              '진행중인 이벤트가 없습니다',
              style: TextStyle(fontSize: 14, color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }
}

/// 2열 그리드용 블록픽 카드
class _BlockpickGridCard extends StatelessWidget {
  final BlockpickSummary item;
  final VoidCallback onTap;

  const _BlockpickGridCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.thumbnailUrl ?? item.topPrize?.prize.imageUrl;
    final productName = item.topPrize?.prize.name ?? item.title;

    // 남은 시간 표시
    String timeLeft = '';
    try {
      final end = DateTime.parse(item.endTime);
      final diff = end.difference(DateTime.now());
      if (diff.isNegative) {
        timeLeft = '마감';
      } else {
        final h = diff.inHours.toString().padLeft(2, '0');
        final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
        final s = (diff.inSeconds % 60).toString().padLeft(2, '0');
        timeLeft = '$h:$m:$s 남음';
      }
    } catch (_) {}

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(color: AppColors.gray200),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1.1,
              child: Container(
                color: AppColors.gray100,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.image_outlined, size: 40, color: AppColors.gray300),
                        ),
                      )
                    : Center(
                        child: Icon(Icons.card_giftcard, size: 40, color: AppColors.gray300),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (timeLeft.isNotEmpty)
                      Text(
                        timeLeft,
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gray400,
                        ),
                      ),
                    const SizedBox(height: 2),
                    const Text(
                      '무료',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryMain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
