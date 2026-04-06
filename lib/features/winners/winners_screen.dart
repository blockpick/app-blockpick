import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/winner_model.dart';
import '../../models/review_model.dart';
import '../../data/mock_winner_data.dart';
import '../../data/mock_review_data.dart';
import 'widgets/winner_list_item.dart';
import 'widgets/review_list_item.dart';
import 'widgets/winners_empty_state.dart';
import 'widgets/winners_filter_dropdown.dart';

/// Winners 화면 (당첨자 발표)
class WinnersScreen extends StatefulWidget {
  const WinnersScreen({super.key});

  @override
  State<WinnersScreen> createState() => _WinnersScreenState();
}

class _WinnersScreenState extends State<WinnersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EventType? _selectedEventType;
  ReviewSource? _selectedReviewSource;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            _buildTabBar(),
            _buildFilterRow(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildWinnersList(),
                  _buildReviewsList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH, vertical: 12),
      child: Text(
        'Winners',
        style: AppTextStyles.heading1.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.darkBlue,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  /// Tab Bar (역대 당첨자 / 리뷰)
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        border: Border.all(
          color: AppColors.gray300,
          width: 1,
        ),
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
          Tab(text: '역대 당첨자'),
          Tab(text: '리뷰'),
        ],
      ),
    );
  }

  /// Filter Row (드롭다운 + 내 당첨/리뷰 내역 버튼)
  Widget _buildFilterRow() {
    final isWinnersTab = _tabController.index == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 필터 드롭다운
          if (isWinnersTab)
            WinnersFilterDropdown<EventType>(
              value: _selectedEventType,
              items: [null, ...EventType.values],
              labelBuilder: (type) =>
                  type == null ? '전체' : type.displayName,
              onChanged: (value) {
                setState(() {
                  _selectedEventType = value;
                });
              },
            )
          else
            WinnersFilterDropdown<ReviewSource>(
              value: _selectedReviewSource,
              items: [null, ...ReviewSource.values],
              labelBuilder: (source) =>
                  source == null ? '전체' : source.displayName,
              onChanged: (value) {
                setState(() {
                  _selectedReviewSource = value;
                });
              },
            ),

          // 내 당첨/리뷰 내역 버튼
          GestureDetector(
            onTap: () {
              // 내 정보 > 참여 내역 > 당첨 탭으로 이동
              context.push('/my/game-history', extra: {'tab': 1});
            },
            child: Row(
              children: [
                Text(
                  isWinnersTab ? '내 당첨 내역' : '내 리뷰 내역',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppColors.darkBlue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 당첨자 리스트
  Widget _buildWinnersList() {
    final winners = MockWinnerData.filterByEventType(_selectedEventType);

    if (winners.isEmpty) {
      return WinnersEmptyState(
        message: '아직 이벤트 당첨자가 없어요.',
        subMessage: '보유하신 이벤트 포인트로\n대박 경품의 주인공이 되어보세요.',
        buttonText: '참여하러 가기',
        onButtonTap: () {
          // TODO: 이벤트 메뉴 첫 화면으로 이동
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
      itemCount: winners.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: AppColors.bgWhite,
      ),
      itemBuilder: (context, index) {
        final winner = winners[index];
        return WinnerListItem(
          winner: winner,
          onTap: () {
            context.push('/winners/${winner.id}');
          },
        );
      },
    );
  }

  /// 리뷰 리스트
  Widget _buildReviewsList() {
    final reviews = MockReviewData.filterBySource(_selectedReviewSource);

    if (reviews.isEmpty) {
      return WinnersEmptyState(
        message: '아직 당첨 리뷰가 없어요.',
        subMessage: '당첨 리뷰는 오직 이벤트 참여 후 쓸 수 있어요.\n지금 바로 당첨의 주인공이 되어보세요.',
        buttonText: '참여하러 가기',
        onButtonTap: () {
          // TODO: 이벤트 메뉴 첫 화면으로 이동
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPaddingH),
      itemCount: reviews.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        color: AppColors.bgWhite,
      ),
      itemBuilder: (context, index) {
        final review = reviews[index];
        return ReviewListItem(
          review: review,
          onTap: () {
            // TODO: 외부 링크로 이동 또는 상세 보기
          },
        );
      },
    );
  }
}
