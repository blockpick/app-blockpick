import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

/// 딥링크(App Links / Universal Links) 처리 서비스
///
/// 지원 패턴:
///   - blockpick://blockpick/:id  → /blockpick/:id
///   - https://blockpick.app/blockpick/:id  → /blockpick/:id
///   - blockpick://invite/:code  → /referral (초대 코드 처리)
///   - https://blockpick.app/invite/:code  → /referral
///
/// 네이티브 설정:
///   - iOS: Info.plist CFBundleURLSchemes + associated domains (docs/external-sdk-keys.md 참조)
///   - Android: AndroidManifest.xml intent-filter (docs/external-sdk-keys.md 참조)
class DeepLinkService {
  DeepLinkService._();

  static AppLinks? _appLinks;
  static bool _initialized = false;
  static GoRouter? _router;

  static bool get isInitialized => _initialized;

  /// 딥링크 서비스를 초기화합니다.
  ///
  /// [router]: go_router 인스턴스 (라우팅 위임에 사용)
  static Future<void> init({required GoRouter router}) async {
    _router = router;
    _appLinks = AppLinks();

    // 앱이 종료된 상태에서 딥링크로 열릴 때 초기 링크 처리
    try {
      final initialUri = await _appLinks!.getInitialLink();
      if (initialUri != null) {
        if (kDebugMode) {
          debugPrint('[DeepLink] 초기 딥링크: $initialUri');
        }
        _handleUri(initialUri);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DeepLink] 초기 링크 처리 실패: $e');
      }
    }

    // 앱 실행 중 딥링크 수신 스트림
    _appLinks!.uriLinkStream.listen(
      (uri) {
        if (kDebugMode) {
          debugPrint('[DeepLink] 수신 URI: $uri');
        }
        _handleUri(uri);
      },
      onError: (error) {
        if (kDebugMode) {
          debugPrint('[DeepLink] 스트림 에러: $error');
        }
      },
    );

    _initialized = true;

    if (kDebugMode) {
      debugPrint('[DeepLink] 서비스 초기화 완료');
    }
  }

  /// URI를 파싱하여 go_router로 라우팅합니다.
  static void _handleUri(Uri uri) {
    if (_router == null) {
      if (kDebugMode) {
        debugPrint('[DeepLink] Router가 설정되지 않았습니다.');
      }
      return;
    }

    final path = uri.path;
    final segments = path.split('/').where((s) => s.isNotEmpty).toList();

    if (segments.isEmpty) return;

    // /blockpick/:id 패턴
    if (segments.length >= 2 && segments[0] == 'blockpick') {
      final id = segments[1];
      if (kDebugMode) {
        debugPrint('[DeepLink] BlockPick 상세 이동: /blockpick_detail/$id');
      }
      // TODO (S20): 실제 라우트 경로로 교체
      _router!.go('/blockpick_detail/$id');
      return;
    }

    // /invite/:code 패턴
    if (segments.length >= 2 && segments[0] == 'invite') {
      final code = segments[1];
      if (kDebugMode) {
        debugPrint('[DeepLink] 초대 코드 처리: $code');
      }
      // TODO (S20): 초대 코드를 저장 후 로그인 → 레퍼럴 화면으로 이동
      _router!.go('/referral?inviteCode=$code');
      return;
    }

    // 기타 경로 — 그대로 go_router에 위임
    if (kDebugMode) {
      debugPrint('[DeepLink] 알 수 없는 경로, 위임: $path');
    }
    try {
      _router!.go(path);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[DeepLink] 라우팅 실패: $e');
      }
    }
  }
}
