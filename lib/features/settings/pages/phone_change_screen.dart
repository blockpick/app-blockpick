import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// SC-011-05, SC-011-06: 휴대폰 번호 변경 화면
class PhoneChangeScreen extends ConsumerStatefulWidget {
  const PhoneChangeScreen({super.key});

  @override
  ConsumerState<PhoneChangeScreen> createState() => _PhoneChangeScreenState();
}

class _PhoneChangeScreenState extends ConsumerState<PhoneChangeScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

  bool _isPhoneValid = false;
  bool _isCodeSent = false;
  bool _isCodeValid = false;
  String? _phoneError;
  String? _codeError;

  // 국가번호
  String _countryCode = 'KOR(+82)';

  // 타이머 관련
  Timer? _timer;
  int _remainingSeconds = 180; // 3분
  bool _canResend = false;
  int _resendCount = 0; // 재전송 횟수 (최대 3회)
  static const int _maxResendCount = 3;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    _timer?.cancel();
    super.dispose();
  }

  /// 휴대폰 번호 유효성 검사
  void _validatePhone(String value) {
    setState(() {
      if (value.isEmpty) {
        _phoneError = null;
        _isPhoneValid = false;
      } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
        _phoneError = '숫자만 입력해 주세요.';
        _isPhoneValid = false;
      } else if (value.length < 10 || value.length > 11) {
        _phoneError = null;
        _isPhoneValid = false;
      } else {
        _phoneError = null;
        _isPhoneValid = true;
      }
    });
  }

  /// 인증번호 전송
  Future<void> _sendVerificationCode() async {
    if (!_isPhoneValid) return;

    setState(() {
      _isCodeSent = true;
      _remainingSeconds = 180;
      _canResend = false;
      _codeError = null;
      _codeController.clear();
      _isCodeValid = false;
    });

    _startTimer();

    // TODO: 실제 SMS 인증번호 전송 API 호출
    // try {
    //   await ref.read(authProvider.notifier).sendPhoneVerificationCode(
    //     _phoneController.text.trim(),
    //   );
    // } catch (e) {
    //   setState(() {
    //     _phoneError = '인증번호 전송에 실패했습니다.';
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
    if (!_canResend || _resendCount >= _maxResendCount) return;

    setState(() {
      _remainingSeconds = 180;
      _canResend = false;
      _codeController.clear();
      _codeError = null;
      _isCodeValid = false;
      _resendCount++;
    });

    _startTimer();

    // TODO: 실제 SMS 인증번호 재전송 API 호출
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
  Future<void> _verifyAndChangePhone() async {
    if (!_isCodeValid) return;

    // TODO: 실제 API 호출
    // try {
    //   await ref.read(authProvider.notifier).changePhone(
    //     _phoneController.text.trim(),
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
          content: const Text('인증이 완료되었어요.'),
          backgroundColor: AppColors.darkBlue,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
          title: const Text(
            '휴대폰 번호 변경',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
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
                    // 휴대폰 번호 섹션
                    const Text(
                      '휴대폰 번호',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 국가번호 + 전화번호 입력
                    _buildPhoneInput(),

                    const SizedBox(height: 12),

                    // 인증번호 전송 버튼
                    _buildSendCodeButton(),

                    // 인증번호 입력 섹션 (코드 전송 후)
                    if (_isCodeSent) ...[
                      const SizedBox(height: 24),
                      _buildCodeInput(),
                      const SizedBox(height: 8),
                      // 재전송 안내
                      Text(
                        '• 인증번호 재전송은 최대 ${_maxResendCount}회까지 가능해요.($_resendCount/$_maxResendCount)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
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

  /// 휴대폰 번호 입력 필드 (국가번호 + 번호)
  Widget _buildPhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 국가번호 드롭다운
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                border: Border.all(color: AppColors.gray200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _countryCode,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 전화번호 입력
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.number,
                enabled: !_isCodeSent,
                onChanged: _validatePhone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                style: TextStyle(
                  fontSize: 16,
                  color: _isCodeSent ? AppColors.gray500 : AppColors.darkBlue,
                ),
                decoration: InputDecoration(
                  hintText: '숫자만 입력',
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
                      color: _phoneError != null
                          ? AppColors.red
                          : AppColors.gray200,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    borderSide: BorderSide(
                      color: _phoneError != null
                          ? AppColors.red
                          : AppColors.darkBlue,
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
            ),
          ],
        ),
        if (_phoneError != null) ...[
          const SizedBox(height: 8),
          Text(
            _phoneError!,
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
    final isEnabled = _isPhoneValid && !_isCodeSent;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: isEnabled ? _sendVerificationCode : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkBlue,
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
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
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _remainingSeconds <= 30
                      ? AppColors.red
                      : AppColors.darkBlue,
                ),
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
    final isEnabled = _canResend && _resendCount < _maxResendCount;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: isEnabled ? _resendCode : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkBlue,
          disabledForegroundColor: AppColors.gray400,
          side: BorderSide(
            color: isEnabled ? AppColors.darkBlue : AppColors.gray300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          ),
        ),
        child: const Text(
          '인증번호 재전송',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// 인증 완료 버튼 (하단 고정)
  Widget _buildVerifyButton() {
    final isEnabled = _isCodeSent && _isCodeValid;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: isEnabled ? _verifyAndChangePhone : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
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
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
