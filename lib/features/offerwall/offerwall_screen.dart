import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/analytics/analytics_service.dart';
import '../../core/theme/app_colors.dart';
import '../../data/offerwall/offerwall_models.dart';
import '../../providers/offerwall_provider.dart';
import '../../providers/point_provider.dart';
import '../../services/offerwall/offerwall_factory.dart';
import '../../services/offerwall/web_offerwall_adapter.dart';
import 'widgets/category_filter.dart';
import 'widgets/offer_card.dart';

/// 오퍼월 메인 화면
///
/// - 카테고리 필터 (전체/소형/중형/대형/이벤트)
/// - 오퍼 카드 리스트
/// - 상단 잔여 포인트 표시
///
/// 포인트 적립은 서버사이드 postback 처리 — 클라이언트는 진입/조회만 담당.
class OfferwallScreen extends ConsumerStatefulWidget {
  const OfferwallScreen({super.key});

  @override
  ConsumerState<OfferwallScreen> createState() => _OfferwallScreenState();
}

class _OfferwallScreenState extends ConsumerState<OfferwallScreen> {
  OfferwallCategory? _selectedCategory;

  @override
  void initState() {
    super.initState();
    AnalyticsService.track('offerwall_opened');
  }

  Future<void> _onOfferTap(OfferwallOffer offer) async {
    AnalyticsService.track('offer_clicked', {
      'offerId': offer.id,
      'pointReward': offer.pointReward,
      'category': offerwallCategoryToString(offer.category),
    });

    // 클릭 트래킹 + 외부 URL 획득
    final notifier = ref.read(startOfferwallOfferProvider.notifier);
    final result = await notifier.startOffer(offer.id);

    if (!mounted) return;

    final url = (result?.externalUrl?.isNotEmpty == true)
        ? result!.externalUrl!
        : offer.clickUrl;

    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오퍼 URL을 불러올 수 없어요. 잠시 후 다시 시도해 주세요.')),
      );
      return;
    }

    final adapter = OfferwallFactory.create();
    adapter.onCompletion(({offerId, pointsEarned}) {
      ref.invalidate(pointWalletProvider);
    });

    // WebOfferwallAdapter: Navigator context 직접 전달
    if (adapter is WebOfferwallAdapter) {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _OfferwallWebViewPage(url: url, title: offer.title),
        ),
      );
      ref.invalidate(pointWalletProvider);
      return;
    }

    // 네이티브 SDK 어댑터 시도, 미구현 시 웹뷰 fallback
    try {
      await adapter.showOfferwall(url: url, title: offer.title);
    } catch (_) {
      if (!mounted) return;
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => _OfferwallWebViewPage(url: url, title: offer.title),
        ),
      );
    }

    if (mounted) ref.invalidate(pointWalletProvider);
  }

  @override
  Widget build(BuildContext context) {
    final offersAsync = ref.watch(offerwallOffersProvider(_selectedCategory));
    final walletAsync = ref.watch(pointWalletProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textBlack,
            size: 20,
          ),
        ),
        title: const Text(
          '포인트 적립',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PointHeader(walletAsync: walletAsync),
          const SizedBox(height: 16),
          OfferwallCategoryFilter(
            selected: _selectedCategory,
            onChanged: (cat) => setState(() => _selectedCategory = cat),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: offersAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, st) => _ErrorState(
                onRetry: () =>
                    ref.invalidate(offerwallOffersProvider(_selectedCategory)),
              ),
              data: (offers) {
                if (offers.isEmpty) return const _EmptyState();
                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.invalidate(offerwallOffersProvider(_selectedCategory)),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 24),
                    itemCount: offers.length,
                    itemBuilder: (context, index) => OfferCard(
                      offer: offers[index],
                      onTap: () => _onOfferTap(offers[index]),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── 포인트 헤더 ──────────────────────────────────────────────

class _PointHeader extends StatelessWidget {
  final AsyncValue<dynamic> walletAsync;
  const _PointHeader({required this.walletAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '내 포인트',
            style: TextStyle(fontSize: 13, color: AppColors.gray600),
          ),
          const SizedBox(height: 4),
          walletAsync.when(
            loading: () => const SizedBox(
              height: 28,
              child: LinearProgressIndicator(minHeight: 2),
            ),
            error: (e, st) => const Text(
              '- P',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.textBlack,
              ),
            ),
            data: (wallet) => Text(
              '${wallet.balance}P',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryMain,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '오퍼를 완료하면 서버에서 포인트가 자동 적립됩니다.',
              style: TextStyle(fontSize: 12, color: AppColors.primaryMain),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 빈 상태 ─────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.inbox_rounded, size: 56, color: AppColors.gray400),
          SizedBox(height: 12),
          Text(
            '현재 진행 중인 오퍼가 없어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            '다른 카테고리를 선택하거나 나중에 다시 확인해 보세요.',
            style: TextStyle(fontSize: 13, color: AppColors.gray400),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── 오류 상태 ────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline_rounded,
              size: 48, color: AppColors.gray400),
          const SizedBox(height: 12),
          const Text(
            '오퍼를 불러오지 못했어요',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.gray600,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('다시 시도')),
        ],
      ),
    );
  }
}

// ── 인앱 웹뷰 오퍼월 페이지 ──────────────────────────────────

class _OfferwallWebViewPage extends StatefulWidget {
  final String url;
  final String title;

  const _OfferwallWebViewPage({required this.url, required this.title});

  @override
  State<_OfferwallWebViewPage> createState() => _OfferwallWebViewPageState();
}

class _OfferwallWebViewPageState extends State<_OfferwallWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (_) {
          if (mounted) setState(() => _loading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
