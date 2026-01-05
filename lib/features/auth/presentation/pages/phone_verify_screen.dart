import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// SC-005-02, SC-005-03: 휴대폰 번호 인증 화면
///
/// - 토스 스타일 디자인
/// - 휴대폰 번호 입력
/// - 인증번호 입력 (6자리, 3분 타이머)
/// - 이용 동의 체크 (개인정보, 제3자, 서비스 약관, 마케팅)
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  final String? signupType; // 'email', 'google', 'apple'
  final String? flowType; // 'signup', 'find-email', 'withdrawal'

  const PhoneVerifyScreen({
    super.key,
    this.signupType,
    this.flowType,
  });

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

  bool _codeSent = false;
  bool _isLoading = false;
  String? _phoneError;
  String? _codeError;

  // 타이머
  Timer? _timer;
  int _remainingSeconds = 180; // 3분
  int _resendCount = 0;
  static const int _maxResendCount = 3;

  // 동의 체크박스
  bool _agreeAll = false;
  bool _agreePrivacy = false;
  bool _agreeThirdParty = false;
  bool _agreeTerms = false;
  bool _agreeMarketing = false;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    _codeController.dispose();
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  bool get _isPhoneValid {
    final phone = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    return phone.length >= 10 && phone.length <= 11;
  }

  bool get _isCodeValid {
    return _codeController.text.length == 6;
  }

  bool get _requiredAgreed {
    return _agreePrivacy && _agreeThirdParty && _agreeTerms;
  }

  bool get _canSendCode {
    return _isPhoneValid && _requiredAgreed && !_isLoading;
  }

  bool get _canComplete {
    return _codeSent && _isCodeValid;
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
        _showExpiredDialog();
      }
    });
  }

  Future<void> _sendCode() async {
    if (!_isPhoneValid) {
      setState(() => _phoneError = '휴대폰 번호를 정확히 입력해 주세요.');
      return;
    }

    if (!_requiredAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('필수 약관에 동의해 주세요.'),
          backgroundColor: AppColors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneError = null;
    });

    // TODO: 실제 인증번호 전송 API 호출
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
      _showMaxResendDialog();
      return;
    }

    setState(() {
      _isLoading = true;
      _codeError = null;
      _codeController.clear();
    });

    // TODO: 실제 인증번호 재전송 API 호출
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _resendCount++;
    });

    _startTimer();
  }

  Future<void> _verifyAndContinue() async {
    final code = _codeController.text;

    // 테스트 코드 체크
    if (code != '000000') {
      // TODO: 실제 인증번호 검증 API 호출
      _showCodeMismatchDialog();
      return;
    }

    // 기존 가입 계정 확인 (회원가입 플로우일 때만)
    if (widget.flowType != 'find-email') {
      // TODO: 실제 API 호출로 확인
      final hasExistingAccount = false; // 테스트용

      if (hasExistingAccount) {
        _showExistingAccountDialog('test@example.com', '구글로 로그인');
        return;
      }
    }

    if (!mounted) return;

    // 다음 화면으로 이동
    final flowType = widget.flowType ?? 'signup';
    switch (flowType) {
      case 'signup':
        context.push('/email-password-setup', extra: {
          'phone': _phoneController.text,
          'agreeMarketing': _agreeMarketing,
        });
        break;
      case 'find-email':
        context.push('/find-email-result', extra: {
          'phone': _phoneController.text,
        });
        break;
      default:
        context.pop();
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

  void _showExistingAccountDialog(String email, String loginMethod) {
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
                  color: AppColors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  size: 28,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '이미 가입된 계정이 있어요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                email,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              Text(
                '($loginMethod)',
                style: TextStyle(fontSize: 13, color: AppColors.gray500),
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
                        context.go('/login');
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
                        '로그인하기',
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

  void _toggleAgreeAll(bool? value) {
    final newValue = value ?? false;
    setState(() {
      _agreeAll = newValue;
      _agreePrivacy = newValue;
      _agreeThirdParty = newValue;
      _agreeTerms = newValue;
      _agreeMarketing = newValue;
    });
  }

  void _updateAgreeAll() {
    setState(() {
      _agreeAll = _agreePrivacy && _agreeThirdParty && _agreeTerms && _agreeMarketing;
    });
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
                      onPressed: () => context.pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 22,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        '휴대폰 인증',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // 균형 맞추기
                  ],
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
                        const SizedBox(height: 20),

                        // 안내 문구
                        Text(
                          _codeSent
                              ? '인증번호를 입력해 주세요'
                              : '휴대폰 번호를 입력해 주세요',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkBlue,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _codeSent
                              ? '${_phoneController.text}로 전송된 6자리 인증번호를 입력해 주세요.'
                              : '본인 확인을 위해 휴대폰 인증이 필요해요.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: AppColors.gray600,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // 휴대폰 번호 입력
                        _buildPhoneInput(),

                        // 인증번호 입력 (전송 후)
                        if (_codeSent) ...[
                          const SizedBox(height: 24),
                          _buildCodeInput(),
                        ],

                        // 약관 동의 (인증번호 전송 전)
                        if (!_codeSent) ...[
                          const SizedBox(height: 32),
                          _buildAgreementSection(),
                        ],
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
                    onPressed: _codeSent
                        ? (_canComplete && !_isLoading ? _verifyAndContinue : null)
                        : (_canSendCode ? _sendCode : null),
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
                            _codeSent ? '인증 완료' : '인증번호 전송',
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
        Row(
          children: [
            // 국가 코드
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text(
                    '🇰🇷',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '+82',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 20,
                    color: AppColors.gray500,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // 전화번호 입력
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                enabled: !_codeSent,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                  _PhoneNumberFormatter(),
                ],
                onChanged: (_) => setState(() => _phoneError = null),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
                decoration: InputDecoration(
                  hintText: '010-0000-0000',
                  hintStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray400,
                  ),
                  filled: true,
                  fillColor: _codeSent ? AppColors.gray200 : AppColors.gray100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                ),
              ),
            ),
          ],
        ),
        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _phoneError!,
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

  Widget _buildAgreementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.gray50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 동의
          _buildCheckboxTile(
            value: _agreeAll,
            onChanged: _toggleAgreeAll,
            title: '전체 동의하기',
            isMain: true,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),

          // 개별 항목들
          _buildCheckboxTile(
            value: _agreePrivacy,
            onChanged: (v) {
              setState(() => _agreePrivacy = v ?? false);
              _updateAgreeAll();
            },
            title: '[필수] 개인정보 수집 및 이용 동의',
            showArrow: true,
          ),
          const SizedBox(height: 8),
          _buildCheckboxTile(
            value: _agreeThirdParty,
            onChanged: (v) {
              setState(() => _agreeThirdParty = v ?? false);
              _updateAgreeAll();
            },
            title: '[필수] 제3자 제공 동의',
            showArrow: true,
          ),
          const SizedBox(height: 8),
          _buildCheckboxTile(
            value: _agreeTerms,
            onChanged: (v) {
              setState(() => _agreeTerms = v ?? false);
              _updateAgreeAll();
            },
            title: '[필수] 서비스 이용약관 동의',
            showArrow: true,
          ),
          const SizedBox(height: 8),
          _buildCheckboxTile(
            value: _agreeMarketing,
            onChanged: (v) {
              setState(() => _agreeMarketing = v ?? false);
              _updateAgreeAll();
            },
            title: '[선택] 마케팅 정보 수신 동의',
            showArrow: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    bool isMain = false,
    bool showArrow = false,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: value ? AppColors.blue : AppColors.white,
              borderRadius: BorderRadius.circular(6),
              border: value ? null : Border.all(color: AppColors.gray300, width: 1.5),
            ),
            child: value
                ? const Icon(Icons.check_rounded, size: 16, color: AppColors.white)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: isMain ? 16 : 14,
                fontWeight: isMain ? FontWeight.w700 : FontWeight.w500,
                color: AppColors.darkBlue,
              ),
            ),
          ),
          if (showArrow)
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.gray400,
            ),
        ],
      ),
    );
  }
}

/// 전화번호 포맷터
class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if (i == 2 || i == 6) {
        if (i != text.length - 1) buffer.write('-');
      }
    }

    return TextEditingValue(
      text: buffer.toString(),
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
