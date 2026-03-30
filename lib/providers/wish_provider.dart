import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/wish_model.dart';
import '../data/mock_wish_data.dart';

// ============================================================
// 소원(Wish) Provider
// 백엔드 API 구현 전까지 Mock 데이터 사용
// API 연동 시 Mock → GraphQL 호출로 교체
// ============================================================

/// 선택된 카테고리 필터
final wishCategoryFilterProvider = StateProvider<WishCategory?>((ref) => null);

/// 선택된 정렬
final wishSortProvider = StateProvider<WishSort>((ref) => WishSort.popular);

/// 소원 리스트 (필터 + 정렬 적용)
final wishListProvider = Provider<List<Wish>>((ref) {
  final category = ref.watch(wishCategoryFilterProvider);
  final sort = ref.watch(wishSortProvider);

  final filtered = MockWishData.getByCategory(category);
  return MockWishData.getSorted(filtered, sort);
});

/// 업체 소원 배너 목록
final businessWishBannersProvider = Provider<List<Wish>>((ref) {
  return MockWishData.businessWishes;
});

/// 소원 상세 조회
final wishDetailProvider = Provider.family<Wish?, String>((ref, wishId) {
  return MockWishData.getById(wishId);
});

/// 소원 공감 댓글 목록
final wishEmpathiesProvider = Provider.family<List<WishEmpathy>, String>((ref, wishId) {
  return MockWishData.getEmpathies(wishId);
});

/// 내 소원 목록 (로그인한 사용자의 소원)
final myWishesProvider = Provider<List<Wish>>((ref) {
  // TODO: 실제 로그인 사용자 ID로 필터링
  return MockWishData.wishes.where((w) => w.userId == 'user-001').toList();
});

/// 소원 등록 상태 관리
class WishCreateNotifier extends StateNotifier<AsyncValue<Wish?>> {
  WishCreateNotifier() : super(const AsyncData(null));

  /// 소원 등록 폼 데이터
  String? purchaseUrl;
  String? productName;
  int? productPrice;
  String? productImageUrl;
  String? oneLiner;
  WishCategory? category;

  /// URL 파싱 결과
  ParsedUrlResult? parsedResult;

  /// URL 파싱 (Mock)
  Future<ParsedUrlResult> parseUrl(String url) async {
    // Mock: 2초 딜레이 후 파싱 결과 반환
    await Future.delayed(const Duration(seconds: 1));

    // URL 기반 간단한 파싱 시뮬레이션
    String storeName = '알 수 없음';
    if (url.contains('coupang')) storeName = '쿠팡';
    if (url.contains('naver')) storeName = '네이버';
    if (url.contains('apple')) storeName = 'Apple';
    if (url.contains('nike')) storeName = 'Nike';
    if (url.contains('amazon')) storeName = 'Amazon';

    parsedResult = ParsedUrlResult(
      productName: '상품명을 입력해주세요',
      price: 0,
      imageUrl: null,
      storeName: storeName,
      isValid: url.startsWith('http'),
      errorMessage: url.startsWith('http') ? null : '올바른 URL 형식이 아닙니다',
    );

    return parsedResult!;
  }

  /// 소원 등록 (Mock)
  Future<Wish> createWish() async {
    state = const AsyncLoading();

    try {
      await Future.delayed(const Duration(seconds: 1));

      final wish = Wish(
        id: 'wish-new-${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current-user',
        type: WishType.personal,
        oneLiner: oneLiner ?? '',
        productName: productName ?? '',
        productImageUrl: productImageUrl ?? 'https://via.placeholder.com/400x400/5941F2/FFFFFF?text=New+Wish',
        purchaseUrl: purchaseUrl ?? '',
        productPrice: productPrice ?? 0,
        category: category ?? WishCategory.etc,
        empathyThreshold: _calculateThreshold(productPrice ?? 0),
        status: WishStatus.pending,
        userName: '나',
        createdAt: DateTime.now(),
      );

      state = AsyncData(wish);
      return wish;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  /// 가격대별 공감 임계값 계산
  int _calculateThreshold(int price) {
    if (price <= 10000) return 5;
    if (price <= 50000) return 10;
    if (price <= 200000) return 20;
    if (price <= 500000) return 30;
    if (price <= 1000000) return 50;
    return 100;
  }

  /// 폼 초기화
  void reset() {
    purchaseUrl = null;
    productName = null;
    productPrice = null;
    productImageUrl = null;
    oneLiner = null;
    category = null;
    parsedResult = null;
    state = const AsyncData(null);
  }
}

final wishCreateProvider =
    StateNotifierProvider<WishCreateNotifier, AsyncValue<Wish?>>((ref) {
  return WishCreateNotifier();
});

/// 공감하기 (Mock)
class EmpathizeWishNotifier extends StateNotifier<AsyncValue<bool?>> {
  EmpathizeWishNotifier() : super(const AsyncData(null));

  Future<bool> empathize(String wishId, {String? comment}) async {
    state = const AsyncLoading();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // TODO: API 호출 → empathizeWish(wishId, comment)
      state = const AsyncData(true);
      return true;
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final empathizeWishProvider =
    StateNotifierProvider<EmpathizeWishNotifier, AsyncValue<bool?>>((ref) {
  return EmpathizeWishNotifier();
});

/// 랜덤 소원 (바로 소문내기용)
final randomWishProvider = Provider<Wish>((ref) {
  final inGameWishes = MockWishData.wishes
      .where((w) => w.status == WishStatus.inGame)
      .toList();
  if (inGameWishes.isEmpty) return MockWishData.wishes.first;

  // 참여자 적은 소원에 가중치
  inGameWishes.sort((a, b) => a.participantCount.compareTo(b.participantCount));
  return inGameWishes.first;
});
