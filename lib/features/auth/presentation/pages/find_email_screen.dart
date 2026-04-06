import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
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
  final PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'KR');
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '해당번호로 가입된 계정이 없어요.',
              style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '회원가입을 하시겠어요?',
              style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
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
            child: Text(
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
            icon: Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkBlue),
            onPressed: () => context.pop(),
          ),
          title: Text(
            '이메일 찾기',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
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
                      SizedBox(height: 24),

                      Text(
                        '가입된 이메일을 찾기 위해\n휴대폰 번호 인증이 필요해요.',
                        style: AppTextStyles.heading2.copyWith(color: AppColors.darkBlue),
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
                              foregroundColor: AppColors.white,
                              disabledBackgroundColor: AppColors.gray300,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
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
                                    style: AppTextStyles.title2,
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
                        foregroundColor: AppColors.white,
                        disabledBackgroundColor: AppColors.gray300,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        '다음',
                        style: AppTextStyles.title2,
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
        Text(
          '휴대폰 번호',
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _codeSent ? AppColors.gray200 : AppColors.gray100,
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              _e164PhoneNumber = number.phoneNumber;
              if (_phoneError != null) {
                setState(() => _phoneError = null);
              }
            },
            onInputValidated: (bool isValid) {
              if (_isPhoneValid != isValid) {
                setState(() => _isPhoneValid = isValid);
              }
            },
            selectorConfig: SelectorConfig(
              selectorType: PhoneInputSelectorType.DIALOG,
              useBottomSheetSafeArea: true,
              leadingPadding: 16,
              setSelectorButtonAsPrefixIcon: true,
              trailingSpace: false,
            ),
            ignoreBlank: false,
            autoValidateMode: AutovalidateMode.disabled,
            selectorTextStyle: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
            initialValue: _initialPhoneNumber,
            textFieldController: _phoneController,
            formatInput: true,
            isEnabled: !_codeSent,
            keyboardType: const TextInputType.numberWithOptions(
              signed: true,
              decimal: true,
            ),
            inputDecoration: InputDecoration(
              hintText: '전화번호 입력',
              hintStyle: AppTextStyles.body1.copyWith(color: AppColors.gray400),
              filled: true,
              fillColor: Colors.transparent,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            ),
            textStyle: AppTextStyles.body2.copyWith(color: AppColors.darkBlue),
            searchBoxDecoration: InputDecoration(
              hintText: '국가 검색',
              hintStyle: TextStyle(color: AppColors.gray400),
              prefixIcon: Icon(Icons.search, color: AppColors.gray500),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                borderSide: BorderSide(color: AppColors.gray300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                borderSide: BorderSide(color: AppColors.blue, width: 2),
              ),
            ),
            locale: 'ko',
          ),
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(_phoneError!, style: AppTextStyles.caption1.copyWith(color: AppColors.red)),
          ),
      ],
    );
  }

  Widget _buildCodeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '인증번호',
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
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
          style: AppTextStyles.body2.copyWith(color: AppColors.darkBlue, letterSpacing: 8),
          decoration: InputDecoration(
            hintText: '인증번호 6자리',
            hintStyle: AppTextStyles.body2.copyWith(color: AppColors.gray400, letterSpacing: 0),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _timerText,
                style: AppTextStyles.title3.copyWith(color: _remainingSeconds < 60 ? AppColors.red : AppColors.blue),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
          ),
        ),
        SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: _resendCount < _maxResendCount ? _resendCode : null,
            child: Text(
              '인증번호 재전송${_resendCount > 0 ? ' ($_resendCount/$_maxResendCount)' : ''}',
              style: AppTextStyles.title3.copyWith(color: AppColors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
