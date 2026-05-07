// Entry / Ticket 도메인 DTO + enum

// ===== Enums =====

enum BlockpickEntryStatus { pending, confirmed, settled, won, lost }

BlockpickEntryStatus blockpickEntryStatusFromString(String? s) {
  if (s == null) return BlockpickEntryStatus.pending;
  return BlockpickEntryStatus.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => BlockpickEntryStatus.pending,
  );
}

String blockpickEntryStatusToString(BlockpickEntryStatus v) =>
    v.name.toUpperCase();

enum TicketStatus { available, used, expired }

TicketStatus ticketStatusFromString(String? s) {
  if (s == null) return TicketStatus.available;
  return TicketStatus.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => TicketStatus.available,
  );
}

String ticketStatusToString(TicketStatus v) => v.name.toUpperCase();

enum TicketSourceType { free, referral, ad, mission }

TicketSourceType ticketSourceTypeFromString(String? s) {
  if (s == null) return TicketSourceType.free;
  return TicketSourceType.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => TicketSourceType.free,
  );
}

enum TxStatus { pending, sent, confirmed, failed, refunded }

TxStatus? txStatusFromStringNullable(String? s) {
  if (s == null) return null;
  return TxStatus.values.firstWhere(
    (e) => e.name.toUpperCase() == s,
    orElse: () => TxStatus.pending,
  );
}

// ===== DTO =====

class EntryTicket {
  final String id;
  final String blockpickId;
  final TicketSourceType sourceType;
  final TicketStatus status;
  final String? expiresAt;
  final String? usedAt;

  const EntryTicket({
    required this.id,
    required this.blockpickId,
    required this.sourceType,
    required this.status,
    this.expiresAt,
    this.usedAt,
  });

  factory EntryTicket.fromJson(Map<String, dynamic> json) => EntryTicket(
        id: json['id'] as String,
        blockpickId: json['blockpickId'] as String,
        sourceType: ticketSourceTypeFromString(json['sourceType'] as String?),
        status: ticketStatusFromString(json['status'] as String?),
        expiresAt: json['expiresAt'] as String?,
        usedAt: json['usedAt'] as String?,
      );
}

class BlockpickEntry {
  final String id;
  final String userId;
  final String blockpickId;
  final String ticketId;
  final int selectedRow;
  final int selectedCol;
  final BlockpickEntryStatus status;
  final TxStatus? txStatus;
  final String? txHash;
  final String? settledAt;
  final String createdAt;

  const BlockpickEntry({
    required this.id,
    required this.userId,
    required this.blockpickId,
    required this.ticketId,
    required this.selectedRow,
    required this.selectedCol,
    required this.status,
    this.txStatus,
    this.txHash,
    this.settledAt,
    required this.createdAt,
  });

  factory BlockpickEntry.fromJson(Map<String, dynamic> json) => BlockpickEntry(
        id: json['id'] as String,
        userId: json['userId'] as String,
        blockpickId: json['blockpickId'] as String,
        ticketId: json['ticketId'] as String,
        selectedRow: (json['selectedRow'] as num?)?.toInt() ?? 0,
        selectedCol: (json['selectedCol'] as num?)?.toInt() ?? 0,
        status: blockpickEntryStatusFromString(json['status'] as String?),
        txStatus: txStatusFromStringNullable(json['txStatus'] as String?),
        txHash: json['txHash'] as String?,
        settledAt: json['settledAt'] as String?,
        createdAt: json['createdAt'] as String,
      );
}

// 페이지 응답 wrapper
class MyEntriesPage {
  final List<BlockpickEntry> items;
  final double totalCount;
  final int page;
  final int size;
  final bool hasNext;

  const MyEntriesPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.size,
    required this.hasNext,
  });

  factory MyEntriesPage.fromJson(Map<String, dynamic> json) => MyEntriesPage(
        items: ((json['items'] as List?) ?? const [])
            .map((e) => BlockpickEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        totalCount: (json['totalCount'] as num?)?.toDouble() ?? 0,
        page: (json['page'] as num?)?.toInt() ?? 0,
        size: (json['size'] as num?)?.toInt() ?? 0,
        hasNext: json['hasNext'] as bool? ?? false,
      );
}
