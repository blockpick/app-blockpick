import '../models/review_model.dart';

/// 목 데이터: 리뷰 목록
class MockReviewData {
  /// X(Twitter) 리뷰
  static final List<ReviewModel> xReviews = [
    ReviewModel(
      id: 'review-x-001',
      userId: 'user-001',
      nickName: 'yoyoyo_1632',
      profileImageUrl: 'https://i.pravatar.cc/150?img=1',
      content: '@blockpick Great!! I won an iPhone 16 Pro last night. Siuuuu...',
      source: ReviewSource.x,
      createdAt: DateTime.now(),
      externalUrl: 'https://x.com/example/status/123',
    ),
  ];

  /// Thread 리뷰
  static final List<ReviewModel> threadReviews = [
    ReviewModel(
      id: 'review-thread-001',
      userId: 'user-002',
      nickName: 'epiktiger_34',
      profileImageUrl: 'https://i.pravatar.cc/150?img=2',
      content: '@blockpick Great!! I won an iPhone 16 Pro last night. Siuuuu...',
      source: ReviewSource.thread,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
      externalUrl: 'https://threads.net/example/123',
    ),
    ReviewModel(
      id: 'review-thread-002',
      userId: 'user-003',
      nickName: 'Jacob_Scott',
      profileImageUrl: 'https://i.pravatar.cc/150?img=3',
      content: 'Got my Airpods Pro delivered super fast. So nice!! @blockpick',
      source: ReviewSource.thread,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      externalUrl: 'https://threads.net/example/456',
    ),
  ];

  /// Blockpick 리뷰
  static final List<ReviewModel> blockpickReviews = [
    ReviewModel(
      id: 'review-blockpick-001',
      userId: 'user-004',
      nickName: 'crystal_lee457',
      profileImageUrl: 'https://i.pravatar.cc/150?img=4',
      content: '@blockpick Great!! I won a iPhone 16 Pro last night. Siuuuu...',
      source: ReviewSource.blockpick,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
    ),
  ];

  /// 전체 리뷰 목록
  static List<ReviewModel> get allReviews {
    return [...xReviews, ...threadReviews, ...blockpickReviews]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// 리뷰 출처별 필터링
  static List<ReviewModel> filterBySource(ReviewSource? source) {
    if (source == null) return allReviews;
    return allReviews.where((r) => r.source == source).toList();
  }
}
