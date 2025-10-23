import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/platform_mode.dart';

part 'platform_mode_provider.g.dart';

/// 현재 선택된 플랫폼 모드 상태 관리
@riverpod
class PlatformModeNotifier extends _$PlatformModeNotifier {
  @override
  PlatformMode build() {
    // 기본값: BlockPick 앱
    return PlatformMode.blockpick;
  }

  /// 플랫폼 모드 변경
  void changePlatform(PlatformMode mode) {
    state = mode;
  }
}
