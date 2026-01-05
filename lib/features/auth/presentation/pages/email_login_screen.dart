import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// 이메일 로그인 화면
class EmailLoginScreen extends ConsumerStatefulWidget {
  const EmailLoginScreen({super.key});

  @override
  ConsumerState<EmailLoginScreen> createState() => _EmailLoginScreenState();
}

class _EmailLoginScreenState extends ConsumerState<EmailLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty;
  }

  Future<void> _handleLogin() async {
    // 유효성 검사
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _emailError = '이메일을 입력해주세요');
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() => _emailError = '올바른 이메일 형식이 아니에요');
      return;
    }

    if (password.isEmpty) {
      setState(() => _passwordError = '비밀번호를 입력해주세요');
      return;
    }

    // 로그인 시도
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signIn(email, password);

      if (!mounted) return;

      // 로그인 성공 - 홈으로 이동
      context.go('/');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = '이메일 또는 비밀번호를 확인해주세요';
      });
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
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
              '이메일로\n로그인하기',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),

            // 이메일 입력
            AuthTextField(
              label: '이메일',
              hint: 'example@email.com',
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              errorText: _emailError,
              onChanged: (_) => setState(() => _emailError = null),
              onEditingComplete: () {
                _passwordFocusNode.requestFocus();
              },
            ),
            const SizedBox(height: 20),

            // 비밀번호 입력
            AuthTextField(
              label: '비밀번호',
              hint: '비밀번호를 입력하세요',
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: true,
              textInputAction: TextInputAction.done,
              errorText: _passwordError,
              onChanged: (_) => setState(() => _passwordError = null),
              onEditingComplete: _handleLogin,
            ),
            const SizedBox(height: 16),

            // 비밀번호 찾기
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => context.push('/auth/forgot-password'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  '비밀번호를 잊으셨나요?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthButton(
            text: '로그인',
            onPressed: _isFormValid ? _handleLogin : null,
            isLoading: _isLoading,
            enabled: _isFormValid,
          ),
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }
}
