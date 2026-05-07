/// 오퍼월 SDK 어댑터 인터페이스
///
/// 사업자 선정 후 구체적인 어댑터(TapjoyAdapter, AdGemAdapter 등)를 구현해
/// OfferwallFactory에 등록하면 됩니다.
///
/// 현재 기본값: WebOfferwallAdapter (webview_flutter 기반 웹뷰 fallback)
abstract class OfferwallAdapter {
  /// 오퍼월을 표시합니다.
  ///
  /// [url]: 오퍼월 진입 URL (startOfferwallOffer 응답 또는 offer.clickUrl)
  /// [title]: 화면 제목 (옵션)
  Future<void> showOfferwall({
    required String url,
    String? title,
  });

  /// 오퍼 완료 콜백을 등록합니다.
  ///
  /// 주의: 실제 포인트 적립은 서버사이드 postback으로 처리됩니다.
  /// 이 콜백은 UI 갱신(포인트 새로고침 등) 용도로만 사용하세요.
  void onCompletion(OfferwallCompletionCallback callback);

  /// 리소스를 해제합니다.
  void dispose();
}

/// 오퍼 완료 콜백 타입
///
/// [offerId]: 완료된 오퍼 ID
/// [pointsEarned]: 적립된 포인트 (서버에서 확인 필요 — 클라이언트 값은 참고용)
typedef OfferwallCompletionCallback = void Function({
  String? offerId,
  int? pointsEarned,
});
