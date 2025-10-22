import 'package:flutter/material.dart';

/// BlockPick 앱의 색상 시스템
///
/// UI_SPECIFICATION 문서에서 정의된 색상 팔레트를 구현합니다.
class AppColors {
  // ========== Main Colors ==========

  /// Primary blue - 주요 CTA, 버튼, 하이라이트
  static const Color blue = Color(0xFF5C72F5);

  /// Purple - 보조 액센트, 그라데이션
  static const Color purple = Color(0xFF6E5AE9);

  /// Pink - 알림, 주요 콘텐츠, 그라데이션
  static const Color pink = Color(0xFFFF58BB);

  /// Red - 삭제 액션, 오류
  static const Color red = Color(0xFFFF5D5C);

  /// Green - 성공, 활성 상태
  static const Color green = Color(0xFF10B981);

  /// Yellow - 경고, 시간 제한 표시
  static const Color yellow = Color(0xFFF59E0B);

  /// White - 배경, 텍스트
  static const Color white = Color(0xFFFFFFFF);

  // ========== Background Colors ==========

  /// Deep White - 기본 배경
  static const Color deepWhite = Color(0xFFFCFCFC);

  /// Blue White - 보조 배경, 호버 상태
  static const Color blueWhite = Color(0xFFECF1F9);

  /// BG White - 카드 배경, 테두리
  static const Color bgWhite = Color(0xFFEFF2F7);

  /// White Gray - 대체 배경
  static const Color whiteGray = Color(0xFFFCFCFC);

  /// Disable - 비활성 상태
  static const Color disable = Color(0xFFDEDEDE);

  // ========== Text Colors ==========

  /// Dark Blue - 주요 텍스트 (H1, 헤드라인)
  static const Color darkBlue = Color(0xFF081245);

  /// Navy - 보조 텍스트 (본문)
  static const Color navy = Color(0xFF2D3661);

  /// Navy White - 삼차 텍스트
  static const Color navyWhite = Color(0xFF4B547F);

  /// Gray Blue - 힌트 텍스트
  static const Color grayBlue = Color(0xFF8A91B0);

  /// Medium - 일반 텍스트
  static const Color medium = Color(0xFF555555);

  /// Light - 4차 텍스트 (힌트)
  static const Color light = Color(0xFF999999);

  /// Hint - 비활성 텍스트, 매우 연한
  static const Color hint = Color(0xFFC5C9DC);

  /// Black
  static const Color black = Color(0xFF111111);

  /// Dark
  static const Color dark = Color(0xFF333333);

  // ========== Stroke Colors ==========

  /// Bule Gray - 기본 border
  static const Color buleGray = Color(0xFFDADBE3);

  /// Navy Stroke - 강조 border
  static const Color navyStroke = Color(0xFF2A3547);

  // ========== Gradient Definitions ==========

  /// Blue Gradient (147deg, #3D81F6 0%, #875DF4 100%)
  static const LinearGradient gradientBlue = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D81F6), Color(0xFF875DF4)],
  );

  /// Pink Gradient (138deg, #FF58BB 6%, #FF5D5C 100%)
  static const LinearGradient gradientPink = LinearGradient(
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
    stops: [0.06, 1.0],
    colors: [Color(0xFFFF58BB), Color(0xFFFF5D5C)],
  );

  /// Purple Gradient (151deg, #E33FF4 0%, #6E5AE9 100%)
  static const LinearGradient gradientPurple = LinearGradient(
    begin: Alignment(-0.5, -1.0),
    end: Alignment(0.5, 1.0),
    colors: [Color(0xFFE33FF4), Color(0xFF6E5AE9)],
  );

  /// Light Gradient (146deg, #EFF6FF 4%, #F9F5FF 100%)
  static const LinearGradient gradientLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.04, 1.0],
    colors: [Color(0xFFEFF6FF), Color(0xFFF9F5FF)],
  );

  /// Blue-Purple-Pink Gradient (for buttons)
  static const LinearGradient gradientBluePurplePink = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [blue, purple, pink],
  );

  /// Disable Gradient
  static const LinearGradient gradientDisable = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [disable, disable],
  );

  // ========== Utility Methods ==========

  /// 색상에 투명도를 적용합니다.
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }

  /// 그림자 색상을 반환합니다 (30% 투명도).
  static Color shadowColor(Color color) {
    return color.withOpacity(0.3);
  }
}
