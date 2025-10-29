/// 디바운서 (연속 입력 방지)
class Debouncer {
  final int milliseconds;
  DateTime? _lastHit;

  Debouncer(this.milliseconds);

  /// 입력 허용 여부
  bool get allow {
    if (_lastHit == null) return true;
    final elapsed = DateTime.now().difference(_lastHit!);
    return elapsed.inMilliseconds >= milliseconds;
  }

  /// 입력 기록
  void hit() {
    _lastHit = DateTime.now();
  }

  /// 리셋
  void reset() {
    _lastHit = null;
  }
}
