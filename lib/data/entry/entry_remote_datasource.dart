import 'package:graphql_flutter/graphql_flutter.dart';
import 'entry_models.dart';

class EntryRemoteDataSource {
  final GraphQLClient _client;

  EntryRemoteDataSource(this._client);

  // ===== Operations =====

  static const String joinBlockpickMutation = r'''
    mutation JoinBlockpick($input: JoinBlockpickInput!) {
      joinBlockpick(input: $input) {
        success
        code
        message
        entry {
          id userId blockpickId ticketId selectedRow selectedCol status
          txStatus txHash settledAt createdAt
        }
      }
    }
  ''';

  static const String myEntriesQuery = r'''
    query MyEntries($input: MyEntriesInput) {
      myEntries(input: $input) {
        success
        code
        message
        items {
          id userId blockpickId ticketId selectedRow selectedCol status
          txStatus txHash settledAt createdAt
        }
        totalCount
        page
        size
        hasNext
      }
    }
  ''';

  static const String entryQuery = r'''
    query Entry($id: String!) {
      entry(id: $id) {
        success
        code
        message
        entry {
          id userId blockpickId ticketId selectedRow selectedCol status
          txStatus txHash settledAt createdAt
        }
      }
    }
  ''';

  static const String myTicketsQuery = r'''
    query MyTickets($input: MyTicketsInput) {
      myTickets(input: $input) {
        success
        code
        message
        items { id blockpickId sourceType status expiresAt usedAt }
      }
    }
  ''';

  // ===== Methods =====

  Future<BlockpickEntry> joinBlockpick({
    required String blockpickId,
    required String ticketId,
    required int selectedRow,
    required int selectedCol,
    String? encryptedCoordinates,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(joinBlockpickMutation),
        variables: {
          'input': {
            'blockpickId': blockpickId,
            'ticketId': ticketId,
            'selectedRow': selectedRow,
            'selectedCol': selectedCol,
            if (encryptedCoordinates != null)
              'encryptedCoordinates': encryptedCoordinates,
          },
        },
      ),
    );

    final data = result.data?['joinBlockpick'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: joinBlockpick');
    }
    final entry = data['entry'];
    if (entry == null) {
      throw Exception('Failed: joinBlockpick (entry null)');
    }
    return BlockpickEntry.fromJson(entry as Map<String, dynamic>);
  }

  Future<MyEntriesPage> fetchMyEntries({
    BlockpickEntryStatus? status,
    int? page,
    int? size,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myEntriesQuery),
        variables: {
          'input': {
            if (status != null)
              'status': blockpickEntryStatusToString(status),
            if (page != null) 'page': page,
            if (size != null) 'size': size,
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myEntries'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myEntries');
    }
    return MyEntriesPage.fromJson(data as Map<String, dynamic>);
  }

  // 단건 entry — NOT_FOUND이면 null
  Future<BlockpickEntry?> fetchEntry({required String id}) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(entryQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['entry'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null) {
      throw Exception('Failed: entry');
    }
    if (data['success'] != true) {
      final code = data['code'] as String?;
      if (code == 'NOT_FOUND' || code == 'ENTRY_NOT_FOUND') {
        return null;
      }
      throw Exception(data['message'] ?? 'Failed: entry');
    }

    final entry = data['entry'];
    if (entry == null) return null;
    return BlockpickEntry.fromJson(entry as Map<String, dynamic>);
  }

  Future<List<EntryTicket>> fetchMyTickets({
    String? blockpickId,
    TicketStatus? status,
  }) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myTicketsQuery),
        variables: {
          'input': {
            if (blockpickId != null) 'blockpickId': blockpickId,
            if (status != null) 'status': ticketStatusToString(status),
          },
        },
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myTickets'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myTickets');
    }
    return ((data['items'] as List?) ?? const [])
        .map((e) => EntryTicket.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
