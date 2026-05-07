import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_share/kakao_flutter_sdk_share.dart';
import 'package:share_plus/share_plus.dart';

/// Kakao SDK 공유 서비스
///
/// 앱키 주입 방법:
///   flutter run --dart-define=KAKAO_NATIVE_KEY=<네이티브앱키>
///
/// 앱키가 비어있으면 share_plus fallback으로 동작합니다.
/// Kakao Developers 앱 등록: https://developers.kakao.com/
class KakaoShareService {
  KakaoShareService._();

  /// Kakao 네이티브 앱키 — --dart-define=KAKAO_NATIVE_KEY=... 으로 주입
  static const String _nativeKey =
      String.fromEnvironment('KAKAO_NATIVE_KEY', defaultValue: '');

  static bool _initialized = false;

  static bool get isInitialized => _initialized;
  static bool get hasKey => _nativeKey.isNotEmpty;

  /// Kakao SDK를 초기화합니다.
  ///
  /// 앱키가 없으면 초기화를 건너뜁니다.
  static Future<void> init() async {
    if (_nativeKey.isEmpty) {
      if (kDebugMode) {
        debugPrint('[Kakao] 네이티브 앱키가 설정되지 않았습니다. 초기화를 건너뜁니다.');
        debugPrint('[Kakao] 주입 방법: flutter run --dart-define=KAKAO_NATIVE_KEY=<키>');
      }
      return;
    }

    KakaoSdk.init(nativeAppKey: _nativeKey);
    _initialized = true;

    if (kDebugMode) {
      debugPrint('[Kakao] SDK 초기화 완료');
    }
  }

  /// 커스텀 템플릿으로 카카오톡 공유
  ///
  /// [templateId]: Kakao Developers에서 생성한 메시지 템플릿 ID
  /// [templateArgs]: 템플릿 변수 치환 값 (예: {'invite_code': 'ABC123'})
  ///
  /// Kakao SDK가 미초기화 또는 카카오톡 미설치 시 share_plus fallback 실행.
  static Future<void> shareCustomTemplate({
    required int templateId,
    required Map<String, String> templateArgs,
    String? fallbackText,
    String? fallbackSubject,
  }) async {
    if (!_initialized) {
      if (kDebugMode) {
        debugPrint('[Kakao] SDK 미초기화 — share_plus fallback 사용');
      }
      _shareFallback(fallbackText, fallbackSubject);
      return;
    }

    try {
      // 카카오톡 설치 여부 확인
      final isInstalled = await ShareClient.instance.isKakaoTalkSharingAvailable();

      if (isInstalled) {
        // 카카오톡 앱으로 공유
        final uri = await ShareClient.instance.shareCustom(
          templateId: templateId,
          templateArgs: templateArgs,
        );
        await ShareClient.instance.launchKakaoTalk(uri);

        if (kDebugMode) {
          debugPrint('[Kakao] 카카오톡 공유 완료');
        }
      } else {
        // 카카오톡 미설치 — 웹 공유
        final uri = await WebSharerClient.instance.makeCustomUrl(
          templateId: templateId,
          templateArgs: templateArgs,
        );
        await launchBrowserTab(uri, popupOpen: true);

        if (kDebugMode) {
          debugPrint('[Kakao] 웹 공유 완료');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[Kakao] 공유 실패: $e — share_plus fallback 사용');
      }
      _shareFallback(fallbackText, fallbackSubject);
    }
  }

  /// 초대 링크 공유 (초대 코드 특화 헬퍼)
  ///
  /// [inviteCode]: 사용자 초대 코드
  /// [templateId]: Kakao 템플릿 ID (TODO S20: 실제 템플릿 ID로 교체)
  static Future<void> shareInviteLink({
    required String inviteCode,
    int templateId = 0, // TODO (S20): 실제 카카오 템플릿 ID로 교체
  }) async {
    final inviteUrl = 'https://blockpick.app/invite/$inviteCode';
    final fallbackText =
        '친구가 BlockPick으로 초대했어요!\n블록 하나 고르고 추첨 기회 받기 → $inviteUrl';

    if (!_initialized || templateId == 0) {
      if (kDebugMode) {
        debugPrint('[Kakao] 템플릿 ID 미설정 — share_plus fallback 사용');
      }
      _shareFallback(fallbackText, 'BlockPick 초대');
      return;
    }

    await shareCustomTemplate(
      templateId: templateId,
      templateArgs: {
        'invite_code': inviteCode,
        'invite_url': inviteUrl,
      },
      fallbackText: fallbackText,
      fallbackSubject: 'BlockPick 초대',
    );
  }

  /// share_plus를 이용한 범용 공유 fallback
  static void _shareFallback(String? text, String? subject) {
    if (text == null || text.isEmpty) return;
    Share.share(text, subject: subject);
  }
}
