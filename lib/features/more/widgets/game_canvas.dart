import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 상품 이미지 위에 1000x1000 좌표 선택을 위한 게임 캔버스
class GameCanvas extends StatelessWidget {
  final Widget child;
  final String? imageUrl;
  final int gridSize;
  final bool showGrid;
  final bool showCoordinate;
  final int? currentRow;
  final int? currentCol;
  final Color accentColor;
  final Widget? overlay;
  final Widget? bottomHUD;

  const GameCanvas({
    super.key,
    required this.child,
    this.imageUrl,
    this.gridSize = 1000,
    this.showGrid = false,
    this.showCoordinate = true,
    this.currentRow,
    this.currentCol,
    this.accentColor = AppColors.primaryMain,
    this.overlay,
    this.bottomHUD,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: 0.1),
            AppColors.textBlack.withValues(alpha: 0.9),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: imageUrl != null
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                  )
                : _buildPlaceholderImage(),
          ),

          // 그라데이션 오버레이
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.textBlack.withValues(alpha: 0.3),
                    AppColors.textBlack.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),
          ),

          // 그리드 오버레이 (선택적)
          if (showGrid)
            Positioned.fill(
              child: CustomPaint(
                painter: _GridPainter(
                  color: accentColor.withValues(alpha: 0.1),
                  divisions: 10,
                ),
              ),
            ),

          // 메인 컨텐츠
          Positioned.fill(child: child),

          // 커스텀 오버레이
          if (overlay != null) Positioned.fill(child: overlay!),

          // 상단 좌표 HUD
          if (showCoordinate && currentRow != null && currentCol != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 60,
              left: 0,
              right: 0,
              child: _CoordinateHUD(
                row: currentRow!,
                col: currentCol!,
                gridSize: gridSize,
                accentColor: accentColor,
              ),
            ),

          // 하단 HUD
          if (bottomHUD != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: bottomHUD!,
            ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.3),
            const Color(0xFF1a1a2e),
            const Color(0xFF16213e),
          ],
        ),
      ),
      child: CustomPaint(
        painter: _PatternPainter(color: accentColor),
      ),
    );
  }
}

/// 좌표 표시 HUD
class _CoordinateHUD extends StatelessWidget {
  final int row;
  final int col;
  final int gridSize;
  final Color accentColor;

  const _CoordinateHUD({
    required this.row,
    required this.col,
    required this.gridSize,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.textBlack.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCoordBox('ROW', row),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '×',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
                _buildCoordBox('COL', col),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordBox(String label, int value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.caption4.copyWith(color: AppColors.white.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString().padLeft(4, '0'),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

/// 그리드 페인터
class _GridPainter extends CustomPainter {
  final Color color;
  final int divisions;

  _GridPainter({required this.color, required this.divisions});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.5;

    for (int i = 1; i < divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 배경 패턴 페인터
class _PatternPainter extends CustomPainter {
  final Color color;

  _PatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const spacing = 30.0;
    for (double x = 0; x < size.width + size.height; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x - size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 글래스모피즘 버튼
class GlassButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final String? emoji;
  final VoidCallback onPressed;
  final Color accentColor;
  final bool isPrimary;
  final bool isLarge;

  const GlassButton({
    super.key,
    required this.label,
    this.icon,
    this.emoji,
    required this.onPressed,
    this.accentColor = AppColors.primaryMain,
    this.isPrimary = false,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onPressed();
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isLarge ? 20 : 14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isLarge ? 32 : 20,
              vertical: isLarge ? 18 : 14,
            ),
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? LinearGradient(
                      colors: [
                        accentColor,
                        accentColor.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: isPrimary ? null : AppColors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isLarge ? 20 : 14),
              border: Border.all(
                color: isPrimary
                    ? accentColor.withValues(alpha: 0.5)
                    : AppColors.white.withValues(alpha: 0.2),
                width: 1,
              ),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (emoji != null) ...[
                  Text(emoji!, style: TextStyle(fontSize: isLarge ? 22 : 18)),
                  SizedBox(width: isLarge ? 12 : 8),
                ],
                if (icon != null) ...[
                  Icon(
                    icon,
                    color: AppColors.white,
                    size: isLarge ? 24 : 20,
                  ),
                  SizedBox(width: isLarge ? 12 : 8),
                ],
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: isLarge ? 18 : 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 하단 컨트롤 패널
class BottomControlPanel extends StatelessWidget {
  final List<Widget> children;
  final Color accentColor;

  const BottomControlPanel({
    super.key,
    required this.children,
    this.accentColor = AppColors.primaryMain,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.textBlack.withValues(alpha: 0.6),
                AppColors.textBlack.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }
}

/// 게임 앱바
class GameAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String emoji;
  final Color accentColor;
  final List<Widget>? actions;

  const GameAppBar({
    super.key,
    required this.title,
    required this.emoji,
    this.accentColor = AppColors.primaryMain,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.textBlack.withValues(alpha: 0.8),
                AppColors.textBlack.withValues(alpha: 0.4),
                Colors.transparent,
              ],
            ),
          ),
          child: SizedBox(
            height: 56,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: AppColors.white,
                    size: 22,
                  ),
                ),
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const Spacer(),
                if (actions != null) ...actions!,
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

/// 타겟 크로스헤어 위젯
class TargetCrosshair extends StatelessWidget {
  final Color color;
  final double size;
  final bool animated;

  const TargetCrosshair({
    super.key,
    this.color = AppColors.white,
    this.size = 60,
    this.animated = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CrosshairPainter(color: color),
      ),
    );
  }
}

class _CrosshairPainter extends CustomPainter {
  final Color color;

  _CrosshairPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // 외부 원
    canvas.drawCircle(center, radius - 2, paint);

    // 내부 원
    paint.strokeWidth = 1;
    canvas.drawCircle(center, radius * 0.4, paint);

    // 십자선
    paint.strokeWidth = 1.5;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 8),
      Offset(center.dx, center.dy - radius * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + radius - 8),
      Offset(center.dx, center.dy + radius * 0.5),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - radius + 8, center.dy),
      Offset(center.dx - radius * 0.5, center.dy),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + radius - 8, center.dy),
      Offset(center.dx + radius * 0.5, center.dy),
      paint,
    );

    // 중심점
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
