/// 이벤트 타입
enum EventType {
  daily,
  select,
  vibe,
  prime,
}

/// 이벤트 타입 확장
extension EventTypeExtension on EventType {
  String get displayName {
    switch (this) {
      case EventType.daily:
        return 'Daily';
      case EventType.select:
        return 'Select';
      case EventType.vibe:
        return 'Vibe';
      case EventType.prime:
        return 'Prime';
    }
  }

  String get koreanName {
    switch (this) {
      case EventType.daily:
        return '데일리';
      case EventType.select:
        return '셀렉트';
      case EventType.vibe:
        return '바이브';
      case EventType.prime:
        return '프라임';
    }
  }
}

/// 당첨자 모델
class WinnerModel {
  final String id;
  final String? orderId;
  final String userId;
  final String nickName;
  final String? profileImageUrl;
  final String productName;
  final String? productImageUrl;
  final EventType eventType;
  final DateTime winDate;
  final String? gameId;

  const WinnerModel({
    required this.id,
    this.orderId,
    required this.userId,
    required this.nickName,
    this.profileImageUrl,
    required this.productName,
    this.productImageUrl,
    required this.eventType,
    required this.winDate,
    this.gameId,
  });

  /// 프로필 이미지가 있는지 확인
  bool get hasProfileImage =>
      profileImageUrl != null && profileImageUrl!.isNotEmpty;

  /// 닉네임 초성 가져오기 (프로필 이미지가 없을 때 사용)
  String get initial {
    if (nickName.isEmpty) return '?';
    return nickName[0].toUpperCase();
  }

  /// JSON에서 모델 생성
  factory WinnerModel.fromJson(Map<String, dynamic> json) {
    return WinnerModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String?,
      userId: json['userId'] as String,
      nickName: json['nickName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      productName: json['productName'] as String,
      productImageUrl: json['productImageUrl'] as String?,
      eventType: EventType.values.firstWhere(
        (e) => e.name == json['eventType'],
        orElse: () => EventType.daily,
      ),
      winDate: DateTime.parse(json['winDate'] as String),
      gameId: json['gameId'] as String?,
    );
  }

  /// 모델을 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'userId': userId,
      'nickName': nickName,
      'profileImageUrl': profileImageUrl,
      'productName': productName,
      'productImageUrl': productImageUrl,
      'eventType': eventType.name,
      'winDate': winDate.toIso8601String(),
      'gameId': gameId,
    };
  }
}

/// 당첨자 상세 정보 (상세 화면용)
class WinnerDetailModel {
  final WinnerModel winner;
  final int totalParticipants;
  final List<WinnerRankModel> topRankers;
  final String? lottieAnimationUrl;
  final String? blockchainViewUrl;

  const WinnerDetailModel({
    required this.winner,
    required this.totalParticipants,
    required this.topRankers,
    this.lottieAnimationUrl,
    this.blockchainViewUrl,
  });
}

/// 순위 모델 (최종 결과용)
class WinnerRankModel {
  final int rank;
  final String oderId;
  final String userId;
  final String nickName;
  final DateTime selectedTime;
  final int duplicateCount;

  const WinnerRankModel({
    required this.rank,
    required this.oderId,
    required this.userId,
    required this.nickName,
    required this.selectedTime,
    this.duplicateCount = 1,
  });
}
