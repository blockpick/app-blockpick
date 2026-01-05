import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_scaffold.dart';
import '../widgets/auth_button.dart';

/// 약관 동의 화면
class TermsAgreeScreen extends ConsumerStatefulWidget {
  final String? provider;
  final String? phone;
  final String? email;

  const TermsAgreeScreen({
    super.key,
    this.provider,
    this.phone,
    this.email,
  });

  @override
  ConsumerState<TermsAgreeScreen> createState() => _TermsAgreeScreenState();
}

class _TermsAgreeScreenState extends ConsumerState<TermsAgreeScreen> {
  bool _allAgreed = false;
  bool _termsAgreed = false;
  bool _privacyAgreed = false;
  bool _marketingAgreed = false;

  void _updateAllAgreed() {
    setState(() {
      _allAgreed = _termsAgreed && _privacyAgreed;
    });
  }

  void _toggleAll(bool value) {
    setState(() {
      _allAgreed = value;
      _termsAgreed = value;
      _privacyAgreed = value;
      _marketingAgreed = value;
    });
  }

  bool get _canProceed => _termsAgreed && _privacyAgreed;

  void _handleNext() {
    if (widget.provider != null) {
      // SNS 가입 완료
      context.push('/auth/signup-complete', extra: {
        'provider': widget.provider,
        'phone': widget.phone,
        'marketingAgreed': _marketingAgreed,
      });
    } else {
      // 이메일 가입의 경우 - 이메일 인증으로 이동
      context.push('/auth/email-verify', extra: {
        'email': widget.email,
        'phone': widget.phone,
        'marketingAgreed': _marketingAgreed,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      showBackButton: true,
      progress: widget.provider != null ? 0.75 : 0.5, // SNS: 3/4, 이메일: 2/4
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),

            // 타이틀
            const Text(
              '서비스 이용약관에\n동의해주세요',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
                height: 1.3,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),

            // 전체 동의
            _AgreementItem(
              title: '약관 전체 동의',
              isChecked: _allAgreed && _marketingAgreed,
              onChanged: _toggleAll,
              isAllAgree: true,
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: AppColors.gray200),
            ),

            // 개별 약관들
            _AgreementItem(
              title: '[필수] 서비스 이용약관',
              isChecked: _termsAgreed,
              onChanged: (value) {
                setState(() => _termsAgreed = value);
                _updateAllAgreed();
              },
              onDetailTap: () => _showTermsDetail(context, '서비스 이용약관'),
            ),
            const SizedBox(height: 12),

            _AgreementItem(
              title: '[필수] 개인정보 처리방침',
              isChecked: _privacyAgreed,
              onChanged: (value) {
                setState(() => _privacyAgreed = value);
                _updateAllAgreed();
              },
              onDetailTap: () => _showTermsDetail(context, '개인정보 처리방침'),
            ),
            const SizedBox(height: 12),

            _AgreementItem(
              title: '[선택] 마케팅 정보 수신 동의',
              isChecked: _marketingAgreed,
              onChanged: (value) {
                setState(() => _marketingAgreed = value);
              },
              onDetailTap: () => _showTermsDetail(context, '마케팅 정보 수신'),
            ),
          ],
        ),
      ),
      bottomButton: AuthButton(
        text: '동의하고 계속하기',
        onPressed: _canProceed ? _handleNext : null,
        enabled: _canProceed,
      ),
    );
  }

  void _showTermsDetail(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TermsDetailSheet(title: title),
    );
  }
}

/// 약관 동의 아이템
class _AgreementItem extends StatelessWidget {
  final String title;
  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onDetailTap;
  final bool isAllAgree;

  const _AgreementItem({
    required this.title,
    required this.isChecked,
    required this.onChanged,
    this.onDetailTap,
    this.isAllAgree = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isChecked),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isAllAgree ? 16 : 0,
          vertical: isAllAgree ? 16 : 8,
        ),
        decoration: isAllAgree
            ? BoxDecoration(
                color: AppColors.gray50,
                borderRadius: BorderRadius.circular(12),
              )
            : null,
        child: Row(
          children: [
            // 체크박스
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isChecked ? AppColors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isChecked ? AppColors.blue : AppColors.gray400,
                  width: 2,
                ),
              ),
              child: isChecked
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // 타이틀
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: isAllAgree ? 17 : 15,
                  fontWeight: isAllAgree ? FontWeight.w700 : FontWeight.w500,
                  color: AppColors.darkBlue,
                ),
              ),
            ),

            // 상세보기 버튼
            if (onDetailTap != null)
              IconButton(
                onPressed: onDetailTap,
                icon: Icon(
                  Icons.chevron_right_rounded,
                  size: 24,
                  color: AppColors.gray400,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}

/// 약관 상세 바텀시트
class _TermsDetailSheet extends StatelessWidget {
  final String title;

  const _TermsDetailSheet({required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 내용
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Text(
                _getTermsContent(title),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.gray700,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTermsContent(String title) {
    // TODO: 실제 약관 내용으로 교체
    return '''
$title

제1조 (목적)
이 약관은 BlockPick(이하 "회사")이 제공하는 서비스의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.

제2조 (정의)
이 약관에서 사용하는 용어의 정의는 다음과 같습니다.
1. "서비스"란 회사가 제공하는 모든 서비스를 의미합니다.
2. "회원"이란 회사와 서비스 이용계약을 체결한 자를 의미합니다.

제3조 (약관의 효력 및 변경)
1. 이 약관은 서비스를 이용하고자 하는 모든 회원에게 그 효력이 발생합니다.
2. 회사는 필요한 경우 관련 법령을 위반하지 않는 범위에서 이 약관을 변경할 수 있습니다.

제4조 (서비스의 제공)
회사는 다음과 같은 서비스를 제공합니다.
1. 블록픽 게임 서비스
2. 기타 회사가 정하는 서비스

[이하 생략]
''';
  }
}
