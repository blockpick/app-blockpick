import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// SC-005-01: 회원가입 방법 선택 화면
///
/// - 이메일 가입 버튼
/// - 구글 계정 가입 버튼
/// - 애플 계정 가입 버튼
class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkBlue),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            '회원가입',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // 안내 문구
              const Text(
                '반가워요!\nBlockpick에서 게임을\n시작해볼까요?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                  height: 1.3,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 48),

              // 이메일 가입 버튼
              _buildSignupButton(
                icon: Icons.email_outlined,
                iconColor: AppColors.blue,
                iconBgColor: AppColors.blue.withValues(alpha: 0.1),
                text: '이메일로 가입하기',
                borderColor: AppColors.gray300,
                onTap: () => context.push('/phone-verify', extra: {'signupType': 'email'}),
              ),
              const SizedBox(height: 12),

              // 구글 가입 버튼
              _buildSignupButton(
                customIcon: _buildGoogleIcon(),
                iconBgColor: AppColors.white,
                text: '구글 계정으로 가입',
                borderColor: AppColors.gray300,
                onTap: () => _handleSocialSignup(context, 'google'),
              ),
              const SizedBox(height: 12),

              // 애플 가입 버튼
              _buildSignupButton(
                icon: Icons.apple,
                iconColor: AppColors.white,
                iconBgColor: AppColors.black,
                text: '애플 계정으로 가입',
                borderColor: AppColors.gray200,
                onTap: () => _handleSocialSignup(context, 'apple'),
              ),

              const Spacer(),

              // 하단 로그인 안내
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
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
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignupButton({
    IconData? icon,
    Widget? customIcon,
    Color? iconColor,
    required Color iconBgColor,
    required String text,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor ?? AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(10),
                  border: iconBgColor == AppColors.white
                      ? Border.all(color: AppColors.gray200)
                      : null,
                ),
                child: Center(
                  child: customIcon ??
                      Icon(icon, size: 22, color: iconColor),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.gray400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }

  void _handleSocialSignup(BuildContext context, String provider) {
    // SNS 인증 후 휴대폰 인증으로 이동
    context.push('/phone-verify', extra: {'signupType': provider});
  }
}

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
