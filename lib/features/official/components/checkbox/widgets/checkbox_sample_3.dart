import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 체크박스 샘플 #3 - 커스텀 아이콘 + 리플 애니메이션
class CheckboxSample3 extends StatefulWidget {
  const CheckboxSample3({super.key});

  @override
  State<CheckboxSample3> createState() => _CheckboxSample3State();
}

class _CheckboxSample3State extends State<CheckboxSample3>
    with TickerProviderStateMixin {
  final List<bool> _checkedStates = List.generate(7, (_) => false);
  final List<AnimationController> _controllers = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < 7; i++) {
      _controllers.add(
        AnimationController(
          duration: const Duration(milliseconds: 600),
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
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkbox #3',
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
              gradient: LinearGradient(
                colors: [AppColors.blue, AppColors.purple],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '커스텀 아이콘 체크박스\n• 리플 애니메이션\n• 다양한 아이콘 스타일',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 커스텀 체크박스 리스트
          ...List.generate(7, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildCustomCheckbox(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(int index) {
    final isChecked = _checkedStates[index];
    final icons = [
      Icons.thumb_up,
      Icons.favorite,
      Icons.star,
      Icons.bookmark,
      Icons.emoji_emotions,
      Icons.grade,
      Icons.workspace_premium,
    ];
    final uncheckedIcons = [
      Icons.thumb_up_outlined,
      Icons.favorite_outline,
      Icons.star_outline,
      Icons.bookmark_outline,
      Icons.emoji_emotions_outlined,
      Icons.grade_outlined,
      Icons.workspace_premium_outlined,
    ];
    final labels = [
      '좋아요',
      '관심 있어요',
      '별점 5점',
      '북마크',
      '재밌어요',
      '추천해요',
      '프리미엄 선택',
    ];
    final gradients = [
      LinearGradient(colors: [AppColors.blue, AppColors.purple]),
      LinearGradient(colors: [AppColors.pink, AppColors.purple]),
      LinearGradient(colors: [AppColors.yellow500, AppColors.pink]),
      LinearGradient(colors: [AppColors.green500, AppColors.blue]),
      LinearGradient(colors: [AppColors.yellow500, AppColors.yellow500]),
      LinearGradient(colors: [AppColors.purple, AppColors.blue]),
      LinearGradient(colors: [AppColors.darkBlue, AppColors.purple]),
    ];

    return GestureDetector(
      onTap: () {
        setState(() {
          _checkedStates[index] = !_checkedStates[index];
          if (_checkedStates[index]) {
            _controllers[index].forward(from: 0);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isChecked ? gradients[index] : null,
          color: isChecked ? null : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isChecked ? Colors.transparent : AppColors.buleGray,
            width: 2,
          ),
          boxShadow: isChecked
              ? [
                  BoxShadow(
                    color: AppColors.darkBlue.withValues(alpha: 0.2),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // 커스텀 아이콘 체크박스 with 리플 애니메이션
            Stack(
              alignment: Alignment.center,
              children: [
                // 리플 효과
                if (isChecked)
                  ScaleTransition(
                    scale: Tween<double>(begin: 0.5, end: 2.0).animate(
                      CurvedAnimation(
                        parent: _controllers[index],
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.8, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _controllers[index],
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                // 아이콘
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? AppColors.white.withValues(alpha: 0.3)
                        : AppColors.bgWhite,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isChecked ? icons[index] : uncheckedIcons[index],
                    color: isChecked ? AppColors.white : AppColors.medium,
                    size: 32,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                labels[index],
                style: AppTextStyles.heading1.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isChecked ? AppColors.white : AppColors.darkBlue,
                ),
              ),
            ),
            // 체크 표시
            AnimatedScale(
              scale: isChecked ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.elasticOut,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: gradients[index].colors.first,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
