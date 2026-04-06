import 'dart:ui';
import '../../../core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 게임 스타일 좌표 결과 다이얼로그
class CoordinateResultDialog extends StatefulWidget {
  final int row;
  final int col;
  final String modeName;
  final Color modeColor;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;
  final String? subtitle;

  const CoordinateResultDialog({
    super.key,
    required this.row,
    required this.col,
    required this.modeName,
    required this.modeColor,
    this.onRetry,
    this.onClose,
    this.subtitle,
  });

  static Future<void> show(
    BuildContext context, {
    required int row,
    required int col,
    required String modeName,
    required Color modeColor,
    VoidCallback? onRetry,
    VoidCallback? onClose,
    String? subtitle,
  }) {
    HapticFeedback.heavyImpact();
    return showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: AppColors.textBlack.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 400),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.elasticOut,
          ),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return CoordinateResultDialog(
          row: row,
          col: col,
          modeName: modeName,
          modeColor: modeColor,
          onRetry: onRetry,
          onClose: onClose,
          subtitle: subtitle,
        );
      },
    );
  }

  @override
  State<CoordinateResultDialog> createState() => _CoordinateResultDialogState();
}

class _CoordinateResultDialogState extends State<CoordinateResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: child,
                );
              },
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      widget.modeColor.withValues(alpha: 0.25),
                      const Color(0xFF0a0a0f).withValues(alpha: 0.9),
                      widget.modeColor.withValues(alpha: 0.15),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                  border: Border.all(
                    color: widget.modeColor.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: widget.modeColor.withValues(alpha: 0.4),
                      blurRadius: 50,
                      spreadRadius: 5,
                    ),
                    BoxShadow(
                      color: AppColors.textBlack.withValues(alpha: 0.5),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 빛나는 효과
                    AnimatedBuilder(
                      animation: _shineAnimation,
                      builder: (context, child) {
                        return Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                            child: ShaderMask(
                              shaderCallback: (bounds) {
                                return LinearGradient(
                                  begin: Alignment(_shineAnimation.value - 1, -0.5),
                                  end: Alignment(_shineAnimation.value, 0.5),
                                  colors: [
                                    Colors.transparent,
                                    AppColors.white.withValues(alpha: 0.08),
                                    Colors.transparent,
                                  ],
                                ).createShader(bounds);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: AppColors.white.withValues(alpha: 0.05),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // 메인 컨텐츠
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 36, 28, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 상단 뱃지
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 18,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.modeColor.withValues(alpha: 0.3),
                                  widget.modeColor.withValues(alpha: 0.15),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                              border: Border.all(
                                color: widget.modeColor.withValues(alpha: 0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: widget.modeColor,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: widget.modeColor,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  widget.modeName.toUpperCase(),
                                  style: AppTextStyles.caption3.copyWith(color: widget.modeColor),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 28),

                          // 타이틀
                          Text(
                            'COORDINATE',
                            style: AppTextStyles.caption4.copyWith(color: AppColors.white.withValues(alpha: 0.5)),
                          ),
                          const SizedBox(height: 6),
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: [
                                  AppColors.white,
                                  widget.modeColor.withValues(alpha: 0.8),
                                ],
                              ).createShader(bounds);
                            },
                            child: const Text(
                              'LOCKED IN',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 36),

                          // 좌표 표시
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.textBlack.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(AppConstants.radiusBottomSheet),
                              border: Border.all(
                                color: widget.modeColor.withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCoordinateBox('ROW', widget.row),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: widget.modeColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: widget.modeColor,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: widget.modeColor,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: widget.modeColor,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildCoordinateBox('COL', widget.col),
                              ],
                            ),
                          ),

                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 20),
                            Text(
                              widget.subtitle!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ],

                          const SizedBox(height: 32),

                          // 버튼들
                          Row(
                            children: [
                              if (widget.onRetry != null) ...[
                                Expanded(
                                  child: _buildButton(
                                    label: 'RETRY',
                                    icon: Icons.refresh_rounded,
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      widget.onRetry?.call();
                                    },
                                    isPrimary: false,
                                  ),
                                ),
                                const SizedBox(width: 12),
                              ],
                              Expanded(
                                child: _buildButton(
                                  label: 'CONFIRM',
                                  icon: Icons.check_rounded,
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    widget.onClose?.call();
                                  },
                                  isPrimary: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinateBox(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: AppTextStyles.caption4.copyWith(color: widget.modeColor.withValues(alpha: 0.7)),
        ),
        const SizedBox(height: 10),
        Text(
          value.toString().padLeft(4, '0'),
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 36,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    widget.modeColor,
                    widget.modeColor.withValues(alpha: 0.7),
                  ],
                )
              : null,
          color: isPrimary ? null : AppColors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(
            color: isPrimary
                ? widget.modeColor.withValues(alpha: 0.6)
                : AppColors.white.withValues(alpha: 0.15),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: widget.modeColor.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppColors.white.withValues(alpha: isPrimary ? 1 : 0.8),
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.title3.copyWith(color: AppColors.white.withValues(alpha: isPrimary ? 1 : 0.8)),
            ),
          ],
        ),
      ),
    );
  }
}
