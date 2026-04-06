import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../models/wish_model.dart';

/// 틴더 스타일 위시 카드 스택
class WishCardStack extends StatefulWidget {
  final List<Wish> wishes;
  final void Function(Wish wish) onTap;
  final void Function(Wish wish) onBuzzTap;

  const WishCardStack({
    super.key,
    required this.wishes,
    required this.onTap,
    required this.onBuzzTap,
  });

  @override
  State<WishCardStack> createState() => _WishCardStackState();
}

class _WishCardStackState extends State<WishCardStack>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  Offset _dragOffset = Offset.zero;
  double _dragAngle = 0;
  late AnimationController _swipeController;
  late AnimationController _resetController;
  Offset _swipeTarget = Offset.zero;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _swipeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..addStatusListener(_onSwipeComplete);
    _resetController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
  }

  @override
  void dispose() {
    _swipeController.dispose();
    _resetController.dispose();
    super.dispose();
  }

  void _onSwipeComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      setState(() {
        _currentIndex++;
        _dragOffset = Offset.zero;
        _dragAngle = 0;
        _isAnimating = false;
      });
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isAnimating) return;
    setState(() {
      _dragOffset += details.delta;
      _dragAngle = _dragOffset.dx * 0.001; // 약간의 회전
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isAnimating) return;
    final velocity = details.velocity.pixelsPerSecond.dx;
    final dx = _dragOffset.dx;

    if (dx > 100 || velocity > 600) {
      // 오른쪽 스와이프 → 소문내기
      _swipeAway(true);
      if (_currentIndex < widget.wishes.length) {
        widget.onBuzzTap(widget.wishes[_currentIndex]);
      }
    } else if (dx < -100 || velocity < -600) {
      // 왼쪽 스와이프 → 스킵
      _swipeAway(false);
    } else {
      // 리셋
      _resetCard();
    }
  }

  void _swipeAway(bool toRight) {
    _isAnimating = true;
    _swipeTarget = Offset(toRight ? 500 : -500, _dragOffset.dy);
    _swipeController.forward(from: 0);
  }

  void _resetCard() {
    final startOffset = _dragOffset;
    final startAngle = _dragAngle;
    _resetController.forward(from: 0).then((_) {
      if (mounted) {
        setState(() {
          _dragOffset = Offset.zero;
          _dragAngle = 0;
        });
      }
    });
    _resetController.addListener(() {
      if (mounted) {
        setState(() {
          final t = Curves.easeOut.transform(_resetController.value);
          _dragOffset = Offset.lerp(startOffset, Offset.zero, t)!;
          _dragAngle = startAngle * (1 - t);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= widget.wishes.length) {
      return _buildEndState();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // 뒤쪽 카드들 (최대 2장)
            for (int i = min(_currentIndex + 2, widget.wishes.length - 1);
                i > _currentIndex;
                i--)
              _buildBackCard(i - _currentIndex, constraints),

            // 맨 앞 카드 (드래그 가능)
            _buildFrontCard(constraints),

            // 스와이프 인디케이터
            if (_dragOffset.dx.abs() > 30) _buildSwipeIndicator(),
          ],
        );
      },
    );
  }

  Widget _buildBackCard(int stackIndex, BoxConstraints constraints) {
    final scale = 1.0 - (stackIndex * 0.05);
    final translateY = stackIndex * 12.0;
    return Transform.translate(
      offset: Offset(0, translateY * scale),
      child: Transform.scale(
        scale: scale,
        child: Opacity(
        opacity: 1.0 - (stackIndex * 0.2),
        child: IgnorePointer(
          child: _WishStackCard(
            wish: widget.wishes[_currentIndex + stackIndex],
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildFrontCard(BoxConstraints constraints) {
    Offset offset = _dragOffset;
    double angle = _dragAngle;

    if (_swipeController.isAnimating) {
      final t = Curves.easeIn.transform(_swipeController.value);
      offset = Offset.lerp(_dragOffset, _swipeTarget, t)!;
      angle = _dragAngle + (_swipeTarget.dx > 0 ? 0.2 : -0.2) * t;
    }

    return GestureDetector(
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      onTap: () => widget.onTap(widget.wishes[_currentIndex]),
      child: Transform.translate(
        offset: offset,
        child: Transform.rotate(
          angle: angle,
          child: _WishStackCard(
            wish: widget.wishes[_currentIndex],
            showSwipeHint: _dragOffset == Offset.zero && !_isAnimating,
          ),
        ),
      ),
    );
  }

  Widget _buildSwipeIndicator() {
    final isRight = _dragOffset.dx > 0;
    final opacity = min((_dragOffset.dx.abs() - 30) / 70, 1.0);
    return Positioned(
      top: 40,
      left: isRight ? 24 : null,
      right: isRight ? null : 24,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isRight
                ? AppColors.primaryMain.withValues(alpha: 0.9)
                : AppColors.gray800.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            border: Border.all(
              color: isRight
                  ? AppColors.white.withValues(alpha: 0.3)
                  : AppColors.gray400.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isRight ? Icons.auto_awesome : Icons.close_rounded,
                size: 20,
                color: AppColors.white,
              ),
              const SizedBox(width: 6),
              Text(
                isRight ? '소문내기' : 'SKIP',
                style: AppTextStyles.title2.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEndState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryBg,
                    shape: BoxShape.circle,
                  ),
                ),
                const Text('🎉', style: TextStyle(fontSize: 36)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '모든 소원을 확인했어요!',
            style: AppTextStyles.heading3.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '새로운 소원이 올라오면 알려드릴게요',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () => setState(() => _currentIndex = 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primaryMain, width: 1.5),
                borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
              ),
              child: Text(
                '처음부터 다시 보기',
                style: AppTextStyles.button.copyWith(color: AppColors.primaryMain),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 스택 카드 — 컴팩트 카드 UI
class _WishStackCard extends StatelessWidget {
  final Wish wish;
  final bool showSwipeHint;

  const _WishStackCard({
    required this.wish,
    this.showSwipeHint = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth - 48;

    return Container(
      width: cardWidth,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        boxShadow: [
          BoxShadow(
            color: AppColors.textBlack.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지
            _buildImage(),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 + 작성자
                  Row(
                    children: [
                      Text(
                        '${wish.category.emoji} ${wish.category.label.split('/').first}',
                        style: AppTextStyles.caption2.copyWith(color: AppColors.gray400),
                      ),
                      const Spacer(),
                      Text(
                        '@${wish.userName ?? ''}',
                        style: AppTextStyles.caption1.copyWith(color: AppColors.gray400),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 한줄평
                  Text(
                    wish.oneLiner,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.title1.copyWith(
                      color: AppColors.textBlack,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 상품명 + 가격
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Expanded(
                        child: Text(
                          wish.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption1.copyWith(color: AppColors.gray600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_formatPrice(wish.productPrice)}원',
                        style: AppTextStyles.title1.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 통계 칩
                  Row(
                    children: [
                      _buildStatChip(Icons.favorite_rounded, '${wish.empathyCount}', AppColors.red.withValues(alpha: 0.7)),
                      const SizedBox(width: 6),
                      _buildStatChip(Icons.people_rounded, _formatCount(wish.participantCount), AppColors.gray400),
                      if (wish.isBusinessWish && wish.prizeDescription != null) ...[
                        const SizedBox(width: 6),
                        _buildStatChip(Icons.card_giftcard_rounded, '${_formatPrice(wish.prizeValue ?? 0)}원', AppColors.orange),
                      ],
                    ],
                  ),
                  // 업체 프로그레스
                  if (wish.isBusinessWish) ...[
                    const SizedBox(height: 12),
                    _buildCompactProgress(),
                  ],
                  // 스와이프 힌트
                  if (showSwipeHint) ...[
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swipe_rounded, size: 15, color: AppColors.gray400.withValues(alpha: 0.5)),
                        const SizedBox(width: 5),
                        Text(
                          '밀어서 소문내기 · 탭하여 상세보기',
                          style: AppTextStyles.caption1.copyWith(color: AppColors.gray400.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: 200,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            wish.productImageUrl,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return _buildPlaceholder(isLoading: true);
            },
          ),
          // 업체 배지
          if (wish.isBusinessWish)
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientDarkPurple,
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.campaign_rounded, size: 12, color: AppColors.white),
                    const SizedBox(width: 4),
                    Text(
                      wish.businessName ?? 'BRAND',
                      style: AppTextStyles.caption2.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          // 참여비 (좌하단)
          Positioned(
            left: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: wish.isBusinessWish
                    ? AppColors.primaryMain.withValues(alpha: 0.9)
                    : AppColors.textBlack.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
              ),
              child: Text(
                wish.isBusinessWish ? '✨ 무료' : '✨ 10원',
                style: AppTextStyles.caption2.copyWith(color: AppColors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder({bool isLoading = false}) {
    final colors = _categoryColors(wish.category);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colors[0].withValues(alpha: 0.15), colors[1].withValues(alpha: 0.08)],
        ),
      ),
      child: Center(
        child: isLoading
            ? SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: colors[0].withValues(alpha: 0.4)))
            : Text(wish.category.emoji, style: const TextStyle(fontSize: 48)),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color iconColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: iconColor),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.caption2.copyWith(color: AppColors.gray600)),
        ],
      ),
    );
  }

  Widget _buildCompactProgress() {
    final progress = wish.exposureProgress;
    return Row(
      children: [
        Text('소문 달성률', style: AppTextStyles.caption4.copyWith(color: AppColors.gray400)),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation(progress > 0.7 ? AppColors.primaryMain : AppColors.primaryLight),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${(progress * 100).toInt()}%',
          style: AppTextStyles.caption2.copyWith(color: AppColors.primaryMain, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final remainder = price % 10000;
      if (remainder == 0) return '$man만';
      return '$man만${_numberWithComma(remainder)}';
    }
    return _numberWithComma(price);
  }

  String _formatCount(int count) {
    if (count >= 10000) return '${(count / 10000).toStringAsFixed(1)}만';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return '$count';
  }

  String _numberWithComma(int n) {
    return n.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}

List<Color> _categoryColors(WishCategory category) {
  switch (category) {
    case WishCategory.food:
      return [AppColors.orange, AppColors.yellow500];
    case WishCategory.beauty:
      return [AppColors.pink, AppColors.red200];
    case WishCategory.fashion:
      return [AppColors.primaryDark, AppColors.primaryLight];
    case WishCategory.electronics:
      return [AppColors.gray800, AppColors.gray600];
    case WishCategory.figure:
      return [AppColors.primaryMain, AppColors.primaryBg];
    case WishCategory.travel:
      return [AppColors.blue, AppColors.blue200];
    case WishCategory.lifestyle:
      return [AppColors.green500, AppColors.green200];
    case WishCategory.etc:
      return [AppColors.gray400, AppColors.gray200];
  }
}
