import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_optimal_game_data.dart';
import '../../models/optimal_game_model.dart';

/// 최적가 게임 리스트 화면
class OptimalGameListScreen extends StatelessWidget {
  const OptimalGameListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final games = MockOptimalGameData.getAllGames();

    return Container(
      color: AppColors.deepWhite,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return _buildGameCard(context, game);
        },
      ),
    );
  }

  Widget _buildGameCard(BuildContext context, OptimalGame game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go('/optimal/${game.id}'),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // 상품 이미지
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.bgWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.buleGray),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      game.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          LucideIcons.package,
                          size: 40,
                          color: AppColors.grayBlue,
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 게임 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 제목
                      Text(
                        game.title,
                        style: AppTextStyles.medium.copyWith(
                          color: AppColors.darkBlue,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // 가격 범위
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: AppColors.gradientLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_formatPrice(game.minPrice)} ~ ${_formatPrice(game.maxPrice)}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // 참여자 및 시간
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.users,
                            size: 14,
                            color: AppColors.grayBlue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${game.participants}명',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.grayBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            LucideIcons.clock,
                            size: 14,
                            color: AppColors.yellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            game.timeLeft,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.yellow,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              gradient: AppColors.gradientBluePurplePink,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '최적가',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final remainder = price % 10000;
      if (remainder == 0) {
        return '${man}만원';
      } else {
        return '${man}.${(remainder / 1000).toStringAsFixed(0)}만원';
      }
    }
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }
}
