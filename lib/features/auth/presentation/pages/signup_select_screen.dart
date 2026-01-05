import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_scaffold.dart';

/// 회원가입 선택 화면
///
/// - SNS 계정 가입 (구글/애플)
/// - 이메일 가입
class SignupSelectScreen extends ConsumerWidget {
  const SignupSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuthScaffold(
      showBackButton: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 타이틀
            const Text(
              '회원가입',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '가입 방법을 선택해주세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 48),

            // SNS 가입 옵션들
            _SignupOption(
              icon: Icons.apple,
              iconColor: AppColors.white,
              iconBgColor: AppColors.black,
              title: 'Apple로 시작하기',
              subtitle: '간편하게 Apple 계정으로 가입',
              onTap: () => _handleSocialSignup(context, 'apple'),
            ),
            const SizedBox(height: 16),

            _SignupOption(
              customIcon: _buildGoogleIcon(),
              iconBgColor: AppColors.white,
              title: 'Google로 시작하기',
              subtitle: '간편하게 Google 계정으로 가입',
              borderColor: AppColors.gray300,
              onTap: () => _handleSocialSignup(context, 'google'),
            ),
            const SizedBox(height: 16),

            _SignupOption(
              icon: Icons.email_outlined,
              iconColor: AppColors.blue,
              iconBgColor: AppColors.blue.withValues(alpha: 0.1),
              title: '이메일로 가입하기',
              subtitle: '이메일 주소로 직접 가입',
              borderColor: AppColors.gray300,
              onTap: () => context.push('/auth/phone-verify'),
            ),
          ],
        ),
      ),
      bottomButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '이미 계정이 있으신가요?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: AppColors.gray600,
            ),
          ),
          TextButton(
            onPressed: () => context.go('/auth/login-select'),
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
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  void _handleSocialSignup(BuildContext context, String provider) {
    // SNS 인증 후 휴대폰 인증으로 이동
    context.push('/auth/phone-verify', extra: {'provider': provider});
  }
}

/// 가입 옵션 위젯
class _SignupOption extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final Color? iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _SignupOption({
    this.icon,
    this.customIcon,
    this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? AppColors.gray200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: borderColor != null
                      ? Border.all(color: borderColor!, width: 1)
                      : null,
                ),
                child: Center(
                  child: customIcon ??
                      Icon(
                        icon,
                        size: 24,
                        color: iconColor,
                      ),
                ),
              ),
              const SizedBox(width: 16),

              // 텍스트
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray600,
                      ),
                    ),
                  ],
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

/// 구글 로고 페인터
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF4285F4);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );
    paint.color = Colors.white;
    final rect = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.35,
      size.width * 0.35,
      size.height * 0.3,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
