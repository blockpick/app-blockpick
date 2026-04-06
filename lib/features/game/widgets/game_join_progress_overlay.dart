import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// 게임 참여 진행 상태
enum GameJoinStep {
  walletCheck('지갑 확인/생성', '1/6'),
  encryptionKey('암호화 키 생성', '2/6'),
  coordinateEncryption('좌표 암호화', '3/6'),
  walletHashing('지갑 주소 해시화', '4/6'),
  joinMutation('게임 참여 요청', '5/6'),
  polling('블록체인 처리 대기', '6/6');

  final String label;
  final String stepNumber;
  const GameJoinStep(this.label, this.stepNumber);
}

/// 게임 참여 진행 상태 오버레이
class GameJoinProgressOverlay extends StatelessWidget {
  final GameJoinStep currentStep;
  final String? statusMessage;
  final String? txHash;
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onClose;

  const GameJoinProgressOverlay({
    super.key,
    required this.currentStep,
    this.statusMessage,
    this.txHash,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.textBlack.withValues(alpha: 0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상태 아이콘
              if (isError)
                const Icon(
                  Icons.error_outline,
                  color: AppColors.red,
                  size: 64,
                )
              else
                const CircularProgressIndicator(
                  strokeWidth: 3,
                ),

              const SizedBox(height: 24),

              // 현재 단계
              Text(
                '${currentStep.stepNumber} ${currentStep.label}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // 상태 메시지
              if (statusMessage != null) ...[
                Text(
                  statusMessage!,
                  style: TextStyle(
                    fontSize: 14,
                    color: isError ? AppColors.red : AppColors.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
              ],

              // 에러 메시지
              if (isError && errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.red200,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 트랜잭션 해시
              if (!isError && txHash != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TX Hash:',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.gray400,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        txHash!.length > 20
                            ? '${txHash!.substring(0, 10)}...${txHash!.substring(txHash!.length - 10)}'
                            : txHash!,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // 진행 바
              if (!isError) ...[
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (currentStep.index + 1) / GameJoinStep.values.length,
                  backgroundColor: AppColors.gray200,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.blue),
                ),
              ],

              // 버튼들
              if (isError && (onRetry != null || onClose != null)) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (onClose != null)
                      TextButton(
                        onPressed: onClose,
                        child: const Text('닫기'),
                      ),
                    if (onRetry != null && onClose != null)
                      const SizedBox(width: 12),
                    if (onRetry != null)
                      ElevatedButton(
                        onPressed: onRetry,
                        child: const Text('재시도'),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// 오버레이로 표시
  static OverlayEntry show(
    BuildContext context, {
    required GameJoinStep currentStep,
    String? statusMessage,
    String? txHash,
    bool isError = false,
    String? errorMessage,
    VoidCallback? onRetry,
    VoidCallback? onClose,
  }) {
    final overlay = OverlayEntry(
      builder: (context) => GameJoinProgressOverlay(
        currentStep: currentStep,
        statusMessage: statusMessage,
        txHash: txHash,
        isError: isError,
        errorMessage: errorMessage,
        onRetry: onRetry,
        onClose: onClose,
      ),
    );

    Overlay.of(context).insert(overlay);
    return overlay;
  }
}
