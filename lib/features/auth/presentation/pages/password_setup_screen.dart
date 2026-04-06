import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// 비밀번호 설정 화면
///
/// 회원가입 마지막 단계:
/// - 비밀번호 입력
/// - 비밀번호 확인
/// - 가입 완료
class PasswordSetupScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? phone;
  final bool? marketingAgreed;
  final String? verificationCode;

  const PasswordSetupScreen({
    super.key,
    this.email,
    this.phone,
    this.marketingAgreed,
    this.verificationCode,
  });

  @override
  ConsumerState<PasswordSetupScreen> createState() =>
      _PasswordSetupScreenState();
}

class _PasswordSetupScreenState extends ConsumerState<PasswordSetupScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  final _confirmFocusNode = FocusNode();

  String? _passwordError;
  String? _confirmError;
  bool _isLoading = false;

  // 비밀번호 규칙 체크
  bool _hasMinLength = false;
  bool _hasLetter = false;
  bool _hasNumber = false;
  bool _hasSpecial = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkPasswordRules);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    _passwordFocusNode.dispose();
    _confirmFocusNode.dispose();
    super.dispose();
  }

  void _checkPasswordRules() {
    final password = _passwordController.text;
    setState(() {
      _hasMinLength = password.length >= 8;
      _hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password);
      _hasNumber = RegExp(r'[0-9]').hasMatch(password);
      _hasSpecial = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
    });
  }

  bool get _isPasswordValid {
    // 최소 8자, 영문/숫자/특수문자 3가지 이상 조합
    int count = 0;
    if (_hasLetter) count++;
    if (_hasNumber) count++;
    if (_hasSpecial) count++;

    return _hasMinLength && count >= 2;
  }

  bool get _isConfirmValid {
    return _confirmController.text == _passwordController.text &&
        _confirmController.text.isNotEmpty;
  }

  bool get _canSubmit => _isPasswordValid && _isConfirmValid;

  Future<void> _handleSignup() async {
    if (!_isPasswordValid) {
      setState(
          () => _passwordError = '비밀번호 규칙을 확인해주세요');
      return;
    }

    if (!_isConfirmValid) {
      setState(() => _confirmError = '비밀번호가 일치하지 않아요');
      return;
    }

    setState(() {
      _isLoading = true;
      _passwordError = null;
      _confirmError = null;
    });

    try {
      // TODO: 레거시 코드 - 새 회원가입 플로우(phone_verify_screen → email_password_setup_screen) 사용 권장
      await ref.read(authProvider.notifier).signUp(
            email: widget.email!,
            password: _passwordController.text,
            phoneNumber: '', // 레거시: phoneNumber 없음 - 서버에서 에러 발생함
          );

      if (!mounted) return;

      // 회원가입 완료 화면으로 이동
      context.go('/auth/signup-complete');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _passwordError = '회원가입 중 오류가 발생했어요';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      progress: 0.875, // 3.5/4 단계
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),

            // 타이틀
            Text(
              '비밀번호를\n설정해주세요',
              style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
            ),
            const SizedBox(height: 40),

            // 비밀번호 입력
            AuthTextField(
              label: '비밀번호',
              hint: '비밀번호를 입력하세요',
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: true,
              textInputAction: TextInputAction.next,
              errorText: _passwordError,
              autofocus: true,
              onChanged: (_) => setState(() => _passwordError = null),
              onEditingComplete: () {
                _confirmFocusNode.requestFocus();
              },
            ),

            const SizedBox(height: 16),

            // 비밀번호 규칙 표시
            _buildPasswordRules(),

            const SizedBox(height: 24),

            // 비밀번호 확인
            AuthTextField(
              label: '비밀번호 확인',
              hint: '비밀번호를 다시 입력하세요',
              controller: _confirmController,
              focusNode: _confirmFocusNode,
              obscureText: true,
              textInputAction: TextInputAction.done,
              errorText: _confirmError,
              onChanged: (_) => setState(() => _confirmError = null),
              onEditingComplete: _handleSignup,
            ),
          ],
        ),
      ),
      bottomButton: AuthButton(
        text: '가입 완료',
        onPressed: _canSubmit ? _handleSignup : null,
        isLoading: _isLoading,
        enabled: _canSubmit,
      ),
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasswordRuleItem(
            text: '8자 이상',
            isValid: _hasMinLength,
          ),
          const SizedBox(height: 8),
          _PasswordRuleItem(
            text: '영문 포함',
            isValid: _hasLetter,
          ),
          const SizedBox(height: 8),
          _PasswordRuleItem(
            text: '숫자 포함',
            isValid: _hasNumber,
          ),
          const SizedBox(height: 8),
          _PasswordRuleItem(
            text: '특수문자 포함 (!@#\$%^&* 등)',
            isValid: _hasSpecial,
          ),
          SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              '* 영문/숫자/특수문자 중 2가지 이상 조합',
              style: AppTextStyles.caption1.copyWith(color: AppColors.gray500),
            ),
          ),
        ],
      ),
    );
  }
}

/// 비밀번호 규칙 아이템
class _PasswordRuleItem extends StatelessWidget {
  final String text;
  final bool isValid;

  const _PasswordRuleItem({
    required this.text,
    required this.isValid,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: isValid ? AppColors.green500 : Colors.transparent,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isValid ? AppColors.green500 : AppColors.gray400,
              width: 2,
            ),
          ),
          child: isValid
              ? const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: AppColors.white,
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: AppTextStyles.body3,
        ),
      ],
    );
  }
}
