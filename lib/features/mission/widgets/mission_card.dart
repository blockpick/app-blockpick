import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/mission/mission_models.dart';
import '../../../providers/mission_provider.dart';
import '../mission_complete_screen.dart';

class MissionCard extends ConsumerWidget {
  final Mission mission;

  const MissionCard({super.key, required this.mission});

  IconData _typeIcon() {
    switch (mission.missionType) {
      case MissionType.signUp:
        return Icons.person_add;
      case MissionType.appInstall:
        return Icons.download_for_offline;
      case MissionType.channelAdd:
        return Icons.campaign;
      case MissionType.pageVisit:
        return Icons.public;
      case MissionType.offlineVerify:
        return Icons.location_on;
    }
  }

  Future<void> _launchUrl(BuildContext context) async {
    final url = mission.externalUrl;
    if (url == null || url.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('준비 중인 미션이에요')));
      }
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('링크를 열 수 없어요')));
      }
    }
  }

  Future<void> _completeMission(BuildContext context, WidgetRef ref) async {
    // 로딩 다이얼로그
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final ds = await ref.read(missionRemoteDataSourceProvider.future);
      final result = await ds.completeMission(missionId: mission.id);
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop(); // 다이얼로그 닫기
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MissionCompleteScreen(
              mission: result.mission,
              ticketsIssued: result.ticketsIssued,
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('미션 완료 처리 중 오류가 발생했어요: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final cs = mission.completionStatus;
    final st = mission.status;

    // 상태 배지 설정
    final Color badgeColor;
    final String badgeLabel;

    if (st == MissionStatus.inactive) {
      badgeColor = Colors.grey;
      badgeLabel = '마감';
    } else if (cs == MissionCompletionStatus.verified) {
      badgeColor = Colors.green;
      badgeLabel = '완료';
    } else if (cs == MissionCompletionStatus.pending) {
      badgeColor = Colors.blue;
      badgeLabel = '확인 중';
    } else if (cs == MissionCompletionStatus.rejected) {
      badgeColor = Colors.red;
      badgeLabel = '반려';
    } else {
      badgeColor = Colors.orange;
      badgeLabel = '진행 가능';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 좌측 아이콘
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(_typeIcon(), color: colorScheme.primary, size: 24),
            ),
            const SizedBox(width: 12),

            // 가운데 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.title,
                    style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (mission.description != null && mission.description!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        mission.description!,
                        style: textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  const SizedBox(height: 6),
                  // 보상 칩
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '참여권 ${mission.rewardTickets}개',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // 우측 배지 + 버튼
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 배지
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: badgeColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    badgeLabel,
                    style: textTheme.labelSmall?.copyWith(
                      color: badgeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 액션 버튼
                if (st == MissionStatus.active && cs == null)
                  _ActionButton(
                    label: '미션하러 가기',
                    onTap: () async {
                      await _launchUrl(context);
                    },
                  )
                else if (cs == MissionCompletionStatus.pending)
                  _ActionButton(
                    label: '완료 확인하기',
                    onTap: () => _completeMission(context, ref),
                  )
                else if (cs == MissionCompletionStatus.verified)
                  _ActionButton(label: '완료', onTap: null, disabled: true)
                else
                  const SizedBox.shrink(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool disabled;

  const _ActionButton({
    required this.label,
    required this.onTap,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 30,
      child: OutlinedButton(
        onPressed: disabled ? null : onTap,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          side: BorderSide(
            color: disabled ? Colors.grey : colorScheme.primary,
          ),
          foregroundColor: disabled ? Colors.grey : colorScheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label),
      ),
    );
  }
}
