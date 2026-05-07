import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// FCM 백그라운드 메시지 핸들러 (top-level 함수 필수)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 백그라운드 수신 시 처리 (Firebase 초기화는 이미 완료됨)
  if (kDebugMode) {
    debugPrint('[FCM] 백그라운드 메시지 수신: ${message.messageId}');
    debugPrint('[FCM] 제목: ${message.notification?.title}');
    debugPrint('[FCM] 본문: ${message.notification?.body}');
    debugPrint('[FCM] 데이터: ${message.data}');
  }
}

/// FCM(Firebase Cloud Messaging) 초기화 및 토큰 관리
///
/// 사전 조건:
///   - android/app/google-services.json 추가 필요
///   - ios/Runner/GoogleService-Info.plist 추가 필요
///   - iOS APNs 인증서 설정 필요 (docs/external-sdk-keys.md 참조)
class FcmConfig {
  FcmConfig._();

  static bool _initialized = false;
  static String? _currentToken;

  static bool get isInitialized => _initialized;
  static String? get currentToken => _currentToken;

  /// FCM을 초기화합니다.
  ///
  /// Google Services 파일이 없으면 예외가 발생하므로
  /// main()에서 try-catch로 감싸 호출하세요.
  static Future<void> init() async {
    final messaging = FirebaseMessaging.instance;

    // iOS / macOS 알림 권한 요청
    if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (kDebugMode) {
        debugPrint('[FCM] iOS 알림 권한: ${settings.authorizationStatus}');
      }
    }

    // Android 13+ 알림 권한 요청 (POST_NOTIFICATIONS)
    if (!kIsWeb && Platform.isAndroid) {
      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // 백그라운드 핸들러 등록 (top-level 함수)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_onForegroundMessage);

    // 앱이 백그라운드에서 열릴 때
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenedApp);

    // 앱이 종료된 상태에서 알림 탭으로 열릴 때
    final initialMessage = await messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageNavigation(initialMessage);
    }

    // FCM 토큰 발급
    try {
      _currentToken = await messaging.getToken();
      if (kDebugMode) {
        debugPrint('[FCM] 토큰: $_currentToken');
      }
      if (_currentToken != null) {
        await _registerToken(_currentToken!);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[FCM] 토큰 발급 실패: $e');
      }
    }

    // 토큰 갱신 리스너
    messaging.onTokenRefresh.listen((newToken) async {
      _currentToken = newToken;
      if (kDebugMode) {
        debugPrint('[FCM] 토큰 갱신: $newToken');
      }
      await _registerToken(newToken);
    });

    _initialized = true;

    if (kDebugMode) {
      debugPrint('[FCM] 초기화 완료');
    }
  }

  /// 포그라운드 메시지 처리
  static void _onForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] 포그라운드 메시지: ${message.notification?.title}');
    }
    // TODO: 인앱 알림 UI 표시 (flutter_local_notifications 연동 예정)
  }

  /// 백그라운드에서 알림 탭으로 앱 열림
  static void _onMessageOpenedApp(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('[FCM] 알림 탭으로 앱 열림: ${message.data}');
    }
    _handleMessageNavigation(message);
  }

  /// 메시지 데이터 기반 화면 이동
  static void _handleMessageNavigation(RemoteMessage message) {
    final data = message.data;
    // TODO: go_router를 통한 딥링크 라우팅 구현 예정
    // 예: data['type'] == 'blockpick' -> /blockpick/${data['id']}
    if (kDebugMode) {
      debugPrint('[FCM] 네비게이션 데이터: $data');
    }
  }

  /// FCM 토큰을 백엔드에 등록합니다.
  ///
  /// TODO (S20): registerPushToken GraphQL mutation 구현 후 실제 API 호출로 교체
  /// mutation RegisterPushToken($token: String!, $platform: String!) {
  ///   registerPushToken(token: $token, platform: $platform) { success }
  /// }
  static Future<void> _registerToken(String token) async {
    final platform = Platform.isIOS ? 'ios' : 'android';
    if (kDebugMode) {
      debugPrint('[FCM] 토큰 등록 요청 (platform: $platform)');
      debugPrint('[FCM] TODO: registerPushToken GraphQL 호출 구현 필요');
    }
    // TODO (S20): GraphQL mutation으로 토큰 등록
    // await graphqlClient.mutate(registerPushTokenMutation(token, platform));
  }
}
