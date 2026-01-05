import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// SC-005-04, SC-005-05: 이메일/비밀번호 입력 화면
///
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

  bool _codeSent = false;
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

  bool get _isPasswordValid {
    final password = _passwordController.text;
    if (password.length < 8) return false;
    // 영문, 숫자, 특수문자 포함 확인
    final hasLetter = password.contains(RegExp(r'[a-zA-Z]'));
    final hasDigit = password.contains(RegExp(r'[0-9]'));
    final hasSpecial = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasLetter && hasDigit && hasSpecial;
  }

  bool get _passwordsMatch {
    return _passwordController.text == _confirmPasswordController.text;
  }

  bool get _canComplete {
    return _codeVerified &&
        _isPasswordValid &&
        _passwordsMatch &&
        _confirmPasswordController.text.isNotEmpty;
  }

  String get _timerText {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _startTimer() {
    _timer?.cancel();
    _remainingSeconds = 180;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _sendEmailCode() async {
    if (!_isEmailValid) {
      setState(() => _emailError = '이메일 형식이 올바르지 않습니다.');
      return;
    }

    setState(() {
      _isLoading = true;
      _emailError = null;
    });

    // TODO: 실제 이메일 인증번호 전송 API 호출
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _codeSent = true;
    });

    _startTimer();
    _codeFocusNode.requestFocus();
  }

  Future<void> _resendCode() async {
    if (_resendCount >= _maxResendCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('인증번호 재전송 횟수를 초과했습니다.'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
      _codeController.clear();
    });

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _resendCount++;
    });

    _startTimer();
  }

  void _verifyCode() {
    final code = _codeController.text;

    // 테스트 코드 체크
    if (code == '000000') {
      setState(() {
        _codeVerified = true;
        _codeError = null;
      });
      _passwordFocusNode.requestFocus();
    } else {
      setState(() {
        _codeError = '인증번호가 올바르지 않습니다.';
      });
    }
  }

  void _validatePassword() {
    final password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _passwordError = '비밀번호를 입력해주세요.');
      return;
    }

    if (!_isPasswordValid) {
      setState(() => _passwordError = '문자,숫자,기호 조합 8자 이상으로 만들어주세요.');
      return;
    }

    setState(() => _passwordError = null);
  }

  void _validateConfirmPassword() {
    if (_confirmPasswordController.text.isEmpty) {
      setState(() => _confirmPasswordError = '비밀번호를 입력해주세요.');
      return;
    }

    if (!_passwordsMatch) {
      setState(() => _confirmPasswordError = '동일한 비밀번호를 입력해 주세요.');
      return;
    }

    setState(() => _confirmPasswordError = null);
  }

  Future<void> _completeSignup() async {
    _validatePassword();
    _validateConfirmPassword();

    if (_passwordError != null || _confirmPasswordError != null) {
      return;
    }

    setState(() => _isLoading = true);

    // TODO: 실제 회원가입 API 호출
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() => _isLoading = false);

    // 성공 토스트 메시지
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('회원 가입을 축하합니다!', style: TextStyle(fontWeight: FontWeight.w600)),
            SizedBox(height: 4),
            Text('Blockpick에서 특별한 행운을 만나보세요.'),
          ],
        ),
        backgroundColor: AppColors.green,
        duration: Duration(seconds: 3),
      ),
    );

    // 홈으로 이동
    context.go('/');
  }

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
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkBlue),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            '회원가입',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // 이메일 입력
                      _buildEmailSection(),
                      const SizedBox(height: 24),

                      // 비밀번호 입력
                      _buildPasswordSection(),
                      const SizedBox(height: 16),

                      // 비밀번호 규칙 안내
                      _buildPasswordRules(),
                    ],
                  ),
                ),
              ),

              // 가입 완료 버튼
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canComplete && !_isLoading ? _completeSignup : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.gray300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Text(
                            '가입 완료',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '이메일',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                keyboardType: TextInputType.emailAddress,
                enabled: !_codeVerified,
                onChanged: (_) => setState(() => _emailError = null),
                style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
                decoration: InputDecoration(
                  hintText: '이메일을 입력해 주세요.',
                  hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400),
                  errorText: _emailError,
                  filled: true,
                  fillColor: _codeVerified ? AppColors.gray200 : AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _codeVerified
                    ? null
                    : (_isEmailValid && !_isLoading ? _sendEmailCode : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _codeVerified ? AppColors.green : AppColors.darkBlue,
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: _codeVerified ? AppColors.green : AppColors.gray300,
                  disabledForegroundColor: AppColors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: _codeVerified
                    ? const Icon(Icons.check, size: 20)
                    : const Text('인증번호 전송', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),

        // 인증번호 입력 (전송 후)
        if (_codeSent && !_codeVerified) ...[
          const SizedBox(height: 16),
          const Text(
            '인증번호',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _codeController,
                  focusNode: _codeFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(6),
                  ],
                  onChanged: (value) {
                    setState(() => _codeError = null);
                    if (value.length == 6) {
                      _verifyCode();
                    }
                  },
                  style: const TextStyle(fontSize: 16, color: AppColors.darkBlue, letterSpacing: 4),
                  decoration: InputDecoration(
                    hintText: '인증번호 6자리',
                    hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400, letterSpacing: 0),
                    errorText: _codeError,
                    filled: true,
                    fillColor: AppColors.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Text(
                        _timerText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: _remainingSeconds < 60 ? AppColors.red : AppColors.blue,
                        ),
                      ),
                    ),
                    suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _resendCount < _maxResendCount ? _resendCode : null,
              child: Text(
                '인증번호 재전송${_resendCount > 0 ? ' ($_resendCount/$_maxResendCount)' : ''}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blue,
                ),
              ),
            ),
          ),
        ],
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
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: _obscurePassword,
          onChanged: (_) => setState(() => _passwordError = null),
          onEditingComplete: () {
            _validatePassword();
            _confirmPasswordFocusNode.requestFocus();
          },
          style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
          decoration: InputDecoration(
            hintText: '문자,숫자,기호 조합 8자 이상',
            hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400),
            errorText: _passwordError,
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
        const SizedBox(height: 16),

        // 비밀번호 확인
        const Text(
          '비밀번호 확인',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          focusNode: _confirmPasswordFocusNode,
          obscureText: _obscureConfirmPassword,
          onChanged: (_) => setState(() => _confirmPasswordError = null),
          onEditingComplete: _validateConfirmPassword,
          style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
          decoration: InputDecoration(
            hintText: '동일한 비밀번호를 입력해 주세요.',
            hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400),
            errorText: _confirmPasswordError,
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: AppColors.gray500,
                size: 22,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRules() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '비밀번호 생성 규칙',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 8),
          _buildRule('영문, 숫자, 특수문자 포함 8자 이상'),
          _buildRule('동일하거나 연속되는 문자, 숫자 사용 금지'),
          _buildRule('이메일, 휴대폰 번호 사용 금지'),
        ],
      ),
    );
  }

  Widget _buildRule(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12, color: AppColors.gray500, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
