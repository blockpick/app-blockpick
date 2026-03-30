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

/// 이메일 인증 화면
///
/// 이메일 가입 플로우:
/// 1. 인증 코드 자동 발송
/// 2. 6자리 코드 입력
/// 3. 인증 성공 시 비밀번호 설정으로 이동
class EmailVerifyScreen extends ConsumerStatefulWidget {
  final String? email;
  final String? phone;
  final bool? marketingAgreed;

  const EmailVerifyScreen({
    super.key,
    this.email,
    this.phone,
    this.marketingAgreed,
  });

  @override
  ConsumerState<EmailVerifyScreen> createState() => _EmailVerifyScreenState();
}

class _EmailVerifyScreenState extends ConsumerState<EmailVerifyScreen> {
  final _codeController = TextEditingController();

  bool _isCodeSent = false;
  bool _isSending = false;
  bool _isVerifying = false;
  String? _codeError;

  Timer? _timer;
  int _remainingSeconds = 180; // 3분

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 자동으로 인증 코드 발송
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('📧 EmailVerifyScreen - email: ${widget.email}');
      debugPrint('📧 EmailVerifyScreen - phone: ${widget.phone}');

      if (widget.email == null || widget.email!.isEmpty) {
        // 이메일이 없으면 바로 테스트 모드로 전환
        setState(() {
          _codeError = '이메일 정보가 없어요. 테스트 코드(000000)를 사용하세요.';
          _isCodeSent = true;
          _isSending = false;
          _remainingSeconds = 180;
        });
        _startTimer();
      } else {
        _sendCode();
      }
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get _maskedEmail {
    final email = widget.email ?? '';
    if (email.isEmpty) return '';

    final parts = email.split('@');
    if (parts.length != 2) return email;

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 3) {
      return '${name[0]}**@$domain';
    }

    return '${name.substring(0, 3)}${'*' * (name.length - 3)}@$domain';
  }

  Future<void> _sendCode() async {
    if (widget.email == null || widget.email!.isEmpty) {
      setState(() {
        _codeError = '이메일 정보가 없어요. 테스트 코드(000000)를 사용하세요.';
        _isCodeSent = true;
        _isSending = false;
        _remainingSeconds = 180;
      });
      _startTimer();
      return;
    }

    setState(() {
      _isSending = true;
      _codeError = null;
    });

    try {
      debugPrint('📧 이메일 인증코드 발송 시작: ${widget.email}');

      // 10초 타임아웃 설정
      final success = await ref
          .read(authProvider.notifier)
          .sendSignUpVerificationCode(widget.email!)
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              debugPrint('⏰ 이메일 인증코드 발송 타임아웃');
              return false;
            },
          );

      debugPrint('📧 이메일 인증코드 발송 결과: $success');

      if (!mounted) return;

      setState(() {
        _isCodeSent = true;
        _remainingSeconds = 180;
        _isSending = false;
        if (!success) {
          _codeError = '인증 코드 발송 실패. 테스트 코드(000000)를 사용하세요.';
        }
      });
      _startTimer();
    } catch (e) {
      debugPrint('❌ 이메일 인증코드 발송 에러: $e');
      if (!mounted) return;
      setState(() {
        _codeError = '발송 오류. 테스트 코드(000000)를 사용하세요.';
        _isCodeSent = true;
        _isSending = false;
        _remainingSeconds = 180;
      });
      _startTimer();
    }
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

    if (isTestCode) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      setState(() => _isVerifying = false);

      // 비밀번호 설정 화면으로 이동
      context.push('/auth/password-setup', extra: {
        'email': widget.email,
        'phone': widget.phone,
        'marketingAgreed': widget.marketingAgreed,
        'verificationCode': code,
      });
      return;
    }

    try {
      final result = await ref.read(authProvider.notifier).verifySignUpCode(
            email: widget.email!,
            code: code,
          );

      if (!mounted) return;

      if (result.isValid) {
        // 비밀번호 설정 화면으로 이동
        context.push('/auth/password-setup', extra: {
          'email': widget.email,
          'phone': widget.phone,
          'marketingAgreed': widget.marketingAgreed,
          'verificationCode': code,
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
      setState(() => _isVerifying = false);
    }
  }

  Future<void> _resendCode() async {
    setState(() {
      _codeController.clear();
      _codeError = null;
    });
    await _sendCode();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      progress: 0.625, // 2.5/4 단계
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 타이틀
            const Text(
              '이메일로 전송된\n인증번호를 입력해주세요',
              style: AppTextStyles.display2.copyWith(color: AppColors.darkBlue),
            ),
            const SizedBox(height: 12),
            Text(
              _maskedEmail,
              style: AppTextStyles.body2.copyWith(color: AppColors.blue),
            ),
            const SizedBox(height: 40),

            // 인증번호 입력
            if (_isCodeSent) ...[
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
                      style: AppTextStyles.title3.copyWith(color: _remainingSeconds > 60),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 재발송 안내
              Center(
                child: Column(
                  children: [
                    Text(
                      '이메일이 오지 않았나요?',
                      style: AppTextStyles.body3.copyWith(color: AppColors.gray500),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _isSending ? null : _resendCode,
                      child: Text(
                        '인증번호 다시 받기',
                        style: AppTextStyles.title3.copyWith(color: AppColors.blue),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // 로딩 상태
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.blue),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '인증번호를 발송하고 있어요',
                      style: AppTextStyles.body2.copyWith(color: AppColors.gray600),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      bottomButton: _isCodeSent
          ? AuthButton(
              text: '인증하기',
              onPressed:
                  _codeController.text.length == 6 ? _verifyCode : null,
              isLoading: _isVerifying,
              enabled: _codeController.text.length == 6,
            )
          : null,
    );
  }
}
