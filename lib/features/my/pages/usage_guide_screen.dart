import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 이용 안내 화면
class UsageGuideScreen extends StatelessWidget {
  const UsageGuideScreen({super.key});

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
            '이용 안내',
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
            _buildGuideSection(
              icon: Icons.videogame_asset_rounded,
              title: '게임 참여 방법',
              steps: [
                '홈 화면에서 참여할 게임을 선택합니다.',
                '게임 상세 화면에서 원하는 블록을 터치하여 선택합니다.',
                '참여 버튼을 눌러 게임에 참여합니다.',
                '당첨 결과는 게임 종료 후 확인할 수 있습니다.',
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideSection(
              icon: Icons.account_balance_wallet_rounded,
              title: '캐시 충전/환불',
              steps: [
                'MY > 충전 메뉴에서 원하는 금액을 선택합니다.',
                '결제 수단을 선택하고 결제를 완료합니다.',
                '환불은 MY > 환불 메뉴에서 신청할 수 있습니다.',
                '환불은 영업일 기준 3-5일 내에 처리됩니다.',
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideSection(
              icon: Icons.emoji_events_rounded,
              title: '당첨금 수령',
              steps: [
                '게임 당첨 시 자동으로 캐시로 지급됩니다.',
                '상품 당첨 시 등록된 연락처로 안내드립니다.',
                '당첨 내역은 MY > 당첨 내역에서 확인할 수 있습니다.',
              ],
            ),
            const SizedBox(height: 16),
            _buildGuideSection(
              icon: Icons.shopping_bag_rounded,
              title: '쇼핑몰 이용',
              steps: [
                'MALL 탭에서 상품을 둘러봅니다.',
                '원하는 상품을 선택하고 구매합니다.',
                '보유한 캐시로 결제할 수 있습니다.',
                '배송 현황은 MY > 쇼핑 주문 내역에서 확인합니다.',
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '더 자세한 문의는 고객센터를 이용해주세요.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGuideSection({
    required IconData icon,
    required String title,
    required List<String> steps,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.blue,
                    size: 20,
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: AppColors.gray100,
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: steps.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final step = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: entry.key < steps.length - 1 ? 12 : 0,
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.gray200,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$index',
                            style: AppTextStyles.caption4.copyWith(color: AppColors.gray600),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          step,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.gray700,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
