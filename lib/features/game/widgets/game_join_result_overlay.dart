import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 게임 참가 결과 전체화면 오버레이 (성공/실패)
class GameJoinResultOverlay extends StatelessWidget {
  final bool success;
  final String? entryId;
  final String? txHash;
  final String? errorMessage;
  final VoidCallback? onConfirm;
  final VoidCallback? onRetry;

  const GameJoinResultOverlay({
    Key? key,
    required this.success,
    this.entryId,
    this.txHash,
    this.errorMessage,
    this.onConfirm,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: success
                ? [
                    AppColors.green500.withOpacity(0.95),
                    AppColors.blue.withOpacity(0.95),
                  ]
                : [
                    AppColors.red.withOpacity(0.95),
                    AppColors.pink.withOpacity(0.95),
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 48), // 상단 여백
                // 결과 아이콘 애니메이션
                _buildResultIcon(success),

                SizedBox(height: 48),

                // 타이틀
                Text(
                  success ? '게임 참가 완료!' : '참가에 실패했어요',
                  style: AppTextStyles.heading1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0),

                SizedBox(height: 16),

                // 설명
                Text(
                  success
                      ? '블록체인에 안전하게 기록되었어요.\n이제 게임 결과를 기다려주세요!'
                      : errorMessage ?? '다시 시도해주세요.',
                  style: AppTextStyles.body3.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms),

                const SizedBox(height: 48),

                // 상세 정보 카드
                if (success) ...[
                  _buildInfoCard(context),
                  const SizedBox(height: 24),
                ],

                // 버튼들
                _buildButtons(context),

                SizedBox(height: 24),

                // 닫기 버튼
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    '닫기',
                    style: AppTextStyles.body3.copyWith(
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                )
                    .animate()
                    .fadeIn(delay: 1000.ms, duration: 500.ms),

                const SizedBox(height: 48), // 하단 여백
              ],
              ),
            ),
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(begin: const Offset(1.1, 1.1), curve: Curves.easeOut);
  }

  Widget _buildResultIcon(bool success) {
    if (success) {
      return Stack(
        alignment: Alignment.center,
        children: [
          // 배경 원 (파티클 효과)
          ...List.generate(8, (index) {
            final angle = (index * 45) * 3.14159 / 180;
            return Transform.translate(
              offset: Offset(
                30 * (index % 2 == 0 ? 1 : -1),
                30 * (index % 2 == 0 ? 1 : -1),
              ),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            )
                .animate(onPlay: (controller) => controller.repeat())
                .fadeOut(duration: 2000.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(2.0, 2.0),
                  delay: Duration(milliseconds: index * 100),
                );
          }),

          // 메인 체크 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.3),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Icon(
              LucideIcons.checkCircle2,
              color: AppColors.green500,
              size: 64,
            ),
          )
              .animate()
              .scale(
                delay: 100.ms,
                duration: 600.ms,
                begin: const Offset(0, 0),
                end: const Offset(1, 1),
                curve: Curves.elasticOut,
              )
              .then()
              .shake(hz: 2, curve: Curves.easeInOut),
        ],
      );
    } else {
      return Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 30,
              spreadRadius: 10,
            ),
          ],
        ),
        child: Icon(
          LucideIcons.xCircle,
          color: AppColors.red,
          size: 64,
        ),
      )
          .animate()
          .scale(
            delay: 100.ms,
            duration: 400.ms,
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
          )
          .then()
          .shake(hz: 4, curve: Curves.easeInOut);
    }
  }

  Widget _buildInfoCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (entryId != null) ...[
            _buildInfoRow(
              context,
              icon: LucideIcons.hash,
              label: 'Entry ID',
              value: entryId!,
              copyable: true,
            ),
            const SizedBox(height: 16),
          ],
          if (txHash != null) ...[
            _buildInfoRow(
              context,
              icon: LucideIcons.link,
              label: '트랜잭션',
              value: '${txHash!.substring(0, 10)}...${txHash!.substring(txHash!.length - 8)}',
              copyable: true,
              fullValue: txHash,
            ),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 500.ms)
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
    String? fullValue,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 20,
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body4.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 4),
              Text(
                value,
                style: AppTextStyles.body3.copyWith(
                  color: Colors.white,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        if (copyable)
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: fullValue ?? value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label가 복사되었습니다'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Icon(
              LucideIcons.copy,
              color: Colors.white.withOpacity(0.7),
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    if (success) {
      return ElevatedButton(
        onPressed: () {
          Navigator.of(context).pop();
          onConfirm?.call();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppColors.green500,
          padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '확인',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              LucideIcons.arrowRight,
              size: 20,
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 900.ms, duration: 500.ms)
          .slideY(begin: 0.2, end: 0);
    } else {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.red,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 8,
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(LucideIcons.refreshCw, size: 20),
                SizedBox(width: 8),
                Text(
                  '다시 시도',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 500.ms)
              .slideY(begin: 0.2, end: 0),
        ],
      );
    }
  }

  /// 성공 오버레이 표시
  static void showSuccess(
    BuildContext context, {
    String? entryId,
    String? txHash,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => GameJoinResultOverlay(
        success: true,
        entryId: entryId,
        txHash: txHash,
        onConfirm: onConfirm,
      ),
    );
  }

  /// 실패 오버레이 표시
  static void showError(
    BuildContext context, {
    String? errorMessage,
    VoidCallback? onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (context) => GameJoinResultOverlay(
        success: false,
        errorMessage: errorMessage,
        onRetry: onRetry,
      ),
    );
  }
}
