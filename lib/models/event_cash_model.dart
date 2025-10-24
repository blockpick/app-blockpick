/// 이벤트 캐시 모델
class EventCashModel {
  final double totalAmount; // 총 캐시 금액
  final String currency; // 통화 (USDT, KRW 등)
  final double todayChange; // 오늘의 변동 금액
  final double todayChangePercent; // 오늘의 변동 퍼센트
  final List<CashHistoryPoint> history; // 차트 데이터

  EventCashModel({
    required this.totalAmount,
    required this.currency,
    required this.todayChange,
    required this.todayChangePercent,
    required this.history,
  });
}

/// 캐시 히스토리 포인트 (차트용)
class CashHistoryPoint {
  final DateTime date;
  final double amount;
  final int participationCount; // 참가 횟수
  final int winCount; // 당첨 횟수
  final double winRate; // 당첨률 (%)
  final double roi; // ROI (%)

  CashHistoryPoint({
    required this.date,
    required this.amount,
    this.participationCount = 0,
    this.winCount = 0,
    this.winRate = 0.0,
    this.roi = 0.0,
  });
}
