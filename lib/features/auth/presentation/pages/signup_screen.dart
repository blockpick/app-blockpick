import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/auth/data/services/google_auth_service.dart';
import '../../../../core/auth/data/services/apple_auth_service.dart';

/// SC-005-01: 회원가입 방법 선택 화면
///
/// - 이메일 가입 버튼
/// - 구글 계정 가입 버튼 (구글 OAuth → 휴대폰 인증)
/// - 애플 계정 가입 버튼 (애플 OAuth → 휴대폰 인증)
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
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
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkBlue),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '회원가입',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // 안내 문구
              Text(
                '반가워요!\nBlockpick에서 게임을\n시작해볼까요?',
                style: AppTextStyles.heading1.copyWith(color: AppColors.darkBlue),
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
                onTap: _isLoading ? null : () => _handleGoogleSignup(),
              ),
              const SizedBox(height: 12),

              // 애플 가입 버튼
              _buildSignupButton(
                icon: Icons.apple,
                iconColor: AppColors.white,
                iconBgColor: AppColors.black,
                text: '애플 계정으로 가입',
                borderColor: AppColors.gray200,
                onTap: _isLoading ? null : () => _handleAppleSignup(),
              ),

              Spacer(),

              // 하단 로그인 안내
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '이미 계정이 있으신가요?',
                    style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
                  ),
                  TextButton(
                    onPressed: () => context.push('/login'),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      '로그인',
                      style: AppTextStyles.title3.copyWith(color: AppColors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
            // 로딩 오버레이
            if (_isLoading)
              Container(
                color: AppColors.black.withValues(alpha: 0.3),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                  ),
                ),
              ),
          ],
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
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(color: borderColor ?? AppColors.gray200),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: iconBgColor == AppColors.white
                      ? Border.all(color: AppColors.gray200)
                      : null,
                ),
                child: Center(
                  child: customIcon ??
                      Icon(icon, size: 22, color: iconColor),
                ),
              ),
              SizedBox(width: 16),
              Text(
                text,
                style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
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

  /// 구글 계정 가입: OAuth 인증 → 휴대폰 인증으로 이동
  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);

    try {
      final googleAuth = ref.read(googleAuthServiceProvider);
      final result = await googleAuth.signIn();

      if (!mounted) return;
      setState(() => _isLoading = false);

      context.push('/phone-verify', extra: {
        'signupType': 'google',
        'flowType': 'signup',
        'socialId': result.id,
        'socialEmail': result.email,
        'socialName': result.displayName,
        'socialPhotoUrl': result.photoUrl,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final msg = e.toString();
      // 사용자 취소는 무시
      if (msg.contains('취소') || msg.contains('cancel')) return;

      _showErrorSnackBar('구글 로그인에 실패했습니다. 다시 시도해 주세요.');
    }
  }

  /// 애플 계정 가입: OAuth 인증 → 휴대폰 인증으로 이동
  Future<void> _handleAppleSignup() async {
    // iOS에서만 지원
    if (!Platform.isIOS) {
      _showErrorSnackBar('Apple 로그인은 iOS에서만 지원됩니다.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final appleAuth = ref.read(appleAuthServiceProvider);

      final isAvailable = await appleAuth.isAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        _showErrorSnackBar('이 기기에서는 Apple 로그인을 지원하지 않습니다.');
        return;
      }

      final result = await appleAuth.signIn();

      if (!mounted) return;
      setState(() => _isLoading = false);

      context.push('/phone-verify', extra: {
        'signupType': 'apple',
        'flowType': 'signup',
        'socialId': result.userIdentifier,
        'socialEmail': result.email,
        'socialName': result.fullName,
        'socialPhotoUrl': null,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      final msg = e.toString();
      if (msg.contains('cancel') || msg.contains('1001')) return;

      _showErrorSnackBar('Apple 로그인에 실패했습니다. 다시 시도해 주세요.');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusLg)),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF4285F4); // Google brand color
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
