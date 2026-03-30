import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// SC-003: 온보딩 화면
///
/// 3장의 스와이프 페이지로 구성
/// - 컨셉 1: 블록픽 게임 플레이
/// - 컨셉 2: 공정성과 투명성 강조
/// - 컨셉 3: 쇼핑몰 이용
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const String _onboardingShownKey = 'onboarding_screen_shown';

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingContent> _contents = [
    _OnboardingContent(
      icon: Icons.grid_on_rounded,
      title: '치열한 눈치싸움,\n단 하나의 독점 블록',
      description: '그리드 속 숨겨진 보물을 찾아보세요.\n전략적으로 좌표를 선택하고 독점의 기쁨을 누리세요.',
      color: AppColors.blue,
    ),
    _OnboardingContent(
      icon: Icons.verified_rounded,
      title: '조작 불가능한\n100% 투명한 결과',
      description: '모든 참여 내역이 블록체인에 암호화되서 보호되며,\n어느 누구도 내가 참여한 게임의 좌표를 열어볼 수 없어요.',
      color: AppColors.purple,
    ),
    _OnboardingContent(
      icon: Icons.shopping_bag_rounded,
      title: '할인 혜택이 많은\n쇼핑까지',
      description: '다양한 상품을 쇼핑캐시로 할인받아 구입해보세요.\n더 많은 제휴 상품으로 더 큰 혜택을 드립니다.',
      color: AppColors.green500,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
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
        body: SafeArea(
          child: Column(
            children: [
              // 페이지 콘텐츠
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemCount: _contents.length,
                  itemBuilder: (context, index) {
                    return _buildPage(_contents[index]);
                  },
                ),
              ),

              // 페이지 인디케이터
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _contents.length,
                    (index) => _buildDot(index),
                  ),
                ),
              ),

              // 하단 안내 문구 및 버튼
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: Column(
                  children: [
                    // 안내 문구
                    Text(
                      '블록픽 일부 기능은 회원가입 및 로그인이 필요합니다.',
                      style: AppTextStyles.body3.copyWith(color: AppColors.gray500),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // 로그인 하기 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _goToLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.darkBlue,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          '로그인 하기',
                          style: AppTextStyles.title2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 앱 둘러보기 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        onPressed: _goToHome,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gray600,
                          side: BorderSide(color: AppColors.gray300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '앱 둘러보기',
                          style: AppTextStyles.title2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(_OnboardingContent content) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: content.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(
              content.icon,
              size: 60,
              color: content.color,
            ),
          ),
          const SizedBox(height: 40),

          // 제목
          Text(
            content.title,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
              height: 1.3,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // 설명
          Text(
            content.description,
            style: AppTextStyles.body1.copyWith(color: AppColors.gray600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    final isActive = index == _currentPage;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.blue : AppColors.gray300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Future<void> _saveOnboardingShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingShownKey, true);
  }

  Future<void> _goToLogin() async {
    await _saveOnboardingShown();
    if (!mounted) return;
    context.go('/login');
  }

  Future<void> _goToHome() async {
    await _saveOnboardingShown();
    if (!mounted) return;
    context.go('/');
  }
}

class _OnboardingContent {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingContent({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
