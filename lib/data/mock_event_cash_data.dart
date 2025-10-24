import '../models/event_cash_model.dart';

/// 이벤트 캐시 목 데이터
class MockEventCashData {
  static EventCashModel getEventCash() {
    return EventCashModel(
      totalAmount: 127500,
      currency: 'KRW',
      todayChange: 12500,
      todayChangePercent: 10.9,
      history: _generateHistory(),
    );
  }

  /// 차트 데이터 생성 (최근 6개월)
  static List<CashHistoryPoint> _generateHistory() {
    final now = DateTime.now();
    final history = <CashHistoryPoint>[];

    int cumulativeParticipation = 0;
    int cumulativeWin = 0;

    // 6개월간 데이터 생성
    for (int i = 180; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));

      // 자연스러운 변동 패턴 (점진적 증가 + 노이즈)
      final baseAmount = 100000;
      final growth = (180 - i) * 150; // 점진적 증가
      final noise = (i % 7) * 1000 - (i % 5) * 800; // 변동성
      final weekendBonus = (date.weekday == 6 || date.weekday == 7) ? 2000 : 0;

      final amount = baseAmount + growth + noise + weekendBonus;

      // 통계 데이터 생성 (누적)
      final dailyParticipation = (180 - i) ~/ 10 + (i % 3); // 점진적 증가
      final dailyWin = (dailyParticipation * 0.15).round(); // 약 15% 당첨

      cumulativeParticipation += dailyParticipation;
      cumulativeWin += dailyWin;

      final winRate = cumulativeParticipation > 0
          ? (cumulativeWin / cumulativeParticipation * 100).clamp(0, 100)
          : 0.0;

      final roi = 100 + (180 - i) * 0.8 + (i % 10) * 5.0; // 점진적 증가

      history.add(CashHistoryPoint(
        date: date,
        amount: amount.toDouble().clamp(80000, 150000),
        participationCount: cumulativeParticipation,
        winCount: cumulativeWin,
        winRate: winRate.toDouble(),
        roi: roi.clamp(0, 300),
      ));
    }

    return history;
  }
}
