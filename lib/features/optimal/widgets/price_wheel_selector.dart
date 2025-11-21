import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import 'price_block_item.dart';

/// 가격 선택 휠 위젯
///
/// ListWheelScrollView를 사용하여 회전하는 휠 형태로
/// 가격을 선택할 수 있는 인터페이스를 제공합니다.
class PriceWheelSelector extends ConsumerStatefulWidget {
  final List<int> prices;
  final int? selectedPrice;
  final Function(int) onPriceSelected;
  final double height;
  final String? backgroundImageUrl;

  const PriceWheelSelector({
    super.key,
    required this.prices,
    required this.onPriceSelected,
    this.selectedPrice,
    this.height = 400,
    this.backgroundImageUrl,
  });

  @override
  ConsumerState<PriceWheelSelector> createState() => _PriceWheelSelectorState();
}

class _PriceWheelSelectorState extends ConsumerState<PriceWheelSelector> {
  late FixedExtentScrollController _scrollController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // 초기 선택된 가격이 있으면 해당 인덱스로 스크롤
    if (widget.selectedPrice != null) {
      _currentIndex = widget.prices.indexOf(widget.selectedPrice!);
      if (_currentIndex == -1) _currentIndex = 0;
    }

    _scrollController = FixedExtentScrollController(initialItem: _currentIndex);
  }

  @override
  void didUpdateWidget(PriceWheelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // selectedPrice가 변경되면 부드럽게 스크롤
    if (widget.selectedPrice != oldWidget.selectedPrice &&
        widget.selectedPrice != null) {
      final newIndex = widget.prices.indexOf(widget.selectedPrice!);
      if (newIndex != -1 && newIndex != _currentIndex) {
        _currentIndex = newIndex;
        // 부드럽게 애니메이션으로 이동
        _scrollController.animateToItem(
          newIndex,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 자석 효과가 적용된 블록 (중력 반전 + 왜곡)
  Widget _build3DRotatedBlock({
    required Widget child,
    required int index,
    required int currentIndex,
  }) {
    // 현재 인덱스와의 거리
    final distance = (index - currentIndex).toDouble();
    final absDistance = distance.abs();

    // 자석 효과: 중앙에 가까울수록 강하게 끌림
    final magneticPull = (1.0 - (absDistance * 0.3).clamp(0.0, 1.0));

    // 스케일: 중앙으로 올수록 커짐 (자석에 끌려 늘어나는 느낌)
    final scale = 0.85 + (magneticPull * 0.15);

    // Y축 이동: 자석에 끌려오는 효과
    final magneticOffset = -absDistance * 5.0 + (magneticPull * 8.0);

    // 회전: 자기장에 의해 약간 기울어짐
    final rotation = distance * 0.1;

    // Wobbly 왜곡: 중앙에 가까울수록 X축으로 찌그러짐
    final scaleX = 1.0 + (magneticPull * 0.05);
    final scaleY = 1.0 - (magneticPull * 0.03);

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001) // 원근감
        ..translate(0.0, magneticOffset) // 자석 끌림
        ..rotateX(rotation) // 자기장 회전
        ..scale(scaleX * scale, scaleY * scale, scale),
      alignment: Alignment.center,
      child: _FloatingBlock(
        distance: absDistance,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 상품 이미지 (블러 처리)
        if (widget.backgroundImageUrl != null)
          Positioned.fill(
            child: ClipRRect(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // 상품 이미지
                  Image.asset(
                    widget.backgroundImageUrl!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                  // 블러 효과
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: Container(
                      color: AppColors.deepWhite.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // 자기장 파장 효과 (애니메이션 오라)
        Positioned.fill(
          child: Center(
            child: _MagneticFieldEffect(),
          ),
        ),

        // 중앙 포커스 인디케이터 (Isometric 블록 테두리)
        Positioned.fill(
          child: Center(
            child: Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              child: CustomPaint(
                painter: _FocusBlockBorderPainter(),
              ),
            ),
          ),
        ),

        // 휠 스크롤 뷰 (3D 블록 스타일)
        SizedBox(
          height: widget.height,
          child: ListWheelScrollView.useDelegate(
            controller: _scrollController,
            itemExtent: 100, // 각 블록 높이 (3D 효과를 위해 증가)
            diameterRatio: 1.2, // 휠 직경 (작을수록 3D 효과 강함)
            perspective: 0.004, // 3D 원근감 증가
            physics: const FixedExtentScrollPhysics(),
            onSelectedItemChanged: (index) {
              setState(() {
                _currentIndex = index;
              });

              // 선택된 가격 콜백
              widget.onPriceSelected(widget.prices[index]);

              // 햅틱 피드백
              // HapticFeedback.selectionClick();
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: widget.prices.length,
              builder: (context, index) {
                final price = widget.prices[index];
                final isSelected = widget.selectedPrice == price;
                final isFocused = _currentIndex == index;

                // 3D 회전 효과 추가
                return _build3DRotatedBlock(
                  child: PriceBlockItem(
                    price: price,
                    isSelected: isSelected,
                    isFocused: isFocused,
                  ),
                  index: index,
                  currentIndex: _currentIndex,
                );
              },
            ),
          ),
        ),

        // 상단 그라데이션 페이드
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 80,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.deepWhite,
                    AppColors.deepWhite.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 하단 그라데이션 페이드
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 80,
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.deepWhite,
                    AppColors.deepWhite.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 떠다니는 블록 애니메이션 (자기장 부유 효과)
class _FloatingBlock extends StatefulWidget {
  final Widget child;
  final double distance;

  const _FloatingBlock({
    required this.child,
    required this.distance,
  });

  @override
  State<_FloatingBlock> createState() => _FloatingBlockState();
}

class _FloatingBlockState extends State<_FloatingBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();

    // 떠다니는 애니메이션 (사인파 움직임)
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000 + (widget.distance * 200).toInt()),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(
      begin: -3.0,
      end: 3.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatAnimation.value),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 자기장 파장 효과 (중앙 주변 애니메이션 오라)
class _MagneticFieldEffect extends StatefulWidget {
  const _MagneticFieldEffect();

  @override
  State<_MagneticFieldEffect> createState() => _MagneticFieldEffectState();
}

class _MagneticFieldEffectState extends State<_MagneticFieldEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 파장이 퍼져나가는 애니메이션
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _MagneticFieldPainter(
            animation: _controller.value,
          ),
          size: const Size(double.infinity, 100),
        );
      },
    );
  }
}

/// 자기장 파장 페인터
class _MagneticFieldPainter extends CustomPainter {
  final double animation;

  _MagneticFieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.5;

    // 3개의 파장 레이어 (시간차를 두고 퍼짐)
    for (int i = 0; i < 3; i++) {
      final phase = (animation + (i * 0.33)) % 1.0;
      final radius = maxRadius * phase;
      final opacity = (1.0 - phase) * 0.3;

      // 파장 원형
      final paint = Paint()
        ..color = AppColors.purple.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 0.6, // 타원형 (Isometric 느낌)
        ),
        paint,
      );

      // 내부 글로우 효과
      final glowPaint = Paint()
        ..color = AppColors.blue.withValues(alpha: opacity * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2,
          height: radius * 0.6,
        ),
        glowPaint,
      );
    }

    // 중앙 자기장 코어 (맥동 효과)
    final coreSize = 40.0 + (10.0 * (0.5 + 0.5 * math.sin(animation * 6.28)));
    final corePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.purple.withValues(alpha: 0.4),
          AppColors.blue.withValues(alpha: 0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCenter(
        center: center,
        width: coreSize * 2,
        height: coreSize * 2,
      ))
      ..style = PaintingStyle.fill;

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: coreSize * 2,
        height: coreSize * 0.6,
      ),
      corePaint,
    );
  }

  @override
  bool shouldRepaint(_MagneticFieldPainter oldDelegate) {
    return oldDelegate.animation != animation;
  }
}

/// 중앙 포커스 블록 테두리 페인터
class _FocusBlockBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final blockDepth = 16.0; // Isometric 깊이
    final paint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    // Isometric 블록 테두리 경로
    final path = Path();

    // 상단 면 테두리
    path.moveTo(0, blockDepth);
    path.lineTo(blockDepth, 0);
    path.lineTo(size.width - blockDepth, 0);
    path.lineTo(size.width, blockDepth);

    // 왼쪽 세로 라인
    path.moveTo(0, blockDepth);
    path.lineTo(0, size.height);

    // 오른쪽 세로 라인
    path.moveTo(size.width, blockDepth);
    path.lineTo(size.width, size.height);

    // 하단 라인
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);

    canvas.drawPath(path, paint);

    // 내부 하이라이트 (선택 영역 강조)
    final innerPaint = Paint()
      ..color = AppColors.purple.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final innerPath = Path()
      ..moveTo(0, blockDepth)
      ..lineTo(blockDepth, 0)
      ..lineTo(size.width - blockDepth, 0)
      ..lineTo(size.width, blockDepth)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(innerPath, innerPaint);
  }

  @override
  bool shouldRepaint(_FocusBlockBorderPainter oldDelegate) => false;
}
