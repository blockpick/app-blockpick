import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

/// 토스 스타일의 스플래시 화면
///
/// - 앱 로고 표시
/// - 자동 로그인 체크
/// - 로그인 상태에 따라 적절한 화면으로 이동
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkAuthStatus();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  Future<void> _checkAuthStatus() async {
    // 최소 1.5초 대기 (스플래시 애니메이션)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 로그인 여부와 관계없이 홈 화면으로 이동
    // 로그인이 필요한 기능은 해당 화면에서 처리
    context.go('/');
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 로고
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: AppColors.gradientBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.blue.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'B',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // 앱 이름
                const Text(
                  'BlockPick',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '블록을 선택하고 보상을 받으세요',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray600,
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
