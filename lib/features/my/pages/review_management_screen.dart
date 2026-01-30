import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/winner_model.dart';
import '../../../utils/time_utils.dart';

/// SC-011-17: 리뷰관리 화면
class ReviewManagementScreen extends StatefulWidget {
  const ReviewManagementScreen({super.key});

  @override
  State<ReviewManagementScreen> createState() =>
      _ReviewManagementScreenState();
}

class _ReviewManagementScreenState extends State<ReviewManagementScreen> {
  // TODO: 실제 API 연동
  late List<_ReviewItemData> _reviewItems;

  @override
  void initState() {
    super.initState();
    _reviewItems = List.from(_mockReviewItems);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: const Text(
            '리뷰관리',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            _buildNoticeBanner(),
            Expanded(
              child: _reviewItems.isEmpty
                  ? _buildEmptyState()
                  : _buildReviewList(),
            ),
          ],
        ),
      ),
    );
  }

  /// 상단 안내 배너
  Widget _buildNoticeBanner() {
    return GestureDetector(
      onTap: _showGuidelineDialog,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                '리뷰 작성 전, 꼭 확인해 주세요!',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chevron_right,
                size: 16,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 리뷰 가이드라인 다이얼로그
  void _showGuidelineDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        title: Text(
          '리뷰 작성 안내',
          style: AppTextStyles.medium.copyWith(
            color: AppColors.darkBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGuidelineItem('1', '당첨된 경품에 한해 리뷰 1건만 작성 가능합니다.'),
            const SizedBox(height: 12),
            _buildGuidelineItem('2', '리뷰는 10자 이상 작성해 주세요.'),
            const SizedBox(height: 12),
            _buildGuidelineItem('3', '욕설, 비방, 광고 등 부적절한 내용은 삭제될 수 있습니다.'),
            const SizedBox(height: 12),
            _buildGuidelineItem('4', '작성된 리뷰는 블록픽 서비스 내 노출될 수 있습니다.'),
            const SizedBox(height: 12),
            _buildGuidelineItem('5', '리뷰 수정은 작성 후에도 가능합니다.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '확인',
              style: AppTextStyles.body.copyWith(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 가이드라인 항목
  Widget _buildGuidelineItem(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.gray200,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.gray600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 빈 상태
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '작성 가능한 리뷰가 없어요.',
              style: AppTextStyles.medium.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '이벤트에 당첨되면\n리뷰를 작성할 수 있어요.',
              style: AppTextStyles.body.copyWith(
                color: AppColors.medium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 리뷰 리스트
  Widget _buildReviewList() {
    // 미작성 리뷰가 상단, 최근순 정렬
    final sortedItems = List<_ReviewItemData>.from(_reviewItems)
      ..sort((a, b) {
        if (a.hasReview != b.hasReview) {
          return a.hasReview ? 1 : -1;
        }
        return b.participatedAt.compareTo(a.participatedAt);
      });

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: sortedItems.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.gray200,
      ),
      itemBuilder: (context, index) {
        return _buildReviewItem(sortedItems[index]);
      },
    );
  }

  /// 리뷰 아이템
  Widget _buildReviewItem(_ReviewItemData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProductImage(item.productImageAsset),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 배지 + 시간
                    Row(
                      children: [
                        _buildEventBadge(item.eventType),
                        const SizedBox(width: 8),
                        Text(
                          TimeUtils.getRelativeTime(item.participatedAt),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.gray500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 상품명
                    Text(
                      item.productName,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 12),
                    // 리뷰쓰기/수정하기 버튼
                    _buildActionButton(item),
                  ],
                ),
              ),
            ],
          ),
          // 작성된 리뷰 텍스트
          if (item.hasReview && item.reviewText != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Text(
                item.reviewText!,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.gray700,
                  height: 1.5,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 상품 이미지
  Widget _buildProductImage(String? imageAsset) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      child: Container(
        width: 72,
        height: 72,
        color: AppColors.gray100,
        child: imageAsset != null
            ? Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildImagePlaceholder(),
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return const Center(
      child: Icon(
        Icons.card_giftcard_rounded,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }

  /// 이벤트 타입 배지
  Widget _buildEventBadge(EventType type) {
    Color badgeColor;
    switch (type) {
      case EventType.daily:
        badgeColor = AppColors.blue;
      case EventType.select:
        badgeColor = AppColors.purple;
      case EventType.vibe:
        badgeColor = AppColors.pink;
      case EventType.prime:
        badgeColor = AppColors.yellow;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
      ),
      child: Text(
        type.displayName.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          height: 1.2,
        ),
      ),
    );
  }

  /// 리뷰쓰기 / 수정하기 버튼
  Widget _buildActionButton(_ReviewItemData item) {
    final hasReview = item.hasReview;

    return GestureDetector(
      onTap: () => _navigateToReviewWrite(item),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: hasReview ? AppColors.gray100 : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: hasReview ? AppColors.gray200 : AppColors.gray300,
            width: 1,
          ),
        ),
        child: Text(
          hasReview ? '수정하기' : '리뷰쓰기',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: hasReview ? AppColors.gray600 : AppColors.darkBlue,
          ),
        ),
      ),
    );
  }

  /// 리뷰 작성/수정 화면으로 이동
  Future<void> _navigateToReviewWrite(_ReviewItemData item) async {
    final result = await context.push<String>(
      '/my/reviews/write',
      extra: {
        'productName': item.productName,
        'productImageUrl': item.productImageAsset,
        'eventType': item.eventType.name,
        'participatedAt':
            TimeUtils.getRelativeTime(item.participatedAt),
        if (item.hasReview && item.reviewText != null)
          'existingReview': item.reviewText,
      },
    );

    if (result != null && mounted) {
      setState(() {
        final index = _reviewItems.indexWhere((e) => e.id == item.id);
        if (index != -1) {
          _reviewItems[index] = _ReviewItemData(
            id: item.id,
            productName: item.productName,
            productImageAsset: item.productImageAsset,
            eventType: item.eventType,
            participatedAt: item.participatedAt,
            hasReview: true,
            reviewText: result,
          );
        }
      });
    }
  }
}

// ========== 내부 데이터 모델 ==========

/// 리뷰 아이템 데이터
class _ReviewItemData {
  final String id;
  final String productName;
  final String? productImageAsset;
  final EventType eventType;
  final DateTime participatedAt;
  final bool hasReview;
  final String? reviewText;

  const _ReviewItemData({
    required this.id,
    required this.productName,
    this.productImageAsset,
    required this.eventType,
    required this.participatedAt,
    this.hasReview = false,
    this.reviewText,
  });
}

// ========== Mock 데이터 ==========

final _mockReviewItems = [
  _ReviewItemData(
    id: 'r1',
    productName: '스타벅스 e-카드 교환권 5만원',
    productImageAsset: 'assets/images/products/starbucks-card.webp',
    eventType: EventType.daily,
    participatedAt: DateTime.now().subtract(const Duration(days: 1)),
    hasReview: false,
  ),
  _ReviewItemData(
    id: 'r2',
    productName: '[SAMSUNG] 갤럭시 버즈3 프로 SM-R630NZAAKOO 제목은 최대 2줄 akf...',
    productImageAsset: 'assets/images/products/galaxy-buds3.webp',
    eventType: EventType.select,
    participatedAt: DateTime.now().subtract(const Duration(days: 3)),
    hasReview: false,
  ),
  _ReviewItemData(
    id: 'r3',
    productName: '롯데시네마 주말 예매권 2장',
    eventType: EventType.vibe,
    participatedAt: DateTime.now().subtract(const Duration(days: 7)),
    hasReview: true,
    reviewText: '블록픽에서 처음 당첨됐는데 정말 신기하고 기뻤어요! 영화 잘 보겠습니다. 감사합니다~',
  ),
];
