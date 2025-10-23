/// BlockPick의 3가지 플랫폼 모드
enum PlatformMode {
  /// 공식 웹사이트 (서비스 소개, 게임 안내, 리소스 등)
  official('OFFICIAL', 'Official'),

  /// BlockPick 앱 메인 (PICK 게임)
  blockpick('BlockPick', 'BlockPick'),

  /// 쇼핑몰 (제품 구매)
  mall('MALL', 'Shopping');

  const PlatformMode(this.id, this.displayName);

  final String id;
  final String displayName;
}
