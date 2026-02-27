import 'package:flutter/material.dart';

/// BlockPick 앱의 색상 디자인 시스템
///
/// 모든 색상은 이 파일에서 중앙 관리됩니다.
/// 색상을 변경할 때 이 파일만 수정하면 앱 전체에 반영됩니다.
class AppColors {
  // ========================================
  // 🎨 Primary Colors (메인 컬러)
  // ========================================

  /// Primary Main - 서비스 메인 컬러
  static const Color primaryMain = Color(0xFF5941F2);

  /// Primary Light - 메인 컬러의 밝은 톤
  static const Color primaryLight = Color(0xFF705CF2);

  /// Primary Dark - 메인 컬러의 어두운 톤
  static const Color primaryDark = Color(0xFF5549A6);

  /// Primary Background - 메인 컬러의 배경 컬러
  static const Color primaryBg = Color(0xFFE8E6FF);

  // ========================================
  // 🔲 Grayscale (회색 계열)
  // ========================================

  /// Black/Text - 텍스트 제목, 강조용
  static const Color textBlack = Color(0xFF191F28);

  /// Gray 800 - 일반 본문 텍스트
  static const Color gray800 = Color(0xFF333D4B);

  /// Gray 600 - 보조 설명, 비활성 상태
  static const Color gray600 = Color(0xFF6B7684);

  /// Gray 400 - 아이콘, 플레이스홀더
  static const Color gray400 = Color(0xFFADB5BD);

  /// Gray 200 - 구분선, 테두리
  static const Color gray200 = Color(0xFFE5E8EB);

  /// Gray 100 - 버튼, 카드 배경
  static const Color gray100 = Color(0xFFF2F4F6);

  /// White - 기본 배경색
  static const Color white = Color(0xFFFFFFFF);

  // ========================================
  // 🚦 Semantic Colors (의미 색상)
  // ========================================

  /// Red - 삭제, 오류
  static const Color red = Color(0xFFF04452);

  /// Blue - 링크, 정보 강조
  static const Color blue = Color(0xFF3182F6);

  /// Yellow - 주의, 대기 상태
  static const Color yellow = Color(0xFFFFD400);

  /// Mint - 완료, 승인, 성공
  static const Color mint = Color(0xFF04D94F);

  // ========================================
  // 🌈 Gradient Colors (그라데이션)
  // ========================================

  /// Main Gradient - 메인 컬러 활용
  static const LinearGradient gradientMain = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3B82F6), Color(0xFF7C3AED)],
  );

  /// Gold Gradient - 골드
  static const LinearGradient gradientGold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF10B981), Color(0xFFF59E0B)],
  );

  /// Dark Purple Gradient - 퍼플
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
  // 🔗 Aliases (기존 코드 호환용)
  // ========================================
  // 기존 참조를 유지하면서 새 디자인 시스템으로 매핑합니다.
  // 새 코드에서는 위의 디자인 시스템 이름을 직접 사용하세요.

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
  static const Color green = mint;
  static const Color success = mint;
  static const Color error = red;
  static const Color orange = Color(0xFFFF9500);

  // -- Grayscale aliases (기존 Material 스타일 이름) --
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray300 = gray200;
  static const Color gray500 = gray400;
  static const Color gray700 = gray600;
  static const Color gray900 = textBlack;

  // -- Stroke aliases --
  static const Color buleGray = gray200;
  static const Color navyStroke = textBlack;

  // ========================================
  // 🛠 Utility Methods
  // ========================================

  /// 색상에 투명도를 적용합니다.
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// 그림자 색상을 반환합니다 (30% 투명도).
  static Color shadowColor(Color color) {
    return color.withOpacity(0.3);
  }
}
