import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/graphql/graphql_client.dart';
import '../data/delivery_address/delivery_address_models.dart';
import '../data/delivery_address/delivery_address_remote_datasource.dart';

/// DeliveryAddressRemoteDataSource provider — 인증 필요
final deliveryAddressRemoteDataSourceProvider =
    FutureProvider<DeliveryAddressRemoteDataSource>((ref) async {
  final client = await ref.watch(graphqlClientProvider.future);
  return DeliveryAddressRemoteDataSource(client);
});

/// 내 배송지 목록
final myDeliveryAddressesProvider =
    FutureProvider.autoDispose<List<DeliveryAddress>>((ref) async {
  final ds = await ref.watch(deliveryAddressRemoteDataSourceProvider.future);
  return ds.fetchMyDeliveryAddresses();
});
