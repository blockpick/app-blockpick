import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'offerwall_adapter.dart';

/// 웹뷰 기반 오퍼월 어댑터 (fallback)
///
/// Tapjoy/AdGem 등 네이티브 SDK 미통합 시 사용하는 기본 어댑터.
/// webview_flutter로 외부 오퍼월 URL을 인앱 웹뷰로 표시합니다.
///
/// 포인트 적립은 서버사이드 postback으로 처리되므로
/// 클라이언트에서는 URL 진입만 담당합니다.
class WebOfferwallAdapter implements OfferwallAdapter {
  OfferwallCompletionCallback? _completionCallback;

  @override
  Future<void> showOfferwall({
    required String url,
    String? title,
  }) async {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => _OfferwallWebView(
          url: url,
          title: title ?? '오퍼월',
          onCompletion: () {
            _completionCallback?.call(offerId: null, pointsEarned: null);
          },
        ),
      ),
    );
  }

  @override
  void onCompletion(OfferwallCompletionCallback callback) {
    _completionCallback = callback;
  }

  @override
  void dispose() {
    _completionCallback = null;
  }

  /// Navigator context 주입용 key.
  /// OfferwallScreen에서 설정합니다.
  static GlobalKey<NavigatorState>? _navigatorKey;

  static void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }
}

/// 인앱 웹뷰 오퍼월 화면
class _OfferwallWebView extends StatefulWidget {
  final String url;
  final String title;
  final VoidCallback? onCompletion;

  const _OfferwallWebView({
    required this.url,
    required this.title,
    this.onCompletion,
  });

  @override
  State<_OfferwallWebView> createState() => _OfferwallWebViewState();
}

class _OfferwallWebViewState extends State<_OfferwallWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            widget.onCompletion?.call();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
