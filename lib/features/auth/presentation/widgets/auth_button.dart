import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// 토스 스타일의 기본 버튼
class AuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double borderRadius;

  const AuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !isLoading && onPressed != null;
    final bgColor = isEnabled
        ? (backgroundColor ?? AppColors.blue)
        : AppColors.gray200;
    final txtColor = isEnabled
        ? (textColor ?? AppColors.white)
        : AppColors.gray500;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: height,
      width: double.infinity,
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(txtColor),
                    ),
                  )
                : Text(
                    text,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: txtColor,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

/// 토스 스타일의 소셜 로그인 버튼
class SocialLoginButton extends StatelessWidget {
  final String text;
  final String iconPath;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color? borderColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.iconPath,
    this.onPressed,
    this.backgroundColor = AppColors.white,
    this.textColor = AppColors.darkBlue,
    this.borderColor,
  });

  /// 구글 로그인 버튼
  factory SocialLoginButton.google({
    VoidCallback? onPressed,
  }) {
    return SocialLoginButton(
      text: 'Google로 계속하기',
      iconPath: 'assets/icons/google.svg',
      onPressed: onPressed,
      backgroundColor: AppColors.white,
      textColor: AppColors.darkBlue,
      borderColor: AppColors.gray300,
    );
  }

  /// 애플 로그인 버튼
  factory SocialLoginButton.apple({
    VoidCallback? onPressed,
  }) {
    return SocialLoginButton(
      text: 'Apple로 계속하기',
      iconPath: 'assets/icons/apple.svg',
      onPressed: onPressed,
      backgroundColor: AppColors.black,
      textColor: AppColors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null
            ? Border.all(color: borderColor!, width: 1)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
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

  Widget _buildIcon() {
    // SVG 아이콘 대신 임시로 아이콘 사용
    if (iconPath.contains('google')) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://www.google.com/favicon.ico',
            ),
            fit: BoxFit.contain,
          ),
        ),
      );
    } else if (iconPath.contains('apple')) {
      return const Icon(
        Icons.apple,
        size: 24,
        color: AppColors.white,
      );
    }
    return const SizedBox(width: 24, height: 24);
  }
}

/// 토스 스타일의 텍스트 버튼
class AuthTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? textColor;

  const AuthTextButton({
    super.key,
    required this.text,
    this.onPressed,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppColors.gray600,
        ),
      ),
    );
  }
}
