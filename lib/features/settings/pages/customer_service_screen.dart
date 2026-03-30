import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 고객센터 화면
class CustomerServiceScreen extends StatelessWidget {
  const CustomerServiceScreen({super.key});

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
            '고객센터',
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
            // 상담 안내
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.gradientBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '무엇을 도와드릴까요?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '평일 09:00 - 18:00 (주말/공휴일 휴무)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 문의 방법
            _buildSectionTitle('문의 방법'),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.chat_bubble_outline_rounded,
              title: '1:1 채팅 상담',
              subtitle: '실시간 채팅으로 빠른 상담',
              onTap: () {
                // TODO: 채팅 상담 연결
              },
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.email_outlined,
              title: '이메일 문의',
              subtitle: 'support@blockpick.net',
              onTap: () async {
                final uri = Uri.parse('mailto:support@blockpick.net');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),
            const SizedBox(height: 12),
            _buildContactCard(
              icon: Icons.phone_outlined,
              title: '전화 상담',
              subtitle: '1588-0000',
              onTap: () async {
                final uri = Uri.parse('tel:15880000');
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri);
                }
              },
            ),

            const SizedBox(height: 24),

            // 자주 묻는 질문
            _buildSectionTitle('자주 묻는 질문'),
            const SizedBox(height: 12),
            _buildFAQCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: AppColors.darkBlue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.gray400,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQCard() {
    final faqs = [
      {'q': '캐시 충전은 어떻게 하나요?', 'a': 'MY > 충전 메뉴에서 원하는 금액을 선택하여 충전할 수 있습니다.'},
      {'q': '게임 참여 방법이 궁금해요', 'a': '홈 화면에서 참여하고 싶은 게임을 선택 후 블록을 선택하면 참여가 완료됩니다.'},
      {'q': '당첨금은 어떻게 받나요?', 'a': '당첨 시 자동으로 캐시로 지급되며, 환불 신청을 통해 출금할 수 있습니다.'},
      {'q': '환불 처리 기간은 얼마나 걸리나요?', 'a': '환불 신청 후 영업일 기준 3-5일 내에 처리됩니다.'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: faqs.asMap().entries.map((entry) {
          final index = entry.key;
          final faq = entry.value;
          return Column(
            children: [
              _FAQItem(
                question: faq['q']!,
                answer: faq['a']!,
              ),
              if (index < faqs.length - 1)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  height: 1,
                  color: AppColors.gray100,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _FAQItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FAQItem({
    required this.question,
    required this.answer,
  });

  @override
  State<_FAQItem> createState() => _FAQItemState();
}

class _FAQItemState extends State<_FAQItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        'Q',
                        style: AppTextStyles.caption3.copyWith(color: AppColors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray400,
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppColors.green500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Center(
                        child: Text(
                          'A',
                          style: AppTextStyles.caption3.copyWith(color: AppColors.green500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.gray700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
