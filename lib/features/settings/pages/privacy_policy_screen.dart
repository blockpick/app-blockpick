import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 개인정보처리방침 화면
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: Text(
            '개인정보처리방침',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BlockPick 개인정보처리방침',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '시행일: 2025년 1월 1일',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildSection(
                    '1. 개인정보의 수집 및 이용 목적',
                    '회사는 다음의 목적을 위해 개인정보를 수집 및 이용합니다.\n\n• 회원 가입 및 관리\n• 서비스 제공 및 요금 정산\n• 고객 상담 및 불만 처리\n• 마케팅 및 광고에 활용',
                  ),
                  _buildSection(
                    '2. 수집하는 개인정보 항목',
                    '• 필수항목: 이메일, 비밀번호, 휴대전화번호\n• 선택항목: 닉네임, 프로필 이미지\n• 자동수집항목: IP주소, 쿠키, 서비스 이용기록',
                  ),
                  _buildSection(
                    '3. 개인정보의 보유 및 이용 기간',
                    '회원 탈퇴 시까지 보유하며, 관련 법령에 따라 일정 기간 보존이 필요한 정보는 해당 기간 동안 보관합니다.\n\n• 계약 또는 청약철회 등에 관한 기록: 5년\n• 대금결제 및 재화 등의 공급에 관한 기록: 5년\n• 소비자의 불만 또는 분쟁처리에 관한 기록: 3년',
                  ),
                  _buildSection(
                    '4. 개인정보의 파기 절차 및 방법',
                    '회사는 개인정보 보유기간의 경과, 처리목적 달성 등 개인정보가 불필요하게 되었을 때에는 지체없이 해당 개인정보를 파기합니다.',
                  ),
                  _buildSection(
                    '5. 개인정보의 제3자 제공',
                    '회사는 원칙적으로 이용자의 개인정보를 제3자에게 제공하지 않습니다. 다만, 다음의 경우에는 예외로 합니다.\n\n• 이용자가 사전에 동의한 경우\n• 법령의 규정에 의거하거나, 수사 목적으로 법령에 정해진 절차와 방법에 따라 수사기관의 요구가 있는 경우',
                  ),
                  _buildSection(
                    '6. 이용자의 권리와 행사 방법',
                    '• 이용자는 언제든지 자신의 개인정보를 조회하거나 수정할 수 있습니다.\n• 이용자는 언제든지 개인정보 처리의 동의를 철회할 수 있습니다.\n• 이용자는 개인정보의 삭제를 요청할 수 있습니다.',
                  ),
                  _buildSection(
                    '7. 개인정보 보호책임자',
                    '회사는 개인정보 처리에 관한 업무를 총괄해서 책임지고, 개인정보 처리와 관련한 이용자의 불만처리 및 피해구제를 위하여 개인정보 보호책임자를 지정하고 있습니다.\n\n• 개인정보 보호책임자: BlockPick 개인정보보호팀\n• 연락처: privacy@blockpick.net',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
