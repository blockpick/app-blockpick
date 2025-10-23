import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BlockPick 앱의 텍스트 스타일 시스템
///
/// UI_SPECIFICATION 문서에서 정의된 타이포그래피를 구현합니다.
class AppTextStyles {
  // ========== Font Sizes ==========

  /// Display / H1 - 32px (font-bold)
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.darkBlue,
  );

  /// Large / H2 - 24px (font-bold)
  static const TextStyle large = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.3,
    color: AppColors.darkBlue,
  );

  /// Medium / H3 - 18px (font-semibold)
  static const TextStyle medium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.darkBlue,
  );

  /// Body Large - 16px (font-medium)
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
    color: AppColors.navy,
  );

  /// Body - 14px (font-normal)
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.navy,
  );

  /// Body Small - 12px (font-normal)
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.medium,
  );

  /// Caption - 10px (font-normal)
  static const TextStyle caption = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.light,
  );

  // ========== Alias Styles (다른 파일 호환용) ==========

  /// XLarge - display와 동일
  static const TextStyle xlarge = display;

  /// Small - bodySmall과 동일
  static const TextStyle small = bodySmall;

  // ========== Specific Use Cases ==========

  /// Button Text - 14px semibold
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: 0.2,
  );

  /// Button Large - 16px bold
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 0.3,
  );

  /// Label - 12px medium
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.medium,
  );

  /// Hint - 14px normal
  static const TextStyle hint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.hint,
  );

  // ========== Gradient Text Support ==========

  /// Gradient 텍스트를 위한 유틸리티
  ///
  /// 사용 예:
  /// ```dart
  /// Text(
  ///   'Gradient Text',
  ///   style: AppTextStyles.gradientText(AppTextStyles.display),
  /// )
  /// ```
  static TextStyle gradientText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = AppColors.gradientBluePurplePink.createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  // ========== Color Variations ==========

  /// 텍스트 색상을 변경합니다.
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// 텍스트 두께를 변경합니다.
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  /// 텍스트 크기를 변경합니다.
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
