import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/game_round_model.dart';

/// Coming Soon 글래스모피즘 카드
/// 전체 카드를 덮는 블러 오버레이 (상품 정보도 블러 뒤에)
class ComingSoonOverlayCard extends StatefulWidget {
  final GameRound game;
  final String gameType;
  final VoidCallback? onTap;

  const ComingSoonOverlayCard({
    super.key,
    required this.game,
    required this.gameType,
    this.onTap,
  });

  @override
  State<ComingSoonOverlayCard> createState() => _ComingSoonOverlayCardState();
}

class _ComingSoonOverlayCardState extends State<ComingSoonOverlayCard> {
  Timer? _timer;
  Duration _remainingTime = const Duration(hours: 2);

  @override
  void initState() {
    super.initState();
    _parseTimeLeft();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _parseTimeLeft() {
    final timeLeft = widget.game.timeLeft;
    if (timeLeft.contains(':')) {
      final parts = timeLeft.split(':');
      if (parts.length == 3) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = int.tryParse(parts[2]) ?? 0;
        _remainingTime = Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime.inSeconds > 0) {
        setState(() {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 180,
        margin: const EdgeInsets.only(bottom: AppConstants.spacingLg),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.textBlack.withValues(alpha: 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. 배경 이미지
              _buildBackgroundImage(),
              // 2. 하단 정보 (블러될 콘텐츠)
              _buildBottomInfoBehindBlur(),
              // 3. 전체 글래스모피즘 오버레이
              _buildFullGlassOverlay(),
              // 4. 상단 태그 (오버레이 위)
              _buildTopTag(),
              // 5. 중앙 COMING SOON + 타이머 (오버레이 위)
              _buildCenterContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    if (widget.game.imageUrl.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.primaryBg, AppColors.gray200],
          ),
        ),
      );
    }

    return Image.network(
      widget.game.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primaryBg, AppColors.gray200],
            ),
          ),
        );
      },
    );
  }

  /// 하단 정보 (블러 뒤에 표시될 콘텐츠)
  Widget _buildBottomInfoBehindBlur() {
    return Positioned(
      left: AppConstants.spacingLg,
      right: AppConstants.spacingLg,
      bottom: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            widget.game.title,
            style: AppTextStyles.title2.copyWith(
              color: AppColors.textBlack,
              height: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // 정보
          Row(
            children: [
              _buildInfoItemBehind(Icons.monetization_on_rounded, '${widget.game.currentPrice}'),
              const SizedBox(width: 14),
              _buildInfoItemBehind(Icons.people_rounded, _formatNumber(widget.game.participants)),
              const SizedBox(width: 14),
              _buildInfoItemBehind(
                Icons.grid_view_rounded,
                '${widget.game.actualGridWidth}×${widget.game.actualGridHeight}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItemBehind(IconData icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.gray600),
        const SizedBox(width: AppConstants.spacingXs),
        Text(
          value,
          style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }

  /// 전체 카드를 덮는 글래스모피즘 오버레이
  Widget _buildFullGlassOverlay() {
    return Positioned.fill(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.white.withValues(alpha: 0.4),
                  AppColors.white.withValues(alpha: 0.6),
                ],
              ),
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.5),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
            ),
          ),
        ),
      ),
    );
  }

  /// 상단 태그 (오버레이 위)
  Widget _buildTopTag() {
    return Positioned(
      top: 14,
      left: 14,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingMd,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: _getTypeBadgeColor(),
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          boxShadow: [
            BoxShadow(
              color: _getTypeBadgeColor().withValues(alpha: 0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          widget.gameType.toUpperCase(),
          style: AppTextStyles.caption4.copyWith(
            color: AppColors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// 중앙 COMING SOON + 타이머 (오버레이 위)
  Widget _buildCenterContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // COMING SOON 텍스트
          Text(
            'COMING SOON',
            style: AppTextStyles.caption2.copyWith(
              color: AppColors.gray800.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 6),
          // 타이머
          Text(
            _formatDuration(_remainingTime),
            style: AppTextStyles.display1.copyWith(
              color: AppColors.textBlack,
              letterSpacing: 2,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 10000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Color _getTypeBadgeColor() {
    switch (widget.gameType.toLowerCase()) {
      case 'daily':
        return AppColors.blue;
      case 'select':
        return AppColors.green500;
      case 'vibe':
        return AppColors.primaryLight;
      case 'prime':
        return AppColors.primaryDark;
      default:
        return AppColors.gray400;
    }
  }
}
