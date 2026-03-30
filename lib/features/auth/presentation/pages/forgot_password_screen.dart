import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// 토스 스타일 비밀번호 찾기 화면
///
/// 3단계 프로세스:
/// 1. 이메일 입력 & 인증코드 발송
/// 2. 인증코드 입력 & 확인
/// 3. 새 비밀번호 설정
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  int _currentStep = 1;

  // 컨트롤러
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  // 상태
  bool _isLoading = false;
  String? _emailError;
  String? _codeError;
  String? _passwordError;
  String? _confirmError;

  // 타이머
  Timer? _timer;
  int _remainingSeconds = 180;

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
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    _timer?.cancel();
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

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress => _currentStep / 3;

  bool get _isEmailValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  bool get _isPasswordValid {
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

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  // Step 1: 인증코드 발송
  Future<void> _sendCode() async {
    if (!_isEmailValid) {
      setState(() => _emailError = '올바른 이메일 형식이 아니에요');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      final success = await ref
          .read(authProvider.notifier)
          .sendPasswordResetCode(_emailController.text.trim());

      if (success) {
        setState(() {
          _currentStep = 2;
          _remainingSeconds = 180;
        });
        _startTimer();
      } else {
        setState(() {
          _emailError = '등록되지 않은 이메일이에요';
        });
      }
    } catch (e) {
      setState(() {
        _emailError = '인증코드 발송 중 오류가 발생했어요';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Step 2: 인증코드 확인
  Future<void> _verifyCode() async {
    final code = _codeController.text;
    if (code.length != 6) {
      setState(() => _codeError = '인증번호 6자리를 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    // 테스트 코드: 000000 입력 시 바로 통과
    final isTestCode = code == '000000';

    if (isTestCode) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() {
        _isLoading = false;
        _currentStep = 3;
      });
      return;
    }

    try {
      final result = await ref.read(authProvider.notifier).verifyPasswordResetCode(
            email: _emailController.text.trim(),
            code: code,
          );

      if (result.isValid) {
        setState(() {
          _currentStep = 3;
        });
      } else {
        setState(() {
          _codeError = result.message ?? '인증번호가 올바르지 않아요 (테스트: 000000)';
        });
      }
    } catch (e) {
      setState(() {
        _codeError = '인증 중 오류가 발생했어요 (테스트: 000000)';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Step 3: 새 비밀번호 설정
  Future<void> _resetPassword() async {
    if (!_isPasswordValid) {
      setState(() => _passwordError = '비밀번호 규칙을 확인해주세요');
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
      final success = await ref.read(authProvider.notifier).resetPassword(
            email: _emailController.text.trim(),
            code: _codeController.text,
            newPassword: _passwordController.text,
          );

      if (!mounted) return;

      if (success) {
        _showSuccessDialog();
      } else {
        setState(() {
          _passwordError = '비밀번호 변경에 실패했어요';
        });
      }
    } catch (e) {
      setState(() {
        _passwordError = '비밀번호 변경 중 오류가 발생했어요';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
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
                  color: AppColors.green500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 32,
                  color: AppColors.green500,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '비밀번호가 변경되었어요',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '새로운 비밀번호로 로그인해주세요',
                style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 24),
              AuthButton(
                text: '로그인하러 가기',
                onPressed: () {
                  Navigator.of(context).pop();
                  context.go('/auth/email-login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _resendCode() async {
    setState(() {
      _codeController.clear();
      _codeError = null;
      _isLoading = true;
    });

    try {
      await ref
          .read(authProvider.notifier)
          .sendPasswordResetCode(_emailController.text.trim());

      setState(() {
        _remainingSeconds = 180;
      });
      _startTimer();
    } catch (e) {
      // 에러 무시
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      progress: _progress,
      onBack: () {
        if (_currentStep > 1) {
          setState(() => _currentStep--);
        } else {
          Navigator.of(context).pop();
        }
      },
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: _buildCurrentStep(),
      ),
      bottomButton: _buildBottomButton(),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return _buildStep1();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(
          '비밀번호를\n찾으시나요?',
          style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
        ),
        SizedBox(height: 12),
        Text(
          '가입하신 이메일로 인증번호를 보내드릴게요',
          style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
        ),
        const SizedBox(height: 40),
        AuthTextField(
          label: '이메일',
          hint: 'example@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: _emailError,
          autofocus: true,
          onChanged: (_) => setState(() => _emailError = null),
          onEditingComplete: _sendCode,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(
          '이메일로 전송된\n인증번호를 입력해주세요',
          style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
        ),
        SizedBox(height: 12),
        Text(
          _emailController.text.trim(),
          style: AppTextStyles.body2.copyWith(color: AppColors.blue),
        ),
        SizedBox(height: 40),
        AuthTextField(
          label: '인증번호',
          hint: '6자리 숫자 입력',
          controller: _codeController,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          maxLength: 6,
          errorText: _codeError,
          autofocus: true,
          onChanged: (_) => setState(() => _codeError = null),
          onEditingComplete: _verifyCode,
          suffix: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _formattedTime,
                style: AppTextStyles.title3.copyWith(color: _remainingSeconds > 60 ? AppColors.blue : AppColors.red),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _isLoading ? null : _resendCode,
            child: Text(
              '인증번호 다시 받기',
              style: AppTextStyles.title3.copyWith(color: AppColors.blue),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 32),
        Text(
          '새로운 비밀번호를\n설정해주세요',
          style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
        ),
        const SizedBox(height: 40),
        AuthTextField(
          label: '새 비밀번호',
          hint: '비밀번호를 입력하세요',
          controller: _passwordController,
          obscureText: true,
          textInputAction: TextInputAction.next,
          errorText: _passwordError,
          autofocus: true,
          onChanged: (_) => setState(() => _passwordError = null),
        ),
        const SizedBox(height: 16),
        _buildPasswordRules(),
        const SizedBox(height: 24),
        AuthTextField(
          label: '새 비밀번호 확인',
          hint: '비밀번호를 다시 입력하세요',
          controller: _confirmController,
          obscureText: true,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onChanged: (_) => setState(() => _confirmError = null),
          onEditingComplete: _resetPassword,
        ),
      ],
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PasswordRuleItem(text: '8자 이상', isValid: _hasMinLength),
          const SizedBox(height: 8),
          _PasswordRuleItem(text: '영문 포함', isValid: _hasLetter),
          const SizedBox(height: 8),
          _PasswordRuleItem(text: '숫자 포함', isValid: _hasNumber),
          const SizedBox(height: 8),
          _PasswordRuleItem(text: '특수문자 포함', isValid: _hasSpecial),
        ],
      ),
    );
  }

  Widget? _buildBottomButton() {
    switch (_currentStep) {
      case 1:
        return AuthButton(
          text: '인증번호 받기',
          onPressed: _isEmailValid ? _sendCode : null,
          isLoading: _isLoading,
          enabled: _isEmailValid,
        );
      case 2:
        return AuthButton(
          text: '인증하기',
          onPressed: _codeController.text.length == 6 ? _verifyCode : null,
          isLoading: _isLoading,
          enabled: _codeController.text.length == 6,
        );
      case 3:
        return AuthButton(
          text: '비밀번호 변경',
          onPressed: _isPasswordValid && _isConfirmValid ? _resetPassword : null,
          isLoading: _isLoading,
          enabled: _isPasswordValid && _isConfirmValid,
        );
      default:
        return null;
    }
  }
}

class _PasswordRuleItem extends StatelessWidget {
  final String text;
  final bool isValid;

  const _PasswordRuleItem({required this.text, required this.isValid});

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
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isValid ? AppColors.green500 : AppColors.gray400,
              width: 2,
            ),
          ),
          child: isValid
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
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
