import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../widgets/auth_button.dart';

/// 회원가입 완료 화면
class SignupCompleteScreen extends ConsumerWidget {
  const SignupCompleteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // 축하 아이콘
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppColors.gradientBlue,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 64,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 40),

              // 축하 메시지
              Text(
                '가입 완료!',
                style: AppTextStyles.display1.copyWith(color: AppColors.darkBlue),
              ),

              SizedBox(height: 12),

              Text(
                '블록픽에 오신 것을 환영해요\n지금 바로 게임을 시작해보세요',
                style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // 시작하기 버튼
              AuthButton(
                text: '시작하기',
                onPressed: () => context.go('/'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
