import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/game_round_model.dart';

/// Coming Soon 아이템 카드
/// 흰색 배경 + 민트색 이미지 영역 + 태그 + 정보 + 프로그레스바 + 타이머
class ComingSoonItemCard extends StatefulWidget {
  final GameRound game;
  final String gameType; // daily, select, vibe
  final bool isLastChance;
  final VoidCallback? onTap;

  const ComingSoonItemCard({
    super.key,
    required this.game,
    required this.gameType,
    this.isLastChance = false,
    this.onTap,
  });

  @override
  State<ComingSoonItemCard> createState() => _ComingSoonItemCardState();
}

class _ComingSoonItemCardState extends State<ComingSoonItemCard> {
  Timer? _timer;
  Duration _remainingTime = const Duration(minutes: 30);
  final Duration _totalTime = const Duration(hours: 1);

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

  double get _progress {
    if (_totalTime.inSeconds == 0) return 0;
    return _remainingTime.inSeconds / _totalTime.inSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // 상단: 이미지 + 정보
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상품 이미지 (민트색 배경)
                _buildProductImage(),
                const SizedBox(width: 12),
                // 정보 영역
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 태그들
                      _buildTags(),
                      const SizedBox(height: 8),
                      // 제목
                      _buildTitle(),
                      const SizedBox(height: 8),
                      // 가격, 참여자, 사이즈
                      _buildInfoRow(),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // 하단: 프로그레스바 + 타이머
            _buildProgressAndTimer(),
          ],
        ),
      ),
    );
  }

  /// 상품 이미지 (민트색 배경)
  Widget _buildProductImage() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE0F2F1), // 민트색 배경
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: widget.game.imageUrl.isNotEmpty
            ? Image.network(
                widget.game.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: const Color(0xFFE0F2F1),
      child: Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          size: 32,
          color: const Color(0xFF80CBC4),
        ),
      ),
    );
  }

  /// 태그들 (DAILY + LAST CHANCE)
  Widget _buildTags() {
    return Row(
      children: [
        // 게임 타입 태그
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getTypeBadgeColor(),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            widget.gameType.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        if (widget.isLastChance) ...[
          const SizedBox(width: 6),
          // LAST CHANCE 태그
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'LAST CHANCE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE91E63),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// 제목
  Widget _buildTitle() {
    return Text(
      widget.game.title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF212121),
        height: 1.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// 정보 행 (가격, 참여자, 사이즈)
  Widget _buildInfoRow() {
    return Row(
      children: [
        // 가격
        _buildInfoChip(
          icon: Icons.monetization_on_outlined,
          value: '${widget.game.currentPrice}',
        ),
        const SizedBox(width: 12),
        // 참여자 수
        _buildInfoChip(
          icon: Icons.people_outline,
          value: _formatNumber(widget.game.participants),
        ),
        const SizedBox(width: 12),
        // 그리드 사이즈
        _buildInfoChip(
          icon: Icons.grid_view_outlined,
          value: '${widget.game.actualGridWidth}×${widget.game.actualGridHeight}',
        ),
      ],
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 14,
          color: AppColors.gray500,
        ),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  /// 프로그레스바 + 타이머
  Widget _buildProgressAndTimer() {
    return Row(
      children: [
        // 프로그레스바
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray200,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF26A69A),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // 타이머
        Text(
          '${_formatDuration(_remainingTime)} 남음',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray500,
          ),
        ),
      ],
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
        return const Color(0xFF2196F3);
      case 'select':
        return const Color(0xFF4CAF50);
      case 'vibe':
        return const Color(0xFF9C27B0);
      case 'prime':
        return const Color(0xFF1A237E);
      default:
        return AppColors.gray500;
    }
  }
}
