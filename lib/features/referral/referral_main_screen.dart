import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/referral/referral_models.dart';
import '../../providers/referral_provider.dart';
import 'referral_history_screen.dart';
import 'widgets/invite_summary_card.dart';
import 'widgets/invite_link_card.dart';
import 'widgets/referral_item_tile.dart';
import '../../core/analytics/analytics_service.dart';

/// 친구초대 메인 화면 (기획서 8-1)
class ReferralMainScreen extends ConsumerWidget {
  const ReferralMainScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeAsync = ref.watch(myInviteCodeProvider);
    final referralsAsync = ref.watch(myReferralsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('친구초대'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: codeAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorRetry(
          message: '초대 코드를 불러오지 못했어요',
          onRetry: () => ref.refresh(myInviteCodeProvider),
        ),
        data: (codeInfo) => referralsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => _ErrorRetry(
            message: '초대 실적을 불러오지 못했어요',
            onRetry: () => ref.refresh(myReferralsProvider),
          ),
          data: (referrals) => _MainBody(
            codeInfo: codeInfo,
            referrals: referrals,
          ),
        ),
      ),
    );
  }
}

class _MainBody extends StatelessWidget {
  final MyInviteCodeInfo codeInfo;
  final List<Referral> referrals;

  const _MainBody({required this.codeInfo, required this.referrals});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final recentReferrals = referrals.take(3).toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        // 1. 내 초대 요약 카드
        InviteSummaryCard(codeInfo: codeInfo, referrals: referrals),

        // 2. 내 초대 링크 카드
        InviteLinkCard(inviteCode: codeInfo.inviteCode),

        // 3. 가이드/FAQ 진입 카드
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.menu_book_outlined,
                  label: '초대 가이드',
                  subtitle: '3단계로 알아보기',
                  onTap: () {
                    AnalyticsService.track('referral_guide_viewed');
                    context.push('/referral/guide');
                  },
                  colorScheme: cs,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.help_outline,
                  label: 'FAQ',
                  subtitle: '자주 묻는 질문',
                  onTap: () => context.push('/referral/faq'),
                  colorScheme: cs,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _QuickLinkCard(
                  icon: Icons.card_giftcard_outlined,
                  label: '보상 조건',
                  subtitle: '지급 조건 확인',
                  onTap: () => context.push('/referral/guide'),
                  colorScheme: cs,
                ),
              ),
            ],
          ),
        ),

        // 4. 보상 조건 안내 섹션
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: cs.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('보상 조건 안내', style: tt.titleSmall),
                  const SizedBox(height: 10),
                  _ConditionRow('친구가 회원가입 + 첫 참여 완료 시 인정'),
                  const SizedBox(height: 6),
                  _ConditionRow('중복/비정상 계정은 제외'),
                  const SizedBox(height: 6),
                  _ConditionRow('보상은 친구가 첫 참여한 후 24시간 내 지급'),
                ],
              ),
            ),
          ),
        ),

        // 5. 최근 초대 실적 (최대 3건)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 초대 실적', style: tt.titleSmall),
              if (referrals.isNotEmpty)
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ReferralHistoryScreen(),
                    ),
                  ),
                  child: const Text('전체 실적 보기'),
                ),
            ],
          ),
        ),

        if (referrals.isEmpty)
          _EmptyState()
        else
          Column(
            children: [
              ...recentReferrals.map((r) => ReferralItemTile(referral: r)),
            ],
          ),
      ],
    );
  }
}

class _ConditionRow extends StatelessWidget {
  final String text;
  const _ConditionRow(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_outline, size: 16, color: cs.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: tt.bodySmall?.copyWith(color: cs.onSurface)),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.group_add_outlined, size: 56, color: cs.outline),
          const SizedBox(height: 16),
          Text(
            '아직 친구를 초대하지 않았어요\n친구를 초대하고 추가 기회를 받아보세요',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.outline),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('위의 초대 링크를 공유해보세요!')),
              );
            },
            icon: const Icon(Icons.share),
            label: const Text('지금 친구 초대하기'),
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            onPressed: () => context.push('/referral/guide'),
            icon: const Icon(Icons.menu_book_outlined, size: 16),
            label: const Text('초대 가이드 보기'),
          ),
        ],
      ),
    );
  }
}

// ===================== 빠른 링크 카드 =====================

class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 24, color: colorScheme.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: tt.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 48, color: cs.error),
          const SizedBox(height: 12),
          Text(message, style: tt.bodyMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: const Text('다시 시도'),
          ),
        ],
      ),
    );
  }
}
