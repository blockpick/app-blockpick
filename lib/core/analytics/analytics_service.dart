import 'package:flutter/foundation.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

/// Mixpanel 기반 이벤트 분석 서비스
///
/// 프로젝트 토큰 주입 방법:
///   flutter run --dart-define=MIXPANEL_TOKEN=<프로젝트토큰>
///
/// 토큰이 비어있으면 초기화를 건너뜁니다 (이벤트는 no-op).
/// Mixpanel 프로젝트 생성: https://mixpanel.com/
class AnalyticsService {
  AnalyticsService._();

  /// Mixpanel 프로젝트 토큰 — --dart-define=MIXPANEL_TOKEN=... 으로 주입
  static const String _token =
      String.fromEnvironment('MIXPANEL_TOKEN', defaultValue: '');

  static Mixpanel? _mixpanel;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Mixpanel을 초기화합니다.
  ///
  /// 토큰이 비어있으면 초기화를 건너뜁니다.
  static Future<void> init() async {
    if (_token.isEmpty) {
      if (kDebugMode) {
        debugPrint('[Analytics] Mixpanel 토큰이 설정되지 않았습니다. 초기화를 건너뜁니다.');
        debugPrint('[Analytics] 주입 방법: flutter run --dart-define=MIXPANEL_TOKEN=<토큰>');
      }
      return;
    }

    _mixpanel = await Mixpanel.init(
      _token,
      trackAutomaticEvents: true,
    );

    // 디버그 모드에서는 로깅 활성화
    _mixpanel?.setLoggingEnabled(kDebugMode);

    _initialized = true;

    if (kDebugMode) {
      debugPrint('[Analytics] Mixpanel 초기화 완료');
    }
  }

  /// 이벤트를 트래킹합니다.
  ///
  /// [event]: 이벤트 이름 (예: 'block_selected', 'game_joined')
  /// [properties]: 이벤트 속성 (예: {'game_id': '123', 'block_number': 5})
  static void track(String event, [Map<String, dynamic>? properties]) {
    if (!_initialized || _mixpanel == null) {
      if (kDebugMode && _token.isEmpty) {
        // 토큰 미설정 시 조용히 무시
      } else if (kDebugMode) {
        debugPrint('[Analytics] 미초기화 상태에서 track() 호출: $event');
      }
      return;
    }

    if (kDebugMode) {
      debugPrint('[Analytics] 이벤트: $event, 속성: $properties');
    }

    _mixpanel!.track(event, properties: properties);
  }

  /// 사용자 ID를 식별합니다 (로그인 시 호출).
  ///
  /// [userId]: 서버에서 발급한 고유 사용자 ID
  static void identify(String userId) {
    if (!_initialized || _mixpanel == null) return;
    _mixpanel!.identify(userId);

    if (kDebugMode) {
      debugPrint('[Analytics] 사용자 식별: $userId');
    }
  }

  /// 사용자 프로파일 속성을 설정합니다.
  ///
  /// [properties]: 저장할 사용자 속성 (예: {'nickname': '홍길동', 'plan': 'free'})
  static void setUserProperties(Map<String, dynamic> properties) {
    if (!_initialized || _mixpanel == null) return;
    for (final entry in properties.entries) {
      _mixpanel!.getPeople().set(entry.key, entry.value);
    }
  }

  /// 사용자 세션을 초기화합니다 (로그아웃 시 호출).
  static void reset() {
    if (!_initialized || _mixpanel == null) return;
    _mixpanel!.reset();

    if (kDebugMode) {
      debugPrint('[Analytics] Mixpanel 세션 초기화');
    }
  }

  /// 공통 이벤트 상수 (오타 방지용)
  static const String evGameJoined = 'game_joined';
  static const String evBlockSelected = 'block_selected';
  static const String evInviteSent = 'invite_sent';
  static const String evAdWatched = 'ad_watched';
  static const String evSignIn = 'sign_in';
  static const String evSignOut = 'sign_out';
  static const String evPageView = 'page_view';
  static const String evDeepLinkOpened = 'deep_link_opened';
  static const String evKakaoShareTapped = 'kakao_share_tapped';
  static const String evPushReceived = 'push_received';
}
