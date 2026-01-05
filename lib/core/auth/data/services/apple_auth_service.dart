import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'apple_auth_service.g.dart';

/// Apple 로그인 결과
class AppleAuthResult {
  final String userIdentifier;
  final String email;
  final String? givenName;
  final String? familyName;
  final String? identityToken;
  final String? authorizationCode;

  AppleAuthResult({
    required this.userIdentifier,
    required this.email,
    this.givenName,
    this.familyName,
    this.identityToken,
    this.authorizationCode,
  });

  String? get fullName {
    final parts = [givenName, familyName].whereType<String>().toList();
    return parts.isEmpty ? null : parts.join(' ');
  }
}

/// Apple 인증 서비스
class AppleAuthService {
  /// Apple 로그인이 가능한지 확인
  Future<bool> isAvailable() async {
    // iOS 13 이상에서만 지원
    if (!Platform.isIOS) return false;
    return await SignInWithApple.isAvailable();
  }

  /// Apple 로그인 수행
  Future<AppleAuthResult> signIn() async {
    // nonce 생성 (보안을 위해)
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    // 이메일이 null인 경우 처리
    // Apple은 첫 로그인시에만 이메일을 제공하므로,
    // 이후 로그인시에는 userIdentifier를 기반으로 이메일을 생성하거나
    // 서버에서 저장된 이메일을 사용해야 함
    final email = credential.email ??
        '${credential.userIdentifier}@privaterelay.appleid.com';

    return AppleAuthResult(
      userIdentifier: credential.userIdentifier ?? '',
      email: email,
      givenName: credential.givenName,
      familyName: credential.familyName,
      identityToken: credential.identityToken,
      authorizationCode: credential.authorizationCode,
    );
  }

  /// 랜덤 nonce 문자열 생성
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// SHA256 해시 생성
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}

@riverpod
AppleAuthService appleAuthService(Ref ref) {
  return AppleAuthService();
}
