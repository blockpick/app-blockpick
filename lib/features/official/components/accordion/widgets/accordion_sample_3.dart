import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 아코디언 샘플 #3 - 그라데이션 + 슬라이드 애니메이션
class AccordionSample3 extends StatefulWidget {
  const AccordionSample3({super.key});

  @override
  State<AccordionSample3> createState() => _AccordionSample3State();
}

class _AccordionSample3State extends State<AccordionSample3>
    with TickerProviderStateMixin {
  final List<bool> _expandedStates = List.generate(5, (_) => false);
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 5; i++) {
      _controllers.add(
        AnimationController(
          duration: const Duration(milliseconds: 400),
          vsync: this,
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Accordion #3',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.buleGray,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 설명
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.gradientBluePurplePink,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '그라데이션 아코디언\n• 슬라이드 애니메이션\n• 화려한 그라데이션 효과',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 아코디언 아이템들
          ...List.generate(5, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildAccordionItem(
                index: index,
                title: '그라데이션 아코디언 ${index + 1}',
                content: '이것은 그라데이션 스타일의 아코디언입니다. '
                    '슬라이드 애니메이션으로 내용이 부드럽게 나타나고, '
                    '화려한 그라데이션 효과가 적용되어 있습니다. '
                    'SlideTransition을 사용하여 슬라이드 효과를 구현했습니다.',
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required String title,
    required String content,
  }) {
    final isExpanded = _expandedStates[index];
    final gradients = [
      AppColors.gradientBluePurplePink,
      AppColors.gradientBlue,
      LinearGradient(
        colors: [AppColors.green500, AppColors.blue],
      ),
      LinearGradient(
        colors: [AppColors.yellow500, AppColors.pink],
      ),
      LinearGradient(
        colors: [AppColors.purple, AppColors.blue],
      ),
    ];
    final gradient = gradients[index % gradients.length];

    final Animation<Offset> slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controllers[index],
      curve: Curves.easeOut,
    ));

    final Animation<double> fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controllers[index],
      curve: Curves.easeIn,
    ));

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 헤더
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                setState(() {
                  _expandedStates[index] = !_expandedStates[index];
                  if (_expandedStates[index]) {
                    _controllers[index].forward();
                  } else {
                    _controllers[index].reverse();
                  }
                });
              },
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // 글로우 아이콘
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.white.withValues(alpha: 0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.star,
                        color: AppColors.white,
                        size: 28,
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.body2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    // 펄스 애니메이션 아이콘
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0.0,
                        end: isExpanded ? 1.0 : 0.0,
                      ),
                      duration: const Duration(milliseconds: 300),
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: 1.0 + (value * 0.2),
                          child: Icon(
                            isExpanded
                                ? Icons.remove_circle_outline
                                : Icons.add_circle_outline,
                            color: AppColors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 내용 - 슬라이드 애니메이션
          if (isExpanded)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppConstants.radiusLg),
                bottomRight: Radius.circular(AppConstants.radiusLg),
              ),
              child: SlideTransition(
                position: slideAnimation,
                child: FadeTransition(
                  opacity: fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Text(
                        content,
                        style: AppTextStyles.body3.copyWith(
                          color: AppColors.darkBlue,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
