import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/game_round_model.dart';

/// SC-008 프로모션 카드 (오픈 버전)
/// 전체 이미지 배경 + 뱃지 + 제목 + 플레이 버튼
class PromotionCard extends StatelessWidget {
  final GameRound game;
  final String gameType; // daily, select, vibe, prime
  final bool isLive;
  final int? rankNumber; // 우측 상단 숫자 뱃지 (null이면 표시 안함)
  final VoidCallback? onTap;

  const PromotionCard({
    super.key,
    required this.game,
    required this.gameType,
    this.isLive = false,
    this.rankNumber,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: _isInactive ? 0.7 : 1.0,
        child: Container(
        height: 220,
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 이미지
              _buildBackgroundImage(),

              // 그라데이션 오버레이
              _buildGradientOverlay(),

              // 콘텐츠
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 뱃지들 + 숫자 + 상태
                    _buildTopRow(),

                    const Spacer(),

                    // 하단: 제목 + 플레이 버튼
                    _buildBottomContent(),
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

  /// 배경 이미지
  Widget _buildBackgroundImage() {
    if (game.imageUrl.isEmpty) {
      return Container(
        color: AppColors.gray700,
        child: Center(
          child: Icon(
            Icons.image_outlined,
            size: 48,
            color: AppColors.gray500,
          ),
        ),
      );
    }

    return Image.network(
      game.imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: AppColors.gray700,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.white.withValues(alpha: 0.5),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.gray700,
          child: Center(
            child: Icon(
              Icons.image_outlined,
              size: 48,
              color: AppColors.gray500,
            ),
          ),
        );
      },
    );
  }

  /// 그라데이션 오버레이 (하단으로 갈수록 어두워짐)
  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.black.withValues(alpha: 0.3),
            AppColors.black.withValues(alpha: 0.7),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  /// 참여 불가 게임 여부
  bool get _isInactive => !game.status.isJoinable;

  /// 상단 행: LIVE + DAILY 뱃지, 우측 상태/숫자 뱃지
  Widget _buildTopRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 좌측: 상태 뱃지 + 타입 뱃지
        Row(
          children: [
            if (_isInactive) ...[
              _buildStatusBadge(),
              const SizedBox(width: 8),
            ] else if (isLive) ...[
              _buildLiveBadge(),
              const SizedBox(width: 8),
            ],
            _buildTypeBadge(),
          ],
        ),

        // 우측: 숫자 뱃지
        if (rankNumber != null) _buildRankBadge(),
      ],
    );
  }

  /// 상태 뱃지 (종료됨, 예정 등)
  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        game.status.badgeText,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// LIVE 뱃지 (빨간 점 + 텍스트)
  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  /// 타입 뱃지 (DAILY, SELECT, VIBE, PRIME)
  Widget _buildTypeBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeBadgeColor(),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        gameType.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// 우측 상단 숫자 뱃지
  Widget _buildRankBadge() {
    return Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.red,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          '$rankNumber',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }

  /// 하단 콘텐츠: 제목 + 플레이 버튼
  Widget _buildBottomContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 제목 (최대 2줄)
        Text(
          game.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.3,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 16),

        // 플레이 버튼
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _isInactive ? '결과 보기' : '${game.currentPrice}P PLAY',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkBlue,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                _isInactive ? Icons.visibility_outlined : Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.darkBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeBadgeColor() {
    switch (gameType.toLowerCase()) {
      case 'daily':
        return AppColors.blue;
      case 'select':
        return AppColors.green;
      case 'vibe':
        return AppColors.primaryLight;
      case 'prime':
        return AppColors.darkBlue;
      default:
        return AppColors.gray500;
    }
  }
}

/// 작은 프로모션 카드 (리스트용)
class PromotionCardSmall extends StatelessWidget {
  final GameRound game;
  final String gameType;
  final bool isLive;
  final VoidCallback? onTap;

  const PromotionCardSmall({
    super.key,
    required this.game,
    required this.gameType,
    this.isLive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 이미지
              _buildBackgroundImage(),

              // 그라데이션 오버레이
              _buildGradientOverlay(),

              // 콘텐츠
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 상단: 뱃지들
                    _buildBadges(),

                    const Spacer(),

                    // 하단: 제목 + 플레이 버튼
                    _buildBottomContent(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (game.imageUrl.isEmpty) {
      return Container(color: AppColors.gray700);
    }

    return Image.network(
      game.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(color: AppColors.gray700);
      },
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.black.withValues(alpha: 0.6),
          ],
        ),
      ),
    );
  }

  Widget _buildBadges() {
    return Row(
      children: [
        if (isLive) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeBadgeColor(),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            gameType.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          game.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            height: 1.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${game.currentPrice}P PLAY',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_rounded,
                size: 14,
                color: AppColors.darkBlue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getTypeBadgeColor() {
    switch (gameType.toLowerCase()) {
      case 'daily':
        return AppColors.blue;
      case 'select':
        return AppColors.green;
      case 'vibe':
        return AppColors.primaryLight;
      case 'prime':
        return AppColors.darkBlue;
      default:
        return AppColors.gray500;
    }
  }
}
