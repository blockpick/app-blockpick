import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 가격 블록 아이템 위젯
///
/// ListWheelScrollView에서 사용되는 개별 가격 블록
class PriceBlockItem extends StatelessWidget {
  final int price;
  final bool isSelected;
  final bool isFocused; // 휠 중앙에 위치한 블록
  final int? recentBidders; // 최근 1시간 입찰자 수 (선택 사항)

  const PriceBlockItem({
    super.key,
    required this.price,
    this.isSelected = false,
    this.isFocused = false,
    this.recentBidders,
  });

  @override
  Widget build(BuildContext context) {
    // 포커스된 블록은 크고 선명하게
    final scale = isFocused ? 1.0 : 0.85;
    final opacity = isFocused ? 1.0 : 0.5;

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: opacity,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? AppColors.gradientBluePurplePink
                : LinearGradient(
                    colors: [
                      AppColors.white,
                      AppColors.bgWhite,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.blue
                  : isFocused
                      ? AppColors.purple.withOpacity(0.5)
                      : AppColors.buleGray,
              width: isSelected ? 3 : 2,
            ),
            boxShadow: [
              if (isSelected || isFocused)
                BoxShadow(
                  color: (isSelected ? AppColors.blue : AppColors.purple)
                      .withOpacity(0.3),
                  blurRadius: isSelected ? 20 : 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 가격 표시
                Text(
                  _formatPrice(price),
                  style: AppTextStyles.large.copyWith(
                    color: isSelected ? AppColors.white : AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: isFocused ? 28 : 24,
                  ),
                ),
                // 중앙 블록에는 가격만 표시 (추가 정보 제거)
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 가격을 원화 형식으로 포맷
  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }
}
