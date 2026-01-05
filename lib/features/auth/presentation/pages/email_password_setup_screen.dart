import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';

/// SC-005-04, SC-005-05: 이메일/비밀번호 설정 화면
///
/// - 토스 스타일 디자인
/// - 이메일 입력 및 인증번호 확인
/// - 비밀번호 설정 (영문,숫자,특수문자 8자 이상)
class EmailPasswordSetupScreen extends ConsumerStatefulWidget {
  final String? phone;
  final bool? agreeMarketing;

  const EmailPasswordSetupScreen({
    super.key,
    this.phone,
    this.agreeMarketing,
  });

  @override
  ConsumerState<EmailPasswordSetupScreen> createState() => _EmailPasswordSetupScreenState();
}

class _EmailPasswordSetupScreenState extends ConsumerState<EmailPasswordSetupScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final _confirmPasswordFocusNode = FocusNode();

  // 단계: 0=이메일, 1=인증번호, 2=비밀번호
  int _currentStep = 0;

  bool _codeVerified = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  String? _emailError;
  String? _codeError;
  String? _passwordError;
  String? _confirmPasswordError;

  // 타이머
  Timer? _timer;
  int _remainingSeconds = 180;
  int _resendCount = 0;
  static const int _maxResendCount = 3;

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  bool get _isEmailValid {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text);
  }

  bool get _isCodeValid {
    return _codeController.text.length == 6;
  }

  bool get _hasLetter => _passwordController.text.contains(RegExp(r'[a-zA-Z]'));
  bool get _hasDigit => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecial => _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _hasMinLength => _passwordController.text.length >= 8;

  bool get _isPasswordValid {
    return _hasLetter && _hasDigit && _hasSpecial && _hasMinLength;
  }

  bool get _passwordsMatch {
    return _passwordController.text == _confirmPasswordController.text &&
        _confirmPasswordController.text.isNotEmpty;
  }

  bool get _canComplete {
    return _codeVerified && _isPasswordValid && _passwordsMatch;
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _stepTitle {
    switch (_currentStep) {
      case 0:
        return '이메일을 입력해 주세요';
      case 1:
        return '인증번호를 입력해 주세요';
      case 2:
        return '비밀번호를 설정해 주세요';
      default:
        return '';
    }
  }

  String get _stepSubtitle {
    switch (_currentStep) {
      case 0:
        return '로그인에 사용할 이메일 주소를 입력해 주세요.';
      case 1:
        return '${_emailController.text}로 전송된\n6자리 인증번호를 입력해 주세요.';
      case 2:
        return '안전한 비밀번호를 설정해 주세요.';
      default:
        return '';
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        _showExpiredDialog();
      }
    });
  }

  Future<void> _sendEmailCode() async {
    if (!_isEmailValid) {
      setState(() => _emailError = '올바른 이메일 형식을 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    try {
      // 실제 이메일 인증번호 전송 API 호출
      final success = await ref
          .read(authProvider.notifier)
          .sendSignUpVerificationCode(_emailController.text)
          .timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!mounted) return;

      if (success) {
        setState(() {
          _isLoading = false;
          _currentStep = 1;
        });
        _startTimer();
        _codeFocusNode.requestFocus();
      } else {
        setState(() {
          _isLoading = false;
          _emailError = '인증번호 전송에 실패했습니다. 다시 시도해 주세요.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _emailError = '오류가 발생했습니다: ${e.toString()}';
      });
    }
  }

  Future<void> _resendCode() async {
    if (_resendCount >= _maxResendCount) {
      _showMaxResendDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
      _codeController.clear();
    });

    try {
      // 실제 이메일 인증번호 재전송 API 호출
      final success = await ref
          .read(authProvider.notifier)
          .sendSignUpVerificationCode(_emailController.text)
          .timeout(const Duration(seconds: 10), onTimeout: () => false);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _resendCount++;
      });

      if (success) {
        _startTimer();
      } else {
        setState(() {
          _codeError = '인증번호 재전송에 실패했습니다.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeError = '오류가 발생했습니다.';
      });
    }
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text;

    // 테스트 코드: 000000 입력 시 바로 통과
    if (code == '000000') {
      _timer?.cancel();
      setState(() {
        _codeVerified = true;
        _codeError = null;
        _currentStep = 2;
      });
      _passwordFocusNode.requestFocus();
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 실제 인증번호 검증 API 호출
      final result = await ref.read(authProvider.notifier).verifySignUpCode(
            email: _emailController.text,
            code: code,
          );

      if (!mounted) return;

      if (result.isValid) {
        _timer?.cancel();
        setState(() {
          _isLoading = false;
          _codeVerified = true;
          _codeError = null;
          _currentStep = 2;
        });
        _passwordFocusNode.requestFocus();
      } else {
        setState(() => _isLoading = false);
        _showCodeMismatchDialog();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeError = '인증 중 오류가 발생했습니다.';
      });
    }
  }

  void _showCodeMismatchDialog() {
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  size: 28,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '인증번호가 일치하지 않아요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '인증번호를 다시 확인해 주세요.',
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '취소',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _resendCode();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '재전송',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExpiredDialog() {
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.timer_off_rounded,
                  size: 28,
                  color: AppColors.orange,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '인증번호가 만료되었어요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '인증번호를 다시 전송해 주세요.',
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _resendCode();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '인증번호 재전송',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMaxResendDialog() {
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
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.block_rounded,
                  size: 28,
                  color: AppColors.red,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '재전송 횟수를 초과했어요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '잠시 후 다시 시도해 주세요.',
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _completeSignup() async {
    if (!_isPasswordValid) {
      setState(() => _passwordError = '비밀번호 규칙을 확인해 주세요.');
      return;
    }

    if (!_passwordsMatch) {
      setState(() => _confirmPasswordError = '비밀번호가 일치하지 않아요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 실제 회원가입 API 호출
      await ref.read(authProvider.notifier).signUp(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (!mounted) return;

      setState(() => _isLoading = false);

      // 성공 토스트 메시지
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 20,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '회원 가입을 축하합니다!',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Blockpick에서 특별한 행운을 만나보세요.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        ),
      );

      // 홈으로 이동
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 실패: ${e.toString()}'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _handleNext() {
    switch (_currentStep) {
      case 0:
        _sendEmailCode();
        break;
      case 1:
        _verifyCode();
        break;
      case 2:
        _completeSignup();
        break;
    }
  }

  bool get _canProceed {
    switch (_currentStep) {
      case 0:
        return _isEmailValid && !_isLoading;
      case 1:
        return _isCodeValid && !_isLoading;
      case 2:
        return _canComplete && !_isLoading;
      default:
        return false;
    }
  }

  String get _buttonText {
    switch (_currentStep) {
      case 0:
        return '인증번호 전송';
      case 1:
        return '확인';
      case 2:
        return '가입 완료';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_currentStep > 0) {
                          setState(() => _currentStep--);
                        } else {
                          context.pop();
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 22,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '회원가입',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // 진행 바
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: (_currentStep + 1) / 3,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.blue,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 28),

                        // 타이틀
                        Text(
                          _stepTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _stepSubtitle,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 이메일 입력 (Step 0)
                        if (_currentStep == 0) _buildEmailInput(),

                        // 인증번호 입력 (Step 1)
                        if (_currentStep == 1) _buildCodeInput(),

                        // 비밀번호 입력 (Step 2)
                        if (_currentStep == 2) _buildPasswordSection(),
                      ],
                    ),
                  ),
                ),
              ),

              // 하단 버튼
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canProceed ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.gray300,
                      disabledForegroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : Text(
                            _buttonText,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          autofocus: true,
          onChanged: (_) => setState(() => _emailError = null),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: 'example@email.com',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _emailError!,
              style: TextStyle(fontSize: 13, color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 이메일 표시 (비활성)
        const Text(
          '이메일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _emailController.text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray600,
                  ),
                ),
              ),
              Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: AppColors.green,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 인증번호 입력
        const Text(
          '인증번호',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeController,
          focusNode: _codeFocusNode,
          keyboardType: TextInputType.number,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (_) => setState(() => _codeError = null),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '● ● ● ● ● ●',
            hintStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: AppColors.gray300,
              letterSpacing: 8,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            suffixIcon: Container(
              padding: const EdgeInsets.only(right: 16),
              alignment: Alignment.centerRight,
              width: 60,
              child: Text(
                _timerText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _remainingSeconds < 60 ? AppColors.red : AppColors.blue,
                ),
              ),
            ),
          ),
        ),
        if (_codeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _codeError!,
              style: TextStyle(fontSize: 13, color: AppColors.red),
            ),
          ),
        const SizedBox(height: 16),
        Center(
          child: TextButton(
            onPressed: _resendCount < _maxResendCount ? _resendCode : null,
            child: Text(
              '인증번호 재전송${_resendCount > 0 ? ' ($_resendCount/$_maxResendCount)' : ''}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _resendCount < _maxResendCount ? AppColors.blue : AppColors.gray400,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 비밀번호
        const Text(
          '비밀번호',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          autofocus: true,
          onChanged: (_) => setState(() => _passwordError = null),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: '비밀번호 입력',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.gray500,
                size: 22,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _passwordError!,
              style: TextStyle(fontSize: 13, color: AppColors.red),
            ),
          ),

        const SizedBox(height: 12),

        // 비밀번호 규칙 체크
        _buildPasswordRule('8자 이상', _hasMinLength),
        _buildPasswordRule('영문 포함', _hasLetter),
        _buildPasswordRule('숫자 포함', _hasDigit),
        _buildPasswordRule('특수문자 포함', _hasSpecial),

        const SizedBox(height: 24),

        // 비밀번호 확인
        const Text(
          '비밀번호 확인',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          onChanged: (_) => setState(() => _confirmPasswordError = null),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: '비밀번호 재입력',
            hintStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_confirmPasswordController.text.isNotEmpty)
                  Icon(
                    _passwordsMatch ? Icons.check_circle_rounded : Icons.cancel_rounded,
                    color: _passwordsMatch ? AppColors.green : AppColors.red,
                    size: 20,
                  ),
                IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.gray500,
                    size: 22,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
              ],
            ),
          ),
        ),
        if (_confirmPasswordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _confirmPasswordError!,
              style: TextStyle(fontSize: 13, color: AppColors.red),
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordRule(String text, bool isValid) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isValid ? AppColors.green : AppColors.gray300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 12,
              color: isValid ? AppColors.white : AppColors.gray500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isValid ? AppColors.green : AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
