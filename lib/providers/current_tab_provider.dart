import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 선택된 탭 인덱스를 관리하는 Provider
///
/// 0: HOME
/// 1: EVENT (게임 목록)
/// 2: PARTNER (파트너 이벤트)
/// 3: WINNERS (당첨자)
/// 4: MY (마이페이지)
class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setTab(int index) {
    state = index;
  }

  void goToHome() => state = 0;
  void goToEvent() => state = 1;
  void goToPartner() => state = 2;
  void goToWinners() => state = 3;
  void goToMy() => state = 4;
}

final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(() {
  return CurrentTabNotifier();
});
