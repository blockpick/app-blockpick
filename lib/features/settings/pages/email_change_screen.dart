import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// SC-011-03, SC-011-04: 이메일 변경 화면
class EmailChangeScreen extends ConsumerStatefulWidget {
  const EmailChangeScreen({super.key});

  @override
  ConsumerState<EmailChangeScreen> createState() => _EmailChangeScreenState();
}

class _EmailChangeScreenState extends ConsumerState<EmailChangeScreen> {
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

  bool _isEmailValid = false;
  bool _isCodeSent = false;
  bool _isCodeValid = false;
  String? _emailError;
  String? _codeError;

  // 타이머 관련
  Timer? _timer;
  int _remainingSeconds = 180; // 3분
  bool _canResend = false;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _emailFocusNode.dispose();
    _codeFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// 이메일 유효성 검사
  void _validateEmail(String value) {
    setState(() {
      if (value.isEmpty) {
        _emailError = null;
        _isEmailValid = false;
      } else if (!_isValidEmailFormat(value)) {
        _emailError = '이메일 형식이 올바르지 않습니다.';
        _isEmailValid = false;
      } else {
        _emailError = null;
        _isEmailValid = true;
      }
    });
  }

  /// 이메일 형식 검사
  bool _isValidEmailFormat(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// 인증번호 전송
  Future<void> _sendVerificationCode() async {
    if (!_isEmailValid) return;

    setState(() {
      _isCodeSent = true;
      _remainingSeconds = 180;
      _canResend = false;
      _codeError = null;
    });

    _startTimer();

    // TODO: 실제 API 호출
    // try {
    //   await ref.read(authProvider.notifier).sendEmailVerificationCode(
    //     _emailController.text.trim(),
    //   );
    // } catch (e) {
    //   setState(() {
    //     _emailError = '인증번호 전송에 실패했습니다.';
    //     _isCodeSent = false;
    //   });
    // }
  }

  /// 타이머 시작
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _canResend = true;
        }
      });
    });
  }

  /// 타이머 포맷
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// 인증번호 재전송
  void _resendCode() {
    if (!_canResend) return;

    setState(() {
      _remainingSeconds = 180;
      _canResend = false;
      _codeController.clear();
      _codeError = null;
      _isCodeValid = false;
    });

    _startTimer();

    // TODO: 실제 API 호출
  }

  /// 인증번호 유효성 검사
  void _validateCode(String value) {
    setState(() {
      if (value.length == 6) {
        _isCodeValid = true;
        _codeError = null;
      } else {
        _isCodeValid = false;
      }
    });
  }

  /// 인증 완료
  Future<void> _verifyAndChangeEmail() async {
    if (!_isCodeValid) return;

    // TODO: 실제 API 호출
    // try {
    //   await ref.read(authProvider.notifier).changeEmail(
    //     _emailController.text.trim(),
    //     _codeController.text.trim(),
    //   );
    //
    //   if (mounted) {
    //     ScaffoldMessenger.of(context).showSnackBar(...);
    //     context.pop();
    //   }
    // } catch (e) {
    //   setState(() {
    //     _codeError = '인증번호가 올바르지 않습니다.';
    //   });
    // }

    // 임시: 성공 처리
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일이 변경되었습니다.'),
          backgroundColor: AppColors.darkBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
        ),
      );
      context.pop();
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
        appBar: AppBar(
          title: Text(
            '이메일 변경',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 이메일 인증 섹션
                    Text(
                      '이메일 인증',
                      style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 12),

                    // 이메일 입력 필드
                    _buildEmailInput(),

                    const SizedBox(height: 12),

                    // 인증번호 전송 버튼
                    _buildSendCodeButton(),

                    // 인증번호 입력 섹션 (코드 전송 후)
                    if (_isCodeSent) ...[
                      const SizedBox(height: 24),
                      _buildCodeInput(),
                      const SizedBox(height: 12),
                      _buildResendButton(),
                    ],
                  ],
                ),
              ),
            ),

            // 인증 완료 버튼
            _buildVerifyButton(),
          ],
        ),
      ),
    );
  }

  /// 이메일 입력 필드
  Widget _buildEmailInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          enabled: !_isCodeSent, // 코드 전송 후 수정 불가
          onChanged: _validateEmail,
          style: TextStyle(
            fontSize: 16,
            color: _isCodeSent ? AppColors.gray500 : AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: '변경할 이메일을 입력해 주세요.',
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: 16,
            ),
            filled: true,
            fillColor: _isCodeSent ? AppColors.gray100 : AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(
                color: _emailError != null ? AppColors.red : AppColors.gray200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(
                color: _emailError != null ? AppColors.red : AppColors.darkBlue,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (_emailError != null) ...[
          const SizedBox(height: 8),
          Text(
            _emailError!,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.red,
            ),
          ),
        ],
      ],
    );
  }

  /// 인증번호 전송 버튼
  Widget _buildSendCodeButton() {
    final isEnabled = _isEmailValid && !_isCodeSent;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? _sendVerificationCode : null,
        style: ElevatedButton.styleFrom(
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.gray300,
          disabledForegroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
          elevation: 0,
        ),
        child: const Text(
          '인증번호 전송',
          style: AppTextStyles.title2,
        ),
      ),
    );
  }

  /// 인증번호 입력 필드
  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: _validateCode,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.darkBlue,
                  letterSpacing: 2,
                ),
                decoration: InputDecoration(
                  hintText: '인증번호 6자리',
                  hintStyle: TextStyle(
                    color: AppColors.gray400,
                    fontSize: 16,
                    letterSpacing: 0,
                  ),
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(
                      color:
                          _codeError != null ? AppColors.red : AppColors.gray200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(
                      color: _codeError != null
                          ? AppColors.red
                          : AppColors.darkBlue,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 타이머
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Text(
                _formatTime(_remainingSeconds),
                style: AppTextStyles.title2,
              ),
            ),
          ],
        ),
        if (_codeError != null) ...[
          const SizedBox(height: 8),
          Text(
            _codeError!,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.red,
            ),
          ),
        ],
      ],
    );
  }

  /// 인증번호 재전송 버튼
  Widget _buildResendButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: _canResend ? _resendCode : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkBlue,
          disabledForegroundColor: AppColors.gray400,
          side: BorderSide(
            color: _canResend ? AppColors.darkBlue : AppColors.gray300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        ),
        child: const Text(
          '인증번호 재전송',
          style: AppTextStyles.title2,
        ),
      ),
    );
  }

  /// 인증 완료 버튼
  Widget _buildVerifyButton() {
    final isEnabled = _isCodeSent && _isCodeValid;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isEnabled ? _verifyAndChangeEmail : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.gray300,
              disabledForegroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              elevation: 0,
            ),
            child: const Text(
              '인증 완료',
              style: AppTextStyles.title2,
            ),
          ),
        ),
      ),
    );
  }
}
