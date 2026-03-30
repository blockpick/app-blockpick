import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// 이메일 입력 화면 (이메일 가입 플로우)
class EmailSignupScreen extends ConsumerStatefulWidget {
  final String? phone;

  const EmailSignupScreen({
    super.key,
    this.phone,
  });

  @override
  ConsumerState<EmailSignupScreen> createState() => _EmailSignupScreenState();
}

class _EmailSignupScreenState extends ConsumerState<EmailSignupScreen> {
  final _emailController = TextEditingController();
  String? _emailError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _checkEmailAndProceed() async {
    final email = _emailController.text.trim();

    if (!_isEmailValid) {
      setState(() => _emailError = '올바른 이메일 형식이 아니에요');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    // TODO: 이메일 중복 체크 API 호출
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // 중복 체크 결과에 따라 분기 (현재는 항상 성공으로 처리)
    final isDuplicate = false; // TODO: 실제 중복 체크 결과로 대체

    if (isDuplicate) {
      setState(() => _isLoading = false);
      _showDuplicateDialog();
      return;
    }

    // 약관 동의 화면으로 이동
    context.push('/auth/terms-agree', extra: {
      'email': email,
      'phone': widget.phone,
    });
  }

  void _showDuplicateDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                '이미 가입된 계정이에요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_emailController.text}\n으로 가입된 계정이 있어요',
                style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: '로그인하러 가기',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/auth/email-login');
                },
              ),
              const SizedBox(height: 12),
              AuthTextButton(
                text: '다른 이메일로 가입하기',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      progress: 0.375, // 이메일 가입 플로우에서 1.5/4 단계
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 타이틀
            const Text(
              '이메일을\n입력해주세요',
              style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
            ),
            const SizedBox(height: 12),
            Text(
              '로그인할 때 사용할 이메일이에요',
              style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
            ),
            const SizedBox(height: 40),

            // 이메일 입력
            AuthTextField(
              label: '이메일',
              hint: 'example@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              errorText: _emailError,
              autofocus: true,
              onChanged: (_) => setState(() => _emailError = null),
              onEditingComplete: _checkEmailAndProceed,
            ),
          ],
        ),
      ),
      bottomButton: AuthButton(
        text: '다음',
        onPressed: _isEmailValid ? _checkEmailAndProceed : null,
        isLoading: _isLoading,
        enabled: _isEmailValid,
      ),
    );
  }
}
