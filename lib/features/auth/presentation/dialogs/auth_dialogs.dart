import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../widgets/login_form.dart';
import '../widgets/signup_form.dart';
import '../widgets/forgot_password_form.dart';

/// 로그인 다이얼로그 (팝업 모드)
Future<void> showLoginDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: const SingleChildScrollView(
          child: LoginForm(isDialog: true),
        ),
      ),
    ),
  );
}

/// 회원가입 다이얼로그 (팝업 모드)
Future<void> showSignupDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: const SingleChildScrollView(
          child: SignupForm(isDialog: true),
        ),
      ),
    ),
  );
}

/// 비밀번호 찾기 다이얼로그 (팝업 모드)
Future<void> showForgotPasswordDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    barrierColor: AppColors.black.withValues(alpha: 0.5),
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        ),
        child: const SingleChildScrollView(
          child: ForgotPasswordForm(isDialog: true),
        ),
      ),
    ),
  );
}
