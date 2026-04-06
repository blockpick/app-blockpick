import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wish_model.dart';

/// 소문내기 완료 화면
class BuzzCompleteScreen extends StatelessWidget {
  final Wish wish;
  final int gridX;
  final int gridY;

  const BuzzCompleteScreen({
    super.key,
    required this.wish,
    required this.gridX,
    required this.gridY,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // 완료 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                '소문내기 완료!',
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: 16),
              // 상품 정보
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      child: Image.network(
                        wish.productImageUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 50,
                          height: 50,
                          color: AppColors.gray200,
                          child: const Icon(Icons.image, color: AppColors.gray400, size: 24),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            wish.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '선택 좌표: ($gridX, $gridY)',
                            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '게임 종료 후 결과를 확인할 수 있어요',
                style: TextStyle(fontSize: 14, color: AppColors.gray600),
              ),
              const SizedBox(height: 24),
              // 팁
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Column(
                  children: [
                    Text(
                      '💡 당첨 확률을 높이려면',
                      style: AppTextStyles.title3.copyWith(color: AppColors.primary),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• 다른 소원에도 소문내기\n• 친구에게 이 소원 공유하기',
                      style: TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.5),
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // 버튼들
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
                    elevation: 0,
                  ),
                  child: const Text(
                    '✨ 다른 소원 소문내기',
                    style: AppTextStyles.buttonLarge,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // TODO: 공유 기능
                  },
                  icon: const Icon(Icons.share, size: 16),
                  label: const Text('이 소원 공유하기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.gray600,
                    side: const BorderSide(color: AppColors.gray200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusXl)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
