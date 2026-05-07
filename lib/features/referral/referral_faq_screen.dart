import 'package:flutter/material.dart';

import '../../core/analytics/analytics_service.dart';

/// 친구초대 FAQ 화면 (기획서 §3, 7개 항목)
class ReferralFaqScreen extends StatefulWidget {
  const ReferralFaqScreen({super.key});

  @override
  State<ReferralFaqScreen> createState() => _ReferralFaqScreenState();
}

class _ReferralFaqScreenState extends State<ReferralFaqScreen> {
  final Set<int> _expanded = {};

  static const _faqs = [
    (
      q: 'Q1. 친구가 가입했는데 보상이 안 와요.',
      a: '초대 보상은 친구가 첫 번째 블록픽에 참여를 완료해야 지급됩니다.\n\n'
          '• 친구가 회원가입만 하면 보상이 지급되지 않습니다.\n'
          '• 친구에게 첫 참여를 완료하도록 안내해주세요.\n'
          '• 첫 참여 후 24시간 이내에 추가 참여권이 자동 적립됩니다.',
    ),
    (
      q: 'Q2. 초대 링크가 작동하지 않습니다.',
      a: '다음을 확인해주세요:\n\n'
          '• 링크가 완전히 복사되었는지 확인\n'
          '• 친구의 기기에서 브라우저나 카카오톡을 통해 직접 클릭\n'
          '• 이미 블록픽 앱이 설치되어 있다면 앱을 먼저 삭제 후 링크 클릭\n'
          '• 문제가 계속되면 고객센터로 문의해주세요.',
    ),
    (
      q: 'Q3. 여러 명을 초대할 수 있나요?',
      a: '네, 많은 친구를 초대할 수 있습니다.\n\n'
          '• 초대 인원의 제한은 없습니다.\n'
          '• 다만 각 친구는 각각 서로 다른 기기와 IP 주소를 사용해야 합니다.\n'
          '• 한 기기에서 여러 계정을 만들어 초대하는 것은 어뷰징으로 적발될 수 있습니다.',
    ),
    (
      q: 'Q4. 초대 실적은 언제까지 조회할 수 있나요?',
      a: '초대 실적은 영구 조회 가능합니다.\n\n'
          '• "초대 실적" 목록에서 모든 초대 기록 확인 가능\n'
          '• 기간별 필터 제공: 최근 7일, 최근 30일, 전체',
    ),
    (
      q: 'Q5. 친구가 다시 참여하면 또 보상을 받나요?',
      a: '아니요, 각 친구당 처음 한 번만 보상을 받습니다.\n\n'
          '• 같은 친구가 여러 번 참여해도 처음 참여 완료 시점에만 보상 지급\n'
          '• 다른 친구를 새로 초대하면 그 친구마다 보상 획득 가능',
    ),
    (
      q: 'Q6. 초대한 친구가 탈퇴하면 어떻게 되나요?',
      a: '초대 보상은 친구가 탈퇴 후에도 유지됩니다.\n\n'
          '• 이미 지급된 추가 참여권은 계속 사용 가능\n'
          '• 친구가 다시 가입하더라도 중복 보상은 제공되지 않습니다.',
    ),
    (
      q: 'Q7. 초대 링크를 여러 번 보낼 수 있나요?',
      a: '네, 같은 링크를 여러 친구에게 보낼 수 있습니다.\n\n'
          '• 링크 개수 제한이 없습니다.\n'
          '• 각 친구는 같은 초대 코드로 가입하더라도 개별 계정으로 인정됩니다.',
    ),
  ];

  @override
  void initState() {
    super.initState();
    AnalyticsService.track('referral_faq_viewed');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('자주 묻는 질문'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 안내 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.help_outline, color: cs.onPrimaryContainer),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '친구초대에 대해 궁금한 점을\n아래에서 확인해보세요',
                    style: tt.bodyMedium?.copyWith(
                      color: cs.onPrimaryContainer,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // FAQ 아코디언 리스트
          ...List.generate(_faqs.length, (i) {
            final faq = _faqs[i];
            final isOpen = _expanded.contains(i);

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cs.surface,
                border: Border.all(
                  color: isOpen
                      ? cs.primary.withValues(alpha: 0.5)
                      : cs.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        if (isOpen) {
                          _expanded.remove(i);
                        } else {
                          _expanded.add(i);
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              faq.q,
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isOpen ? cs.primary : cs.onSurface,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            isOpen
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: cs.onSurfaceVariant,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (isOpen) ...[
                    Divider(
                      height: 1,
                      color: cs.primary.withValues(alpha: 0.2),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                      child: Text(
                        faq.a,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          const SizedBox(height: 24),

          // 고객센터 문의
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.support_agent, size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 8),
                    Text(
                      '원하는 답을 찾지 못하셨나요?',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '고객센터로 문의하시면 빠르게 도움드릴게요.',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // 고객센터 라우트로 이동
                    },
                    icon: const Icon(Icons.chat_outlined, size: 16),
                    label: const Text('고객센터 문의'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
