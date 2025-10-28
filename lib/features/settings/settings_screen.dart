import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
      ),
      backgroundColor: AppColors.deepWhite,
      body: ListView(
        children: [
          // 사용자 정보 섹션
          if (user != null) ...[
            Container(
              color: AppColors.white,
              padding: const EdgeInsets.all(AppConstants.spacingXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppColors.blueWhite,
                        child: Text(
                          user.nickname?.substring(0, 1) ?? user.email.substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spacingLg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.nickname ?? '사용자',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],

          // 계정 관리
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingLg),
                  child: Text(
                    '계정 관리',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                  ),
                ),
                _SettingItem(
                  icon: Icons.person_outline,
                  title: '프로필 수정',
                  onTap: () {
                    // TODO: 프로필 수정 페이지
                  },
                ),
                _SettingItem(
                  icon: Icons.lock_outline,
                  title: '비밀번호 변경',
                  onTap: () {
                    // TODO: 비밀번호 변경 페이지
                  },
                ),
                _SettingItem(
                  icon: Icons.logout,
                  title: '로그아웃',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('로그아웃'),
                        content: const Text('로그아웃 하시겠습니까?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('로그아웃'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && context.mounted) {
                      await ref.read(authProvider.notifier).signOut();
                      if (context.mounted) {
                        context.go('/');
                      }
                    }
                  },
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 앱 정보
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingLg),
                  child: Text(
                    '앱 정보',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                  ),
                ),
                _SettingItem(
                  icon: Icons.info_outline,
                  title: '버전 정보',
                  trailing: const Text(
                    'v1.0.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.medium,
                    ),
                  ),
                  onTap: () {},
                ),
                _SettingItem(
                  icon: Icons.description_outlined,
                  title: '이용약관',
                  onTap: () {
                    // TODO: 이용약관 페이지
                  },
                ),
                _SettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '개인정보처리방침',
                  onTap: () {
                    // TODO: 개인정보처리방침 페이지
                  },
                ),
                _SettingItem(
                  icon: Icons.help_outline,
                  title: '고객센터',
                  onTap: () {
                    // TODO: 고객센터 페이지
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 알림 설정
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingLg),
                  child: Text(
                    '알림 설정',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                  ),
                ),
                _SettingItem(
                  icon: Icons.notifications_outlined,
                  title: '푸시 알림',
                  trailing: Switch(
                    value: true,
                    onChanged: (value) {
                      // TODO: 푸시 알림 설정
                    },
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
                _SettingItem(
                  icon: Icons.campaign_outlined,
                  title: '마케팅 수신 동의',
                  trailing: Switch(
                    value: false,
                    onChanged: (value) {
                      // TODO: 마케팅 수신 동의 설정
                    },
                    activeColor: AppColors.primary,
                  ),
                  onTap: () {},
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 기타
          Container(
            color: AppColors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(AppConstants.spacingLg),
                  child: Text(
                    '기타',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                  ),
                ),
                _SettingItem(
                  icon: Icons.delete_outline,
                  title: '회원 탈퇴',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('회원 탈퇴'),
                        content: const Text('정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text('취소'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.error,
                            ),
                            child: const Text('탈퇴'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      // TODO: 회원 탈퇴 처리
                    }
                  },
                  textColor: AppColors.error,
                ),
              ],
            ),
          ),

          const SizedBox(height: AppConstants.spacing2Xl),
        ],
      ),
    );
  }
}

/// 설정 항목 위젯
class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback onTap;
  final Color? textColor;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingLg,
            vertical: AppConstants.spacingLg,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: textColor ?? AppColors.navy,
              ),
              const SizedBox(width: AppConstants.spacingLg),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor ?? AppColors.darkBlue,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.medium,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
