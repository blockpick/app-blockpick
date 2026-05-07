import 'package:graphql_flutter/graphql_flutter.dart';
import 'blockpick_models.dart';

class BlockpickRemoteDataSource {
  final GraphQLClient _client;

  BlockpickRemoteDataSource(this._client);

  // 블록픽 목록 Query
  static const String blockpicksQuery = r'''
    query Blockpicks($input: BlockpickFilterInput) {
      blockpicks(input: $input) {
        success
        code
        message
        items {
          id
          title
          thumbnailUrl
          gridRows
          gridCols
          maxEntriesPerUser
          freeEntryQuota
          visibleFrom
          startTime
          endTime
          status
          isRecommended
          totalEntryCount
          partner { id name logoUrl websiteUrl }
          category { id code name iconUrl displayOrder active }
          topPrize {
            id
            tier
            quantity
            sequence
            prize { id name prizeType description imageUrl faceValue }
          }
        }
        totalCount
        page
        size
        hasNext
      }
    }
  ''';

  // 블록픽 상세 Query
  static const String blockpickQuery = r'''
    query Blockpick($id: String!) {
      blockpick(id: $id) {
        success
        code
        message
        blockpick {
          id
          title
          description
          thumbnailUrl
          mainImageUrl
          gridRows
          gridCols
          maxEntriesPerUser
          freeEntryQuota
          visibleFrom
          startTime
          endTime
          status
          isRecommended
          referralEnabled
          adRewardEnabled
          missionEnabled
          onchainContractAddr
          totalEntryCount
          partner { id name logoUrl websiteUrl }
          category { id code name iconUrl displayOrder active }
          prizes {
            id
            tier
            quantity
            sequence
            prize { id name prizeType description imageUrl faceValue }
          }
        }
      }
    }
  ''';

  // 카테고리 목록 Query
  static const String blockpickCategoriesQuery = r'''
    query BlockpickCategories {
      blockpickCategories {
        success
        code
        message
        items { id code name iconUrl displayOrder active }
      }
    }
  ''';

  // 블록픽 목록
  Future<BlockpickListPage> fetchBlockpicks({
    BlockpickFilterInput? filter,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(blockpicksQuery),
        variables: {
          if (filter != null) 'input': filter.toJson(),
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['blockpicks'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: blockpicks');
    }

    return BlockpickListPage.fromJson(data as Map<String, dynamic>);
  }

  // 블록픽 상세 — NOT_FOUND이면 null 리턴
  Future<BlockpickDetail?> fetchBlockpick({required String id}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(blockpickQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['blockpick'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null) {
      throw Exception('Failed: blockpick');
    }
    if (data['success'] != true) {
      // NOT_FOUND 등은 null 리턴
      final code = data['code'] as String?;
      if (code == 'NOT_FOUND' || code == 'BLOCKPICK_NOT_FOUND') {
        return null;
      }
      throw Exception(data['message'] ?? 'Failed: blockpick');
    }

    final detail = data['blockpick'];
    if (detail == null) return null;
    return BlockpickDetail.fromJson(detail as Map<String, dynamic>);
  }

  // 카테고리 목록
  Future<List<Category>> fetchCategories() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(blockpickCategoriesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['blockpickCategories'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: blockpickCategories');
    }

    return ((data['items'] as List?) ?? const [])
        .map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
