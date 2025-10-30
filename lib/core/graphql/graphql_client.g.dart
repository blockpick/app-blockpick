// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'graphql_client.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$graphqlClientHash() => r'e37e8539215fcd645739ab6724ba1a84c9f0c289';

/// See also [graphqlClient].
@ProviderFor(graphqlClient)
final graphqlClientProvider = AutoDisposeFutureProvider<GraphQLClient>.internal(
  graphqlClient,
  name: r'graphqlClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$graphqlClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GraphqlClientRef = AutoDisposeFutureProviderRef<GraphQLClient>;
String _$publicGraphqlClientHash() =>
    r'18885985aed97c0a460ec3369106774b7de10685';

/// 인증 없는 GraphQL 클라이언트 (공개 API용)
///
/// Copied from [publicGraphqlClient].
@ProviderFor(publicGraphqlClient)
final publicGraphqlClientProvider = AutoDisposeProvider<GraphQLClient>.internal(
  publicGraphqlClient,
  name: r'publicGraphqlClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$publicGraphqlClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PublicGraphqlClientRef = AutoDisposeProviderRef<GraphQLClient>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
