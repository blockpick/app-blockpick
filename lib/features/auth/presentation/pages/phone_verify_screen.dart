import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_text_field.dart';

/// 휴대폰 인증 화면
///
/// 회원가입 플로우:
/// 1. 휴대폰 번호 입력
/// 2. 인증번호 발송
/// 3. 인증번호 확인
/// 4. 성공 시 다음 단계로 이동
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  final String? provider; // SNS 가입의 경우 provider 정보

  const PhoneVerifyScreen({
    super.key,
    this.provider,
  });

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isCodeSent = false;
  bool _isLoading = false;
  bool _isVerifying = false;
  String? _phoneError;
  String? _codeError;

  Timer? _timer;
  int _remainingSeconds = 180; // 3분

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  bool get _isPhoneValid {
    final phone = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
    return phone.length >= 10;
  }

  Future<void> _sendCode() async {
    if (!_isPhoneValid) {
      setState(() => _phoneError = '올바른 휴대폰 번호를 입력해주세요');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneError = null;
    });

    // TODO: 실제 SMS 인증 API 호출
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _isCodeSent = true;
      _remainingSeconds = 180;
    });

    _startTimer();
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

  Future<void> _verifyCode() async {
    final code = _codeController.text;
    if (code.length != 6) {
      setState(() => _codeError = '인증번호 6자리를 입력해주세요');
      return;
    }

    setState(() {
      _isVerifying = true;
      _codeError = null;
    });

    // 테스트 코드: 000000 입력 시 바로 통과
    final isTestCode = code == '000000';

    if (!isTestCode) {
      // TODO: 실제 인증번호 확인 API 호출
      await Future.delayed(const Duration(seconds: 1));

      // 실제 API 연동 전까지는 테스트 코드만 허용
      setState(() {
        _isVerifying = false;
        _codeError = '인증번호가 올바르지 않아요 (테스트: 000000)';
      });
      return;
    }

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() => _isVerifying = false);

    // 성공 시 다음 화면으로 이동
    if (widget.provider != null) {
      // SNS 가입의 경우 - 약관 동의로 이동
      context.push('/auth/terms-agree', extra: {
        'provider': widget.provider,
        'phone': _phoneController.text,
      });
    } else {
      // 이메일 가입의 경우 - 이메일 입력으로 이동
      context.push('/auth/email-signup', extra: {
        'phone': _phoneController.text,
      });
    }
  }

  Future<void> _resendCode() async {
    setState(() => _isLoading = true);

    // TODO: 재발송 API 호출
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      _remainingSeconds = 180;
      _codeController.clear();
    });

    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      progress: 0.25, // 1/4 단계
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 타이틀
            const Text(
              '휴대폰 번호를\n인증해주세요',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '본인 확인을 위해 휴대폰 인증이 필요해요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray600,
              ),
            ),
            const SizedBox(height: 40),

            // 휴대폰 번호 입력
            AuthTextField(
              label: '휴대폰 번호',
              hint: '010-0000-0000',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              errorText: _phoneError,
              enabled: !_isCodeSent,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                _PhoneNumberFormatter(),
              ],
              onChanged: (_) => setState(() => _phoneError = null),
              suffix: _isCodeSent
                  ? TextButton(
                      onPressed: () {
                        setState(() {
                          _isCodeSent = false;
                          _codeController.clear();
                          _timer?.cancel();
                        });
                      },
                      child: Text(
                        '변경',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.blue,
                        ),
                      ),
                    )
                  : null,
            ),

            if (_isCodeSent) ...[
              const SizedBox(height: 24),

              // 인증번호 입력
              AuthTextField(
                label: '인증번호',
                hint: '6자리 숫자 입력',
                controller: _codeController,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                maxLength: 6,
                errorText: _codeError,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => setState(() => _codeError = null),
                suffix: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _remainingSeconds > 60
                            ? AppColors.blue
                            : AppColors.red,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 재발송 버튼
              Center(
                child: TextButton(
                  onPressed: _remainingSeconds == 0 || !_isLoading
                      ? _resendCode
                      : null,
                  child: Text(
                    '인증번호 다시 받기',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomButton: _isCodeSent
          ? AuthButton(
              text: '인증하기',
              onPressed: _codeController.text.length == 6 ? _verifyCode : null,
              isLoading: _isVerifying,
              enabled: _codeController.text.length == 6,
            )
          : AuthButton(
              text: '인증번호 받기',
              onPressed: _isPhoneValid ? _sendCode : null,
              isLoading: _isLoading,
              enabled: _isPhoneValid,
            ),
    );
  }
}

/// 휴대폰 번호 포맷터 (010-0000-0000)
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (text.isEmpty) return newValue.copyWith(text: '');

    String formatted = '';
    for (int i = 0; i < text.length && i < 11; i++) {
      if (i == 3 || i == 7) {
        formatted += '-';
      }
      formatted += text[i];
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
