import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'offerwall_models.dart';

/// 오퍼월 도메인 GraphQL 데이터소스
///
/// 백엔드 미구현 시 mock fallback 자동 적용.
/// postback은 서버사이드 처리 — 클라이언트는 진입/조회만 담당.
class OfferwallRemoteDataSource {
  final GraphQLClient _client;

  OfferwallRemoteDataSource(this._client);

  // ===== GraphQL Operations =====

  static const String offerwallOffersQuery = r'''
    query OfferwallOffers($filter: OfferwallFilterInput) {
      offerwallOffers(filter: $filter) {
        success
        code
        message
        items {
          id
          title
          description
          pointReward
          category
          sponsorLogoUrl
          clickUrl
          status
        }
      }
    }
  ''';

  static const String startOfferwallOfferMutation = r'''
    mutation StartOfferwallOffer($offerId: ID!) {
      startOfferwallOffer(offerId: $offerId) {
        success
        code
        message
        externalUrl
      }
    }
  ''';

  // ===== 메서드 =====

  /// 오퍼 목록 조회.
  /// 백엔드 미구현(FIELD_NOT_FOUND 등) 시 mock 데이터 반환.
  Future<List<OfferwallOffer>> fetchOfferwallOffers({
    OfferwallFilter? filter,
  }) async {
    try {
      final result = await _client.query(
        QueryOptions(
          document: gql(offerwallOffersQuery),
          variables: filter != null ? {'filter': filter.toJson()} : {},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      // 백엔드 미구현 또는 네트워크 오류 시 mock fallback
      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('[OfferwallDS] 백엔드 오류 — mock 데이터 반환: ${result.exception}');
        }
        return _mockOffers(filter?.category);
      }

      final data = result.data?['offerwallOffers'];
      if (data == null || data['success'] != true) {
        if (kDebugMode) {
          debugPrint('[OfferwallDS] 응답 실패 — mock 데이터 반환: ${data?['message']}');
        }
        return _mockOffers(filter?.category);
      }

      final rawItems = (data['items'] as List?) ?? const [];
      return rawItems
          .map((e) => OfferwallOffer.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OfferwallDS] 예외 — mock 데이터 반환: $e');
      }
      return _mockOffers(filter?.category);
    }
  }

  /// 오퍼 시작 — 클릭 트래킹 + 외부 URL 반환.
  /// 백엔드 미구현 시 clickUrl을 그대로 반환.
  Future<StartOfferwallOfferResult> startOfferwallOffer(String offerId) async {
    try {
      final result = await _client.mutate(
        MutationOptions(
          document: gql(startOfferwallOfferMutation),
          variables: {'offerId': offerId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        if (kDebugMode) {
          debugPrint('[OfferwallDS] startOffer 오류 — 직접 URL 사용: ${result.exception}');
        }
        return const StartOfferwallOfferResult(
          success: true,
          externalUrl: null, // 호출부에서 offer.clickUrl로 fallback
          message: 'mock',
        );
      }

      final data = result.data?['startOfferwallOffer'];
      if (data == null || data['success'] != true) {
        return StartOfferwallOfferResult(
          success: false,
          message: data?['message'] as String? ?? '오퍼 시작 실패',
        );
      }

      return StartOfferwallOfferResult.fromJson(data as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[OfferwallDS] startOffer 예외: $e');
      }
      return const StartOfferwallOfferResult(
        success: true,
        externalUrl: null,
        message: 'fallback',
      );
    }
  }

  // ===== Mock 데이터 =====

  static List<OfferwallOffer> _mockOffers(OfferwallCategory? filterCategory) {
    final all = <OfferwallOffer>[
      // 소형 오퍼
      const OfferwallOffer(
        id: 'mock_small_1',
        title: '앱 다운로드하고 포인트 받기',
        description: '파트너 앱을 다운로드하고 회원가입을 완료하면 포인트를 드려요.',
        pointReward: 30,
        category: OfferwallCategory.small,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/1',
        status: OfferwallOfferStatus.active,
      ),
      const OfferwallOffer(
        id: 'mock_small_2',
        title: '설문조사 참여하기',
        description: '3분 설문조사에 참여하고 포인트를 받아가세요.',
        pointReward: 20,
        category: OfferwallCategory.small,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/2',
        status: OfferwallOfferStatus.active,
      ),
      // 중형 오퍼
      const OfferwallOffer(
        id: 'mock_medium_1',
        title: '첫 구매 시 포인트 지급',
        description: '파트너 쇼핑몰에서 첫 구매를 완료하면 포인트를 드려요.',
        pointReward: 80,
        category: OfferwallCategory.medium,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/3',
        status: OfferwallOfferStatus.active,
      ),
      const OfferwallOffer(
        id: 'mock_medium_2',
        title: '금융 서비스 가입',
        description: '카드 발급 신청 완료 시 포인트를 드려요.',
        pointReward: 100,
        category: OfferwallCategory.medium,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/4',
        status: OfferwallOfferStatus.active,
      ),
      // 대형 오퍼
      const OfferwallOffer(
        id: 'mock_large_1',
        title: '보험 상담 신청',
        description: '보험 전문가와 무료 상담을 완료하면 포인트를 드려요.',
        pointReward: 200,
        category: OfferwallCategory.large,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/5',
        status: OfferwallOfferStatus.active,
      ),
      const OfferwallOffer(
        id: 'mock_large_2',
        title: '대출 한도 조회',
        description: '대출 한도 조회를 완료하면 포인트를 드려요.',
        pointReward: 150,
        category: OfferwallCategory.large,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/6',
        status: OfferwallOfferStatus.active,
      ),
      // 이벤트 오퍼
      const OfferwallOffer(
        id: 'mock_event_1',
        title: '[이벤트] 부동산 앱 가입 + 매물 조회',
        description: '앱 가입 후 매물 3개 이상 조회 시 포인트를 드려요.',
        pointReward: 500,
        category: OfferwallCategory.event,
        sponsorLogoUrl: null,
        clickUrl: 'https://example.com/offer/7',
        status: OfferwallOfferStatus.active,
      ),
    ];

    if (filterCategory == null) return all;
    return all.where((o) => o.category == filterCategory).toList();
  }
}
