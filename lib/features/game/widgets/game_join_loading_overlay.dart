import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// 게임 참가 진행 중 전체화면 오버레이 (토스 스타일)
///
/// 사용법:
/// ```dart
/// GameJoinLoadingOverlay.show(context);
/// // 작업 완료 후
/// GameJoinLoadingOverlay.hide(context);
/// ```
class GameJoinLoadingOverlay extends StatefulWidget {
  final String currentStep;
  final int stepNumber;
  final int totalSteps;

  const GameJoinLoadingOverlay({
    Key? key,
    required this.currentStep,
    this.stepNumber = 1,
    this.totalSteps = 5,
  }) : super(key: key);

  @override
  State<GameJoinLoadingOverlay> createState() => _GameJoinLoadingOverlayState();

  /// 오버레이 표시
  static OverlayEntry? _overlayEntry;

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => const _GameJoinLoadingOverlayManager(),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  /// 오버레이 숨김
  static void hide(BuildContext context) {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  /// 진행 단계 업데이트
  static void updateStep(String step, int stepNumber) {
    // StreamController나 ValueNotifier를 사용하여 상태 업데이트
  }
}

class _GameJoinLoadingOverlayState extends State<GameJoinLoadingOverlay> {
  @override
  Widget build(BuildContext context) {
    final progress = widget.stepNumber / widget.totalSteps;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blue.withValues(alpha: 0.95),
              AppColors.purple.withValues(alpha: 0.95),
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
                  // 로딩 애니메이션
                  _buildLoadingAnimation(),

                SizedBox(height: 48),

                // 타이틀
                Text(
                  '게임에 참가하고 있어요',
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(
                      duration: 2000.ms,
                      color: AppColors.white.withValues(alpha: 0.3),
                    ),

                SizedBox(height: 16),

                // 현재 단계 설명
                Text(
                  widget.currentStep,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.2, end: 0),

                const SizedBox(height: 48),

                // 진행률 바
                _buildProgressBar(progress),

                SizedBox(height: 16),

                // 단계 표시
                Text(
                  '${widget.stepNumber}/${widget.totalSteps}',
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.white.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 64),

                // 안내 메시지
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.white.withValues(alpha: 0.8),
                        size: 20,
                      ),
                      SizedBox(height: 8),
                      Text(
                        '블록체인에 트랜잭션을 전송하고 있습니다.\n잠시만 기다려주세요.',
                        style: AppTextStyles.body4.copyWith(
                          color: AppColors.white.withValues(alpha: 0.8),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 500.ms, duration: 500.ms)
                    .scale(begin: const Offset(0.8, 0.8)),
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

  Widget _buildLoadingAnimation() {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 외부 회전 원
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 2000.ms),

          // 중간 회전 원
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 1500.ms, begin: 1, end: 0),

          // 중앙 아이콘
          Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.white,
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              color: AppColors.blue,
              size: 28,
            ),
          )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scale(
                duration: 1000.ms,
                begin: const Offset(1.0, 1.0),
                end: const Offset(1.1, 1.1),
              ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: SizedBox(
            height: 8,
            child: Stack(
              children: [
                // 배경
                Container(
                  width: double.infinity,
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
                // 진행률
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.white, Colors.white70],
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .shimmer(
                        duration: 1500.ms,
                        color: AppColors.white.withValues(alpha: 0.5),
                      ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// 게임 참가 로딩 오버레이 관리자
class _GameJoinLoadingOverlayManager extends StatefulWidget {
  const _GameJoinLoadingOverlayManager({Key? key}) : super(key: key);

  @override
  State<_GameJoinLoadingOverlayManager> createState() =>
      _GameJoinLoadingOverlayManagerState();
}

class _GameJoinLoadingOverlayManagerState
    extends State<_GameJoinLoadingOverlayManager> {
  String currentStep = '블록체인 지갑을 확인하고 있어요';
  int stepNumber = 1;
  final int totalSteps = 5;

  final List<String> steps = [
    '블록체인 지갑을 확인하고 있어요',
    '암호화 키를 요청하고 있어요',
    '좌표를 암호화하고 있어요',
    '지갑 주소를 보호하고 있어요',
    '게임 참가를 완료하고 있어요',
  ];

  @override
  void initState() {
    super.initState();
    _startStepAnimation();
  }

  void _startStepAnimation() {
    // 3초마다 단계 업데이트 (시뮬레이션)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && stepNumber < totalSteps) {
        setState(() {
          stepNumber++;
          currentStep = steps[stepNumber - 1];
        });
        _startStepAnimation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GameJoinLoadingOverlay(
      currentStep: currentStep,
      stepNumber: stepNumber,
      totalSteps: totalSteps,
    );
  }
}
