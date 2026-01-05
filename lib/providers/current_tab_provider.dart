import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 선택된 탭 인덱스를 관리하는 Provider
///
/// 0: HOME (토스 스타일)
/// 1: My Pick
/// 2: PICK (게임 목록)
/// 3: Winners
/// 4: MALL
/// 5: MY (마이페이지)
class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }

  void goToHome() => state = 0;
  void goToMyPick() => state = 1;
  void goToPick() => state = 2;
  void goToWinners() => state = 3;
  void goToMall() => state = 4;
  void goToMy() => state = 5;
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(() {
  return CurrentTabNotifier();
});
