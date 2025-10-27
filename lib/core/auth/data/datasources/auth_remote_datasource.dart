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
        isSocialAccount
        socialProvider
      }
    }
  ''';

  // 회원가입 1단계 - 이메일 인증 코드 발송
  static const String sendSignUpVerificationCodeMutation = r'''
    mutation SendSignUpVerificationCode($email: String!) {
      sendSignUpVerificationCode(email: $email)
    }
  ''';

  // 회원가입 2단계 - 인증 코드 확인
  static const String verifySignUpCodeMutation = r'''
    mutation VerifySignUpCode($input: VerifyCodeInput!) {
      verifySignUpCode(input: $input) {
        isValid
        message
      }
    }
  ''';

  // 회원가입 3단계 - 최종 회원가입
  static const String signUpMutation = r'''
    mutation SignUp($input: SignUpInput!) {
      signUp(input: $input) {
        id
        email
        nickname
        profileImageUrl
        point
        cash
        isPushNotification
        isMarketingNotification
        isBan
        userRole
        isSocialAccount
        socialProvider
        socialName
      }
    }
  ''';

  // 비밀번호 찾기 1단계 - 이메일 인증 코드 발송
  static const String sendPasswordResetCodeMutation = r'''
    mutation SendPasswordResetCode($email: String!) {
      sendPasswordResetCode(email: $email)
    }
  ''';

  // 비밀번호 찾기 2단계 - 인증 코드 확인
  static const String verifyPasswordResetCodeMutation = r'''
    mutation VerifyPasswordResetCode($input: VerifyPasswordResetCodeInput!) {
      verifyPasswordResetCode(input: $input) {
        isValid
        message
      }
    }
  ''';

  // 비밀번호 찾기 3단계 - 새 비밀번호 설정
  static const String resetPasswordMutation = r'''
    mutation ResetPassword($input: ResetPasswordInput!) {
      resetPassword(input: $input)
    }
  ''';

  // ME Query (사용자 정보 가져오기)
  static const String meQuery = r'''
    query Me {
      me {
        id
        email
        nickname
        profileImageUrl
        point
        cash
        isPushNotification
        isMarketingNotification
        isBan
        userRole
        isSocialAccount
        socialProvider
        socialName
      }
    }
  ''';

  // 로그인
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

  // 회원가입 1단계 - 이메일 인증 코드 발송
  Future<bool> sendSignUpVerificationCode(String email) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(sendSignUpVerificationCodeMutation),
        variables: {'email': email},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data?['sendSignUpVerificationCode'] as bool? ?? false;
  }

  // 회원가입 2단계 - 인증 코드 확인
  Future<({bool isValid, String? message})> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(verifySignUpCodeMutation),
        variables: {
          'input': {
            'email': email,
            'verifyType': 'SIGN_UP',
            'code': code,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['verifySignUpCode'];
    if (data == null) {
      throw Exception('Verify code failed: No data returned');
    }

    return (
      isValid: data['isValid'] as bool,
      message: data['message'] as String?,
    );
  }

  // 회원가입 3단계 - 최종 회원가입
  Future<User> signUp({
    required String email,
    required String password,
    String? nickname,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(signUpMutation),
        variables: {
          'input': {
            'email': email,
            'password': password,
            if (nickname != null) 'nickname': nickname,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['signUp'];
    if (data == null) {
      throw Exception('SignUp failed: No data returned');
    }

    return User.fromJson(data as Map<String, dynamic>);
  }

  // 비밀번호 찾기 1단계 - 이메일 인증 코드 발송
  Future<bool> sendPasswordResetCode(String email) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(sendPasswordResetCodeMutation),
        variables: {'email': email},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data?['sendPasswordResetCode'] as bool? ?? false;
  }

  // 비밀번호 찾기 2단계 - 인증 코드 확인
  Future<({bool isValid, String? message})> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(verifyPasswordResetCodeMutation),
        variables: {
          'input': {
            'email': email,
            'code': code,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['verifyPasswordResetCode'];
    if (data == null) {
      throw Exception('Verify code failed: No data returned');
    }

    return (
      isValid: data['isValid'] as bool,
      message: data['message'] as String?,
    );
  }

  // 비밀번호 찾기 3단계 - 새 비밀번호 설정
  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(resetPasswordMutation),
        variables: {
          'input': {
            'email': email,
            'code': code,
            'newPassword': newPassword,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    return result.data?['resetPassword'] as bool? ?? false;
  }

  // 현재 사용자 정보 가져오기
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
