import 'package:graphql_flutter/graphql_flutter.dart';
import '../../domain/models/user.dart';
import '../../domain/exceptions/auth_exception.dart';

class AuthRemoteDataSource {
  final GraphQLClient _client;

  AuthRemoteDataSource(this._client);

  // 로그인 Mutation
  static const String loginMutation = r'''
    mutation Login($input: LoginRequest!) {
      login(input: $input) {
        success
        code
        message
        accessToken
        refreshToken
        user {
          id
          email
          nickname
          avatar
          balance
          totalGamesPlayed
          totalWins
          winRate
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // 인증 코드 발송 (통합)
  static const String sendVerificationCodeMutation = r'''
    mutation SendVerificationCode($email: String!, $verifyType: VerifyType!) {
      sendVerificationCode(email: $email, verifyType: $verifyType) {
        success
        code
        message
      }
    }
  ''';

  // 코드 인증 (통합)
  static const String verifyCodeMutation = r'''
    mutation VerifyCode($input: VerifyCodeRequest!) {
      verifyCode(input: $input) {
        success
        code
        message
      }
    }
  ''';

  // 회원가입
  static const String signUpMutation = r'''
    mutation SignUp($input: SignUpRequest!) {
      signUp(input: $input) {
        success
        code
        message
        user {
          id
          email
          nickname
          avatar
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // 비밀번호 재설정
  static const String resetPasswordMutation = r'''
    mutation ResetPassword($input: ResetPasswordRequest!) {
      resetPassword(input: $input) {
        success
        code
        message
      }
    }
  ''';

  // 토큰 갱신
  static const String refreshTokenMutation = r'''
    mutation RefreshToken($refreshToken: String!) {
      refreshToken(refreshToken: $refreshToken) {
        success
        code
        message
        accessToken
        refreshToken
        user {
          id
          email
          nickname
          avatar
        }
      }
    }
  ''';

  // 비밀번호 변경
  static const String changePasswordMutation = r'''
    mutation ChangePassword($input: ChangePasswordRequest!) {
      changePassword(input: $input) {
        success
        code
        message
      }
    }
  ''';

  // 회원 탈퇴
  static const String withdrawUserMutation = r'''
    mutation WithdrawUser($input: WithdrawUserRequest!) {
      withdrawUser(input: $input) {
        success
        code
        message
      }
    }
  ''';

  // ME Query (사용자 정보 가져오기)
  static const String meQuery = r'''
    query Me {
      me {
        success
        code
        message
        user {
          id
          email
          nickname
          avatar
          balance
          totalGamesPlayed
          totalWins
          winRate
          createdAt
          updatedAt
        }
      }
    }
  ''';

  // 로그인
  Future<({String accessToken, String refreshToken, User user})> login({
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

    // 데이터가 있으면 캐시 에러를 무시하고 계속 진행
    final data = result.data?['login'];

    // 데이터가 없고 예외가 있으면 throw
    if (data == null && result.hasException) {
      throw result.exception!;
    }

    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'Login failed',
        code: data?['code'],
      );
    }

    return (
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  // 인증 코드 발송 (통합)
  Future<bool> sendVerificationCode({
    required String email,
    required String verifyType, // 'SIGN_UP', 'CHANGE_PASSWORD', 'WITHDRAW'
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(sendVerificationCodeMutation),
        variables: {
          'email': email,
          'verifyType': verifyType,
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['sendVerificationCode'];
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'Failed to send verification code',
        code: data?['code'],
      );
    }

    return data['success'] as bool;
  }

  // 코드 인증 (통합)
  Future<bool> verifyCode({
    required String email,
    required String code,
    required String verifyType, // 'SIGN_UP', 'CHANGE_PASSWORD', 'WITHDRAW'
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(verifyCodeMutation),
        variables: {
          'input': {
            'email': email,
            'code': code,
            'verifyType': verifyType,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['verifyCode'];
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'Code verification failed',
        code: data?['code'],
      );
    }

    return data['success'] as bool;
  }

  // 레거시 메서드 (하위 호환성)
  Future<bool> sendSignUpVerificationCode(String email) =>
      sendVerificationCode(email: email, verifyType: 'SIGN_UP');

  Future<({bool isValid, String? message})> verifySignUpCode({
    required String email,
    required String code,
  }) async {
    try {
      final success = await verifyCode(
        email: email,
        code: code,
        verifyType: 'SIGN_UP',
      );
      return (isValid: success, message: null);
    } catch (e) {
      return (isValid: false, message: e.toString());
    }
  }

  // 회원가입
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
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'SignUp failed',
        code: data?['code'],
      );
    }

    return User.fromJson(data['user'] as Map<String, dynamic>);
  }

  // 비밀번호 재설정
  Future<bool> resetPassword({
    required String email,
    required String verificationCode,
    required String newPassword,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(resetPasswordMutation),
        variables: {
          'input': {
            'email': email,
            'verificationCode': verificationCode,
            'newPassword': newPassword,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['resetPassword'];
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'Password reset failed',
        code: data?['code'],
      );
    }

    return data['success'] as bool;
  }

  // 토큰 갱신
  Future<({String accessToken, String refreshToken, User user})> refreshToken(
    String refreshToken,
  ) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(refreshTokenMutation),
        variables: {'refreshToken': refreshToken},
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['refreshToken'];
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'Token refresh failed',
        code: data?['code'],
      );
    }

    return (
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  // 비밀번호 변경
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(changePasswordMutation),
        variables: {
          'input': {
            'currentPassword': currentPassword,
            'newPassword': newPassword,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['changePassword'];
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'Password change failed',
        code: data?['code'],
      );
    }

    return data['success'] as bool;
  }

  // 회원 탈퇴
  Future<bool> withdrawUser({
    required String password,
    String? reason,
  }) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql(withdrawUserMutation),
        variables: {
          'input': {
            'password': password,
            if (reason != null) 'reason': reason,
          },
        },
      ),
    );

    if (result.hasException) {
      throw result.exception!;
    }

    final data = result.data?['withdrawUser'];
    if (data == null || data['success'] != true) {
      throw AuthException(
        message: data?['message'] ?? 'User withdrawal failed',
        code: data?['code'],
      );
    }

    return data['success'] as bool;
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
    if (data == null || data['success'] != true) {
      return null;
    }

    final userData = data['user'];
    if (userData == null) return null;

    return User.fromJson(userData as Map<String, dynamic>);
  }

  // 레거시 메서드 (하위 호환성)
  Future<bool> sendPasswordResetCode(String email) =>
      sendVerificationCode(email: email, verifyType: 'CHANGE_PASSWORD');

  Future<({bool isValid, String? message})> verifyPasswordResetCode({
    required String email,
    required String code,
  }) async {
    try {
      final success = await verifyCode(
        email: email,
        code: code,
        verifyType: 'CHANGE_PASSWORD',
      );
      return (isValid: success, message: null);
    } catch (e) {
      return (isValid: false, message: e.toString());
    }
  }
}
