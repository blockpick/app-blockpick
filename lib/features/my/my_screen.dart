import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../components/common/common_app_bar.dart';

/// SC-011: 내 정보 화면
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
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              // 앱바
              SliverToBoxAdapter(
                child: CommonAppBar(
                  title: '내 정보',
                  trailing: SettingsButton(
                    onTap: () => context.push('/settings'),
                  ),
                ),
              ),

              // 본문
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 8),

                    // 1. 프로필 섹션
                    _buildProfileSection(
                      context,
                      ref,
                      user,
                      isAuthenticated,
                    ),

                    const SizedBox(height: 16),

                    // 2. 참여 내역 & 이벤트 포인트 카드 (로그인 시)
                    if (isAuthenticated) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _buildStatsCards(context, user),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // 3. 포인트 추가 적립 섹션 (로그인 시)
                    if (isAuthenticated) ...[
                      _buildPointEarnSection(context),
                      const SizedBox(height: 24),
                    ],

                    // 4. 메뉴 섹션
                    _buildMenuSection(context, isAuthenticated),

                    const SizedBox(height: 32),

                    // 5. 회사 정보 푸터
                    _buildFooter(context),

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

  /// 프로필 섹션
  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
    bool isAuthenticated,
  ) {
    if (!isAuthenticated) {
      // 비로그인 상태
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
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
                    context.push('/login');
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
        ),
      );
    }

    // 로그인 상태 - 프로필
    final profileImageUrl = user?.profileImageUrl;
    final hasProfileImage = profileImageUrl != null && profileImageUrl.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push('/settings/profile'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // 프로필 이미지
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  shape: BoxShape.circle,
                  image: hasProfileImage
                      ? DecorationImage(
                          image: NetworkImage(profileImageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: hasProfileImage
                    ? null
                    : Center(
                        child: Icon(
                          Icons.person,
                          size: 28,
                          color: AppColors.gray400,
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
                      user?.nickname ?? user?.email?.split('@').first ?? '사용자',
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
              // 화살표 버튼
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray600,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 참여 내역 & 이벤트 포인트 카드
  Widget _buildStatsCards(BuildContext context, dynamic user) {
    final formatter = NumberFormat('#,###');
    final eventPoints = user?.eventPoint.toInt() ?? 0;
    final participationCount = 4; // TODO: 실제 참여 횟수 데이터 연결

    return Row(
      children: [
        // 참여 내역 카드
        Expanded(
          child: _buildStatCard(
            title: '참여 내역',
            value: '$participationCount회',
            onTap: () => context.push('/my/game-history'),
          ),
        ),
        const SizedBox(width: 12),
        // 이벤트 포인트 카드
        Expanded(
          child: _buildStatCard(
            title: '이벤트 포인트',
            value: '${formatter.format(eventPoints)}P',
            onTap: () => context.push('/my/event-points'),
          ),
        ),
      ],
    );
  }

  /// 통계 카드 위젯
  Widget _buildStatCard({
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: AppColors.gray200,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 포인트 추가 적립 섹션
  Widget _buildPointEarnSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 제목
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              const Text(
                '포인트 추가 적립',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => _showPointInfoDialog(context),
                child: Icon(
                  Icons.help_outline_rounded,
                  size: 18,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // 포인트 적립 아이템들
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              _buildPointEarnItem(
                icon: Icons.person_add_outlined,
                title: '친구 추가 하고 10P 받기',
                onTap: () {
                  // TODO: 친구 추가 기능
                },
              ),
              const SizedBox(height: 8),
              _buildPointEarnItem(
                icon: Icons.videocam_outlined,
                title: '광고 시청 하고 30P 받기',
                onTap: () {
                  // TODO: 광고 시청 기능
                },
              ),
              const SizedBox(height: 8),
              _buildPointEarnItem(
                icon: Icons.phone_android_outlined,
                title: 'oooo앱 설치 하고 30P 받기',
                onTap: () {
                  // TODO: 앱 설치 기능
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 포인트 적립 아이템
  Widget _buildPointEarnItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.gray50,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: AppColors.gray700,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 포인트 적립 안내 다이얼로그
  void _showPointInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '포인트 적립 안내',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBullet('매일 출석 체크로 10P를 받으세요.'),
            const SizedBox(height: 8),
            _buildInfoBullet('광고 시청은 하루 최대 10회까지 가능합니다.'),
            const SizedBox(height: 8),
            _buildInfoBullet('친구 초대 시 친구가 첫 게임을 시작하면 포인트가 지급됩니다.'),
            const SizedBox(height: 8),
            _buildInfoBullet('포인트는 게임 참여에만 사용 가능하며 환불되지 않습니다.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBullet(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.darkBlue,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 메뉴 섹션
  Widget _buildMenuSection(BuildContext context, bool isAuthenticated) {
    return Column(
      children: [
        if (isAuthenticated) ...[
          _buildMenuItem(
            context,
            title: '후기관리',
            onTap: () => context.push('/my/reviews'),
          ),
          _buildMenuDivider(),
        ],
        _buildMenuItem(
          context,
          title: '알림설정',
          onTap: () => context.push('/settings/notifications'),
        ),
        _buildMenuDivider(),
        _buildMenuItem(
          context,
          title: '약관',
          onTap: () => context.push('/settings/terms'),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required String title,
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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
              const Spacer(),
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

  /// 회사 정보 푸터
  Widget _buildFooter(BuildContext context) {
    const footerTextStyle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      color: AppColors.gray500,
      height: 1.6,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      color: AppColors.gray50,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 회사명
          const Text(
            'Blockpick, Inc.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray700,
            ),
          ),
          const SizedBox(height: 6),
          // 주소
          const Text(
            '8th Floor, 101, Ogeum-ro, Songpa-gu, Seoul, Republic of Korea, [05548]',
            style: footerTextStyle,
          ),
          const SizedBox(height: 2),
          // 연락처
          const Text(
            'Contact : support@blockpick.com',
            style: footerTextStyle,
          ),
          const SizedBox(height: 12),
          // 링크들
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // TODO: 사업자 정보 페이지
                },
                child: const Text(
                  'Business Information',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              _footerDot(),
              GestureDetector(
                onTap: () => context.push('/settings/terms'),
                child: const Text(
                  'Terms of Service',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              _footerDot(),
              GestureDetector(
                onTap: () => context.push('/settings/privacy'),
                child: const Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // 법적 고지
          const Text(
            'Must be 18+ to participate in events. Void where prohibited by law.',
            style: footerTextStyle,
          ),
          const SizedBox(height: 4),
          const Text(
            'Apple is not a sponsor of any contests or sweepstakes within this app.',
            style: footerTextStyle,
          ),
          const SizedBox(height: 12),
          // 저작권
          const Text(
            '\u00a9 2025 Blockpick, Inc. All rights reserved.',
            style: footerTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _footerDot() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '\u00b7',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.gray400,
        ),
      ),
    );
  }
}
