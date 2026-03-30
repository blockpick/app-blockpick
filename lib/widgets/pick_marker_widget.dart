import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../models/block_model.dart';
import '../models/pick_cluster_model.dart';
import '../utils/zoom_calculator.dart';

/// 픽 마커 위젯 (적응형)
///
/// 줌 레벨에 따라 다른 스타일의 마커를 표시
class PickMarkerWidget extends StatelessWidget {
  final BlockModel block;
  final double markerSize;
  final ZoomLevel zoomLevel;
  final bool isFocused;

  const PickMarkerWidget({
    super.key,
    required this.block,
    required this.markerSize,
    required this.zoomLevel,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    switch (zoomLevel) {
      case ZoomLevel.ultraZoomedOut:
      case ZoomLevel.zoomedOut:
        // 축소: 고정 크기 원형 마커
        return _buildCircleMarker();

      case ZoomLevel.medium:
      case ZoomLevel.zoomedIn:
      case ZoomLevel.ultraZoomedIn:
        // 확대: SVG 아이콘
        return _buildSvgMarker();
    }
  }

  /// 원형 마커 (축소 시)
  Widget _buildCircleMarker() {
    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        color: isFocused ? AppColors.yellow500 : AppColors.blue,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }

  /// SVG 아이콘 마커 (확대 시)
  Widget _buildSvgMarker() {
    String iconPath;

    if (isFocused) {
      iconPath = 'assets/icons/pick/list-selected.svg';
    } else {
      switch (block.state) {
        case BlockState.selected:
          iconPath = 'assets/icons/pick/selected.svg';
          break;
        case BlockState.past:
          iconPath = 'assets/icons/pick/past.svg';
          break;
        case BlockState.winner:
        case BlockState.unique:
        case BlockState.duplicate:
          iconPath = 'assets/icons/pick/selected.svg';
          break;
        default:
          iconPath = 'assets/icons/pick/selected.svg';
      }
    }

    return SizedBox(
      width: markerSize,
      height: markerSize,
      child: SvgPicture.asset(
        iconPath,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 클러스터 마커 위젯 (매우 축소 시)
class ClusterMarkerWidget extends StatelessWidget {
  final PickCluster cluster;
  final double markerSize;

  const ClusterMarkerWidget({
    super.key,
    required this.cluster,
    required this.markerSize,
  });

  @override
  Widget build(BuildContext context) {
    if (cluster.isSingle) {
      // 단일 픽: 일반 마커
      return PickMarkerWidget(
        block: cluster.firstPick,
        markerSize: markerSize,
        zoomLevel: ZoomLevel.ultraZoomedOut,
      );
    }

    // 다중 픽: 숫자 배지
    return _buildClusterBadge();
  }

  Widget _buildClusterBadge() {
    // 픽 개수에 따른 색상
    Color backgroundColor;
    if (cluster.picks.length <= 3) {
      backgroundColor = AppColors.blue;
    } else if (cluster.picks.length <= 10) {
      backgroundColor = AppColors.blue.withOpacity(0.8);
    } else {
      backgroundColor = AppColors.darkBlue;
    }

    return Container(
      width: markerSize,
      height: markerSize,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.white,
          width: 2.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.4),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          cluster.label,
          style: AppTextStyles.body4.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.w700,
            fontSize: _getTextSize(),
          ),
        ),
      ),
    );
  }

  double _getTextSize() {
    // 마커 크기에 따라 텍스트 크기 조정
    if (markerSize >= 28) {
      return 11.0;
    } else if (markerSize >= 24) {
      return 10.0;
    } else {
      return 8.0;
    }
  }
}

/// 펄스 애니메이션 마커 (포커스 시)
class PulsingMarkerWidget extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const PulsingMarkerWidget({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<PulsingMarkerWidget> createState() => _PulsingMarkerWidgetState();
}

class _PulsingMarkerWidgetState extends State<PulsingMarkerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.8).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.7, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulsingMarkerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // 펄스 효과
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.yellow500,
                      width: 3.0,
                    ),
                  ),
                ),
              ),
            );
          },
        ),

        // 실제 마커
        widget.child,
      ],
    );
  }
}
