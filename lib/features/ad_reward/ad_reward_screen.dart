import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/ad_reward/ad_reward_models.dart';
import '../../providers/ad_reward_provider_v2.dart';
import 'ad_reward_complete_screen.dart';

/// 9-1. 광고 시청 보상 화면
/// TODO: AdMob RewardedAd 연결 — 현재 3초 대기 다이얼로그로 대체
class AdRewardScreen extends ConsumerStatefulWidget {
  const AdRewardScreen({super.key, required this.blockpickId});

  final String blockpickId;

  @override
  ConsumerState<AdRewardScreen> createState() => _AdRewardScreenState();
}

class _AdRewardScreenState extends ConsumerState<AdRewardScreen> {
  bool _isClaiming = false;

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

  Future<void> _onWatchAd() async {
    if (_isClaiming) return;

    // TODO: AdMob RewardedAd 연결 — 아래 dialog 를 실제 광고로 교체
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _AdSimulationDialog(),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isClaiming = true);
    try {
      final ds =
          await ref.read(adRewardRemoteDataSourceProvider.future);
      final result = await ds.claimAdReward(
        blockpickId: widget.blockpickId,
        externalNetworkRef: 'sim_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => AdRewardCompleteScreen(
            log: result.log,
            ticketId: result.ticketId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('보상 지급 실패: $e')),
      );
    } finally {
      if (mounted) setState(() => _isClaiming = false);
    }
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
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _isClaiming ? null : _onWatchAd,
                  child: _isClaiming
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('광고 보고 기회 받기',
                          style: TextStyle(fontSize: 16)),
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

class _Body extends StatelessWidget {
  const _Body({
    required this.theme,
    required this.logs,
    required this.todayWatchedCount,
  });

  final ThemeData theme;
  final List<AdRewardLog> logs;
  final int todayWatchedCount;

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

class _BulletText extends StatelessWidget {
  const _BulletText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('• '),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
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
      title: Text(_formatTime(log.watchedAt),
          style: theme.textTheme.bodySmall),
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

/// 광고 시뮬레이션 다이얼로그 (3초 대기 후 자동 닫힘)
/// TODO: AdMob RewardedAd 연결 시 이 다이얼로그 제거
class _AdSimulationDialog extends StatefulWidget {
  const _AdSimulationDialog();

  @override
  State<_AdSimulationDialog> createState() => _AdSimulationDialogState();
}

class _AdSimulationDialogState extends State<_AdSimulationDialog> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('광고 시청 중'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(),
          SizedBox(height: 12),
          Text('잠시만 기다려 주세요...'),
        ],
      ),
    );
  }
}
