/// 실시간 참가 이력 모델
class ParticipationFeedModel {
  final String id;
  final String userName; // 익명 처리된 사용자명 (예: "김**")
  final String gameName; // 참가한 게임/상품명
  final DateTime participatedAt; // 참가 시간
  final String? userAvatar; // 사용자 아바타 (옵셔널)

  ParticipationFeedModel({
    required this.id,
    required this.userName,
    required this.gameName,
    required this.participatedAt,
    this.userAvatar,
  });

  /// 상대 시간 표시 (예: "2분 전", "1시간 전")
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(participatedAt);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else {
      return '${difference.inDays}일 전';
    }
  }
}
