import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/models/user.dart';

class AuthRemoteDataSource {
  final GraphQLClient _client;

  AuthRemoteDataSource(this._client);

  // 로그인 Mutation
  static const String loginMutation = r'''
    mutation Login($input: LoginInput!) {
      login(input: $input) {
        token
        email
      }
    }
  ''';

  // 회원가입 Mutation
  static const String signupMutation = r'''
    mutation Signup($input: SignupInput!) {
      signup(input: $input) {
        token
        email
      }
    }
  ''';

  // ME Query (사용자 정보 가져오기)
  static const String meQuery = r'''
    query Me {
      me {
        id
        email
        name
        role
      }
    }
  ''';

  Future<({String token, String email})> login({
    required String email,
    required String password,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(loginMutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['login'];
    if (data == null) {
      throw Exception('Login failed: No data returned');
    }

    return (
      token: data['token'] as String,
      email: data['email'] as String,
    );
  }

  Future<({String token, String email})> signup({
    required String email,
    required String password,
    String? name,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(signupMutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
            if (name != null) 'name': name,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['signup'];
    if (data == null) {
      throw Exception('Signup failed: No data returned');
    }

    return (
      token: data['token'] as String,
      email: data['email'] as String,
    );
  }

  Future<User?> fetchCurrentUser() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(meQuery),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );

    if (result.hasException || result.data == null) {
      return null;
    }

    final data = result.data?['me'];
    if (data == null) return null;

    return User.fromJson(data as Map<String, dynamic>);
  }
}
