import 'package:flutter/foundation.dart';
// dart:io는 웹에서 지원하지 않으므로 조건부로 사용
import 'dart:io' if (dart.library.html) 'package:blockpick_flutter/utils/platform_stub.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/auth/data/services/apple_auth_service.dart';
import '../../../../core/auth/data/services/google_auth_service.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../widgets/auth_button.dart';

/// 토스 스타일의 로그인 선택 화면
///
/// - SNS 로그인 (구글/애플)
/// - 이메일 로그인
/// - 회원가입 안내
class LoginSelectScreen extends ConsumerWidget {
  LoginSelectScreen({super.key});

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
                _buildLoginButtons(context, ref),

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
        SizedBox(height: 32),

        // 환영 메시지
        Text(
          '반가워요!',
          style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
        ),
        SizedBox(height: 8),
        Text(
          '로그인하고 블록픽을 시작하세요',
          style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // 애플 로그인 (iOS에서만 표시)
        if (Platform.isIOS)
          _SocialButton(
            icon: Icons.apple,
            text: 'Apple로 계속하기',
            backgroundColor: AppColors.black,
            textColor: AppColors.white,
            onTap: () => _handleAppleLogin(context, ref),
          ),
        // 애플과 구글 버튼 사이 간격
        if (Platform.isIOS) const SizedBox(height: 12),
        // 구글 로그인
        _SocialButton(
          icon: null,
          customIcon: _buildGoogleIcon(),
          text: 'Google로 계속하기',
          backgroundColor: AppColors.white,
          textColor: AppColors.darkBlue,
          borderColor: AppColors.gray300,
          onTap: () => _handleGoogleLogin(context, ref),
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
                style: AppTextStyles.body3.copyWith(color: AppColors.gray500),
              ),
            ),
            Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
          ],
        ),
        SizedBox(height: 24),
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
              style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
            ),
            TextButton(
              onPressed: () => context.push('/auth/signup-select'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '회원가입',
                style: AppTextStyles.title3.copyWith(color: AppColors.blue),
              ),
            ),
          ],
        ),
        SizedBox(height: 16),
        Text(
          '로그인 시 이용약관과 개인정보처리방침에 동의하게 됩니다',
          style: AppTextStyles.caption1.copyWith(color: AppColors.gray500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleAppleLogin(BuildContext context, WidgetRef ref) async {
    final appleAuthService = AppleAuthService();

    // Apple 로그인 가능 여부 확인
    if (!Platform.isIOS) {
      _showErrorSnackBar(context, 'Apple 로그인은 iOS에서만 지원됩니다.');
      return;
    }

    final isAvailable = await appleAuthService.isAvailable();
    if (!isAvailable) {
      _showErrorSnackBar(context, 'Apple 로그인을 사용할 수 없습니다.');
      return;
    }

    try {
      // 로딩 표시
      _showLoadingDialog(context);

      // Apple 로그인 수행
      final appleResult = await appleAuthService.signIn();

      // Auth Provider를 통해 소셜 로그인 수행
      await ref.read(authProvider.notifier).socialSignIn(
            provider: 'APPLE',
            socialId: appleResult.userIdentifier,
            email: appleResult.email,
            name: appleResult.fullName,
          );

      // 로딩 닫기
      if (context.mounted) Navigator.of(context).pop();

      // 홈으로 이동
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      // 로딩 닫기
      if (context.mounted) Navigator.of(context).pop();

      // 사용자가 취소한 경우
      if (e.toString().contains('canceled') ||
          e.toString().contains('AuthorizationErrorCode.canceled')) {
        return;
      }

      // 에러 처리
      if (context.mounted) {
        _showErrorSnackBar(context, 'Apple 로그인에 실패했습니다: ${e.toString()}');
      }
    }
  }

  Future<void> _handleGoogleLogin(BuildContext context, WidgetRef ref) async {
    final googleAuthService = GoogleAuthService();

    try {
      // 로딩 표시
      _showLoadingDialog(context);

      // Google 로그인 수행
      final googleResult = await googleAuthService.signIn();

      // Auth Provider를 통해 소셜 로그인 수행
      await ref.read(authProvider.notifier).socialSignIn(
            provider: 'GOOGLE',
            socialId: googleResult.id,
            email: googleResult.email,
            name: googleResult.displayName,
            profileImageUrl: googleResult.photoUrl,
          );

      // 로딩 닫기
      if (context.mounted) Navigator.of(context).pop();

      // 홈으로 이동
      if (context.mounted) {
        context.go('/home');
      }
    } catch (e) {
      // 로딩 닫기
      if (context.mounted) Navigator.of(context).pop();

      // 사용자가 취소한 경우
      if (e.toString().contains('취소')) {
        return;
      }

      // 에러 처리
      if (context.mounted) {
        _showErrorSnackBar(context, 'Google 로그인에 실패했습니다: ${e.toString()}');
      }
    }
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: AppColors.blue),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
      ),
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
              SizedBox(width: 12),
              Text(
                text,
                style: AppTextStyles.title2.copyWith(color: textColor),
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
            Text(
              '처음 오셨네요!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '회원가입을 진행할까요?',
              style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
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

    paint.color = AppColors.white;
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
