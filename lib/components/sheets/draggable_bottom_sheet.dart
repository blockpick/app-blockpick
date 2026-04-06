import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// 재사용 가능한 드래그 가능 바텀시트 컴포넌트
///
/// 모바일(터치)과 웹(마우스) 모두 지원하는 범용 바텀시트
///
/// 사용 예시:
/// ```dart
/// DraggableBottomSheet(
///   header: Text('Header'),
///   footer: ElevatedButton(...),
///   children: [Widget1(), Widget2()],
///   onClose: () { /* 닫힐 때 로직 */ },
/// )
/// ```
class DraggableBottomSheet extends StatefulWidget {
  /// 바텀시트 헤더 위젯
  final Widget? header;

  /// 바텀시트 하단 고정 위젯 (버튼 등)
  final Widget? footer;

  /// 스크롤 가능한 내용 위젯 리스트
  final List<Widget> children;

  /// 바텀시트 초기 크기 (0.0 ~ 1.0)
  final double initialChildSize;

  /// 바텀시트 최소 크기 (0.0 ~ 1.0)
  final double minChildSize;

  /// 바텀시트 최대 크기 (0.0 ~ 1.0)
  final double maxChildSize;

  /// 스냅 크기 리스트
  final List<double> snapSizes;

  /// 바텀시트가 닫힐 때 호출되는 콜백 (minChildSize 이하로 드래그시)
  final VoidCallback? onClose;

  /// 드래그 핸들 표시 여부
  final bool showHandle;

  const DraggableBottomSheet({
    super.key,
    this.header,
    this.footer,
    required this.children,
    this.initialChildSize = 0.4,
    this.minChildSize = 0.1,
    this.maxChildSize = 0.7,
    this.snapSizes = const [0.4, 0.7],
    this.onClose,
    this.showHandle = true,
  });

  @override
  State<DraggableBottomSheet> createState() => _DraggableBottomSheetState();
}

class _DraggableBottomSheetState extends State<DraggableBottomSheet> {
  final DraggableScrollableController _controller = DraggableScrollableController();
  double? _dragStartY;
  double? _dragStartSize;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onSheetSizeChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onSheetSizeChanged);
    _controller.dispose();
    super.dispose();
  }

  /// 바텀시트 크기 변경 감지하여 일정 크기 이하면 닫기 콜백 호출
  void _onSheetSizeChanged() {
    // minChildSize에 도달하면 닫기 (약간의 threshold 추가)
    if (_controller.isAttached && _controller.size <= widget.minChildSize + 0.01) {
      // 닫기 콜백을 다음 프레임에 호출하여 부드러운 애니메이션 보장
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onClose?.call();
      });
    }
  }

  /// 마우스/터치 드래그 시작
  void _onDragStart(double globalY) {
    _dragStartY = globalY;
    _dragStartSize = _controller.size;
  }

  /// 마우스/터치 드래그 업데이트
  void _onDragUpdate(double globalY, double screenHeight) {
    if (_dragStartY != null && _dragStartSize != null) {
      final delta = _dragStartY! - globalY;
      final sizeDelta = delta / screenHeight;
      final newSize = (_dragStartSize! + sizeDelta).clamp(
        widget.minChildSize,
        widget.maxChildSize,
      );

      if (_controller.isAttached) {
        _controller.jumpTo(newSize);
      }
    }
  }

  /// 마우스/터치 드래그 종료
  void _onDragEnd() {
    if (_controller.isAttached) {
      // 가장 가까운 snap size로 애니메이션
      final currentSize = _controller.size;
      final snapSize = _findNearestSnapSize(currentSize);

      if ((currentSize - snapSize).abs() > 0.01) {
        _controller.animateTo(
          snapSize,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    }

    _dragStartY = null;
    _dragStartSize = null;
  }

  /// 현재 크기에서 가장 가까운 snap size 찾기
  double _findNearestSnapSize(double currentSize) {
    if (widget.snapSizes.isEmpty) {
      return currentSize;
    }

    double nearest = widget.snapSizes.first;
    double minDiff = (currentSize - nearest).abs();

    for (final snapSize in widget.snapSizes) {
      final diff = (currentSize - snapSize).abs();
      if (diff < minDiff) {
        minDiff = diff;
        nearest = snapSize;
      }
    }

    return nearest;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      controller: _controller,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      snap: true,
      snapSizes: widget.snapSizes,
      shouldCloseOnMinExtent: false,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radius2Xl),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.textBlack.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 드래그 핸들 (상단 고정)
              if (widget.showHandle) _buildDragHandle(),

              // 헤더 (상단 고정)
              if (widget.header != null) widget.header!,

              // 스크롤 가능한 내용 (중간 영역)
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: widget.children.length,
                  itemBuilder: (context, index) => widget.children[index],
                ),
              ),

              // 하단 고정 버튼
              if (widget.footer != null)
                SafeArea(
                  top: false,
                  child: Container(
                    padding: const EdgeInsets.all(AppConstants.spacingLg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      border: Border(
                        top: BorderSide(
                          color: AppColors.gray200.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: widget.footer!,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  /// 드래그 핸들 위젯 (마우스와 터치 모두 지원)
  Widget _buildDragHandle() {
    return GestureDetector(
      onVerticalDragStart: (details) {
        _onDragStart(details.globalPosition.dy);
      },
      onVerticalDragUpdate: (details) {
        _onDragUpdate(
          details.globalPosition.dy,
          MediaQuery.of(context).size.height,
        );
      },
      onVerticalDragEnd: (details) {
        _onDragEnd();
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.grab,
        child: Container(
          // 드래그 영역 확대 (전체 너비)
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingMd),
          child: Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
