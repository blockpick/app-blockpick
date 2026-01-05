import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_button.dart';

/// 토스 스타일의 로그인 선택 화면
///
/// - SNS 로그인 (구글/애플)
/// - 이메일 로그인
/// - 회원가입 안내
class LoginSelectScreen extends ConsumerWidget {
  const LoginSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(flex: 2),

                // 로고 및 환영 메시지
                _buildHeader(),

                const Spacer(flex: 3),

                // 로그인 버튼들
                _buildLoginButtons(context),

                const SizedBox(height: 24),

                // 이메일 로그인
                _buildEmailLoginButton(context),

                const SizedBox(height: 32),

                // 하단 정보
                _buildFooter(context),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // 로고
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.gradientBlue,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.blue.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'B',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // 환영 메시지
        const Text(
          '반가워요!',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '로그인하고 블록픽을 시작하세요',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(BuildContext context) {
    return Column(
      children: [
        // 애플 로그인
        _SocialButton(
          icon: Icons.apple,
          text: 'Apple로 계속하기',
          backgroundColor: AppColors.black,
          textColor: AppColors.white,
          onTap: () {
            // TODO: Apple 로그인 구현
            _handleSocialLogin(context, 'apple');
          },
        ),
        const SizedBox(height: 12),

        // 구글 로그인
        _SocialButton(
          icon: null,
          customIcon: _buildGoogleIcon(),
          text: 'Google로 계속하기',
          backgroundColor: AppColors.white,
          textColor: AppColors.darkBlue,
          borderColor: AppColors.gray300,
          onTap: () {
            // TODO: Google 로그인 구현
            _handleSocialLogin(context, 'google');
          },
        ),
      ],
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

  Widget _buildEmailLoginButton(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '또는',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray500,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
          ],
        ),
        const SizedBox(height: 24),
        AuthButton(
          text: '이메일로 계속하기',
          onPressed: () => context.push('/auth/email-login'),
          backgroundColor: AppColors.gray100,
          textColor: AppColors.darkBlue,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '계정이 없으신가요?',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
            TextButton(
              onPressed: () => context.push('/auth/signup-select'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          '로그인 시 이용약관과 개인정보처리방침에 동의하게 됩니다',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: AppColors.gray500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleSocialLogin(BuildContext context, String provider) {
    // SNS 로그인 후 회원 여부 확인
    // - 회원이면 홈으로 이동
    // - 비회원이면 회원가입 다이얼로그 표시
    showDialog(
      context: context,
      builder: (context) => _MemberCheckDialog(provider: provider),
    );
  }
}

/// 소셜 로그인 버튼
class _SocialButton extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;
  final VoidCallback? onTap;

  const _SocialButton({
    this.icon,
    this.customIcon,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.borderColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null)
                Icon(icon, size: 22, color: textColor)
              else if (customIcon != null)
                customIcon!,
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 회원 확인 다이얼로그
class _MemberCheckDialog extends StatelessWidget {
  final String provider;

  const _MemberCheckDialog({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.person_outline_rounded,
                size: 32,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '처음 오셨네요!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '회원가입을 진행할까요?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 24),
            AuthButton(
              text: '회원가입하기',
              onPressed: () {
                Navigator.of(context).pop();
                context.push('/auth/signup-info', extra: {'provider': provider});
              },
            ),
            const SizedBox(height: 12),
            AuthTextButton(
              text: '다음에 할게요',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

/// 구글 로고 커스텀 페인터
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 간단한 G 로고 (실제로는 SVG 사용 권장)
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
