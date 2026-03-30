import 'package:flutter/material.dart';

/// BlockPick 디자인 시스템 — 색상 토큰
///
/// Figma "블록픽_2026 / 02.디자인" 기준으로 생성됨.
/// 색상을 변경할 때 이 파일만 수정하면 앱 전체에 반영됩니다.
class AppColors {
  // ========================================
  // Primary Colors
  // ========================================

  /// Primary Main — #5941F2
  static const Color primaryMain = Color(0xFF5941F2);

  /// Primary Light (Hover/Press) — #705CF2
  static const Color primaryLight = Color(0xFF705CF2);

  /// Primary Dark — #46399B
  static const Color primaryDark = Color(0xFF46399B);

  /// Primary BG — #E8E6FF
  static const Color primaryBg = Color(0xFFE8E6FF);

  // ========================================
  // Grayscale
  // ========================================

  /// Black — #191F28
  static const Color textBlack = Color(0xFF191F28);

  /// Gray 800 — #333D4B
  static const Color gray800 = Color(0xFF333D4B);

  /// Gray 600 — #6B7684
  static const Color gray600 = Color(0xFF6B7684);

  /// Gray 400 — #ADB5BD
  static const Color gray400 = Color(0xFFADB5BD);

  /// Gray 200 — #E5E8EB
  static const Color gray200 = Color(0xFFE5E8EB);

  /// Gray 100 — #F2F4F6
  static const Color gray100 = Color(0xFFF2F4F6);

  /// White — #FFFFFF
  static const Color white = Color(0xFFFFFFFF);

  // ========================================
  // Point Colors — 500 (원색)
  // ========================================

  /// Red 500 — #F04452
  static const Color red = Color(0xFFF04452);

  /// Blue 500 — #3182F6
  static const Color blue = Color(0xFF3182F6);

  /// Green 500 — #04D94F
  static const Color green500 = Color(0xFF04D94F);

  /// Yellow 500 — #F5CE0D
  static const Color yellow500 = Color(0xFFF5CE0D);

  // ========================================
  // Point Colors — 200 (파스텔)
  // ========================================

  /// Red 200 — #FFDADD
  static const Color red200 = Color(0xFFFFDADD);

  /// Blue 200 — #D5E6FF
  static const Color blue200 = Color(0xFFD5E6FF);

  /// Green 200 — #D1FCE0
  static const Color green200 = Color(0xFFD1FCE0);

  /// Yellow 200 — #FFF6C8
  static const Color yellow200 = Color(0xFFFFF6C8);

  // ========================================
  // Opacity
  // ========================================

  /// White 40%
  static Color whiteOpacity40 = const Color(0xFFFFFFFF).withValues(alpha: 0.4);

  // ========================================
  // Gradient Colors
  // ========================================

  /// Gradient/Main
  static const LinearGradient gradientMain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
  );

  /// Gradient/Gold
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFFF59E0B)],
  );

  /// Gradient/Dark Purple
  static const LinearGradient gradientDarkPurple = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5941F2), Color(0xFF7C3AED)],
  );

  /// Blue Gradient (레거시 호환)
  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3182F6), primaryMain],
  );

  /// Pink Gradient (레거시 호환)
  static const LinearGradient gradientPink = LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    stops: [0.06, 1.0],
    colors: [Color(0xFFFF58BB), Color(0xFFFF5D5C)],
  );

  /// Purple Gradient (레거시 호환)
  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment(-0.5, -1.0),
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFFE33FF4), primaryMain],
  );

  /// Light Gradient (레거시 호환)
  static const LinearGradient gradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.04, 1.0],
    colors: [gray100, primaryBg],
  );

  /// Blue-Purple-Pink Gradient (버튼용)
  static const LinearGradient gradientBluePurplePink = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [blue, primaryMain, Color(0xFFFF58BB)],
  );

  /// Disable Gradient
  static const LinearGradient gradientDisable = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gray200, gray200],
  );

  // ========================================
  // Aliases (기존 코드 호환용)
  // ========================================

  // -- Primary aliases --
  static const Color primary = primaryMain;
  static const Color purple = primaryLight;
  static const Color pink = Color(0xFFFF58BB);

  // -- Text color aliases --
  static const Color darkBlue = textBlack;
  static const Color navy = gray800;
  static const Color navyWhite = gray600;
  static const Color grayBlue = gray400;
  static const Color medium = gray600;
  static const Color light = gray400;
  static const Color hint = gray400;
  static const Color black = textBlack;
  static const Color dark = gray800;
  static const Color darker = textBlack;

  // -- Background aliases --
  static const Color deepWhite = white;
  static const Color blueWhite = primaryBg;
  static const Color bgWhite = gray100;
  static const Color whiteGray = gray100;
  static const Color disable = gray200;
  static const Color background = white;

  // -- Semantic aliases --
  static const Color mint = green500;
  static const Color green = green500;
  static const Color success = green500;
  static const Color error = red;
  static const Color yellow = yellow500;
  static const Color orange = Color(0xFFFF9500);

  // -- Grayscale aliases --
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray300 = gray200;
  static const Color gray500 = gray400;
  static const Color gray700 = gray600;
  static const Color gray900 = textBlack;

  // -- Stroke aliases --
  static const Color buleGray = gray200;
  static const Color navyStroke = textBlack;

  // ========================================
  // Utility Methods
  // ========================================

  static Color withOpacity(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }

  static Color shadowColor(Color color) {
    return color.withValues(alpha: 0.3);
  }
}
