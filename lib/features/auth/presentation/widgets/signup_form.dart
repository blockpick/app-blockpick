import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../../../../core/auth/domain/exceptions/auth_exception.dart';

enum SignUpStep {
  email, // 1단계: 이메일 입력 및 인증 코드 발송
  verifyCode, // 2단계: 인증 코드 확인
  userInfo, // 3단계: 비밀번호 및 닉네임 입력
}

/// 재사용 가능한 회원가입 폼 위젯 (3단계 프로세스)
class SignupForm extends ConsumerStatefulWidget {
  final bool isDialog;

  const SignupForm({
    super.key,
    this.isDialog = false,
  });

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _nicknameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  SignUpStep _currentStep = SignUpStep.email;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 1단계: 이메일 인증 코드 발송
  Future<void> _handleSendCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final success = await ref.read(authProvider.notifier).sendSignUpVerificationCode(email);

      if (success) {
        setState(() {
          _currentStep = SignUpStep.verifyCode;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Verification code sent to your email'),
              backgroundColor: AppColors.green500,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to send verification code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthException
          ? e.message
          : 'Email already exists or invalid';
        _isLoading = false;
      });
    }
  }

  // 2단계: 인증 코드 확인
  Future<void> _handleVerifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final code = _codeController.text.trim();

      final result = await ref.read(authProvider.notifier).verifySignUpCode(
        email: email,
        code: code,
      );

      if (result.isValid) {
        setState(() {
          _currentStep = SignUpStep.userInfo;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified successfully'),
              backgroundColor: AppColors.green500,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = result.message ?? 'Invalid verification code';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthException
          ? e.message
          : 'Verification failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  // 3단계: 최종 회원가입
  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      final nickname = _nicknameController.text.trim();

      // TODO: 레거시 코드 - 새 회원가입 플로우(phone_verify_screen → email_password_setup_screen) 사용 권장
      await ref.read(authProvider.notifier).signUp(
        email: email,
        password: password,
        phoneNumber: '', // 레거시: phoneNumber 없음 - 서버에서 에러 발생함
        nickname: nickname,
      );

      setState(() => _isLoading = false);

      // 회원가입 성공 시 다이얼로그/페이지 닫기
      if (mounted) {
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e is AuthException
          ? e.message
          : 'Signup failed. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _handleClose() {
    if (widget.isDialog) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }

  void _handleBack() {
    if (_currentStep == SignUpStep.verifyCode) {
      setState(() {
        _currentStep = SignUpStep.email;
        _codeController.clear();
        _errorMessage = null;
      });
    } else if (_currentStep == SignUpStep.userInfo) {
      setState(() {
        _currentStep = SignUpStep.verifyCode;
        _errorMessage = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: widget.isDialog ? MainAxisSize.min : MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (_currentStep != SignUpStep.email) ...[
                    IconButton(
                      onPressed: _handleBack,
                      icon: const Icon(Icons.arrow_back),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 12),
                  ],
                  const Text(
                    'Sign Up',
                    style: AppTextStyles.heading3,
                  ),
                ],
              ),
              IconButton(
                onPressed: _handleClose,
                icon: const Icon(Icons.close),
                iconSize: 20,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // 단계 표시
          _buildStepIndicator(),
          const SizedBox(height: 24),

          // 단계별 콘텐츠
          if (_currentStep == SignUpStep.email) _buildEmailStep(),
          if (_currentStep == SignUpStep.verifyCode) _buildVerifyCodeStep(),
          if (_currentStep == SignUpStep.userInfo) _buildUserInfoStep(),

          // 에러 메시지
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppColors.red.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTextStyles.body3.copyWith(color: AppColors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),

          // 하단 링크
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
              ),
              TextButton(
                onPressed: () {
                  if (widget.isDialog) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/login');
                  }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  'Sign in',
                  style: AppTextStyles.caption2.copyWith(color: AppColors.primaryMain),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      children: [
        _buildStepDot(1, _currentStep.index >= SignUpStep.email.index),
        Expanded(child: _buildStepLine(_currentStep.index >= SignUpStep.verifyCode.index)),
        _buildStepDot(2, _currentStep.index >= SignUpStep.verifyCode.index),
        Expanded(child: _buildStepLine(_currentStep.index >= SignUpStep.userInfo.index)),
        _buildStepDot(3, _currentStep.index >= SignUpStep.userInfo.index),
      ],
    );
  }

  Widget _buildStepDot(int step, bool isActive) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primaryMain : AppColors.gray200,
      ),
      child: Center(
        child: Text(
          '$step',
          style: AppTextStyles.title3.copyWith(
            color: isActive ? AppColors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      color: isActive ? AppColors.primaryMain : AppColors.gray200,
    );
  }

  // 1단계: 이메일 입력
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Enter your email address',
          style: AppTextStyles.caption1,
        ),
        const SizedBox(height: 16),
        const Text(
          'Email',
          style: AppTextStyles.title3,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: 'Enter email',
            hintStyle: AppTextStyles.hint.copyWith(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.primaryMain),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty || !value.contains('@')) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        _isLoading
            ? const Center(
                child: SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSendCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Send Verification Code',
                    style: AppTextStyles.title2,
                  ),
                ),
              ),
      ],
    );
  }

  // 2단계: 인증 코드 확인
  Widget _buildVerifyCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Enter the verification code sent to ${_emailController.text}',
          style: AppTextStyles.caption1,
        ),
        const SizedBox(height: 16),
        const Text(
          'Verification Code',
          style: AppTextStyles.title3,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _codeController,
          decoration: InputDecoration(
            hintText: 'Enter 6-digit code',
            hintStyle: AppTextStyles.hint.copyWith(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.primaryMain),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          keyboardType: TextInputType.number,
          maxLength: 6,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter verification code';
            }
            return null;
          },
        ),
        SizedBox(height: 8),
        TextButton(
          onPressed: _handleSendCode,
          child: Text(
            'Resend Code',
            style: AppTextStyles.body4.copyWith(color: AppColors.primaryMain),
          ),
        ),
        const SizedBox(height: 16),
        _isLoading
            ? const Center(
                child: SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleVerifyCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Verify Code',
                    style: AppTextStyles.title2,
                  ),
                ),
              ),
      ],
    );
  }

  // 3단계: 사용자 정보 입력
  Widget _buildUserInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Complete your profile',
          style: AppTextStyles.caption1,
        ),
        const SizedBox(height: 16),

        // 닉네임
        const Text(
          'Nickname',
          style: AppTextStyles.title3,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nicknameController,
          decoration: InputDecoration(
            hintText: 'Enter your nickname',
            hintStyle: AppTextStyles.hint.copyWith(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.primaryMain),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Enter a nickname';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 비밀번호
        const Text(
          'Password',
          style: AppTextStyles.title3,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            hintText: '••••••••••••',
            hintStyle: AppTextStyles.hint.copyWith(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.primaryMain),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.gray600,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value == null || value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // 비밀번호 확인
        const Text(
          'Confirm Password',
          style: AppTextStyles.title3,
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          decoration: InputDecoration(
            hintText: 'Confirm Password',
            hintStyle: AppTextStyles.hint.copyWith(color: AppColors.gray400),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.gray200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.primaryMain),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: const BorderSide(color: AppColors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.gray600,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
          validator: (value) {
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),

        // 회원가입 버튼
        _isLoading
            ? const Center(
                child: SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                ),
              )
            : SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryMain,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Sign Up',
                    style: AppTextStyles.title2,
                  ),
                ),
              ),
      ],
    );
  }
}
