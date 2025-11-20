import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../core/theme/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    final canZoomIn = maxLevel == null || currentLevel == null || currentLevel! < maxLevel!;
    final canZoomOut = minLevel == null || currentLevel == null || currentLevel! > minLevel!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(opacity),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
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
            icon: const Icon(LucideIcons.plus),
            color: canZoomIn ? AppColors.darkBlue : AppColors.disable,
            iconSize: 24,
            padding: const EdgeInsets.all(12),
          ),

          // LOD 레벨 표시 (숫자만)
          if (lodLevel != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                '$lodLevel',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
            ),

          // 구분선
          Container(
            width: 40,
            height: 1,
            color: AppColors.buleGray,
          ),

          // Zoom Out
          IconButton(
            onPressed: canZoomOut ? onZoomOut : null,
            icon: const Icon(LucideIcons.minus),
            color: canZoomOut ? AppColors.darkBlue : AppColors.disable,
            iconSize: 24,
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
                    const SizedBox(width: 4),
                    Text(
                      '(LOD$lodLevel)',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.medium,
                      ),
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
