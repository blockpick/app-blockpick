import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ad_reward/ad_reward_models.dart';
import '../../providers/ad_reward_provider_v2.dart';
import '../../services/admob_service.dart';
import 'ad_reward_complete_screen.dart';

/// 9-1. 광고 시청 보상 화면
///
/// 흐름:
///   1. 화면 진입 시 AdMobService.preloadRewardedAd() 호출
///   2. "광고 보기" 버튼 → AdRewardController.showAdAndClaim()
///   3. 시청 완료 → claimAdReward GraphQL 호출 → 완료 화면으로 이동
///   4. 광고 미준비 / 실패 시 안내 메시지 표시
class AdRewardScreen extends ConsumerStatefulWidget {
  const AdRewardScreen({super.key, required this.blockpickId});

  final String blockpickId;

  @override
  ConsumerState<AdRewardScreen> createState() => _AdRewardScreenState();
}

class _AdRewardScreenState extends ConsumerState<AdRewardScreen> {
  /// 광고 준비 상태 (preload 완료 여부)
  bool _adReady = false;

  /// 광고 로드 중 여부
  bool _adLoading = true;

  /// 보상 청구 처리 중 여부
  bool _isClaiming = false;

  /// 광고 로드 실패 메시지 (null 이면 정상)
  String? _adLoadError;

  @override
  void initState() {
    super.initState();
    _preloadAd();
  }

  /// 광고 미리 로드
  void _preloadAd() {
    setState(() {
      _adLoading = true;
      _adLoadError = null;
    });

    AdMobService().preloadRewardedAd(
      onAdLoaded: () {
        if (!mounted) return;
        setState(() {
          _adReady = true;
          _adLoading = false;
          _adLoadError = null;
        });
      },
      onAdFailedToLoad: (error) {
        if (!mounted) return;
        setState(() {
          _adReady = false;
          _adLoading = false;
          _adLoadError = error;
        });
      },
    );
  }

  /// 오늘 시청한 로그 수 계산
  int _countToday(List<AdRewardLog> logs) {
    final today = DateTime.now();
    return logs.where((log) {
      try {
        final dt = DateTime.parse(log.watchedAt);
        return dt.year == today.year &&
            dt.month == today.month &&
            dt.day == today.day;
      } catch (_) {
        return false;
      }
    }).length;
  }

  /// 광고 보기 버튼 핸들러
  Future<void> _onWatchAd() async {
    if (_isClaiming) return;

    // 광고 미준비 시 재시도 유도
    if (!_adReady) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('광고를 준비 중이에요. 잠시 후 다시 시도해 주세요.'),
          action: SnackBarAction(
            label: '재시도',
            onPressed: _preloadAd,
          ),
        ),
      );
      return;
    }

    setState(() => _isClaiming = true);

    final controller = ref.read(adRewardControllerProvider);
    final result = await controller.showAdAndClaim(
      blockpickId: widget.blockpickId,
      contextType: 'blockpick',
    );

    if (!mounted) return;

    switch (result) {
      case AdClaimSuccess(:final log, :final ticketId):
        // 광고 시청 완료 + 보상 지급 성공
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute<void>(
            builder: (_) => AdRewardCompleteScreen(
              log: log,
              ticketId: ticketId,
            ),
          ),
        );

      case AdClaimAdFailed(:final reason):
        // 광고 표시 실패 — 재시도 유도
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('광고를 불러오지 못했어요: $reason'),
            action: SnackBarAction(
              label: '재시도',
              onPressed: () {
                _preloadAd();
              },
            ),
          ),
        );
        // 광고 상태 초기화 후 재로드
        setState(() {
          _adReady = false;
        });
        _preloadAd();

      case AdClaimCancelled():
        // 사용자가 광고를 끝까지 보지 않고 닫음
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고를 끝까지 시청해야 보상이 지급돼요.'),
          ),
        );
        // 다음 광고 자동 preload (AdMobService 내부에서 처리되지만 상태 반영)
        setState(() {
          _adReady = AdMobService().isReady;
        });

      case AdClaimBackendFailed(:final error):
        // 광고는 시청했지만 서버 청구 실패
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('보상 지급 처리 중 문제가 발생했어요. 잠시 후 다시 시도해 주세요.\n($error)'),
          ),
        );
    }

    if (mounted) setState(() => _isClaiming = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final logsAsync = ref.watch(myAdRewardsProvider(widget.blockpickId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('광고 시청 보상'),
        elevation: 0,
      ),
      body: logsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('불러오기 실패: $e')),
        data: (logs) => _Body(
          theme: theme,
          logs: logs,
          todayWatchedCount: _countToday(logs),
          adLoading: _adLoading,
          adLoadError: _adLoadError,
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 광고 로드 상태 안내
              if (_adLoading)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '광고 준비 중...',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              else if (_adLoadError != null && !_adReady)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 14, color: theme.colorScheme.error),
                      const SizedBox(width: 6),
                      Text(
                        '광고를 불러오지 못했어요.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: _preloadAd,
                        child: Text(
                          '재시도',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: (_isClaiming || _adLoading) ? null : _onWatchAd,
                  child: _isClaiming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          _adReady ? '광고 보고 기회 받기' : '광고 준비 중...',
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('나중에 할게요'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _Body extends StatelessWidget {
  const _Body({
    required this.theme,
    required this.logs,
    required this.todayWatchedCount,
    required this.adLoading,
    this.adLoadError,
  });

  final ThemeData theme;
  final List<AdRewardLog> logs;
  final int todayWatchedCount;
  final bool adLoading;
  final String? adLoadError;

  @override
  Widget build(BuildContext context) {
    final recentLogs = logs.take(5).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      children: [
        // ── 오늘 시청 현황 카드 ──
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘 광고 시청: $todayWatchedCount / 무제한',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '이번 시청 시 보상: 참여권 1개',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── 안내 카드 ──
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('이용 안내',
                  style: theme.textTheme.labelLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              const _BulletText('광고를 끝까지 시청해야 보상이 지급돼요'),
              const SizedBox(height: 6),
              const _BulletText('지급된 참여권은 즉시 사용할 수 있어요'),
              const SizedBox(height: 6),
              const _BulletText('비정상 시청 감지 시 보상이 회수될 수 있어요'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ── 시청 내역 ──
        Text('최근 시청 내역',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (recentLogs.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('아직 시청 내역이 없어요',
                  style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ),
          )
        else
          ...recentLogs.map((log) => _LogTile(log: log)),
      ],
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────────────

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• '),
        Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }
}

class _LogTile extends StatelessWidget {
  const _LogTile({required this.log});
  final AdRewardLog log;

  String _formatTime(String watchedAt) {
    try {
      final dt = DateTime.parse(watchedAt).toLocal();
      final h = dt.hour.toString().padLeft(2, '0');
      final m = dt.minute.toString().padLeft(2, '0');
      return '${dt.month}/${dt.day} $h:$m';
    } catch (_) {
      return watchedAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.play_circle_outline,
          color: theme.colorScheme.primary, size: 20),
      title: Text(_formatTime(log.watchedAt), style: theme.textTheme.bodySmall),
      trailing: Text(
        log.ticketIssued ? '참여권 지급됨' : '미지급',
        style: theme.textTheme.labelSmall?.copyWith(
          color: log.ticketIssued
              ? theme.colorScheme.primary
              : theme.colorScheme.error,
        ),
      ),
    );
  }
}
