import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/game_round_model.dart';

/// 토스 스타일 게임 섹션
class TossGameSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<GameRound> games;
  final VoidCallback? onViewAll;
  final bool isVibe;

  const TossGameSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.games,
    this.onViewAll,
    this.isVibe = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body3.copyWith(color: AppColors.gray500),
                ),
              ],
            ),
            if (onViewAll != null)
              GestureDetector(
                onTap: onViewAll,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '전체보기',
                        style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.gray600,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // 게임 카드들
        if (isVibe)
          _buildVibeCards(context)
        else
          _buildGameCards(context),
      ],
    );
  }

  Widget _buildGameCards(BuildContext context) {
    return Column(
      children: games
          .map((game) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _TossGameCard(game: game),
              ))
          .toList(),
    );
  }

  Widget _buildVibeCards(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: games.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(right: index < games.length - 1 ? 12 : 0),
            child: _TossVibeCard(game: games[index]),
          );
        },
      ),
    );
  }
}

/// 토스 스타일 게임 카드
class _TossGameCard extends StatelessWidget {
  final GameRound game;

  const _TossGameCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/game/${game.id}'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _buildImage(),
            ),
            SizedBox(width: 16),

            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 태그
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getCategoryColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      game.category,
                      style: AppTextStyles.caption4.copyWith(color: _getCategoryColor()),
                    ),
                  ),
                  SizedBox(height: 8),

                  // 제목
                  Text(
                    game.title,
                    style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // 참가자 / 남은시간
                  Row(
                    children: [
                      Icon(
                        Icons.people_outline_rounded,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_formatNumber(game.participants)}명',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.gray500,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        game.timeLeft,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // 가격
                  Row(
                    children: [
                      Text(
                        '${_formatCurrency(game.currentPrice)}원',
                        style: AppTextStyles.buttonLarge.copyWith(color: AppColors.blue),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${_formatCurrency(game.originalPrice)}원',
                        style: AppTextStyles.caption1.copyWith(color: AppColors.gray400, decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 화살표
            Icon(
              Icons.chevron_right_rounded,
              size: 24,
              color: AppColors.gray400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (game.imageUrl.startsWith('http')) {
      return Image.network(
        game.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (game.imageUrl.startsWith('assets/')) {
      return Image.asset(
        game.imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: AppColors.gray200,
      child: Icon(
        Icons.image_outlined,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }

  Color _getCategoryColor() {
    switch (game.category.toLowerCase()) {
      case 'digital':
        return AppColors.blue;
      case 'fashion':
        return AppColors.purple;
      case 'gift':
        return AppColors.pink;
      case 'food':
        return AppColors.yellow500;
      case 'charity':
        return AppColors.green500;
      case 'art':
        return AppColors.purple;
      case 'tribute':
        return AppColors.pink;
      default:
        return AppColors.gray600;
    }
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }

  String _formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(amount);
  }
}

/// 토스 스타일 바이브 카드 (가로 스크롤)
class _TossVibeCard extends StatelessWidget {
  final GameRound game;

  const _TossVibeCard({required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/game/${game.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 배경 이미지
              Positioned.fill(
                child: _buildImage(),
              ),

              // 그라데이션 오버레이
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // 컨텐츠
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        game.category,
                        style: AppTextStyles.caption4.copyWith(color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 8),

                    // 제목
                    Text(
                      game.title,
                      style: AppTextStyles.title3.copyWith(color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),

                    // 참가자
                    Row(
                      children: [
                        const Icon(
                          Icons.people_outline_rounded,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatNumber(game.participants)}명 참여',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
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
    );
  }

  Widget _buildImage() {
    if (game.imageUrl.startsWith('http')) {
      return Image.network(
        game.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else if (game.imageUrl.startsWith('assets/')) {
      return Image.asset(
        game.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.purple.withValues(alpha: 0.3),
      child: Center(
        child: Icon(
          Icons.auto_awesome_rounded,
          size: 40,
          color: AppColors.purple.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 10000).toStringAsFixed(1)}만';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}천';
    }
    return number.toString();
  }
}
