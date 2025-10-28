import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/wallet_provider.dart';
import 'widgets/cash_allocation_card.dart';
import 'widgets/transaction_list_item.dart';

/// MY 화면 (마이페이지)
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;
    final wallet = ref.watch(userWalletProvider);
    final recentTransactions = ref.watch(recentTransactionsProvider);

    print('🔍 MY 화면 빌드:');
    print('   - authState.isLoading: ${authState.isLoading}');
    print('   - user: ${user?.email ?? "null"}');
    print('   - wallet: ${wallet != null ? "있음" : "null"}');

    // if (user == null) {
    //   print('⏳ user가 null이라서 로딩 표시');
    //   return const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

    print('✅ MY 화면 콘텐츠 표시');

    return CustomScrollView(
      slivers: [
        // 총 자산 영역
        SliverToBoxAdapter(child: _buildTotalAssets(context, user)),

        // 주요 액션 버튼
        SliverToBoxAdapter(child: _buildActionButtons(context)),

        // 캐시 배분 섹션
        SliverToBoxAdapter(child: _buildCashAllocation(context, wallet)),

        // 활동 내역 섹션 (게임/쇼핑)
        SliverToBoxAdapter(child: _buildActivitySection(context)),

        // 최근 거래 내역
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingXl,
              AppConstants.spacingLg,
              AppConstants.spacingSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 거래 내역',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: 전체 거래 내역 페이지로 이동
                  },
                  child: const Text(
                    '전체보기',
                    style: TextStyle(color: AppColors.grayBlue, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 거래 내역 리스트
        SliverPadding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
          ),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              return TransactionListItem(
                transaction: recentTransactions[index],
              );
            }, childCount: recentTransactions.length),
          ),
        ),

        // 하단 여백
        const SliverToBoxAdapter(
          child: SizedBox(height: AppConstants.spacing2Xl),
        ),
      ],
    );
  }

  Widget _buildTotalAssets(BuildContext context, dynamic user) {
    final formatter = NumberFormat('#,###');
    final totalCash = user?.balance?.toInt() ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingSm,
      ),
      padding: const EdgeInsets.all(AppConstants.spacingXl),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.buleGray, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '총 보유 캐시',
            style: TextStyle(fontSize: 14, color: AppColors.grayBlue),
          ),
          const SizedBox(height: AppConstants.spacingSm),
          Row(
            children: [
              Text(
                '₩${formatter.format(totalCash)}',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      child: Row(
        children: [
          Expanded(
            child: _ActionButton(
              icon: Icons.add_card,
              label: '충전',
              onPressed: () {
                // TODO: 충전 페이지
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _ActionButton(
              icon: Icons.account_balance_wallet_outlined,
              label: '환불',
              onPressed: () {
                // TODO: 환불 페이지
              },
            ),
          ),
          const SizedBox(width: AppConstants.spacingMd),
          Expanded(
            child: _ActionButton(
              icon: Icons.history,
              label: '내역',
              onPressed: () {
                // TODO: 거래 내역 페이지
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCashAllocation(BuildContext context, dynamic wallet) {
    // wallet이 null이면 빈 위젯 반환
    if (wallet == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 캐시 잔액',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: AppConstants.spacingMd),
          Row(
            children: [
              Expanded(
                child: CashAllocationCard(
                  icon: Icons.videogame_asset,
                  title: '이벤트 캐시',
                  amount: wallet.eventCash,
                  status: '사용 가능',
                  isRefundable: true,
                ),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: CashAllocationCard(
                  icon: Icons.shopping_bag_outlined,
                  title: '쇼핑 캐시',
                  amount: wallet.shoppingCash,
                  status: '사용 가능',
                  isRefundable: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingLg,
        vertical: AppConstants.spacingMd,
      ),
      child: Column(
        children: [
          _ActivityCard(
            icon: Icons.videogame_asset,
            title: '게임 참가 내역',
            subtitle: '진행 중: 2건 • 완료: 15건',
            onTap: () {
              // TODO: 게임 참가 내역 페이지
            },
          ),
          const SizedBox(height: AppConstants.spacingMd),
          _ActivityCard(
            icon: Icons.shopping_bag_outlined,
            title: '쇼핑 주문 내역',
            subtitle: '최근 주문: 3건',
            onTap: () {
              // TODO: 쇼핑 주문 내역 페이지
            },
          ),
        ],
      ),
    );
  }
}

/// 액션 버튼 위젯
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      elevation: 0,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingLg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.buleGray, width: 1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Column(
            children: [
              Icon(icon, size: 28, color: AppColors.primary),
              const SizedBox(height: AppConstants.spacingSm),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 활동 카드 위젯
class _ActivityCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.buleGray, width: 1),
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppConstants.spacingMd),
                decoration: BoxDecoration(
                  color: AppColors.blueWhite,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Icon(icon, size: 24, color: AppColors.primary),
              ),
              const SizedBox(width: AppConstants.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.grayBlue,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
