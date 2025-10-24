/// 이벤트 배너 모델
class EventBannerModel {
  final String id;
  final String title; // 배너 제목
  final String subtitle; // 배너 부제목
  final String? imageUrl; // 배너 이미지 URL (옵셔널)
  final String? linkUrl; // 클릭 시 이동할 URL
  final String backgroundColor; // 배경색 (헥스 코드)
  final String textColor; // 텍스트 색상

  EventBannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    this.imageUrl,
    this.linkUrl,
    this.backgroundColor = '#5B6FED',
    this.textColor = '#FFFFFF',
  });
}
