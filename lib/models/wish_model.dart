// 소원(Wish) 데이터 모델 - 소원 등록, 공감, 소문내기에 사용

/// 소원 카테고리
enum WishCategory {
  food('식품/음료', '🍽️'),
  beauty('뷰티/화장품', '💄'),
  fashion('패션/의류', '👟'),
  electronics('전자기기', '🎮'),
  figure('피규어/굿즈', '🤖'),
  travel('여행/체험', '✈️'),
  lifestyle('생활용품', '🏠'),
  etc('기타', '📦');

  final String label;
  final String emoji;
  const WishCategory(this.label, this.emoji);
}

/// 소원 상태
enum WishStatus {
  pending, // 공감 수집 중
  active, // 공감 달성, 판 배치 대기
  inGame, // 게임판에 노출 중
  won, // 당첨자 발생
  expired, // 공감 미달성 만료
  rejected, // 운영 검수 탈락
  fulfilled, // 상품 구매 완료
}

/// 소원 타입
enum WishType {
  personal, // 개인 소원
  business, // 업체 소원
}

/// 소원 모델
class Wish {
  final String id;
  final String userId;
  final WishType type;
  final String oneLiner;
  final String productName;
  final String productImageUrl;
  final String purchaseUrl;
  final int productPrice;
  final WishCategory category;
  final int empathyCount;
  final int empathyThreshold;
  final int participantCount;
  final int wonCount;
  final WishStatus status;
  final String? userName;
  final String? userAvatarUrl;
  final String? businessName;
  final String? prizeDescription;
  final int? prizeValue;
  final int? maxExposures;
  final int? currentExposures;
  final DateTime createdAt;

  const Wish({
    required this.id,
    required this.userId,
    required this.type,
    required this.oneLiner,
    required this.productName,
    required this.productImageUrl,
    required this.purchaseUrl,
    required this.productPrice,
    required this.category,
    this.empathyCount = 0,
    this.empathyThreshold = 10,
    this.participantCount = 0,
    this.wonCount = 0,
    this.status = WishStatus.pending,
    this.userName,
    this.userAvatarUrl,
    this.businessName,
    this.prizeDescription,
    this.prizeValue,
    this.maxExposures,
    this.currentExposures,
    required this.createdAt,
  });

  /// 업체 소원 여부
  bool get isBusinessWish => type == WishType.business;

  /// 공감 달성 비율 (0.0 ~ 1.0)
  double get empathyProgress =>
      empathyThreshold > 0 ? (empathyCount / empathyThreshold).clamp(0.0, 1.0) : 0.0;

  /// 공감 달성 여부
  bool get isEmpathyReached => empathyCount >= empathyThreshold;

  /// 업체 노출 진행률 (0.0 ~ 1.0)
  double get exposureProgress {
    if (maxExposures == null || maxExposures == 0) return 0.0;
    return ((currentExposures ?? 0) / maxExposures!).clamp(0.0, 1.0);
  }

  /// 남은 공감 수
  int get remainingEmpathy => (empathyThreshold - empathyCount).clamp(0, empathyThreshold);

  Wish copyWith({
    String? id,
    String? userId,
    WishType? type,
    String? oneLiner,
    String? productName,
    String? productImageUrl,
    String? purchaseUrl,
    int? productPrice,
    WishCategory? category,
    int? empathyCount,
    int? empathyThreshold,
    int? participantCount,
    int? wonCount,
    WishStatus? status,
    String? userName,
    String? userAvatarUrl,
    String? businessName,
    String? prizeDescription,
    int? prizeValue,
    int? maxExposures,
    int? currentExposures,
    DateTime? createdAt,
  }) {
    return Wish(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      oneLiner: oneLiner ?? this.oneLiner,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      purchaseUrl: purchaseUrl ?? this.purchaseUrl,
      productPrice: productPrice ?? this.productPrice,
      category: category ?? this.category,
      empathyCount: empathyCount ?? this.empathyCount,
      empathyThreshold: empathyThreshold ?? this.empathyThreshold,
      participantCount: participantCount ?? this.participantCount,
      wonCount: wonCount ?? this.wonCount,
      status: status ?? this.status,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      businessName: businessName ?? this.businessName,
      prizeDescription: prizeDescription ?? this.prizeDescription,
      prizeValue: prizeValue ?? this.prizeValue,
      maxExposures: maxExposures ?? this.maxExposures,
      currentExposures: currentExposures ?? this.currentExposures,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

/// 소원 공감 (댓글)
class WishEmpathy {
  final String id;
  final String wishId;
  final String userId;
  final String userName;
  final String? comment;
  final DateTime createdAt;

  const WishEmpathy({
    required this.id,
    required this.wishId,
    required this.userId,
    required this.userName,
    this.comment,
    required this.createdAt,
  });
}

/// 소원 정렬
enum WishSort {
  popular('🔥 인기'),
  newest('🆕 최신'),
  endingSoon('⏰ 마감임박');

  final String label;
  const WishSort(this.label);
}

/// URL 파싱 결과
class ParsedUrlResult {
  final String? productName;
  final int? price;
  final String? imageUrl;
  final String? storeName;
  final bool isValid;
  final String? errorMessage;

  const ParsedUrlResult({
    this.productName,
    this.price,
    this.imageUrl,
    this.storeName,
    this.isValid = false,
    this.errorMessage,
  });
}
