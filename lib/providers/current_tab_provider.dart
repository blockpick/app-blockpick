import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 선택된 탭 인덱스를 관리하는 Provider
///
/// 0: HOME (홈)
/// 1: DAILY (데일리)
/// 2: WISH (위시 - 소원/소문)
/// 3: PRIME (프라임 - 역경매)
/// 4: MY (마이페이지)
class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }

  void goToHome() => state = 0;
  void goToDaily() => state = 1;
  void goToWish() => state = 2;
  void goToPrime() => state = 3;
  void goToMy() => state = 4;

  // 하위 호환: 기존 코드에서 goToEvent() 호출 시 데일리로 이동
  void goToEvent() => state = 1;
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(() {
  return CurrentTabNotifier();
});
