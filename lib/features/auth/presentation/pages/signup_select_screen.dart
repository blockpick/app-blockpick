import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// SC-005-01: 회원가입 선택 화면
///
/// - 토스 스타일 디자인
/// - SNS 계정 가입 (구글/애플)
/// - 이메일 가입
class SignupSelectScreen extends ConsumerWidget {
  const SignupSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 상단 헤더 (뒤로가기)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 22,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),

                      // 타이틀
                      const Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkBlue,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Blockpick에 오신 것을 환영해요!\n가입 방법을 선택해 주세요.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.gray600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 48),

                      // 이메일 가입 버튼
                      _SignupButton(
                        icon: Icons.email_rounded,
                        iconColor: AppColors.white,
                        iconBgColor: AppColors.darkBlue,
                        text: '이메일로 가입하기',
                        onTap: () => context.push('/phone-verify', extra: {
                          'signupType': 'email',
                          'flowType': 'signup',
                        }),
                      ),
                      const SizedBox(height: 12),

                      // 구글 가입 버튼
                      _SignupButton(
                        customIcon: _buildGoogleIcon(),
                        iconBgColor: Colors.white,
                        text: '구글 계정으로 가입하기',
                        hasBorder: true,
                        onTap: () => _handleSocialSignup(context, 'google'),
                      ),
                      const SizedBox(height: 12),

                      // 애플 가입 버튼
                      _SignupButton(
                        icon: Icons.apple,
                        iconColor: AppColors.white,
                        iconBgColor: AppColors.black,
                        text: '애플 계정으로 가입하기',
                        onTap: () => _handleSocialSignup(context, 'apple'),
                      ),

                      const Spacer(),

                      // 하단 로그인 안내
                      Padding(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '이미 계정이 있으신가요?',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: AppColors.gray500,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/login'),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                '로그인',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.network(
        'https://www.google.com/favicon.ico',
        width: 20,
        height: 20,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.g_mobiledata, size: 24, color: Colors.blue);
        },
      ),
    );
  }

  void _handleSocialSignup(BuildContext context, String provider) {
    // SNS 인증 후 휴대폰 인증으로 이동
    context.push('/phone-verify', extra: {
      'signupType': provider,
      'flowType': 'signup',
    });
  }
}

/// 토스 스타일 가입 버튼
class _SignupButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final Color iconBgColor;
  final String text;
  final bool hasBorder;
  final VoidCallback? onTap;

  const _SignupButton({
    this.icon,
    this.customIcon,
    this.iconColor,
    required this.iconBgColor,
    required this.text,
    this.hasBorder = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: hasBorder ? AppColors.gray200 : AppColors.gray100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: hasBorder
                      ? Border.all(color: AppColors.gray200, width: 1)
                      : null,
                ),
                child: Center(
                  child: customIcon ??
                      Icon(
                        icon,
                        size: 22,
                        color: iconColor,
                      ),
                ),
              ),
              const SizedBox(width: 14),

              // 텍스트
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),

              // 화살표
              Icon(
                Icons.chevron_right_rounded,
                size: 24,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
