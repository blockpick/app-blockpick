import 'package:graphql_flutter/graphql_flutter.dart';
import 'delivery_address_models.dart';

class DeliveryAddressRemoteDataSource {
  final GraphQLClient _client;

  DeliveryAddressRemoteDataSource(this._client);

  static const String myDeliveryAddressesQuery = r'''
    query MyDeliveryAddresses {
      myDeliveryAddresses {
        success
        code
        message
        items {
          id
          recipientName
          email
          countryCode
          address
          postalCode
          phone
          isDefault
        }
      }
    }
  ''';

  static const String createDeliveryAddressMutation = r'''
    mutation CreateDeliveryAddress($input: DeliveryAddressInput!) {
      createDeliveryAddress(input: $input) {
        success
        code
        message
        address {
          id
          recipientName
          email
          countryCode
          address
          postalCode
          phone
          isDefault
        }
      }
    }
  ''';

  static const String updateDeliveryAddressMutation = r'''
    mutation UpdateDeliveryAddress($id: String!, $input: DeliveryAddressInput!) {
      updateDeliveryAddress(id: $id, input: $input) {
        success
        code
        message
        address {
          id
          recipientName
          email
          countryCode
          address
          postalCode
          phone
          isDefault
        }
      }
    }
  ''';

  static const String deleteDeliveryAddressMutation = r'''
    mutation DeleteDeliveryAddress($id: String!) {
      deleteDeliveryAddress(id: $id) {
        success
        code
        message
      }
    }
  ''';

  Future<List<DeliveryAddress>> fetchMyDeliveryAddresses() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(myDeliveryAddressesQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    final data = result.data?['myDeliveryAddresses'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: myDeliveryAddresses');
    }
    return ((data['items'] as List?) ?? const [])
        .map((e) => DeliveryAddress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryAddress> createDeliveryAddress(
      DeliveryAddressInput input) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(createDeliveryAddressMutation),
        variables: {'input': input.toJson()},
      ),
    );

    final data = result.data?['createDeliveryAddress'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: createDeliveryAddress');
    }
    final address = data['address'];
    if (address == null) {
      throw Exception('Failed: createDeliveryAddress (address null)');
    }
    return DeliveryAddress.fromJson(address as Map<String, dynamic>);
  }

  Future<DeliveryAddress> updateDeliveryAddress({
    required String id,
    required DeliveryAddressInput input,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(updateDeliveryAddressMutation),
        variables: {
          'id': id,
          'input': input.toJson(),
        },
      ),
    );

    final data = result.data?['updateDeliveryAddress'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: updateDeliveryAddress');
    }
    final address = data['address'];
    if (address == null) {
      throw Exception('Failed: updateDeliveryAddress (address null)');
    }
    return DeliveryAddress.fromJson(address as Map<String, dynamic>);
  }

  Future<bool> deleteDeliveryAddress({required String id}) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(deleteDeliveryAddressMutation),
        variables: {'id': id},
      ),
    );

    final data = result.data?['deleteDeliveryAddress'];
    if (data == null && result.hasException) {
      throw result.exception!;
    }
    if (data == null || data['success'] != true) {
      throw Exception(data?['message'] ?? 'Failed: deleteDeliveryAddress');
    }
    return data['success'] as bool? ?? false;
  }
}
