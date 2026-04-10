import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_round_model.dart';

/// 데일리 게임 참여 완료 화면 — 위시 BuzzCompleteScreen 완전 복제
class DailyBuzzCompleteScreen extends StatelessWidget {
  final GameRound game;
  final Set<(int, int)> selectedBlocks;

  const DailyBuzzCompleteScreen({
    super.key,
    required this.game,
    required this.selectedBlocks,
  });

  @override
  Widget build(BuildContext context) {
    final blockList = selectedBlocks.toList();

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
                '참여 완료!',
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
                      child: game.imageUrl.isNotEmpty
                          ? Image.network(
                              game.imageUrl.replaceAll(' ', '%20'),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 50,
                                color: AppColors.gray200,
                                child: const Icon(Icons.image, color: AppColors.gray400, size: 24),
                              ),
                            )
                          : Container(
                              width: 50,
                              height: 50,
                              color: AppColors.gray200,
                              child: const Icon(Icons.image, color: AppColors.gray400, size: 24),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            game.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.title3,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '선택 좌표: ${blockList.map((b) => '(${b.$1}, ${b.$2})').join(', ')}',
                            style: const TextStyle(fontSize: 12, color: AppColors.gray600),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
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
                      '당첨 확률을 높이려면',
                      style: AppTextStyles.title3.copyWith(color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '다른 이벤트에도 참여해보세요!\n친구에게 공유하면 보너스 포인트!',
                      style: TextStyle(fontSize: 13, color: AppColors.gray600, height: 1.5),
                      textAlign: TextAlign.center,
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
                    '다른 이벤트 참여하기',
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
                  label: const Text('이 이벤트 공유하기'),
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
