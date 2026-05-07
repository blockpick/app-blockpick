// Blockpick 도메인 DTO 모델 + enum
// schema.graphqls 의 Blockpick 섹션을 그대로 매핑.

// ===== Enums =====

enum BlockpickStatus { draft, active, paused, ended }

BlockpickStatus blockpickStatusFromString(String? s) {
  if (s == null) return BlockpickStatus.draft;
  return BlockpickStatus.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => BlockpickStatus.draft,
  );
}

String blockpickStatusToString(BlockpickStatus v) => v.name.toUpperCase();

enum BlockpickSortBy { latest, deadlineSoon, popular }

BlockpickSortBy blockpickSortByFromString(String? s) {
  if (s == null) return BlockpickSortBy.latest;
  // DEADLINE_SOON -> deadlineSoon 매핑
  switch (s) {
    case 'LATEST':
      return BlockpickSortBy.latest;
    case 'DEADLINE_SOON':
      return BlockpickSortBy.deadlineSoon;
    case 'POPULAR':
      return BlockpickSortBy.popular;
    default:
      return BlockpickSortBy.latest;
  }
}

String blockpickSortByToString(BlockpickSortBy v) {
  switch (v) {
    case BlockpickSortBy.latest:
      return 'LATEST';
    case BlockpickSortBy.deadlineSoon:
      return 'DEADLINE_SOON';
    case BlockpickSortBy.popular:
      return 'POPULAR';
  }
}

enum PrizeTier { grand, first, second, third, participation }

PrizeTier prizeTierFromString(String? s) {
  if (s == null) return PrizeTier.participation;
  return PrizeTier.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => PrizeTier.participation,
  );
}

enum PrizeType { coupon, physical, code, point }

PrizeType prizeTypeFromString(String? s) {
  if (s == null) return PrizeType.coupon;
  return PrizeType.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => PrizeType.coupon,
  );
}

// ===== DTO =====

class PartnerSummary {
  final String id;
  final String name;
  final String? logoUrl;
  final String? websiteUrl;

  const PartnerSummary({
    required this.id,
    required this.name,
    this.logoUrl,
    this.websiteUrl,
  });

  factory PartnerSummary.fromJson(Map<String, dynamic> json) => PartnerSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        logoUrl: json['logoUrl'] as String?,
        websiteUrl: json['websiteUrl'] as String?,
      );
}

class Category {
  final String id;
  final String code;
  final String name;
  final String? iconUrl;
  final int displayOrder;
  final bool active;

  const Category({
    required this.id,
    required this.code,
    required this.name,
    this.iconUrl,
    required this.displayOrder,
    required this.active,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        code: json['code'] as String,
        name: json['name'] as String,
        iconUrl: json['iconUrl'] as String?,
        displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
        active: json['active'] as bool? ?? false,
      );
}

class PrizeSummary {
  final String id;
  final String name;
  final PrizeType prizeType;
  final String? description;
  final String? imageUrl;
  final double? faceValue;

  const PrizeSummary({
    required this.id,
    required this.name,
    required this.prizeType,
    this.description,
    this.imageUrl,
    this.faceValue,
  });

  factory PrizeSummary.fromJson(Map<String, dynamic> json) => PrizeSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        prizeType: prizeTypeFromString(json['prizeType'] as String?),
        description: json['description'] as String?,
        imageUrl: json['imageUrl'] as String?,
        faceValue: (json['faceValue'] as num?)?.toDouble(),
      );
}

class BlockpickPrize {
  final String id;
  final PrizeTier tier;
  final int quantity;
  final int sequence;
  final PrizeSummary prize;

  const BlockpickPrize({
    required this.id,
    required this.tier,
    required this.quantity,
    required this.sequence,
    required this.prize,
  });

  factory BlockpickPrize.fromJson(Map<String, dynamic> json) => BlockpickPrize(
        id: json['id'] as String,
        tier: prizeTierFromString(json['tier'] as String?),
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        sequence: (json['sequence'] as num?)?.toInt() ?? 0,
        prize: PrizeSummary.fromJson(json['prize'] as Map<String, dynamic>),
      );
}

class BlockpickSummary {
  final String id;
  final String title;
  final String? thumbnailUrl;
  final int gridRows;
  final int gridCols;
  final int maxEntriesPerUser;
  final int freeEntryQuota;
  final String visibleFrom; // ISO8601 string
  final String startTime;
  final String endTime;
  final BlockpickStatus status;
  final bool isRecommended;
  final double totalEntryCount;
  final PartnerSummary partner;
  final Category category;
  final BlockpickPrize? topPrize;

  const BlockpickSummary({
    required this.id,
    required this.title,
    this.thumbnailUrl,
    required this.gridRows,
    required this.gridCols,
    required this.maxEntriesPerUser,
    required this.freeEntryQuota,
    required this.visibleFrom,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isRecommended,
    required this.totalEntryCount,
    required this.partner,
    required this.category,
    this.topPrize,
  });

  factory BlockpickSummary.fromJson(Map<String, dynamic> json) =>
      BlockpickSummary(
        id: json['id'] as String,
        title: json['title'] as String,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        gridRows: (json['gridRows'] as num?)?.toInt() ?? 0,
        gridCols: (json['gridCols'] as num?)?.toInt() ?? 0,
        maxEntriesPerUser: (json['maxEntriesPerUser'] as num?)?.toInt() ?? 0,
        freeEntryQuota: (json['freeEntryQuota'] as num?)?.toInt() ?? 0,
        visibleFrom: json['visibleFrom'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        status: blockpickStatusFromString(json['status'] as String?),
        isRecommended: json['isRecommended'] as bool? ?? false,
        totalEntryCount: (json['totalEntryCount'] as num?)?.toDouble() ?? 0,
        partner:
            PartnerSummary.fromJson(json['partner'] as Map<String, dynamic>),
        category: Category.fromJson(json['category'] as Map<String, dynamic>),
        topPrize: json['topPrize'] == null
            ? null
            : BlockpickPrize.fromJson(
                json['topPrize'] as Map<String, dynamic>),
      );
}

class BlockpickDetail {
  final String id;
  final String title;
  final String? description;
  final String? thumbnailUrl;
  final String? mainImageUrl;
  final int gridRows;
  final int gridCols;
  final int maxEntriesPerUser;
  final int freeEntryQuota;
  final String visibleFrom;
  final String startTime;
  final String endTime;
  final BlockpickStatus status;
  final bool isRecommended;
  final bool referralEnabled;
  final bool adRewardEnabled;
  final bool missionEnabled;
  final String? onchainContractAddr;
  final double totalEntryCount;
  final PartnerSummary partner;
  final Category category;
  final List<BlockpickPrize> prizes;

  const BlockpickDetail({
    required this.id,
    required this.title,
    this.description,
    this.thumbnailUrl,
    this.mainImageUrl,
    required this.gridRows,
    required this.gridCols,
    required this.maxEntriesPerUser,
    required this.freeEntryQuota,
    required this.visibleFrom,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.isRecommended,
    required this.referralEnabled,
    required this.adRewardEnabled,
    required this.missionEnabled,
    this.onchainContractAddr,
    required this.totalEntryCount,
    required this.partner,
    required this.category,
    required this.prizes,
  });

  factory BlockpickDetail.fromJson(Map<String, dynamic> json) =>
      BlockpickDetail(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        thumbnailUrl: json['thumbnailUrl'] as String?,
        mainImageUrl: json['mainImageUrl'] as String?,
        gridRows: (json['gridRows'] as num?)?.toInt() ?? 0,
        gridCols: (json['gridCols'] as num?)?.toInt() ?? 0,
        maxEntriesPerUser: (json['maxEntriesPerUser'] as num?)?.toInt() ?? 0,
        freeEntryQuota: (json['freeEntryQuota'] as num?)?.toInt() ?? 0,
        visibleFrom: json['visibleFrom'] as String,
        startTime: json['startTime'] as String,
        endTime: json['endTime'] as String,
        status: blockpickStatusFromString(json['status'] as String?),
        isRecommended: json['isRecommended'] as bool? ?? false,
        referralEnabled: json['referralEnabled'] as bool? ?? false,
        adRewardEnabled: json['adRewardEnabled'] as bool? ?? false,
        missionEnabled: json['missionEnabled'] as bool? ?? false,
        onchainContractAddr: json['onchainContractAddr'] as String?,
        totalEntryCount: (json['totalEntryCount'] as num?)?.toDouble() ?? 0,
        partner:
            PartnerSummary.fromJson(json['partner'] as Map<String, dynamic>),
        category: Category.fromJson(json['category'] as Map<String, dynamic>),
        prizes: ((json['prizes'] as List?) ?? const [])
            .map((e) => BlockpickPrize.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

// 페이지 응답 wrapper
class BlockpickListPage {
  final List<BlockpickSummary> items;
  final double totalCount;
  final int page;
  final int size;
  final bool hasNext;

  const BlockpickListPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  factory BlockpickListPage.fromJson(Map<String, dynamic> json) =>
      BlockpickListPage(
        items: ((json['items'] as List?) ?? const [])
            .map((e) => BlockpickSummary.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toDouble() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 0,
        size: (json['size'] as num?)?.toInt() ?? 0,
        hasNext: json['hasNext'] as bool? ?? false,
      );
}

// 입력 필터
class BlockpickFilterInput {
  final String? keyword;
  final String? categoryCode;
  final bool? onlyOngoing;
  final bool? onlyRecommended;
  final BlockpickSortBy? sortBy;
  final int? page;
  final int? size;

  const BlockpickFilterInput({
    this.keyword,
    this.categoryCode,
    this.onlyOngoing,
    this.onlyRecommended,
    this.sortBy,
    this.page,
    this.size,
  });

  Map<String, dynamic> toJson() => {
        if (keyword != null) 'keyword': keyword,
        if (categoryCode != null) 'categoryCode': categoryCode,
        if (onlyOngoing != null) 'onlyOngoing': onlyOngoing,
        if (onlyRecommended != null) 'onlyRecommended': onlyRecommended,
        if (sortBy != null) 'sortBy': blockpickSortByToString(sortBy!),
        if (page != null) 'page': page,
        if (size != null) 'size': size,
      };
}
