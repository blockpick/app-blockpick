import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

/// Zoom 컨트롤 버튼
class ZoomControls extends StatelessWidget {
  /// Zoom In 콜백
  final VoidCallback? onZoomIn;

  /// Zoom Out 콜백
  final VoidCallback? onZoomOut;

  /// 현재 레벨
  final int? currentLevel;

  /// 최대 레벨
  final int? maxLevel;

  /// 최소 레벨
  final int? minLevel;

  /// LOD (Level of Detail) 레벨
  final int? lodLevel;

  /// 투명도
  final double opacity;

  const ZoomControls({
    super.key,
    this.onZoomIn,
    this.onZoomOut,
    this.currentLevel,
    this.maxLevel,
    this.minLevel,
    this.lodLevel,
    this.opacity = 0.75,
  });

  /// 줌 라벨: MIN / MAX / NX (기획 SC-009-16)
  String _getZoomLabel() {
    if (currentLevel == null || minLevel == null || maxLevel == null) return '';
    if (currentLevel! <= minLevel!) return 'MIN';
    if (currentLevel! >= maxLevel!) return 'MAX';
    final relativeLevel = currentLevel! - minLevel!;
    // 배율 매핑: 레벨 0=1X, 1=2X, 2=5X, 3=10X, 4=20X, 5=50X, ...
    const multipliers = [1, 2, 5, 10, 20, 50, 100, 200, 500];
    final idx = relativeLevel.clamp(0, multipliers.length - 1);
    return '${multipliers[idx]}X';
  }

  @override
  Widget build(BuildContext context) {
    final canZoomIn = maxLevel == null || currentLevel == null || currentLevel! < maxLevel!;
    final canZoomOut = minLevel == null || currentLevel == null || currentLevel! > minLevel!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In
          IconButton(
            onPressed: canZoomIn ? onZoomIn : null,
            icon: Icon(LucideIcons.plus),
            color: canZoomIn ? AppColors.darkBlue : AppColors.gray200,
            iconSize: 22,
            padding: const EdgeInsets.all(12),
          ),

          // 배율 라벨 (MIN / MAX / NX)
          if (currentLevel != null && minLevel != null && maxLevel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                _getZoomLabel(),
                style: AppTextStyles.caption3.copyWith(color: AppColors.darkBlue),
              ),
            ),

          // Zoom Out
          IconButton(
            onPressed: canZoomOut ? onZoomOut : null,
            icon: const Icon(LucideIcons.minus),
            color: canZoomOut ? AppColors.darkBlue : AppColors.gray200,
            iconSize: 22,
            padding: const EdgeInsets.all(12),
          ),
        ],
      ),
    );
  }
}

/// Horizontal Zoom Controls (가로 버전)
class HorizontalZoomControls extends StatelessWidget {
  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final int? currentLevel;
  final int? maxLevel;
  final int? minLevel;
  final int? lodLevel;
  final double opacity;

  const HorizontalZoomControls({
    super.key,
    this.onZoomIn,
    this.onZoomOut,
    this.currentLevel,
    this.maxLevel,
    this.minLevel,
    this.lodLevel,
    this.opacity = 0.75,
  });

  @override
  Widget build(BuildContext context) {
    final canZoomIn = maxLevel == null || currentLevel == null || currentLevel! < maxLevel!;
    final canZoomOut = minLevel == null || currentLevel == null || currentLevel! > minLevel!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom Out
          IconButton(
            onPressed: canZoomOut ? onZoomOut : null,
            icon: const Icon(LucideIcons.minus),
            color: canZoomOut ? AppColors.darkBlue : AppColors.disable,
            iconSize: 20,
            padding: const EdgeInsets.all(8),
          ),

          // 레벨 표시
          if (currentLevel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'L$currentLevel',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  if (lodLevel != null) ...[
                    SizedBox(width: 4),
                    Text(
                      '(LOD$lodLevel)',
                      style: AppTextStyles.caption4.copyWith(color: AppColors.medium),
                    ),
                  ],
                ],
              ),
            ),

          // Zoom In
          IconButton(
            onPressed: canZoomIn ? onZoomIn : null,
            icon: const Icon(LucideIcons.plus),
            color: canZoomIn ? AppColors.darkBlue : AppColors.disable,
            iconSize: 20,
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
