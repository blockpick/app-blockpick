import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// SC-001: 스플래시 화면
///
/// - SC-001-01: 브랜드 로고 표시
/// - SC-001-02: 네트워크 오류 시 재시도 화면
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

  bool _isNetworkError = false;
  bool _isChecking = true;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _checkNetworkAndProceed();
    _listenToConnectivity();
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

  void _listenToConnectivity() {
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      // 네트워크 연결되면 자동으로 다시 시도
      if (_isNetworkError && results.isNotEmpty && results.first != ConnectivityResult.none) {
        _checkNetworkAndProceed();
      }
    });
  }

  Future<bool> _hasInternetConnection() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult.isNotEmpty &&
        connectivityResult.first != ConnectivityResult.none;
  }

  Future<void> _checkNetworkAndProceed() async {
    setState(() {
      _isChecking = true;
      _isNetworkError = false;
    });

    // 최소 1.5초 대기 (스플래시 애니메이션)
    await Future.delayed(const Duration(milliseconds: 1500));

    if (!mounted) return;

    // 네트워크 연결 확인
    final hasConnection = await _hasInternetConnection();

    if (!mounted) return;

    if (!hasConnection) {
      setState(() {
        _isNetworkError = true;
        _isChecking = false;
      });
      return;
    }

    // 네트워크 연결됨 - 최초 실행 여부 확인 후 분기
    // 웹에서는 권한/온보딩 화면 건너뛰기 (직접 URL 접근 허용)
    if (kIsWeb) {
      if (!mounted) return;
      context.go('/');
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final permissionShown = prefs.getBool('permission_screen_shown') ?? false;
    final onboardingShown = prefs.getBool('onboarding_screen_shown') ?? false;

    if (!mounted) return;

    if (!permissionShown) {
      // 최초 실행 - 권한 설정 화면으로
      context.go('/permission');
    } else if (!onboardingShown) {
      // 권한 설정 완료, 온보딩 미완료 - 온보딩 화면으로
      context.go('/onboarding');
    } else {
      // 모두 완료 - 홈 화면으로 (로그인 여부 상관없이 컨텐츠 볼 수 있음)
      context.go('/');
    }
  }

  Future<void> _retry() async {
    await _checkNetworkAndProceed();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _connectivitySubscription?.cancel();
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
        body: _isNetworkError ? _buildNetworkErrorView() : _buildSplashView(),
      ),
    );
  }

  /// SC-001-01: 기본 스플래시 화면
  Widget _buildSplashView() {
    return Center(
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
              'Blockpick',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: AppColors.darkBlue,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// SC-001-02: 네트워크 오류 화면
  Widget _buildNetworkErrorView() {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 네트워크 오류 아이콘
              Icon(
                Icons.wifi_off_rounded,
                size: 80,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 32),

              // 제목
              Text(
                '연결이 잠시 끊겼어요.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12),

              // 설명
              Text(
                '인터넷 연결 상태를 확인하고\n다시 시도해 주세요.',
                style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 다시시도 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _retry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : const Text(
                          '다시시도',
                          style: AppTextStyles.title2,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
