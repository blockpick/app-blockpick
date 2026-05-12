import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';

/// 파트너 게임 WebView 화면
/// 웹 가차 게임을 앱 내에서 실행하고 Bridge로 통신
class PartnerGameWebView extends ConsumerStatefulWidget {
  final String gameId;
  final String? gameTitle;

  const PartnerGameWebView({
    super.key,
    required this.gameId,
    this.gameTitle,
  });

  @override
  ConsumerState<PartnerGameWebView> createState() => _PartnerGameWebViewState();
}

class _PartnerGameWebViewState extends ConsumerState<PartnerGameWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  // TODO: 환경별 URL 분기
  // TODO: 환경별 URL 분기 (production: https://web-blockpick.vercel.app)
  static const String _baseUrl = String.fromEnvironment(
    'PARTNER_WEB_BASE_URL',
    defaultValue: 'https://web-blockpick.vercel.app',
  );

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final authState = ref.read(authProvider).valueOrNull;
    final token = authState?.token ?? '';

    final url = '$_baseUrl/game/${widget.gameId}?source=app&token=$token';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'BlockPickBridge',
        onMessageReceived: _handleBridgeMessage,
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  /// 웹 → 앱 Bridge 메시지 처리
  void _handleBridgeMessage(JavaScriptMessage message) {
    try {
      final msg = jsonDecode(message.message) as Map<String, dynamic>;
      final type = msg['type'] as String?;
      final payload = msg['payload'] as Map<String, dynamic>? ?? {};
      final messageId = msg['messageId'] as String? ?? '';

      switch (type) {
        case 'READY':
          debugPrint('[Bridge] 웹 로드 완료: gameId=${payload['gameId']}');
          break;

        case 'GAME_RESULT':
          _handleGameResult(payload);
          break;

        case 'REQUEST_TOKEN_REFRESH':
          _handleTokenRefresh(messageId);
          break;

        case 'REQUEST_CLOSE':
          if (mounted) Navigator.of(context).pop();
          break;

        case 'HAPTIC':
          _handleHaptic(payload['type'] as String? ?? 'medium');
          break;

        case 'ANALYTICS':
          debugPrint('[Bridge] Analytics: ${payload['event']}');
          break;

        default:
          debugPrint('[Bridge] 알 수 없는 메시지: $type');
      }
    } catch (e) {
      debugPrint('[Bridge] 메시지 파싱 오류: $e');
    }
  }

  /// 게임 결과 처리
  void _handleGameResult(Map<String, dynamic> payload) {
    final isWin = payload['isWin'] as bool? ?? false;
    final prize = payload['prize'] as Map<String, dynamic>?;
    final guestToken = payload['guestToken'] as String?;

    debugPrint('[Bridge] 게임 결과: isWin=$isWin, prize=$prize');

    // 비회원 guestToken 저장 (향후 재참여 시 사용)
    if (guestToken != null) {
      debugPrint('[Bridge] guestToken 수신: $guestToken');
    }

    // TODO: 포인트 잔액 갱신, 당첨 내역 업데이트
    // ref.invalidate(walletProvider);
  }

  /// 토큰 갱신 요청 처리
  Future<void> _handleTokenRefresh(String requestId) async {
    try {
      // TODO: refreshToken 호출 후 새 토큰 전달
      final authState = ref.read(authProvider).valueOrNull;
      final newToken = authState?.token ?? '';

      _sendToWeb({
        'type': 'TOKEN_REFRESH',
        'payload': {'newToken': newToken},
        'requestId': requestId,
        'success': true,
        'messageId': DateTime.now().millisecondsSinceEpoch.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      debugPrint('[Bridge] 토큰 갱신 실패: $e');
    }
  }

  /// 햅틱 피드백
  void _handleHaptic(String type) {
    switch (type) {
      case 'light':
        HapticFeedback.lightImpact();
        break;
      case 'medium':
        HapticFeedback.mediumImpact();
        break;
      case 'heavy':
        HapticFeedback.heavyImpact();
        break;
    }
  }

  /// 앱 → 웹 메시지 전달
  void _sendToWeb(Map<String, dynamic> message) {
    final json = jsonEncode(message);
    _controller.runJavaScript('''
      window.dispatchEvent(new CustomEvent('blockpick', {
        detail: $json
      }));
    ''');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          widget.gameTitle ?? '파트너 이벤트',
          style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
        ),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkBlue,
          ),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
              ),
            ),
        ],
      ),
    );
  }
}
