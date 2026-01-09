import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/data/repositories/auth_repository.dart';
import '../../../../core/auth/domain/providers/verification_state_provider.dart';

/// SC-006: 이메일 찾기 화면
///
/// - SC-006-01: 휴대폰 번호 입력 (국제 전화번호 지원)
/// - SC-006-02: 인증번호 입력
/// - SC-006-03: 이메일 찾기 결과
class FindEmailScreen extends ConsumerStatefulWidget {
  const FindEmailScreen({super.key});

  @override
  ConsumerState<FindEmailScreen> createState() => _FindEmailScreenState();
}

class _FindEmailScreenState extends ConsumerState<FindEmailScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  // 국제 전화번호 입력
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'KR');
  bool _isPhoneValid = false;
  String? _e164PhoneNumber;

  bool _codeSent = false;
  bool _isLoading = false;
  String? _phoneError;

  Timer? _timer;
  int _remainingSeconds = 180;
  int _resendCount = 0;
  static const int _maxResendCount = 3;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  bool get _isCodeValid {
    return _codeController.text.length == 6;
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

  Future<void> _sendCode() async {
    if (!_isPhoneValid || _e164PhoneNumber == null) {
      setState(() => _phoneError = '휴대폰 번호를 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneError = null;
    });

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);

      final result = await authRepo.sendSmsVerificationCode(
        phoneNumber: _e164PhoneNumber!,
        verifyType: 'FIND_EMAIL',
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _isLoading = false;
          _codeSent = true;
        });
        _startTimer();
        _codeFocusNode.requestFocus();
      } else {
        setState(() {
          _isLoading = false;
          _phoneError = result.message ?? 'SMS 발송에 실패했습니다.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _phoneError = 'SMS 발송 중 오류가 발생했습니다.';
      });
    }
  }

  Future<void> _resendCode() async {
    if (_resendCount >= _maxResendCount) return;

    setState(() {
      _isLoading = true;
      _codeController.clear();
    });

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);

      final result = await authRepo.sendSmsVerificationCode(
        phoneNumber: _e164PhoneNumber!,
        verifyType: 'FIND_EMAIL',
      );

      if (!mounted) return;

      if (result.success) {
        setState(() {
          _isLoading = false;
          _resendCount++;
        });
        _startTimer();
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyAndSearch() async {
    if (_e164PhoneNumber == null) return;

    // 이미 인증된 번호인지 확인 (24시간 유효)
    final verificationState = ref.read(verificationProvider);
    if (verificationState.isPhoneVerified(_e164PhoneNumber!)) {
      // 이미 인증됨 - API 호출 없이 바로 결과 화면으로
      context.push('/find-email-result', extra: {
        'phone': _phoneController.text,
        'phoneE164': _e164PhoneNumber,
      });
      return;
    }

    final code = _codeController.text;

    setState(() => _isLoading = true);

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);

      final result = await authRepo.verifySmsCode(
        phoneNumber: _e164PhoneNumber!,
        code: code,
        verifyType: 'FIND_EMAIL',
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (!result.success) {
        _showNoAccountDialog();
        return;
      }

      // 인증 상태 저장
      ref.read(verificationProvider.notifier).markPhoneVerified(_e164PhoneNumber!);

      // 결과 화면으로 이동
      context.push('/find-email-result', extra: {
        'phone': _phoneController.text,
        'phoneE164': _e164PhoneNumber,
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showNoAccountDialog();
    }
  }

  void _showNoAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '해당번호로 가입된 계정이 없어요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '회원가입을 하시겠어요?',
              style: TextStyle(fontSize: 14, color: AppColors.gray600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('취소', style: TextStyle(color: AppColors.gray600)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/signup');
            },
            child: const Text(
              '회원가입 하기',
              style: TextStyle(color: AppColors.blue, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
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
            '이메일 찾기',
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

                      const Text(
                        '가입된 이메일을 찾기 위해\n휴대폰 번호 인증이 필요해요.',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 32),

                      _buildPhoneInput(),
                      const SizedBox(height: 16),

                      if (!_codeSent)
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isPhoneValid && !_isLoading ? _sendCode : null,
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
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                                    ),
                                  )
                                : const Text(
                                    '인증번호 전송',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                          ),
                        ),

                      if (_codeSent) ...[
                        const SizedBox(height: 24),
                        _buildCodeInput(),
                      ],
                    ],
                  ),
                ),
              ),

              if (_codeSent)
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isCodeValid ? _verifyAndSearch : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.gray300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        '다음',
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

  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '휴대폰 번호',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _codeSent ? AppColors.gray200 : AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              setState(() {
                _phoneNumber = number;
                _e164PhoneNumber = number.phoneNumber;
                _phoneError = null;
              });
            },
            onInputValidated: (bool isValid) {
              setState(() {
                _isPhoneValid = isValid;
              });
            },
            selectorConfig: const SelectorConfig(
              selectorType: PhoneInputSelectorType.DIALOG,
              useBottomSheetSafeArea: true,
              leadingPadding: 16,
              setSelectorButtonAsPrefixIcon: true,
              trailingSpace: false,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
            initialValue: _phoneNumber,
            textFieldController: _phoneController,
            formatInput: true,
            isEnabled: !_codeSent,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputDecoration: InputDecoration(
              hintText: '전화번호 입력',
              hintStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray400,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkBlue,
            ),
            searchBoxDecoration: InputDecoration(
              hintText: '국가 검색',
              hintStyle: TextStyle(color: AppColors.gray400),
              prefixIcon: Icon(Icons.search, color: AppColors.gray500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.blue, width: 2),
              ),
            ),
            locale: 'ko',
          ),
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(_phoneError!, style: TextStyle(fontSize: 12, color: AppColors.red)),
          ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '인증번호',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _codeController,
          focusNode: _codeFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 16, color: AppColors.darkBlue, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '인증번호 6자리',
            hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400, letterSpacing: 0),
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
        const SizedBox(height: 12),
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
    );
  }
}
