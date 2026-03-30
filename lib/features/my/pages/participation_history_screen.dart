import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/winner_model.dart';
import '../../../utils/time_utils.dart';

/// SC-011: 참여 내역 화면 (참여/당첨 탭)
class ParticipationHistoryScreen extends StatefulWidget {
  final int initialTab;

  const ParticipationHistoryScreen({
    super.key,
    this.initialTab = 0,
  });

  @override
  State<ParticipationHistoryScreen> createState() =>
      _ParticipationHistoryScreenState();
}

class _ParticipationHistoryScreenState
    extends State<ParticipationHistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // TODO: 실제 API 연동
  final List<_ParticipationItemData> _participations = _mockParticipations;
  final List<_WinningItemData> _winnings = _mockWinnings;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          title: Text(
            '참여 내역',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            _buildTabBar(),
            const SizedBox(height: 8),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildParticipationTab(),
                  _buildWinningTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 탭 바 (참여 / 당첨)
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        border: Border.all(color: AppColors.gray300, width: 1),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl - 4),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.darkBlue,
        unselectedLabelColor: AppColors.gray500,
        labelStyle: AppTextStyles.body3.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.body3,
        labelPadding: EdgeInsets.zero,
        tabs: const [
          Tab(text: '참여'),
          Tab(text: '당첨'),
        ],
      ),
    );
  }

  // ========== 참여 탭 ==========

  Widget _buildParticipationTab() {
    if (_participations.isEmpty) {
      return _buildEmptyState(
        message: '최근 참여한 이벤트가 없어요.',
        subMessage: '보유하신 이벤트 포인트로\n대박 경품 이벤트에 참여해 보세요.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _participations.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.gray200,
      ),
      itemBuilder: (context, index) {
        return _buildParticipationItem(_participations[index]);
      },
    );
  }

  Widget _buildParticipationItem(_ParticipationItemData item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
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
                    SizedBox(width: 8),
                    Text(
                      TimeUtils.getRelativeTime(item.participatedAt),
                      style: AppTextStyles.body4.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 상품명 (최대 2줄)
                Text(
                  item.productName,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // 상태 배지
                _buildParticipationStatusBadge(item.status),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 참여 상태 배지
  Widget _buildParticipationStatusBadge(_ParticipationStatus status) {
    final Color bgColor;
    final Color textColor;
    final String text;

    switch (status) {
      case _ParticipationStatus.inProgress:
        bgColor = AppColors.blue.withValues(alpha: 0.1);
        textColor = AppColors.blue;
        text = '진행중';
      case _ParticipationStatus.completed:
        bgColor = AppColors.gray200;
        textColor = AppColors.gray600;
        text = '종료';
      case _ParticipationStatus.won:
        bgColor = AppColors.green500.withValues(alpha: 0.1);
        textColor = AppColors.green500;
        text = '당첨';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
      ),
      child: Text(
        text,
        style: AppTextStyles.caption2.copyWith(color: textColor),
      ),
    );
  }

  // ========== 당첨 탭 ==========

  Widget _buildWinningTab() {
    if (_winnings.isEmpty) {
      return _buildEmptyState(
        message: '최근 당첨된 이벤트가 없어요.',
        subMessage: '보유하신 이벤트 포인트로\n대박 경품 이벤트에 참여해 보세요.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _winnings.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: AppColors.gray200,
      ),
      itemBuilder: (context, index) {
        return _buildWinningItem(_winnings[index]);
      },
    );
  }

  Widget _buildWinningItem(_WinningItemData item) {
    final isPending = item.claimStatus == _WinningClaimStatus.pending;
    final String claimText;
    switch (item.claimStatus) {
      case _WinningClaimStatus.pending:
        claimText = '상품 받기';
      case _WinningClaimStatus.claimed:
        claimText = '상품 받기 완료';
      case _WinningClaimStatus.delivered:
        claimText = '상품 받기 완료';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
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
                    SizedBox(width: 8),
                    Text(
                      TimeUtils.getRelativeTime(item.winDate),
                      style: AppTextStyles.body4.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // 상품명 (최대 2줄)
                Text(
                  item.productName,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // 상품 받기 / 당첨 리뷰쓰기 버튼
                Row(
                  children: [
                    _buildActionChip(
                      text: claimText,
                      isEnabled: isPending,
                      onTap: isPending
                          ? () => _handleClaimProduct(item)
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _buildActionChip(
                      text: '당첨 리뷰쓰기',
                      isEnabled: true,
                      onTap: () => _handleWriteReview(item),
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

  // ========== 공통 위젯 ==========

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
    return Center(
      child: Icon(
        Icons.card_giftcard_rounded,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }

  /// 이벤트 타입 배지 (DAILY / SELECT / VIBE / PRIME)
  Widget _buildEventBadge(EventType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _getBadgeColor(type),
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

  /// 액션 칩 버튼 (상품 받기 / 당첨 리뷰쓰기)
  Widget _buildActionChip({
    required String text,
    required bool isEnabled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isEnabled ? AppColors.white : AppColors.gray100,
          borderRadius: BorderRadius.circular(AppConstants.radiusFull),
          border: Border.all(
            color: isEnabled ? AppColors.gray300 : AppColors.gray200,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption2,
        ),
      ),
    );
  }

  /// 빈 상태 (당첨 이벤트가 없을 때)
  Widget _buildEmptyState({
    required String message,
    required String subMessage,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              message,
              style: AppTextStyles.title1.copyWith(
                color: AppColors.darkBlue,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12),
            Text(
              subMessage,
              style: AppTextStyles.body3.copyWith(
                color: AppColors.medium,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24),
            // 참여하러 가기 버튼
            GestureDetector(
              onTap: _navigateToHome,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.darkBlue,
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '참여하러 가기',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== 헬퍼 ==========

  Color _getBadgeColor(EventType type) {
    switch (type) {
      case EventType.daily:
        return AppColors.blue;
      case EventType.select:
        return AppColors.purple;
      case EventType.vibe:
        return AppColors.pink;
      case EventType.prime:
        return AppColors.yellow500;
    }
  }

  /// 상품 받기 처리
  void _handleClaimProduct(_WinningItemData item) {
    // TODO: 상품 받기 로직 구현
    // - 배송지 필요 상품 → 배송지 입력 화면 이동
    //   (입력된 정보가 있으면 입력 정보 그대로 표시)
    // - e-쿠폰 → 가입된 휴대폰 번호로 MMS 전송
    // - 배송 완료 시 → 상품 받기 완료로 변경 (버튼 비활성화)
  }

  /// 당첨 리뷰 작성
  void _handleWriteReview(_WinningItemData item) {
    // TODO: 리뷰 작성 화면으로 이동
  }

  /// 홈 화면으로 이동
  void _navigateToHome() {
    context.go('/');
  }
}

// ========== 내부 데이터 모델 ==========

/// 참여 상태
enum _ParticipationStatus {
  inProgress,
  completed,
  won,
}

/// 상품 수령 상태
enum _WinningClaimStatus {
  pending,
  claimed,
  delivered,
}

/// 참여 아이템 데이터
class _ParticipationItemData {
  final String id;
  final String productName;
  final String? productImageAsset;
  final EventType eventType;
  final DateTime participatedAt;
  final _ParticipationStatus status;

  const _ParticipationItemData({
    required this.id,
    required this.productName,
    this.productImageAsset,
    required this.eventType,
    required this.participatedAt,
    required this.status,
  });
}

/// 당첨 아이템 데이터
class _WinningItemData {
  final String id;
  final String productName;
  final String? productImageAsset;
  final EventType eventType;
  final DateTime winDate;
  final _WinningClaimStatus claimStatus;
  final bool hasReview;

  const _WinningItemData({
    required this.id,
    required this.productName,
    this.productImageAsset,
    required this.eventType,
    required this.winDate,
    required this.claimStatus,
    this.hasReview = false,
  });
}

// ========== Mock 데이터 ==========

final _mockParticipations = [
  _ParticipationItemData(
    id: 'p1',
    productName: '스타벅스 e-카드 교환권 5만원',
    productImageAsset: 'assets/images/products/starbucks-card.webp',
    eventType: EventType.daily,
    participatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: _ParticipationStatus.won,
  ),
  _ParticipationItemData(
    id: 'p2',
    productName: '[SAMSUNG] 갤럭시 버즈3 프로 SM-R630NZAAKOO 제목은 최대 2줄 akf...',
    productImageAsset: 'assets/images/products/galaxy-buds3.webp',
    eventType: EventType.select,
    participatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: _ParticipationStatus.inProgress,
  ),
  _ParticipationItemData(
    id: 'p3',
    productName: '롯데시네마 주말 예매권 2장',
    eventType: EventType.vibe,
    participatedAt: DateTime.now().subtract(const Duration(hours: 2)),
    status: _ParticipationStatus.completed,
  ),
];

final _mockWinnings = [
  _WinningItemData(
    id: 'w1',
    productName: '스타벅스 e-카드 교환권 5만원',
    productImageAsset: 'assets/images/products/starbucks-card.webp',
    eventType: EventType.daily,
    winDate: DateTime.now().subtract(const Duration(hours: 2)),
    claimStatus: _WinningClaimStatus.pending,
  ),
  _WinningItemData(
    id: 'w2',
    productName: '[SAMSUNG] 갤럭시 버즈3 프로 SM-R630NZAAKOO 제목은 최대 2줄 akf...',
    productImageAsset: 'assets/images/products/galaxy-buds3.webp',
    eventType: EventType.select,
    winDate: DateTime.now().subtract(const Duration(hours: 2)),
    claimStatus: _WinningClaimStatus.pending,
  ),
  _WinningItemData(
    id: 'w3',
    productName: '롯데시네마 주말 예매권 2장',
    eventType: EventType.vibe,
    winDate: DateTime.now().subtract(const Duration(hours: 2)),
    claimStatus: _WinningClaimStatus.delivered,
    hasReview: true,
  ),
];
