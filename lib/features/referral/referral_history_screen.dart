import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../providers/referral_provider.dart';
import 'widgets/referral_item_tile.dart';

/// 초대 실적 상세 화면 (기획서 8-2)
class ReferralHistoryScreen extends ConsumerStatefulWidget {
  const ReferralHistoryScreen({super.key});

  @override
  ConsumerState<ReferralHistoryScreen> createState() =>
      _ReferralHistoryScreenState();
}

class _ReferralHistoryScreenState extends ConsumerState<ReferralHistoryScreen> {
  int _selectedFilter = 2; // 0: 최근 7일, 1: 최근 30일, 2: 전체

  final List<String> _filterLabels = ['최근 7일', '최근 30일', '전체'];

  String get _inviteUrl {
    final codeAsync = ref.read(myInviteCodeProvider);
    final code = codeAsync.valueOrNull?.inviteCode;
    return 'https://blockpick.app/invite/${code ?? ''}';
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: _inviteUrl));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('초대 링크가 복사되었어요')),
    );
  }

  void _showGuideSheet() {
    context.push('/referral/guide');
  }

  void _shareInvite() {
    final codeAsync = ref.read(myInviteCodeProvider);
    final code = codeAsync.valueOrNull?.inviteCode;
    if (code == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초대 코드가 아직 발급되지 않았어요')),
      );
      return;
    }
    Share.share(
      '친구가 BlockPick으로 초대했어요!\n블록 하나 고르고 추첨 기회 받기 → https://blockpick.app/invite/$code',
      subject: 'BlockPick 초대',
    );
  }

  @override
  Widget build(BuildContext context) {
    final referralsAsync = ref.watch(myReferralsProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('초대 실적'),
      ),
      body: Column(
        children: [
          // 기간 필터 칩 (UI placeholder — 클라이언트 필터 없음)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_filterLabels.length, (i) {
                final selected = _selectedFilter == i;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_filterLabels[i]),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedFilter = i),
                    selectedColor: cs.primaryContainer,
                    checkmarkColor: cs.onPrimaryContainer,
                    labelStyle: tt.labelMedium?.copyWith(
                      color: selected ? cs.onPrimaryContainer : cs.onSurface,
                    ),
                  ),
                );
              }),
            ),
          ),

          // 실적 리스트
          Expanded(
            child: referralsAsync.when(
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: cs.error),
                    const SizedBox(height: 12),
                    Text('초대 실적을 불러오지 못했어요',
                        style: tt.bodyMedium),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => ref.refresh(myReferralsProvider),
                      child: const Text('다시 시도'),
                    ),
                  ],
                ),
              ),
              data: (referrals) {
                if (referrals.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.group_add_outlined,
                              size: 56, color: cs.outline),
                          const SizedBox(height: 16),
                          Text(
                            '아직 친구를 초대하지 않았어요\n친구를 초대하고 추가 기회를 받아보세요',
                            textAlign: TextAlign.center,
                            style: tt.bodyMedium
                                ?.copyWith(color: cs.outline),
                          ),
                          const SizedBox(height: 20),
                          FilledButton.icon(
                            onPressed: _shareInvite,
                            icon: const Icon(Icons.share),
                            label: const Text('지금 초대하기'),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _showGuideSheet,
                            icon: const Icon(Icons.menu_book_outlined, size: 16),
                            label: const Text('초대 가이드 보기'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async =>
                      ref.refresh(myReferralsProvider),
                  child: ListView.builder(
                    itemCount: referrals.length,
                    itemBuilder: (_, i) =>
                        ReferralItemTile(referral: referrals[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // 하단 고정 버튼 영역
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _shareInvite,
                  child: const Text('다시 초대하기'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _copyLink,
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('링크 복사'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
