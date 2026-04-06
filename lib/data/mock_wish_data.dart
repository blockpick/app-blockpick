import '../models/wish_model.dart';

/// Mock 소원 데이터 (백엔드 API 구현 전 UI 개발용)
class MockWishData {
  static final List<Wish> wishes = [
    Wish(
      id: 'wish-001',
      userId: 'user-001',
      type: WishType.personal,
      oneLiner: '어릴 때부터 갖고 싶었던 건담 RG 사자비!',
      productName: 'RG 사자비 1/144',
      productImageUrl: 'https://images.unsplash.com/photo-1569017388730-020b5f80a004?w=400&h=400&fit=crop',
      purchaseUrl: 'https://coupang.com/product/12345',
      productPrice: 55000,
      category: WishCategory.figure,
      empathyCount: 47,
      empathyThreshold: 10,
      participantCount: 1234,
      wonCount: 1,
      status: WishStatus.inGame,
      userName: '건담매니아',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Wish(
      id: 'wish-002',
      userId: 'user-002',
      type: WishType.personal,
      oneLiner: '에어팟 프로 사고 싶다!! 노이즈캔슬링 짱',
      productName: '에어팟 프로 2세대',
      productImageUrl: 'https://images.unsplash.com/photo-1606220945770-b5b6c2c55bf1?w=400&h=400&fit=crop',
      purchaseUrl: 'https://apple.com/airpods-pro',
      productPrice: 359000,
      category: WishCategory.electronics,
      empathyCount: 23,
      empathyThreshold: 30,
      participantCount: 834,
      status: WishStatus.inGame,
      userName: '음악러버',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Wish(
      id: 'wish-003',
      userId: 'user-003',
      type: WishType.business,
      oneLiner: '소원을 빌어봐! 운전면허 취득 도전하세요',
      productName: '운전면허 풀패키지',
      productImageUrl: 'https://images.unsplash.com/photo-1449965408869-ebd3fee73e46?w=400&h=400&fit=crop',
      purchaseUrl: 'https://drivingzone.co.kr',
      productPrice: 700000,
      category: WishCategory.travel,
      empathyCount: 0,
      empathyThreshold: 0,
      participantCount: 3720,
      status: WishStatus.inGame,
      userName: '드라이빙존',
      businessName: '드라이빙존',
      prizeDescription: '운전면허 풀패키지 (70만원 상당)',
      prizeValue: 700000,
      maxExposures: 5000,
      currentExposures: 3720,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Wish(
      id: 'wish-004',
      userId: 'user-004',
      type: WishType.personal,
      oneLiner: '시드니 여행 가고 싶어요! 호주 가보고 싶다',
      productName: '시드니 멜버른 8박 9일 여행권',
      productImageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=400&h=400&fit=crop',
      purchaseUrl: 'https://travel.naver.com/sydney',
      productPrice: 1200000,
      category: WishCategory.travel,
      empathyCount: 92,
      empathyThreshold: 100,
      participantCount: 4523,
      status: WishStatus.inGame,
      userName: '여행가고싶다',
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Wish(
      id: 'wish-005',
      userId: 'user-005',
      type: WishType.personal,
      oneLiner: '결혼 10주년 아내에게 선물하고 싶어요',
      productName: '나이키 에어맥스 97',
      productImageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=400&h=400&fit=crop',
      purchaseUrl: 'https://nike.com/airmax97',
      productPrice: 189000,
      category: WishCategory.fashion,
      empathyCount: 7,
      empathyThreshold: 20,
      participantCount: 0,
      status: WishStatus.pending,
      userName: '좋은남편',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    ),
    Wish(
      id: 'wish-006',
      userId: 'user-006',
      type: WishType.personal,
      oneLiner: '이 드라이어 유튜브에서 봤는데 대박!',
      productName: '다이슨 에어랩',
      productImageUrl: 'https://images.unsplash.com/photo-1522338242992-e1a54906a8da?w=400&h=400&fit=crop',
      purchaseUrl: 'https://coupang.com/dyson-airwrap',
      productPrice: 599000,
      category: WishCategory.beauty,
      empathyCount: 35,
      empathyThreshold: 50,
      participantCount: 0,
      status: WishStatus.pending,
      userName: '뷰티덕후',
      createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    Wish(
      id: 'wish-007',
      userId: 'user-007',
      type: WishType.business,
      oneLiner: '소원을 빌어봐! 프리미엄 화장품 세트',
      productName: '설화수 자음생 세트',
      productImageUrl: 'https://images.unsplash.com/photo-1596462502278-27bfdc403348?w=400&h=400&fit=crop',
      purchaseUrl: 'https://sulwhasoo.com',
      productPrice: 450000,
      category: WishCategory.beauty,
      empathyCount: 0,
      empathyThreshold: 0,
      participantCount: 1850,
      status: WishStatus.inGame,
      userName: '설화수',
      businessName: '설화수',
      prizeDescription: '자음생 세트 (45만원 상당)',
      prizeValue: 450000,
      maxExposures: 2500,
      currentExposures: 1850,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Wish(
      id: 'wish-008',
      userId: 'user-008',
      type: WishType.personal,
      oneLiner: '학교 졸업 선물로 딱인 노트북!',
      productName: '맥북 에어 M3',
      productImageUrl: 'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400&h=400&fit=crop',
      purchaseUrl: 'https://apple.com/macbook-air',
      productPrice: 1590000,
      category: WishCategory.electronics,
      empathyCount: 15,
      empathyThreshold: 100,
      participantCount: 0,
      status: WishStatus.pending,
      userName: '졸업생',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    Wish(
      id: 'wish-009',
      userId: 'user-009',
      type: WishType.personal,
      oneLiner: '매일 마시는 커피 한 달치 갖고 싶어요',
      productName: '스타벅스 원두 1kg',
      productImageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=400&fit=crop',
      purchaseUrl: 'https://starbucks.co.kr/beans',
      productPrice: 32000,
      category: WishCategory.food,
      empathyCount: 5,
      empathyThreshold: 5,
      participantCount: 456,
      status: WishStatus.inGame,
      userName: '커피중독',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Wish(
      id: 'wish-010',
      userId: 'user-010',
      type: WishType.personal,
      oneLiner: '레고 스타워즈 밀레니엄 팔콘 조립하고 싶다',
      productName: '레고 스타워즈 밀레니엄 팔콘 75375',
      productImageUrl: 'https://images.unsplash.com/photo-1587654780291-39c9404d7dd0?w=400&h=400&fit=crop',
      purchaseUrl: 'https://lego.com/millennium-falcon',
      productPrice: 219000,
      category: WishCategory.figure,
      empathyCount: 12,
      empathyThreshold: 20,
      participantCount: 0,
      status: WishStatus.pending,
      userName: '레고매니아',
      createdAt: DateTime.now().subtract(const Duration(hours: 18)),
    ),
  ];

  /// 카테고리별 필터
  static List<Wish> getByCategory(WishCategory? category) {
    if (category == null) return wishes;
    return wishes.where((w) => w.category == category).toList();
  }

  /// 정렬
  static List<Wish> getSorted(List<Wish> list, WishSort sort) {
    final sorted = List<Wish>.from(list);
    switch (sort) {
      case WishSort.popular:
        sorted.sort((a, b) =>
            (b.empathyCount * 2 + b.participantCount)
                .compareTo(a.empathyCount * 2 + a.participantCount));
      case WishSort.newest:
        sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case WishSort.endingSoon:
        // IN_GAME 상태를 우선, 그 다음 참여자 많은 순
        sorted.sort((a, b) {
          if (a.status == WishStatus.inGame && b.status != WishStatus.inGame) return -1;
          if (a.status != WishStatus.inGame && b.status == WishStatus.inGame) return 1;
          return b.participantCount.compareTo(a.participantCount);
        });
    }
    return sorted;
  }

  /// 소원 상세 조회
  static Wish? getById(String id) {
    try {
      return wishes.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 업체 소원만
  static List<Wish> get businessWishes =>
      wishes.where((w) => w.type == WishType.business).toList();

  /// Mock 공감 댓글
  static List<WishEmpathy> getEmpathies(String wishId) {
    return [
      WishEmpathy(
        id: 'emp-001',
        wishId: wishId,
        userId: 'user-100',
        userName: '소원응원단',
        comment: '이거 진짜 탐나요 ㅠㅠ',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      WishEmpathy(
        id: 'emp-002',
        wishId: wishId,
        userId: 'user-101',
        userName: '쇼핑왕',
        comment: '저도 어릴 때부터 갖고 싶었어요',
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      ),
      WishEmpathy(
        id: 'emp-003',
        wishId: wishId,
        userId: 'user-102',
        userName: '행운의주인공',
        comment: '같이 소문내요! 당첨되면 좋겠다',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      ),
      WishEmpathy(
        id: 'emp-004',
        wishId: wishId,
        userId: 'user-103',
        userName: '덕후친구',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      WishEmpathy(
        id: 'emp-005',
        wishId: wishId,
        userId: 'user-104',
        userName: '소원빌기',
        comment: '소문내기 참여했어요! 화이팅!',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),
    ];
  }
}
