import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/data/datasources/token_local_datasource.dart';

part 'graphql_client.g.dart';

class GraphQLClientService {
  static const String _endpoint = 'https://api-dev.blockpick.net/api/graphql';

  GraphQLClient createClient({String? token}) {
    final HttpLink httpLink = HttpLink(_endpoint);

    final AuthLink authLink = AuthLink(
      getToken: () async => token != null ? 'Bearer $token' : null,
    );

    final Link link = authLink.concat(httpLink);

    return GraphQLClient(
      cache: GraphQLCache(store: InMemoryStore()),
      link: link,
    );
  }
}

@riverpod
Future<GraphQLClient> graphqlClient(GraphqlClientRef ref) async {
  // 토큰 가져오기
  final tokenDataSource = ref.watch(tokenLocalDataSourceProvider);
  final token = await tokenDataSource.getToken();

  return GraphQLClientService().createClient(token: token);
}
