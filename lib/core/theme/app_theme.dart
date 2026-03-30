import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// BlockPick 앱의 테마 시스템
class AppTheme {
  /// Light Theme (기본 테마)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryMain,
        secondary: AppColors.primaryLight,
        tertiary: AppColors.primaryDark,
        error: AppColors.red,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.textBlack,
        onError: AppColors.white,
      ),

      // Scaffold
      scaffoldBackgroundColor: AppColors.white,

      // AppBar Theme
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textBlack,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textBlack,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          textStyle: AppTextStyles.button,
          foregroundColor: AppColors.primaryMain,
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTextStyles.button,
          side: const BorderSide(color: AppColors.gray200, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      // Icon Button Theme
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: AppColors.gray600,
          highlightColor: AppColors.primaryBg,
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.gray100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.gray200, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryMain, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red, width: 1),
        ),
        hintStyle: AppTextStyles.hint,
        labelStyle: AppTextStyles.label,
      ),

      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: AppColors.gray200,
        thickness: 1,
        space: 1,
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        elevation: 8,
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Text Theme — Figma 디자인 시스템 매핑
      textTheme: const TextTheme(
        displayLarge: AppTextStyles.display1,
        displayMedium: AppTextStyles.display2,
        displaySmall: AppTextStyles.heading1,
        headlineLarge: AppTextStyles.heading2,
        headlineMedium: AppTextStyles.heading3,
        headlineSmall: AppTextStyles.title1,
        titleLarge: AppTextStyles.title2,
        titleMedium: AppTextStyles.title3,
        bodyLarge: AppTextStyles.body1,
        bodyMedium: AppTextStyles.body3,
        bodySmall: AppTextStyles.body4,
        labelLarge: AppTextStyles.caption2,
        labelMedium: AppTextStyles.caption1,
        labelSmall: AppTextStyles.caption4,
      ),

      // Icon Theme
      iconTheme: const IconThemeData(
        color: AppColors.gray600,
        size: 24,
      ),
    );
  }

  /// 그라데이션 배경을 가진 Container 데코레이션
  static BoxDecoration get gradientBackground {
    return const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppColors.white,
          AppColors.primaryBg,
          AppColors.primaryBg,
        ],
        stops: [0.0, 0.5, 1.0],
      ),
    );
  }

  /// 카드 데코레이션
  static BoxDecoration cardDecoration({Color? color, Color? borderColor}) {
    return BoxDecoration(
      color: color ?? AppColors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: borderColor ?? AppColors.gray200,
        width: 1,
      ),
    );
  }

  /// 그림자 효과
  static List<BoxShadow> get defaultShadow {
    return [
      BoxShadow(
        color: AppColors.black.withValues(alpha: 0.1),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  /// 버튼 그림자 효과
  static List<BoxShadow> get buttonShadow {
    return [
      BoxShadow(
        color: AppColors.primaryMain.withValues(alpha: 0.3),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ];
  }
}
