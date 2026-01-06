import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_auth_service.g.dart';

/// Google 로그인 결과
class GoogleAuthResult {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;

  GoogleAuthResult({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
  });
}

/// Google 인증 서비스 (google_sign_in v7.x)
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  Completer<GoogleAuthResult>? _signInCompleter;
  StreamSubscription<GoogleSignInAuthenticationEvent>? _authSubscription;
  bool _isInitialized = false;

  /// 초기화
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _googleSignIn.initialize();
    _isInitialized = true;
  }

  /// Google 로그인 수행
  Future<GoogleAuthResult> signIn() async {
    await _ensureInitialized();

    // 기존 세션 정리
    try {
      await _googleSignIn.disconnect();
    } catch (_) {
      // 이미 로그아웃 상태일 수 있음
    }

    // Completer 생성
    _signInCompleter = Completer<GoogleAuthResult>();

    // 인증 이벤트 리스너 설정
    _authSubscription?.cancel();
    _authSubscription = _googleSignIn.authenticationEvents.listen(
      _handleAuthenticationEvent,
      onError: _handleAuthenticationError,
    );

    // 인증 시도
    if (_googleSignIn.supportsAuthenticate()) {
      try {
        await _googleSignIn.authenticate();
      } catch (e) {
        _signInCompleter?.completeError(e);
      }
    } else {
      _signInCompleter?.completeError(
        Exception('이 플랫폼에서는 Google 로그인을 지원하지 않습니다.'),
      );
    }

    try {
      final result = await _signInCompleter!.future;
      return result;
    } finally {
      _authSubscription?.cancel();
      _authSubscription = null;
    }
  }

  /// 인증 이벤트 핸들러
  void _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) {
    switch (event) {
      case GoogleSignInAuthenticationEventSignIn():
        final user = event.user;
        _signInCompleter?.complete(
          GoogleAuthResult(
            id: user.id,
            email: user.email,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
          ),
        );
      case GoogleSignInAuthenticationEventSignOut():
        _signInCompleter?.completeError(
          Exception('Google 로그인이 취소되었습니다.'),
        );
    }
  }

  /// 인증 에러 핸들러
  void _handleAuthenticationError(Object error) {
    _signInCompleter?.completeError(error);
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _ensureInitialized();
    await _googleSignIn.disconnect();
  }
}

@riverpod
GoogleAuthService googleAuthService(Ref ref) {
  return GoogleAuthService();
}
