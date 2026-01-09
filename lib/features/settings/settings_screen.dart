import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../../core/auth/data/repositories/auth_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/notification_settings_provider.dart';

/// 토스 스타일 설정 화면
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isAuthenticated = authState.valueOrNull?.isAuthenticated ?? false;
    final notificationSettings = ref.watch(notificationSettingsProvider).valueOrNull ??
        const NotificationSettings();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: const Text(
            '설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // 계정 관리 섹션
            if (isAuthenticated) ...[
              _buildSectionTitle('계정 관리'),
              const SizedBox(height: 8),
              _buildCard([
                _SettingItem(
                  icon: Icons.person_outline_rounded,
                  title: '프로필 수정',
                  onTap: () => context.push('/settings/profile'),
                ),
                _buildDivider(),
                _SettingItem(
                  icon: Icons.lock_outline_rounded,
                  title: '비밀번호 변경',
                  onTap: () => context.push('/settings/password'),
                ),
              ]),
              const SizedBox(height: 24),
            ],

            // 알림 설정 섹션
            _buildSectionTitle('알림 설정'),
            const SizedBox(height: 8),
            _buildCard([
              _SettingToggleItem(
                icon: Icons.notifications_none_rounded,
                title: '푸시 알림',
                value: notificationSettings.pushEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsProvider.notifier).setPushEnabled(value);
                },
              ),
              _buildDivider(),
              _SettingToggleItem(
                icon: Icons.campaign_outlined,
                title: '마케팅 수신 동의',
                value: notificationSettings.marketingEnabled,
                onChanged: (value) {
                  ref.read(notificationSettingsProvider.notifier).setMarketingEnabled(value);
                },
              ),
            ]),
            const SizedBox(height: 24),

            // 앱 정보 섹션
            _buildSectionTitle('앱 정보'),
            const SizedBox(height: 8),
            _buildCard([
              _SettingItem(
                icon: Icons.info_outline_rounded,
                title: '버전 정보',
                trailing: Text(
                  'v1.0.0',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray500,
                  ),
                ),
                showArrow: false,
                onTap: () {},
              ),
              _buildDivider(),
              _SettingItem(
                icon: Icons.description_outlined,
                title: '이용약관',
                onTap: () => context.push('/settings/terms'),
              ),
              _buildDivider(),
              _SettingItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보처리방침',
                onTap: () => context.push('/settings/privacy'),
              ),
              _buildDivider(),
              _SettingItem(
                icon: Icons.headset_mic_outlined,
                title: '고객센터',
                onTap: () => context.push('/settings/customer-service'),
              ),
            ]),
            const SizedBox(height: 24),

            // 로그아웃/로그인
            _buildCard([
              if (isAuthenticated)
                _SettingItem(
                  icon: Icons.logout_rounded,
                  title: '로그아웃',
                  textColor: AppColors.blue,
                  showArrow: false,
                  onTap: () => _showLogoutDialog(context, ref),
                )
              else
                _SettingItem(
                  icon: Icons.login_rounded,
                  title: '로그인',
                  textColor: AppColors.blue,
                  onTap: () {
                    context.push('/login');
                  },
                ),
            ]),

            // 회원 탈퇴 (로그인 시에만)
            if (isAuthenticated) ...[
              const SizedBox(height: 16),
              _buildCard([
                _SettingItem(
                  icon: Icons.delete_outline_rounded,
                  title: '회원 탈퇴',
                  textColor: AppColors.red,
                  showArrow: false,
                  onTap: () => _showDeleteAccountDialog(context, ref),
                ),
              ]),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.gray600,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.gray100,
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '로그아웃',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        content: const Text(
          '로그아웃 하시겠습니까?',
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) {
                context.go('/');
              }
            },
            child: Text(
              '로그아웃',
              style: TextStyle(color: AppColors.blue),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          '회원 탈퇴',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        content: const Text(
          '정말로 탈퇴하시겠습니까?\n모든 데이터가 삭제되며 복구할 수 없습니다.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showPasswordInputDialog(context, ref);
            },
            child: Text(
              '탈퇴',
              style: TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showPasswordInputDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    bool isLoading = false;
    String? errorMessage;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            '비밀번호 확인',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '탈퇴를 위해 비밀번호를 입력해 주세요.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                enabled: !isLoading,
                decoration: InputDecoration(
                  hintText: '비밀번호',
                  hintStyle: TextStyle(color: AppColors.gray400),
                  filled: true,
                  fillColor: AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  errorText: errorMessage,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(
                '취소',
                style: TextStyle(
                  color: isLoading ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
            ),
            TextButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final password = passwordController.text.trim();
                      if (password.isEmpty) {
                        setState(() {
                          errorMessage = '비밀번호를 입력해 주세요.';
                        });
                        return;
                      }

                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });

                      try {
                        final authRepo = await ref.read(authRepositoryProvider.future);
                        final success = await authRepo.withdrawUser(
                          password: password,
                        );

                        if (!context.mounted) return;

                        if (success) {
                          Navigator.of(context).pop();
                          // 로그아웃 처리 (토큰 삭제는 withdrawUser에서 이미 처리됨)
                          await ref.read(authProvider.notifier).signOut();

                          if (context.mounted) {
                            // 탈퇴 완료 안내
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('회원 탈퇴가 완료되었습니다.'),
                                backgroundColor: AppColors.darkBlue,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );
                            context.go('/');
                          }
                        } else {
                          setState(() {
                            isLoading = false;
                            errorMessage = '탈퇴 처리에 실패했습니다.';
                          });
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        setState(() {
                          isLoading = false;
                          errorMessage = '비밀번호가 일치하지 않습니다.';
                        });
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
                      ),
                    )
                  : Text(
                      '탈퇴하기',
                      style: TextStyle(
                        color: AppColors.red,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ],
        ),
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
  final bool showArrow;

  const _SettingItem({
    required this.icon,
    required this.title,
    this.trailing,
    required this.onTap,
    this.textColor,
    this.showArrow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                size: 22,
                color: textColor ?? AppColors.gray700,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: textColor ?? AppColors.darkBlue,
                  ),
                ),
              ),
              if (trailing != null)
                trailing!
              else if (showArrow)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray400,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 토글 설정 항목 위젯
class _SettingToggleItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: AppColors.gray700,
          ),
          const SizedBox(width: 14),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.blue,
            activeTrackColor: AppColors.blue.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.gray400,
            inactiveTrackColor: AppColors.gray200,
          ),
        ],
      ),
    );
  }
}
