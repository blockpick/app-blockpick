import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

/// Sentry 초기화 설정
///
/// DSN 주입 방법:
///   flutter run --dart-define=SENTRY_DSN=https://...@sentry.io/...
///
/// DSN이 비어있으면 초기화를 건너뜁니다 (개발 환경 safe).
class SentryConfig {
  SentryConfig._();

  /// Sentry DSN — --dart-define=SENTRY_DSN=... 으로 주입
  static const String _dsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  /// Sentry 환경 — --dart-define=SENTRY_ENV=production 등
  static const String _environment = String.fromEnvironment('SENTRY_ENV', defaultValue: 'development');

  /// 초기화 완료 여부
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  /// Sentry를 초기화합니다.
  ///
  /// [appRunner]: Sentry zone 내에서 실행할 앱 실행 함수
  ///
  /// DSN이 비어있으면 [appRunner]를 그대로 실행하고 반환합니다.
  static Future<void> init(AppRunner appRunner) async {
    // DSN 미주입 시 SKIP
    if (_dsn.isEmpty) {
      if (kDebugMode) {
        debugPrint('[Sentry] DSN이 설정되지 않았습니다. 초기화를 건너뜁니다.');
        debugPrint('[Sentry] 주입 방법: flutter run --dart-define=SENTRY_DSN=<DSN>');
      }
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = _dsn;
        options.environment = _environment;

        // 릴리즈 모드에서만 성능 샘플링 활성화
        options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
        options.profilesSampleRate = kReleaseMode ? 0.1 : 0.0;

        // 디버그 모드에서는 Sentry 로그 출력
        options.debug = kDebugMode;
        options.attachStacktrace = true;

        // Flutter 에러 자동 캡처
        options.enableAutoSessionTracking = true;
      },
      appRunner: appRunner,
    );

    _initialized = true;

    if (kDebugMode) {
      debugPrint('[Sentry] 초기화 완료 (env: $_environment)');
    }
  }

  /// 수동으로 에러를 캡처합니다.
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    Map<String, dynamic>? extras,
  }) async {
    if (!_initialized) return;
    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: extras != null
          ? (scope) {
              extras.forEach((key, value) {
                // setExtra는 deprecated — Contexts 방식으로 태그 저장
                scope.setTag(key, value.toString());
              });
            }
          : null,
    );
  }

  /// 사용자 정보를 Sentry에 설정합니다.
  static Future<void> setUser({
    required String userId,
    String? email,
  }) async {
    if (!_initialized) return;
    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(id: userId, email: email));
    });
  }

  /// 사용자 정보를 초기화합니다 (로그아웃 시 호출).
  static Future<void> clearUser() async {
    if (!_initialized) return;
    await Sentry.configureScope((scope) {
      scope.setUser(null);
    });
  }
}
