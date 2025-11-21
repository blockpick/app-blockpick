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

  /// 기본 블록 (애니메이션 제거)
  Widget _build3DRotatedBlock({
    required Widget child,
    required int index,
    required int currentIndex,
  }) {
    return child;
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
            physics: const FixedExtentScrollPhysics(), // 중앙 스냅
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
