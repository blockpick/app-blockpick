import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/game_round_model.dart';

/// 가로형 게임 카드 위젯 (SC-009 디자인)
class HorizontalGameCard extends StatelessWidget {
  final GameRound game;
  final VoidCallback? onTap;

  const HorizontalGameCard({
    super.key,
    required this.game,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 왼쪽: 이미지 + 배지
            _buildImageSection(),

            const SizedBox(width: 14),

            // 오른쪽: 정보
            Expanded(
              child: _buildInfoSection(),
            ),
          ],
        ),
      ),
    );
  }

  /// 이미지 섹션
  Widget _buildImageSection() {
    return Stack(
      children: [
        // 이미지
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 100,
            height: 100,
            child: game.imageUrl.isEmpty
                ? Container(
                    color: AppColors.gray100,
                    child: Center(
                      child: Icon(
                        Icons.image_rounded,
                        size: 32,
                        color: AppColors.gray400,
                      ),
                    ),
                  )
                : Image.network(
                    game.imageUrl.replaceAll(' ', '%20'),
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.gray100,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.gray400,
                            ),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.gray100,
                      child: Center(
                        child: Icon(
                          Icons.image_rounded,
                          size: 32,
                          color: AppColors.gray400,
                        ),
                      ),
                    ),
                  ),
          ),
        ),

        // 배지
        Positioned(
          top: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getBadgeColor(),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              _getTypeText(),
              style: AppTextStyles.caption4.copyWith(color: AppColors.white),
            ),
          ),
        ),
      ],
    );
  }

  /// 정보 섹션
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목
        Text(
          game.title,
          style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 10),

        // 통계 칩들
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _buildStatChip('P', '${game.currentPrice}'),
            _buildStatChip('👥', '${game.participants.toInt()}'),
            _buildStatChip('⊞', _formatGridSize(game.totalBlocks)),
          ],
        ),

        const SizedBox(height: 12),

        // 프로그레스 바 + 남은 시간
        _buildProgressSection(),
      ],
    );
  }

  /// 통계 칩
  Widget _buildStatChip(String icon, String value) {
    final isPoint = icon == 'P';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.gray200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPoint)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ),
            )
          else
            Text(
              icon,
              style: const TextStyle(fontSize: 11),
            ),
          SizedBox(width: 4),
          Text(
            value,
            style: AppTextStyles.caption2.copyWith(color: AppColors.gray700),
          ),
        ],
      ),
    );
  }

  /// 프로그레스 섹션
  Widget _buildProgressSection() {
    // 남은 시간을 파싱해서 진행률 계산 (간단히 처리)
    final progress = _calculateProgress();

    return Row(
      children: [
        // 프로그레스 바
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: _getProgressColor(progress),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),

        SizedBox(width: 10),

        // 남은 시간
        Text(
          '${game.timeLeft} 남음',
          style: AppTextStyles.body4.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }

  /// 배지 색상
  Color _getBadgeColor() {
    switch (game.type) {
      case GameType.daily:
        return AppColors.darkBlue;
      case GameType.select:
        return AppColors.purple;
      case GameType.vibe:
        return AppColors.blue;
      case GameType.prime:
        return AppColors.yellow500;
    }
  }

  /// 타입 텍스트
  String _getTypeText() {
    switch (game.type) {
      case GameType.daily:
        return 'Daily';
      case GameType.select:
        return 'Select';
      case GameType.vibe:
        return 'Vibe';
      case GameType.prime:
        return 'Prime';
    }
  }

  /// 그리드 크기 포맷
  String _formatGridSize(int totalBlocks) {
    final size = math.sqrt(totalBlocks).round();
    return '$size×$size';
  }

  /// 진행률 계산 (임시)
  double _calculateProgress() {
    // timeLeft 파싱해서 진행률 계산
    // 예: "03:34:56" -> 약 70% 남음
    try {
      final parts = game.timeLeft.split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0].replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        // 24시간 기준으로 진행률 계산
        return (hours / 24).clamp(0.0, 1.0);
      }
    } catch (_) {}
    return 0.5; // 기본값
  }

  /// 프로그레스 색상
  Color _getProgressColor(double progress) {
    if (progress < 0.2) return AppColors.red;
    if (progress < 0.5) return AppColors.yellow500;
    return AppColors.green500;
  }
}
