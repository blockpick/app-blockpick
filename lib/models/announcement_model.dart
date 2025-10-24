/// 공지사항 모델
class AnnouncementModel {
  final String id;
  final String title; // 공지 제목
  final String content; // 공지 내용
  final DateTime createdAt; // 등록 일시
  final bool isImportant; // 중요 공지 여부
  final String? imageUrl; // 첨부 이미지 (옵셔널)

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isImportant = false,
    this.imageUrl,
  });

  /// 날짜 포맷팅 (예: "2025.10.23 20:00")
  String get formattedDate {
    return '${createdAt.year}.${createdAt.month.toString().padLeft(2, '0')}.${createdAt.day.toString().padLeft(2, '0')} ${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
