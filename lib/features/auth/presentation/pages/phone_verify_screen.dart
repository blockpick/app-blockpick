import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/auth/data/repositories/auth_repository.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../../../../core/auth/domain/providers/verification_state_provider.dart';

/// SC-005-02, SC-005-03: 휴대폰 번호 인증 화면
///
/// - 토스 스타일 디자인
/// - 휴대폰 번호 입력 (국제 전화번호 지원)
/// - 인증번호 입력 (6자리, 3분 타이머)
/// - 이용 동의 체크 (개인정보, 제3자, 서비스 약관, 마케팅)
class PhoneVerifyScreen extends ConsumerStatefulWidget {
  final String? signupType; // 'email', 'google', 'apple'
  final String? flowType; // 'signup', 'find-email', 'withdrawal'

  // SNS 가입 시 OAuth에서 받은 정보
  final String? socialId;
  final String? socialEmail;
  final String? socialName;
  final String? socialPhotoUrl;

  const PhoneVerifyScreen({
    super.key,
    this.signupType,
    this.flowType,
    this.socialId,
    this.socialEmail,
    this.socialName,
    this.socialPhotoUrl,
  });

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _codeFocusNode = FocusNode();

  // 국제 전화번호 입력
  final PhoneNumber _initialPhoneNumber = PhoneNumber(isoCode: 'KR');
  PhoneNumber _phoneNumber = PhoneNumber(isoCode: 'KR');
  bool _isPhoneValid = false;
  String? _e164PhoneNumber;

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
    _codeFocusNode.dispose();
    super.dispose();
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

  /// flowType에 따라 SmsVerifyType을 반환
  String get _smsVerifyType {
    switch (widget.flowType) {
      case 'find-email':
        return 'FIND_EMAIL';
      case 'withdrawal':
        return 'WITHDRAW';
      case 'change-password':
        return 'CHANGE_PASSWORD';
      default:
        return 'SIGN_UP';
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

  Future<void> _sendCode() async {
    if (!_isPhoneValid || _e164PhoneNumber == null) {
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

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);

      // 회원가입 플로우일 때만 이미 가입된 번호인지 먼저 체크
      if (_smsVerifyType == 'SIGN_UP') {
        final checkResult = await authRepo.checkPhoneNumber(
          phoneNumber: _e164PhoneNumber!,
        );

        if (!mounted) return;

        if (checkResult.success && checkResult.exists) {
          // 이미 가입된 번호
          setState(() => _isLoading = false);
          _showExistingPhoneDialog();
          return;
        }
      }

      // SMS 인증 코드 발송
      final result = await authRepo.sendSmsVerificationCode(
        phoneNumber: _e164PhoneNumber!,
        verifyType: _smsVerifyType,
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
        setState(() => _isLoading = false);

        // 이미 가입된 전화번호 체크 (백업 - API 에러 코드로도 체크)
        final errorCode = result.code?.toUpperCase() ?? '';
        if (_isPhoneAlreadyRegisteredError(errorCode)) {
          _showExistingPhoneDialog();
        } else {
          setState(() {
            _phoneError = result.message ?? 'SMS 발송에 실패했습니다.';
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _phoneError = 'SMS 발송 중 오류가 발생했습니다.';
      });
    }
  }

  /// 이미 가입된 전화번호 에러인지 확인
  bool _isPhoneAlreadyRegisteredError(String code) {
    const duplicateCodes = [
      'PHONE_ALREADY_EXISTS',
      'PHONE_ALREADY_REGISTERED',
      'DUPLICATE_PHONE',
      'PHONE_DUPLICATE',
      'USER_ALREADY_EXISTS',
      'ALREADY_REGISTERED',
    ];
    return duplicateCodes.contains(code);
  }

  /// 이미 가입된 전화번호 다이얼로그
  void _showExistingPhoneDialog() {
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
                '이미 가입된 번호예요',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '해당 번호로 가입된 계정이 있어요.\n로그인하거나 이메일을 찾아보세요.',
                style: TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/find-email');
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: AppColors.gray300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        '이메일 찾기',
                        style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
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
                        style: AppTextStyles.title2.copyWith(color: AppColors.white),
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
      final authRepo = await ref.read(authRepositoryProvider.future);

      final result = await authRepo.sendSmsVerificationCode(
        phoneNumber: _e164PhoneNumber!,
        verifyType: _smsVerifyType,
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
          _codeError = result.message ?? '재전송에 실패했습니다.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeError = '재전송 중 오류가 발생했습니다.';
      });
    }
  }

  Future<void> _verifyAndContinue() async {
    if (_e164PhoneNumber == null) return;

    // 이미 인증된 번호인지 확인 (24시간 유효)
    final verificationState = ref.read(verificationProvider);
    if (verificationState.isPhoneVerified(_e164PhoneNumber!)) {
      // 이미 인증됨 - API 호출 없이 바로 다음 화면으로
      _navigateToNext(_e164PhoneNumber!);
      return;
    }

    final code = _codeController.text;

    setState(() {
      _isLoading = true;
      _codeError = null;
    });

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);

      final result = await authRepo.verifySmsCode(
        phoneNumber: _e164PhoneNumber!,
        code: code,
        verifyType: _smsVerifyType,
      );

      if (!mounted) return;

      if (!result.success) {
        setState(() => _isLoading = false);
        _showCodeMismatchDialog();
        return;
      }

      // 인증 상태 저장 (뒤로갔다가 다시 와도 재인증 불필요)
      ref.read(verificationProvider.notifier).markPhoneVerified(_e164PhoneNumber!);

      setState(() => _isLoading = false);

      // 다음 화면으로 이동
      _navigateToNext(_e164PhoneNumber!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _codeError = '인증 확인 중 오류가 발생했습니다.';
      });
    }
  }

  void _navigateToNext(String e164Phone) {
    final flowType = widget.flowType ?? 'signup';
    // 표시용 전화번호 (국가코드 제외)
    final displayPhone = _phoneController.text;
    final signupType = widget.signupType ?? 'email';

    switch (flowType) {
      case 'signup':
        if (signupType == 'google' || signupType == 'apple') {
          // SNS 가입: socialLogin API 호출 후 홈으로 이동
          _completeSocialSignup(e164Phone);
        } else {
          // 이메일 가입: 이메일/비밀번호 설정 화면으로
          context.push('/email-password-setup', extra: {
            'phone': displayPhone,
            'phoneE164': e164Phone,
            'agreeMarketing': _agreeMarketing,
          });
        }
        break;
      case 'find-email':
        context.push('/find-email-result', extra: {
          'phone': displayPhone,
          'phoneE164': e164Phone,
        });
        break;
      default:
        context.pop();
    }
  }

  /// SNS 가입 완료: socialLogin API 호출
  Future<void> _completeSocialSignup(String e164Phone) async {
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).socialSignIn(
        provider: widget.signupType!.toUpperCase(),
        socialId: widget.socialId!,
        email: widget.socialEmail!,
        name: widget.socialName,
        profileImageUrl: widget.socialPhotoUrl,
      );

      if (!mounted) return;
      setState(() => _isLoading = false);

      // 가입 완료 → 홈으로 이동
      context.go('/');
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      _showSocialSignupErrorDialog(e.toString());
    }
  }

  /// SNS 가입 실패 다이얼로그
  void _showSocialSignupErrorDialog(String error) {
    String title = '가입에 실패했어요';
    String message = '다시 시도해 주세요.';

    if (error.contains('already exists') || error.contains('DUPLICATE')) {
      title = '이미 가입된 계정이에요';
      message = '해당 SNS 계정으로 이미 가입되어 있어요.\n로그인을 시도해 주세요.';
    }

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
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: TextStyle(fontSize: 14, color: AppColors.gray600, height: 1.4),
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
                        '닫기',
                        style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
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
                        style: AppTextStyles.title2.copyWith(color: AppColors.white),
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
                        style: AppTextStyles.title2.copyWith(color: AppColors.gray600),
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
                        style: AppTextStyles.title2.copyWith(color: AppColors.white),
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
                    style: AppTextStyles.title2.copyWith(color: AppColors.white),
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
                    style: AppTextStyles.title2.copyWith(color: AppColors.white),
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
                        style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
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
                              ? '${_phoneNumber.dialCode} ${_phoneController.text}로 전송된 6자리 인증번호를 입력해 주세요.'
                              : '본인 확인을 위해 휴대폰 인증이 필요해요.',
                          style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
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
        const Text(
          '휴대폰 번호',
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: _codeSent ? AppColors.gray200 : AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: InternationalPhoneNumberInput(
            onInputChanged: (PhoneNumber number) {
              _phoneNumber = number;
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
            selectorConfig: const SelectorConfig(
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
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
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
          style: AppTextStyles.heading3.copyWith(color: AppColors.darkBlue),
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
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _timerText,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _remainingSeconds < 60 ? AppColors.red : AppColors.blue,
                ),
              ),
            ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
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
              style: AppTextStyles.title3.copyWith(color: _resendCount < _maxResendCount ? AppColors.blue : AppColors.gray400),
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
