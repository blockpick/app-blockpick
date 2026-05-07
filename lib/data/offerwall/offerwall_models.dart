// 오퍼월 도메인 DTO 모델 + enum
// 기획문서 "포인트 적립 및 사용 기획.md" 기준 카테고리 매핑

// ===== Enums =====

/// 오퍼 카테고리 (포인트 규모 기준)
enum OfferwallCategory {
  small,   // 소형 20~40P
  medium,  // 중형 50~100P
  large,   // 대형 120~300P+
  event,   // 이벤트성 500P+
}

OfferwallCategory offerwallCategoryFromString(String? s) {
  switch (s) {
    case 'SMALL':
      return OfferwallCategory.small;
    case 'MEDIUM':
      return OfferwallCategory.medium;
    case 'LARGE':
      return OfferwallCategory.large;
    case 'EVENT':
      return OfferwallCategory.event;
    default:
      return OfferwallCategory.small;
  }
}

String offerwallCategoryToString(OfferwallCategory c) {
  switch (c) {
    case OfferwallCategory.small:
      return 'SMALL';
    case OfferwallCategory.medium:
      return 'MEDIUM';
    case OfferwallCategory.large:
      return 'LARGE';
    case OfferwallCategory.event:
      return 'EVENT';
  }
}

/// 카테고리 한글 라벨
String offerwallCategoryLabel(OfferwallCategory c) {
  switch (c) {
    case OfferwallCategory.small:
      return '소형';
    case OfferwallCategory.medium:
      return '중형';
    case OfferwallCategory.large:
      return '대형';
    case OfferwallCategory.event:
      return '이벤트';
  }
}

/// 카테고리 포인트 범위 설명
String offerwallCategoryPointRange(OfferwallCategory c) {
  switch (c) {
    case OfferwallCategory.small:
      return '20~40P';
    case OfferwallCategory.medium:
      return '50~100P';
    case OfferwallCategory.large:
      return '120~300P+';
    case OfferwallCategory.event:
      return '500P+';
  }
}

/// 오퍼 상태
enum OfferwallOfferStatus {
  active,    // 진행 중
  completed, // 완료됨 (유저가 완료한 경우)
  expired,   // 만료
}

OfferwallOfferStatus offerwallOfferStatusFromString(String? s) {
  switch (s) {
    case 'ACTIVE':
      return OfferwallOfferStatus.active;
    case 'COMPLETED':
      return OfferwallOfferStatus.completed;
    case 'EXPIRED':
      return OfferwallOfferStatus.expired;
    default:
      return OfferwallOfferStatus.active;
  }
}

// ===== DTO =====

/// 오퍼월 개별 오퍼
class OfferwallOffer {
  final String id;
  final String title;
  final String description;
  final int pointReward;
  final OfferwallCategory category;
  final String? sponsorLogoUrl;
  final String clickUrl;
  final OfferwallOfferStatus status;

  const OfferwallOffer({
    required this.id,
    required this.title,
    required this.description,
    required this.pointReward,
    required this.category,
    this.sponsorLogoUrl,
    required this.clickUrl,
    required this.status,
  });

  factory OfferwallOffer.fromJson(Map<String, dynamic> json) {
    return OfferwallOffer(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      pointReward: (json['pointReward'] as num?)?.toInt() ?? 0,
      category: offerwallCategoryFromString(json['category'] as String?),
      sponsorLogoUrl: json['sponsorLogoUrl'] as String?,
      clickUrl: json['clickUrl'] as String? ?? '',
      status: offerwallOfferStatusFromString(json['status'] as String?),
    );
  }
}

/// startOfferwallOffer 응답 — 외부 URL + 트래킹 정보
class StartOfferwallOfferResult {
  final bool success;
  final String? externalUrl;
  final String? message;

  const StartOfferwallOfferResult({
    required this.success,
    this.externalUrl,
    this.message,
  });

  factory StartOfferwallOfferResult.fromJson(Map<String, dynamic> json) {
    return StartOfferwallOfferResult(
      success: json['success'] as bool? ?? false,
      externalUrl: json['externalUrl'] as String?,
      message: json['message'] as String?,
    );
  }
}

/// 오퍼 목록 필터
class OfferwallFilter {
  final OfferwallCategory? category;

  const OfferwallFilter({this.category});

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (category != null) {
      map['category'] = offerwallCategoryToString(category!);
    }
    return map;
  }
}
