import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/analytics/analytics_service.dart';
import '../../data/blockpick/blockpick_models.dart';
import '../../providers/blockpick_provider.dart';
import 'widgets/prize_list.dart';
import 'widgets/extra_entry_methods.dart';

/// 블록픽 상세 화면 (기획 4-1)
class BlockpickDetailScreen extends ConsumerWidget {
  final String blockpickId;

  const BlockpickDetailScreen({super.key, required this.blockpickId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(blockpickDetailProvider(blockpickId));

    return detailAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 56, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              const Text('블록픽을 불러오지 못했어요'),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.invalidate(blockpickDetailProvider(blockpickId)),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
      ),
      data: (detail) {
        if (detail == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('블록픽을 찾을 수 없습니다')),
          );
        }
        return _DetailBody(detail: detail);
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final BlockpickDetail detail;

  const _DetailBody({required this.detail});

  String _remainingText() {
    final end = DateTime.tryParse(detail.endTime);
    if (end == null) return '종료 일시 없음';
    final diff = end.difference(DateTime.now());
    if (diff.isNegative) return '종료됨';
    if (diff.inDays >= 1) return '종료까지 ${diff.inDays}일 남음';
    if (diff.inHours >= 1) return '종료까지 ${diff.inHours}시간 남음';
    return '종료까지 ${diff.inMinutes}분 남음';
  }

  String _statusLabel(BlockpickStatus status) {
    switch (status) {
      case BlockpickStatus.active:
        return '진행 중';
      case BlockpickStatus.paused:
        return '일시 중단';
      case BlockpickStatus.ended:
        return '종료';
      case BlockpickStatus.draft:
        return '준비 중';
    }
  }

  Color _statusColor(BlockpickStatus status, ColorScheme cs) {
    switch (status) {
      case BlockpickStatus.active:
        return Colors.green;
      case BlockpickStatus.paused:
        return Colors.orange;
      case BlockpickStatus.ended:
        return cs.onSurfaceVariant;
      case BlockpickStatus.draft:
        return cs.onSurfaceVariant;
    }
  }

  bool get _isCtaEnabled =>
      detail.status != BlockpickStatus.ended &&
      detail.status != BlockpickStatus.paused;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final imageUrl = detail.mainImageUrl ?? detail.thumbnailUrl;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 상단 SliverAppBar (대표 이미지 collapsible)
          SliverAppBar.large(
            expandedHeight: 260,
            pinned: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                tooltip: '공유',
                onPressed: () {
                  AnalyticsService.track(
                    'blockpick_share_clicked',
                    {'blockpick_id': detail.id, 'channel': 'share_plus'},
                  );
                  Share.share(
                    '${detail.title}\n블록픽에서 지금 참여해보세요!\nhttps://blockpick.app/blockpick/${detail.id}',
                    subject: detail.title,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                tooltip: '알림',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('알림 기능은 준비 중입니다.')),
                  );
                },
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: imageUrl != null
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, e, stack) => Container(
                        color: cs.surfaceContainerHighest,
                        child: Icon(Icons.image_not_supported_outlined,
                            size: 48, color: cs.onSurfaceVariant),
                      ),
                    )
                  : Container(
                      color: cs.surfaceContainerHighest,
                      child: Icon(Icons.image_outlined,
                          size: 48, color: cs.onSurfaceVariant),
                    ),
            ),
          ),

          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. 타이틀 섹션
                    Text(
                      detail.title,
                      style: tt.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.partner.name,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. 상태 배지 행
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        _Badge(
                          label: _statusLabel(detail.status),
                          color: _statusColor(detail.status, cs),
                        ),
                        if (detail.isRecommended)
                          _Badge(label: '추천', color: cs.primary),
                        if (detail.freeEntryQuota > 0)
                          _Badge(
                            label: '무료 ${detail.freeEntryQuota}회',
                            color: Colors.teal,
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. 남은 시간 카드
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.timer_outlined,
                              size: 20, color: cs.onSurfaceVariant),
                          const SizedBox(width: 8),
                          Text(
                            _remainingText(),
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // 4. 혜택 섹션
                    _SectionTitle(label: '혜택'),
                    const SizedBox(height: 8),
                    PrizeList(prizes: detail.prizes),
                    const SizedBox(height: 28),

                    // 5. 참여 방법 섹션
                    _SectionTitle(label: '참여 방법'),
                    const SizedBox(height: 12),
                    _StepItem(
                      number: '1',
                      text: '무료로 ${detail.freeEntryQuota}회 참여',
                    ),
                    _StepItem(
                      number: '2',
                      text: '그리드에서 블록 선택',
                    ),
                    _StepItem(
                      number: '3',
                      text: [
                        if (detail.referralEnabled) '친구초대',
                        if (detail.adRewardEnabled) '광고',
                        if (detail.missionEnabled) '미션',
                      ].join(' / ').let((s) =>
                          s.isNotEmpty ? '$s으로 추가 참여' : '추가 참여 방법 없음'),
                    ),
                    const SizedBox(height: 28),

                    // 6. 추가 참여 방법 섹션
                    _SectionTitle(label: '추가 참여 방법'),
                    const SizedBox(height: 12),
                    ExtraEntryMethods(
                      referralEnabled: detail.referralEnabled,
                      adRewardEnabled: detail.adRewardEnabled,
                      missionEnabled: detail.missionEnabled,
                    ),
                    const SizedBox(height: 28),

                    // 7. 참여 가능 정보 섹션
                    _SectionTitle(label: '참여 가능 정보'),
                    const SizedBox(height: 12),
                    _InfoRow(
                        label: '그리드',
                        value: '${detail.gridRows}×${detail.gridCols}'),
                    _InfoRow(
                        label: '1인 최대',
                        value: '${detail.maxEntriesPerUser}회 참여'),
                    _InfoRow(
                        label: '현재 총 참여 수',
                        value: '${detail.totalEntryCount.toInt()}회'),
                    const SizedBox(height: 28),

                    // 8. 유의사항 아코디언
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '유의사항',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      children: const [
                        _CautionItem(
                            text:
                                '한 번 참여 후 결과 발표 시점까지 추첨 결과를 변경할 수 없어요'),
                        _CautionItem(
                            text: '비정상 참여 감지 시 보상이 회수될 수 있어요'),
                        _CautionItem(
                            text: '글로벌 배송은 일부 국가에서 제한될 수 있어요'),
                      ],
                    ),
                    const Divider(),

                    // 9. 글로벌 배송 안내 섹션
                    const SizedBox(height: 8),
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '글로벌 배송 안내',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _InfoRow(
                                label: '배송 가능 국가',
                                value: 'KR, US, JP (일부 국가 제한)',
                              ),
                              _InfoRow(
                                label: '배송비',
                                value: '파트너 부담',
                              ),
                              _InfoRow(
                                label: '관세/통관',
                                value: '당첨자 부담',
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '• 배송지 입력은 당첨 확정 후 진행합니다\n'
                                  '• 해외 배송 시 통관 절차로 인해 지연될 수 있습니다\n'
                                  '• 일부 국가는 배송이 제한될 수 있으며, 제한 국가로 당첨 시 상품 교체 또는 환불 처리됩니다',
                                  style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    height: 1.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),

                    // 10. 파트너 정보 아코디언
                    ExpansionTile(
                      tilePadding: EdgeInsets.zero,
                      title: Text(
                        '파트너 정보',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 4, 0, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                detail.partner.name,
                                style: tt.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600),
                              ),
                              if (detail.partner.websiteUrl != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    detail.partner.websiteUrl!,
                                    style: tt.bodySmall?.copyWith(
                                      color: cs.primary,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // 하단 여백 (CTA 버튼 높이 확보)
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),

      // 하단 고정 CTA
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: FilledButton(
            onPressed: _isCtaEnabled
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          '블록 선택 화면은 준비 중입니다 (block_select_screen 라우트)',
                        ),
                      ),
                    );
                  }
                : null,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _isCtaEnabled ? '지금 참여하기' : '참여 불가',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

// ===================== 재사용 소형 위젯 =====================

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context)
          .textTheme
          .titleMedium
          ?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String text;
  const _StepItem({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cs.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
            ),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _CautionItem extends StatelessWidget {
  final String text;
  const _CautionItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 13)),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== String 유틸 extension =====================

extension _StringLet on String {
  T let<T>(T Function(String) block) => block(this);
}
