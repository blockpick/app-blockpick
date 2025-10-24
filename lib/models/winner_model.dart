/// 상품 타입 (프리미엄 vs 쇼핑몰)
enum PrizeType {
  /// 프리미엄 상품 (명품, 가전제품 등 - 게임 전용, 쇼핑몰 미판매)
  premium,

  /// 쇼핑몰 상품 (숙박권, 항공권, 티켓 등 - 쇼핑몰 구매 가능)
  shop,
}

/// 당첨자 모델
class WinnerModel {
  final String id;
  final String userName;
  final String userAvatar;
  final String prizeName;
  final String prizeImage;
  final PrizeType prizeType;
  final DateTime winDate;
  final String gameId;
  final bool isMyWin; // 내 당첨 여부

  const WinnerModel({
    required this.id,
    required this.userName,
    required this.userAvatar,
    required this.prizeName,
    required this.prizeImage,
    required this.prizeType,
    required this.winDate,
    required this.gameId,
    this.isMyWin = false,
  });

  /// 상품 타입 이름 가져오기
  String get prizeTypeName {
    switch (prizeType) {
      case PrizeType.premium:
        return '프리미엄 상품';
      case PrizeType.shop:
        return '쇼핑몰 상품';
    }
  }

  /// 상품 타입 배지 텍스트
  String get prizeTypeBadge {
    switch (prizeType) {
      case PrizeType.premium:
        return '💎 게임 전용';
      case PrizeType.shop:
        return '🛒 쇼핑 가능';
    }
  }
}
