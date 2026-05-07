import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../data/point/point_models.dart';
import '../../providers/point_provider.dart';
import 'widgets/wallet_summary_card.dart';
import 'widgets/transaction_tile.dart';

/// SC-POI-01: 포인트 지갑 화면
/// 잔액 요약 + 거래 내역(reason별 필터) 표시
class PointWalletScreen extends ConsumerStatefulWidget {
  const PointWalletScreen({super.key});

  @override
  ConsumerState<PointWalletScreen> createState() => _PointWalletScreenState();
}

class _PointWalletScreenState extends ConsumerState<PointWalletScreen> {
  PointReason? _selectedReason; // null = 전체

  @override
  Widget build(BuildContext context) {
    final walletAsync = ref.watch(pointWalletProvider);
    final transactionsAsync = ref.watch(pointTransactionsProvider(0));

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textBlack,
          onPressed: () => context.pop(),
        ),
        title: Text(
          '포인트 지갑',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textBlack),
        ),
        centerTitle: true,
        actions: [
          // 미니게임 바로가기
          TextButton(
            onPressed: () => context.push('/point/mini-game'),
            child: Text(
              '미니게임',
              style: AppTextStyles.body4.copyWith(color: AppColors.primaryMain),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryMain,
        onRefresh: () async {
          ref.invalidate(pointWalletProvider);
          ref.invalidate(pointTransactionsProvider(0));
        },
        child: CustomScrollView(
          slivers: [
            // 잔액 카드
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 16),
                child: walletAsync.when(
                  data: (wallet) => WalletSummaryCard(wallet: wallet),
                  loading: () => _buildWalletShimmer(),
                  error: (e, _) => _buildWalletError(),
                ),
              ),
            ),

            // 적립 버튼 행
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                ),
                child: _buildEarnButtons(context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // 필터 칩
            SliverToBoxAdapter(
              child: _buildFilterChips(),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 8)),

            // 거래 내역 섹션 타이틀
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenPaddingH,
                  vertical: 12,
                ),
                child: Text(
                  '거래 내역',
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
              ),
            ),

            // 거래 내역 리스트
            transactionsAsync.when(
              data: (page) {
                final items = _filteredItems(page.items);
                if (items.isEmpty) {
                  return SliverToBoxAdapter(child: _buildEmptyState());
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = items[index];
                      return Column(
                        children: [
                          TransactionTile(transaction: item),
                          if (index < items.length - 1)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.screenPaddingH,
                              ),
                              child: Divider(
                                height: 1,
                                color: AppColors.gray200,
                              ),
                            ),
                        ],
                      );
                    },
                    childCount: items.length,
                  ),
                );
              },
              loading: () => SliverToBoxAdapter(
                child: const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: _buildListError(),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  /// 필터 적용된 거래 목록
  List<PointTransaction> _filteredItems(List<PointTransaction> all) {
    if (_selectedReason == null) return all;
    return all.where((t) => t.reason == _selectedReason).toList();
  }

  /// 포인트 적립 버튼 행
  Widget _buildEarnButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildEarnButton(
            icon: '📅',
            label: '출석체크',
            subtitle: '+10P',
            onTap: () => context.push('/point/check-in'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildEarnButton(
            icon: '🎮',
            label: '미니게임',
            subtitle: '+5P',
            onTap: () => context.push('/point/mini-game'),
          ),
        ),
      ],
    );
  }

  Widget _buildEarnButton({
    required String icon,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.textBlack,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.green500,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  /// reason 필터 칩
  Widget _buildFilterChips() {
    final reasons = [null, ...PointReason.values];
    final labels = {
      null: '전체',
      PointReason.checkIn: '출석',
      PointReason.miniGame: '미니게임',
      PointReason.adReward: '광고',
      PointReason.referral: '친구초대',
      PointReason.blockpickJoin: '블록픽',
      PointReason.offerwall: '오퍼월',
      PointReason.adminGrant: '관리자',
    };

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPaddingH,
      ),
      child: Row(
        children: reasons.map((reason) {
          final isSelected = _selectedReason == reason;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedReason = reason),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryMain : AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryMain
                        : AppColors.gray200,
                  ),
                ),
                child: Text(
                  labels[reason] ?? '',
                  style: AppTextStyles.caption1.copyWith(
                    color: isSelected ? AppColors.white : AppColors.gray600,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildWalletShimmer() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.screenPaddingH,
      ),
      height: 160,
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
    );
  }

  Widget _buildWalletError() {
    return Center(
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, color: AppColors.gray400, size: 32),
          const SizedBox(height: 8),
          Text(
            '잔액을 불러오지 못했어요.',
            style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.only(top: 60),
      child: Center(
        child: Column(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text(
              '거래 내역이 없어요.',
              style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListError() {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Center(
        child: Text(
          '내역을 불러오지 못했어요. 아래로 당겨 새로고침해 주세요.',
          textAlign: TextAlign.center,
          style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
        ),
      ),
    );
  }
}
