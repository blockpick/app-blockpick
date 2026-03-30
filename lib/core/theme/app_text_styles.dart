import 'package:flutter/material.dart';
import 'app_colors.dart';

/// BlockPick 디자인 시스템 — 타이포그래피 토큰
///
/// Figma "블록픽_2026 / 02.디자인" 기준으로 생성됨.
/// 폰트: Pretendard, letterSpacing: -0.5% ~ -1%
class AppTextStyles {
  // ========================================
  // Display (최대 크기)
  // ========================================

  /// Display 1 — 32px Bold
  static const TextStyle display1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 40 / 32,
    letterSpacing: -0.16,
    color: AppColors.textBlack,
  );

  /// Display 2 — 28px Bold
  static const TextStyle display2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 36 / 28,
    letterSpacing: -0.14,
    color: AppColors.textBlack,
  );

  // ========================================
  // Heading (섹션 제목)
  // ========================================

  /// Heading 1 — 24px Bold
  static const TextStyle heading1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 32 / 24,
    letterSpacing: -0.12,
    color: AppColors.textBlack,
  );

  /// Heading 2 — 22px Bold
  static const TextStyle heading2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 28 / 22,
    letterSpacing: -0.11,
    color: AppColors.textBlack,
  );

  /// Heading 3 — 20px SemiBold
  static const TextStyle heading3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 28 / 20,
    letterSpacing: -0.1,
    color: AppColors.textBlack,
  );

  // ========================================
  // Title (컨텐츠 제목)
  // ========================================

  /// Title 1 — 18px SemiBold, lh:24px, ls:-0.5%
  static const TextStyle title1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 24 / 18,
    letterSpacing: -0.09,
    color: AppColors.textBlack,
  );

  /// Title 2 — 16px SemiBold, lh:24px, ls:-0.5%
  static const TextStyle title2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 24 / 16,
    letterSpacing: -0.08,
    color: AppColors.textBlack,
  );

  /// Title 3 — 14px SemiBold, lh:20px, ls:-0.5%
  static const TextStyle title3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: -0.07,
    color: AppColors.textBlack,
  );

  // ========================================
  // Body (본문)
  // ========================================

  /// Body 1 — 16px Regular, lh:24px
  static const TextStyle body1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 24 / 16,
    letterSpacing: -0.08,
    color: AppColors.gray800,
  );

  /// Body 2 — 16px Medium, lh:24px, ls:-0.5%
  static const TextStyle body2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 24 / 16,
    letterSpacing: -0.08,
    color: AppColors.gray800,
  );

  /// Body 3 — 14px Regular, lh:20px
  static const TextStyle body3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: -0.07,
    color: AppColors.gray800,
  );

  /// Body 4 — 12px Medium, lh:16px, ls:-0.5%
  static const TextStyle body4 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: -0.06,
    color: AppColors.gray800,
  );

  // ========================================
  // Caption (보조 텍스트)
  // ========================================

  /// Caption 1 — 12px Regular, lh:16px, ls:-1%
  static const TextStyle caption1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 16 / 12,
    letterSpacing: -0.12,
    color: AppColors.gray600,
  );

  /// Caption 2 — 12px SemiBold, lh:16px, ls:-1%
  static const TextStyle caption2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 16 / 12,
    letterSpacing: -0.12,
    color: AppColors.gray600,
  );

  /// Caption 3 — 12px Bold, lh:16px, ls:-1%
  static const TextStyle caption3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 16 / 12,
    letterSpacing: -0.12,
    color: AppColors.gray600,
  );

  /// Caption 4 — 11px SemiBold, lh:12px, ls:-1%
  static const TextStyle caption4 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 12 / 11,
    letterSpacing: -0.11,
    color: AppColors.gray400,
  );

  // ========================================
  // Specific Use Cases
  // ========================================

  /// Button — 14px SemiBold
  static const TextStyle button = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 20 / 14,
    letterSpacing: -0.07,
  );

  /// Button Large — 16px Bold
  static const TextStyle buttonLarge = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 24 / 16,
    letterSpacing: -0.08,
  );

  /// Label — 12px Medium
  static const TextStyle label = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 16 / 12,
    letterSpacing: -0.06,
    color: AppColors.gray600,
  );

  /// Hint — 14px Regular
  static const TextStyle hint = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 20 / 14,
    letterSpacing: -0.07,
    color: AppColors.gray400,
  );

  // ========================================
  // Aliases (기존 코드 호환용)
  // ========================================

  static const TextStyle display = display1;
  static const TextStyle large = heading1;
  static const TextStyle xlarge = display1;
  static const TextStyle medium = title1;
  static const TextStyle bodyLarge = body2;
  static const TextStyle body = body3;
  static const TextStyle bodySmall = body4;
  static const TextStyle small = body4;
  static const TextStyle caption = caption1;

  // ========================================
  // Utility
  // ========================================

  static TextStyle gradientText(TextStyle baseStyle) {
    return baseStyle.copyWith(
      foreground: Paint()
        ..shader = AppColors.gradientBluePurplePink.createShader(
          const Rect.fromLTWH(0, 0, 200, 70),
        ),
    );
  }

  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }

  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
}
