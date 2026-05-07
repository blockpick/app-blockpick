import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/entry/entry_models.dart';
import '../data/entry/entry_remote_datasource.dart';

/// EntryRemoteDataSource provider — 인증 필요 (myEntries/myTickets/joinBlockpick)
final entryRemoteDataSourceProvider =
    FutureProvider<EntryRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return EntryRemoteDataSource(client);
});

/// myEntries family input — datasource named param wrapper
class MyEntriesInput {
  final BlockpickEntryStatus? status;
  final int? page;
  final int? size;

  const MyEntriesInput({this.status, this.page, this.size});

  @override
  bool operator ==(Object other) =>
      other is MyEntriesInput &&
      status == other.status &&
      page == other.page &&
      size == other.size;

  @override
  int get hashCode => Object.hash(status, page, size);
}

/// myTickets family input
class MyTicketsInput {
  final String? blockpickId;
  final TicketStatus? status;

  const MyTicketsInput({this.blockpickId, this.status});

  @override
  bool operator ==(Object other) =>
      other is MyTicketsInput &&
      blockpickId == other.blockpickId &&
      status == other.status;

  @override
  int get hashCode => Object.hash(blockpickId, status);
}

/// 내 참여내역 페이지
final myEntriesProvider = FutureProvider.autoDispose
    .family<MyEntriesPage, MyEntriesInput?>((ref, input) async {
  final ds = await ref.watch(entryRemoteDataSourceProvider.future);
  return ds.fetchMyEntries(
    status: input?.status,
    page: input?.page,
    size: input?.size,
  );
});

/// 단건 entry — NOT_FOUND이면 null
final entryDetailProvider = FutureProvider.autoDispose
    .family<BlockpickEntry?, String>((ref, id) async {
  final ds = await ref.watch(entryRemoteDataSourceProvider.future);
  return ds.fetchEntry(id: id);
});

/// 내 티켓 목록
final myTicketsProvider = FutureProvider.autoDispose
    .family<List<EntryTicket>, MyTicketsInput?>((ref, input) async {
  final ds = await ref.watch(entryRemoteDataSourceProvider.future);
  return ds.fetchMyTickets(
    blockpickId: input?.blockpickId,
    status: input?.status,
  );
});
