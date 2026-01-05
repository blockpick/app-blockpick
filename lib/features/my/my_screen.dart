import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../components/common/common_app_bar.dart';

/// 토스 스타일 MY 화면 (마이페이지)
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 앱바
              SliverToBoxAdapter(
                child: CommonAppBar(
                  title: 'My',
                  trailing: SettingsButton(
                    onTap: () => context.push('/settings'),
                  ),
                ),
              ),

              // 본문
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // 1. 프로필 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildProfileCard(
                      context,
                      ref,
                      user,
                      isAuthenticated,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 2. 내 자산 카드 (로그인 시)
                  if (isAuthenticated) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildAssetCard(context, user),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // 3. 퀵 액션 (로그인 시)
                  if (isAuthenticated) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildQuickActions(context),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 4. 메뉴 섹션
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildMenuSection(context, isAuthenticated),
                  ),

                  const SizedBox(height: 24),

                  // 5. 앱 정보
                  _buildAppInfo(),

                  const SizedBox(height: 100), // 바텀 네비게이션 여백
                ],
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }

  /// 프로필 카드
  Widget _buildProfileCard(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isAuthenticated,
  ) {
    if (!isAuthenticated) {
      // 비로그인 상태
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // 프로필 아이콘
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 40,
                color: AppColors.gray500,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '로그인이 필요합니다',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '로그인하고 다양한 서비스를 이용해보세요',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/auth/login-select');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkBlue,
                  foregroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 로그인 상태
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 프로필 이미지
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.gradientBlue,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                (user?.nickname ?? user?.email ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 유저 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nickname ?? user?.email ?? '사용자',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
              ],
            ),
          ),
          // 프로필 수정 버튼
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/settings/profile'),
              icon: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray600,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 자산 카드
  Widget _buildAssetCard(BuildContext context, dynamic user) {
    final formatter = NumberFormat('#,###');
    final balance = user?.balance?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '내 캐시',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/my/transactions'),
                child: Row(
                  children: [
                    Text(
                      '내역',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.gray500,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(balance),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '원',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 퀵 액션 버튼들
  Widget _buildQuickActions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildQuickActionItem(
            icon: Icons.add_rounded,
            label: '충전',
            onTap: () => context.push('/my/charge'),
          ),
          _buildQuickActionItem(
            icon: Icons.account_balance_wallet_outlined,
            label: '환불',
            onTap: () => context.push('/my/refund'),
          ),
          _buildQuickActionItem(
            icon: Icons.receipt_long_rounded,
            label: '거래내역',
            onTap: () => context.push('/my/transactions'),
          ),
          _buildQuickActionItem(
            icon: Icons.card_giftcard_rounded,
            label: '쿠폰',
            onTap: () => context.push('/my/coupon'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }

  /// 메뉴 섹션
  Widget _buildMenuSection(BuildContext context, bool isAuthenticated) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (isAuthenticated) ...[
            _buildMenuItem(
              context,
              icon: Icons.videogame_asset_rounded,
              title: '게임 참여 내역',
              subtitle: '참여한 게임과 결과 확인',
              onTap: () => context.push('/my/game-history'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              context,
              icon: Icons.shopping_bag_rounded,
              title: '쇼핑 주문 내역',
              subtitle: '주문 현황 및 배송 조회',
              onTap: () => context.push('/my/order-history'),
            ),
            _buildMenuDivider(),
            _buildMenuItem(
              context,
              icon: Icons.emoji_events_rounded,
              title: '당첨 내역',
              subtitle: '나의 당첨 기록',
              onTap: () => context.push('/my/winning-history'),
            ),
            _buildMenuDivider(),
          ],
          _buildMenuItem(
            context,
            icon: Icons.campaign_rounded,
            title: '공지사항',
            onTap: () => context.push('/my/announcements'),
          ),
          _buildMenuDivider(),
          _buildMenuItem(
            context,
            icon: Icons.info_outline_rounded,
            title: '이용 안내',
            onTap: () => context.push('/my/usage-guide'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: AppColors.gray700,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.gray100,
    );
  }

  /// 앱 정보
  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Text(
            'BlockPick',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.gray400,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '버전 1.0.0',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}
