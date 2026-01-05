import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

/// 토스 스타일의 인증 화면 Scaffold
///
/// 특징:
/// - 흰색 배경
/// - 상단에 뒤로가기 버튼
/// - 하단에 고정된 CTA 버튼 영역
/// - 키보드에 반응하는 레이아웃
class AuthScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final Widget? bottomButton;
  final VoidCallback? onBack;
  final bool showBackButton;
  final bool resizeToAvoidBottomInset;
  final double? progress;

  const AuthScaffold({
    super.key,
    this.title,
    required this.body,
    this.bottomButton,
    this.onBack,
    this.showBackButton = true,
    this.resizeToAvoidBottomInset = true,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        body: SafeArea(
          child: Column(
            children: [
              // 상단 앱바
              _buildAppBar(context),

              // 진행률 표시 (있는 경우)
              if (progress != null) _buildProgressBar(),

              // 본문
              Expanded(
                child: body,
              ),

              // 하단 버튼
              if (bottomButton != null) _buildBottomButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: [
          if (showBackButton)
            IconButton(
              onPressed: onBack ?? () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 22,
                color: AppColors.darkBlue,
              ),
              splashRadius: 24,
            )
          else
            const SizedBox(width: 48),

          if (title != null)
            Expanded(
              child: Text(
                title!,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else
            const Expanded(child: SizedBox()),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(1.5),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress!.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.blue,
            borderRadius: BorderRadius.circular(1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom > 0 ? 16 : 24,
        top: 16,
      ),
      child: bottomButton,
    );
  }
}
