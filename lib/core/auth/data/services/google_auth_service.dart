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

  // Web Client ID (Google Cloud Console에서 발급받은 웹 클라이언트 ID)
  // Android에서 serverClientId로 필요
  static const String _webClientId = '339699664526-c8qg0a3o2b8t6qorlboha55teg64rf4d.apps.googleusercontent.com';

  /// 초기화
  Future<void> _ensureInitialized() async {
    if (_isInitialized) return;

    await _googleSignIn.initialize(
      serverClientId: _webClientId,
    );
    _isInitialized = true;
  }

  /// Google 로그인 수행
  Future<GoogleAuthResult> signIn() async {
    print('🔵 [GoogleAuth] signIn() 시작');

    await _ensureInitialized();
    print('🔵 [GoogleAuth] 초기화 완료');

    // 기존 세션 정리
    try {
      await _googleSignIn.disconnect();
      print('🔵 [GoogleAuth] 기존 세션 정리 완료');
    } catch (e) {
      print('🔵 [GoogleAuth] 기존 세션 없음: $e');
    }

    // Completer 생성
    _signInCompleter = Completer<GoogleAuthResult>();

    // 인증 이벤트 리스너 설정
    _authSubscription?.cancel();
    _authSubscription = _googleSignIn.authenticationEvents.listen(
      _handleAuthenticationEvent,
      onError: _handleAuthenticationError,
    );
    print('🔵 [GoogleAuth] 이벤트 리스너 설정 완료');

    // 인증 시도
    final supportsAuth = _googleSignIn.supportsAuthenticate();
    print('🔵 [GoogleAuth] supportsAuthenticate: $supportsAuth');

    if (supportsAuth) {
      try {
        print('🔵 [GoogleAuth] authenticate() 호출 시작');
        await _googleSignIn.authenticate();
        print('🔵 [GoogleAuth] authenticate() 호출 완료');
      } catch (e) {
        print('🔴 [GoogleAuth] authenticate() 에러: $e');
        _signInCompleter?.completeError(e);
      }
    } else {
      print('🔴 [GoogleAuth] 이 플랫폼에서 지원 안됨');
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
