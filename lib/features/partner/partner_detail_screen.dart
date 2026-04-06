import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'partner_game_webview.dart';
import '../../core/constants/app_constants.dart';

/// 파트너 이벤트 상세 화면
/// 시안 기반: 브랜드 콜라보 헤더 + 경품 이미지 + 혜택 + 참여방법 + 유의사항 + CTA
class PartnerDetailScreen extends StatelessWidget {
  final Map<String, dynamic> game;

  const PartnerDetailScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final product = (game['gameProducts'] as List?)?.isNotEmpty == true
        ? (game['gameProducts'] as List).first['product'] as Map<String, dynamic>?
        : null;
    final imageUrl = product?['defaultImage'] as String?;
    final productName = product?['name'] as String? ?? game['mainProductName'] as String? ?? '';
    final brand = product?['brand'] as String? ?? '파트너';
    final title = game['title'] as String? ?? '';
    final description = game['description'] as String? ?? '';
    final startTime = game['startTime'] as String? ?? '';
    final endTime = game['endTime'] as String? ?? '';
    final maxEntries = game['maxEntries'] as int?;
    final maxEntriesPerUser = game['maxEntriesPerUser'] as int?;
    final entryFee = game['entryFee'] as int? ?? 0;
    final hasInstantPrize = game['hasInstantPrize'] as bool? ?? false;

    // 기간 포맷
    String period = '';
    try {
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        final start = DateTime.parse(startTime);
        final end = DateTime.parse(endTime);
        period = '이벤트 기간 : ${_formatDate(start)} ~ ${_formatDate(end)}';
      }
    } catch (_) {}

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkBlue),
        ),
        title: Text(
          '파트너 이벤트',
          style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 브랜드 콜라보 헤더
                  _buildCollaboHeader(brand),

                  // 오늘의 행운 문구
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    color: AppColors.primaryBg,
                    child: Text(
                      '오늘의 행운 꿈기 🍀',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title3.copyWith(color: AppColors.primaryMain),
                    ),
                  ),

                  // 경품 타이틀
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                    child: Text(
                      productName.isNotEmpty ? productName : title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkBlue,
                        height: 1.3,
                      ),
                    ),
                  ),

                  // 기간
                  if (period.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      child: Text(
                        period,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.gray500),
                      ),
                    ),

                  const SizedBox(height: 16),

                  // 경품 이미지
                  if (imageUrl != null)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      height: 200,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(Icons.image_outlined, size: 60, color: AppColors.gray300),
                        ),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // 혜택 섹션
                  _buildBenefitSection(brand, hasInstantPrize, entryFee),

                  const SizedBox(height: 24),

                  // 참여방법
                  _buildHowToSection(),

                  const SizedBox(height: 24),

                  // 유의사항
                  _buildNoticeSection(maxEntries, maxEntriesPerUser),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // CTA 버튼
          _buildCTA(context),
        ],
      ),
    );
  }

  /// BLOCKPICK X 파트너 브랜드 헤더
  Widget _buildCollaboHeader(String brand) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'BLOCKPICK',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
              letterSpacing: 1,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '×',
              style: TextStyle(fontSize: 18, color: AppColors.gray400),
            ),
          ),
          Text(
            brand,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.primaryMain,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 혜택 카드 섹션
  Widget _buildBenefitSection(String brand, bool hasInstantPrize, int entryFee) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _BenefitCard(
            icon: Icons.emoji_events_rounded,
            iconColor: const Color(0xFFF5A623),
            title: '당첨 혜택',
            description: '경품 당첨 시 블록픽 앱에서\n수령 가능합니다',
          ),
          const SizedBox(height: 10),
          _BenefitCard(
            icon: Icons.add_circle_outline_rounded,
            iconColor: AppColors.primaryMain,
            title: '추가 혜택',
            description: '블록픽 이벤트 1회 응모권\n100% 지급',
          ),
          if (hasInstantPrize) ...[
            const SizedBox(height: 10),
            _BenefitCard(
              icon: Icons.flash_on_rounded,
              iconColor: AppColors.blue,
              title: '즉석 혜택',
              description: '즉석경품 당첨 기회!\n바로 확인 가능합니다',
            ),
          ],
        ],
      ),
    );
  }

  /// 참여방법 섹션
  Widget _buildHowToSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '참여방법',
              style: AppTextStyles.buttonLarge.copyWith(color: AppColors.darkBlue),
            ),
            const SizedBox(height: 16),
            _buildStep('1', '이벤트 참여하기 버튼 선택'),
            _buildStep('2', '블록픽 APP 회원가입'),
            _buildStep('3', '이벤트 플레이'),
            _buildStep('4', '블록픽 APP에서 당첨 결과 확인하기'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.primaryMain,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Center(
              child: Text(
                number,
                style: AppTextStyles.caption3.copyWith(color: AppColors.white),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
            ),
          ),
        ],
      ),
    );
  }

  /// 유의사항 섹션
  Widget _buildNoticeSection(int? maxEntries, int? maxEntriesPerUser) {
    final notices = [
      '본 이벤트는 1일 1회 참여가능하며, 당사 사정에 따라 이벤트 일정 및 내용이 변경 될 수 있습니다.',
      '블록픽 App 회원가입을 하셔야 경품 수령 및 혜택을 받을 수 있습니다.',
      if (maxEntries != null) '참여 인원은 최대 ${maxEntries.toString()}명으로 제한됩니다.',
      if (maxEntriesPerUser != null) '1인당 최대 ${maxEntriesPerUser.toString()}회까지 참여 가능합니다.',
      '부정 참여 시 당첨이 취소될 수 있습니다.',
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber.shade700),
                SizedBox(width: 6),
                Text(
                  '이벤트 유의사항',
                  style: AppTextStyles.title3.copyWith(color: Colors.amber.shade900),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...notices.map((n) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('· ', style: TextStyle(fontSize: 12, color: AppColors.gray500)),
                  Expanded(
                    child: Text(
                      n,
                      style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.gray500),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  /// 하단 CTA 버튼
  Widget _buildCTA(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => PartnerGameWebView(
                  gameId: game['id'] as String,
                  gameTitle: game['title'] as String?,
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryMain,
            foregroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusXl),
            ),
            elevation: 0,
          ),
          child: const Text(
            '이벤트 참여하기',
            style: AppTextStyles.buttonLarge,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}(${weekdays[dt.weekday - 1]})';
  }
}

/// 혜택 카드 위젯
class _BenefitCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String description;

  const _BenefitCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: AppColors.gray500, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
