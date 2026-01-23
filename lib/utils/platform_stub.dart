/// 웹에서 dart:io의 Platform을 대체하는 stub
/// 웹에서는 이 파일이 import되어 Platform.isAndroid 등이 false를 반환합니다.

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isLinux => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isFuchsia => false;
  static String get operatingSystem => 'web';
}

/// 웹에서는 exit 함수가 없으므로 no-op
void exit(int code) {
  // 웹에서는 앱 종료 불가 - 아무 작업도 하지 않음
}
