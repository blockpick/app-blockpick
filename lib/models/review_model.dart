/// 리뷰 출처 타입
enum ReviewSource {
  x,
  thread,
  blockpick,
}

/// 리뷰 출처 확장
extension ReviewSourceExtension on ReviewSource {
  String get displayName {
    switch (this) {
      case ReviewSource.x:
        return 'X';
      case ReviewSource.thread:
        return 'Thread';
      case ReviewSource.blockpick:
        return 'Blockpick';
    }
  }

  String get iconAsset {
    switch (this) {
      case ReviewSource.x:
        return 'assets/icons/x_logo.png';
      case ReviewSource.thread:
        return 'assets/icons/thread_logo.png';
      case ReviewSource.blockpick:
        return 'assets/icons/blockpick_logo.png';
    }
  }
}

/// 리뷰 모델
class ReviewModel {
  final String id;
  final String userId;
  final String nickName;
  final String? profileImageUrl;
  final String content;
  final ReviewSource source;
  final DateTime createdAt;
  final String? externalUrl;

  const ReviewModel({
    required this.id,
    required this.userId,
    required this.nickName,
    this.profileImageUrl,
    required this.content,
    required this.source,
    required this.createdAt,
    this.externalUrl,
  });

  /// 프로필 이미지가 있는지 확인
  bool get hasProfileImage =>
      profileImageUrl != null && profileImageUrl!.isNotEmpty;

  /// 닉네임 초성 가져오기
  String get initial {
    if (nickName.isEmpty) return '?';
    return nickName[0].toUpperCase();
  }

  /// JSON에서 모델 생성
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      nickName: json['nickName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      content: json['content'] as String,
      source: ReviewSource.values.firstWhere(
        (e) => e.name == json['source'],
        orElse: () => ReviewSource.blockpick,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
      externalUrl: json['externalUrl'] as String?,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'nickName': nickName,
      'profileImageUrl': profileImageUrl,
      'content': content,
      'source': source.name,
      'createdAt': createdAt.toIso8601String(),
      'externalUrl': externalUrl,
    };
  }
}
