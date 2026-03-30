import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 이용약관 화면
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: const Text(
            '이용약관',
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BlockPick 서비스 이용약관',
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
                    '제1조 (목적)',
                    '이 약관은 BlockPick(이하 "회사")이 제공하는 서비스의 이용조건 및 절차, 회사와 회원 간의 권리, 의무 및 책임사항을 규정함을 목적으로 합니다.',
                  ),
                  _buildSection(
                    '제2조 (정의)',
                    '① "서비스"란 회사가 제공하는 블록픽 게임 및 쇼핑몰 서비스를 말합니다.\n② "회원"이란 회사와 서비스 이용계약을 체결한 자를 말합니다.\n③ "캐시"란 서비스 내에서 사용 가능한 가상화폐를 말합니다.',
                  ),
                  _buildSection(
                    '제3조 (약관의 효력 및 변경)',
                    '① 이 약관은 서비스 화면에 게시하거나 기타의 방법으로 공지함으로써 효력이 발생합니다.\n② 회사는 필요한 경우 관련 법령을 위배하지 않는 범위에서 이 약관을 변경할 수 있습니다.',
                  ),
                  _buildSection(
                    '제4조 (서비스의 제공)',
                    '① 회사는 다음과 같은 서비스를 제공합니다.\n- 블록픽 게임 서비스\n- 쇼핑몰 서비스\n- 캐시 충전 및 환불 서비스\n② 서비스는 연중무휴, 1일 24시간 제공함을 원칙으로 합니다.',
                  ),
                  _buildSection(
                    '제5조 (회원가입)',
                    '① 서비스 이용을 희망하는 자는 회사가 정한 절차에 따라 회원가입을 신청합니다.\n② 회사는 신청자의 신청에 대하여 승낙함을 원칙으로 합니다.',
                  ),
                  _buildSection(
                    '제6조 (회원 탈퇴)',
                    '회원은 언제든지 탈퇴를 요청할 수 있으며, 회사는 즉시 회원탈퇴를 처리합니다. 탈퇴 시 보유한 캐시는 환불 정책에 따라 처리됩니다.',
                  ),
                  _buildSection(
                    '제7조 (개인정보 보호)',
                    '회사는 회원의 개인정보를 보호하기 위해 개인정보처리방침을 수립하고 이를 준수합니다.',
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
