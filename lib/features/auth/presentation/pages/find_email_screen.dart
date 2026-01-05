import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// SC-006: 이메일 찾기 화면
///
/// - SC-006-01: 휴대폰 번호 입력
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
  final _phoneFocusNode = FocusNode();
  final _codeFocusNode = FocusNode();

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
    if (!_isPhoneValid) {
      setState(() => _phoneError = '휴대폰 번호를 입력해 주세요.');
      return;
    }

    setState(() {
      _isLoading = true;
      _phoneError = null;
    });

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
    if (_resendCount >= _maxResendCount) return;

    setState(() {
      _isLoading = true;
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

  Future<void> _verifyAndSearch() async {
    final code = _codeController.text;

    if (code != '000000') {
      _showNoAccountDialog();
      return;
    }

    if (!mounted) return;

    // 결과 화면으로 이동
    context.push('/find-email-result', extra: {
      'phone': _phoneController.text,
    });
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
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Text('KOR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.gray600)),
                  const SizedBox(width: 4),
                  Text('+82', style: TextStyle(fontSize: 16, color: AppColors.gray500)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                enabled: !_codeSent,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (_) => setState(() => _phoneError = null),
                style: const TextStyle(fontSize: 16, color: AppColors.darkBlue),
                decoration: InputDecoration(
                  hintText: '숫자만 입력',
                  hintStyle: TextStyle(fontSize: 16, color: AppColors.gray400),
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
