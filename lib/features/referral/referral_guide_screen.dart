import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/analytics/analytics_service.dart';

/// 친구초대 가이드 화면 (기획서 §2–§4)
/// 3단계 초대 방법 + 어뷰징 안내 + 보상 조건
class ReferralGuideScreen extends StatefulWidget {
  const ReferralGuideScreen({super.key});

  @override
  State<ReferralGuideScreen> createState() => _ReferralGuideScreenState();
}

class _ReferralGuideScreenState extends State<ReferralGuideScreen> {
  bool _abuseExpanded = false;
  bool _rewardExpanded = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.track('referral_guide_viewed');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('초대 가이드'),
        actions: [
          TextButton(
            onPressed: () => context.push('/referral/faq'),
            child: const Text('FAQ'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primaryContainer, cs.secondaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.group_add, size: 48, color: cs.onPrimaryContainer),
                const SizedBox(height: 12),
                Text(
                  '친구를 초대하고\n추가 참여 기회를 얻어보세요!',
                  textAlign: TextAlign.center,
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // 초대 방법 3단계
          Text(
            '초대 방법',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          _StepCard(
            step: 1,
            icon: Icons.share,
            title: '초대 링크 공유하기',
            desc: '친구초대 탭에서 내 초대 코드를 확인한 후\n'
                '[링크 복사] 또는 [공유하기]를 통해 친구에게 보내세요.\n\n'
                '카카오톡, 문자, SNS, 이메일 등 어디서든 공유 가능합니다.',
            colorScheme: cs,
          ),
          const SizedBox(height: 12),
          _StepCard(
            step: 2,
            icon: Icons.person_add,
            title: '친구가 가입 및 첫 참여',
            desc: '초대받은 친구가 링크를 통해 회원가입한 뒤\n'
                '첫 번째 블록픽에 참여를 완료해야 초대가 인정됩니다.\n\n'
                '회원가입만으로는 보상이 지급되지 않습니다.',
            colorScheme: cs,
          ),
          const SizedBox(height: 12),
          _StepCard(
            step: 3,
            icon: Icons.card_giftcard,
            title: '보상 자동 지급',
            desc: '친구의 첫 참여 완료 후 24시간 이내에\n'
                '초대자와 친구 모두 추가 참여권 1개씩 자동 적립됩니다.\n\n'
                '보상은 "참여내역 → 추가 참여" 섹션에서 사용 가능합니다.',
            colorScheme: cs,
          ),
          const SizedBox(height: 28),

          // 보상 조건 아코디언
          _AccordionCard(
            title: '보상 조건 상세',
            icon: Icons.info_outline,
            iconColor: cs.primary,
            expanded: _rewardExpanded,
            onTap: () => setState(() => _rewardExpanded = !_rewardExpanded),
            children: [
              _ConditionItem(
                icon: Icons.check_circle_outline,
                color: Colors.green,
                text: '초대 링크를 통해 친구가 회원가입',
              ),
              _ConditionItem(
                icon: Icons.check_circle_outline,
                color: Colors.green,
                text: '친구가 첫 번째 블록픽에 참여 완료',
              ),
              _ConditionItem(
                icon: Icons.check_circle_outline,
                color: Colors.green,
                text: '초대자와 친구가 서로 다른 기기/IP 주소 사용',
              ),
              const Divider(height: 24),
              _ConditionItem(
                icon: Icons.cancel_outlined,
                color: Colors.red,
                text: '친구가 회원가입만 하고 미참여 → 보상 없음',
              ),
              _ConditionItem(
                icon: Icons.cancel_outlined,
                color: Colors.red,
                text: '같은 기기에서 초대자·친구 계정 생성 → 무효',
              ),
              _ConditionItem(
                icon: Icons.cancel_outlined,
                color: Colors.red,
                text: '어뷰징 적발 시 보상 몰수',
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '보상 지급 일정',
                      style: tt.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 8),
                    _ScheduleRow('친구 가입 완료', '대기 중', cs),
                    _ScheduleRow('친구 첫 참여 완료', '보상 지급 대기', cs),
                    _ScheduleRow('참여 후 24시간 이내', '추가 참여권 1개 지급', cs,
                        highlight: true),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 어뷰징 방지 아코디언
          _AccordionCard(
            title: '어뷰징 방지 안내',
            icon: Icons.shield_outlined,
            iconColor: Colors.orange,
            expanded: _abuseExpanded,
            onTap: () => setState(() => _abuseExpanded = !_abuseExpanded),
            children: [
              _AbuseItem(
                title: '다계정 생성 및 자가 초대',
                items: const [
                  '같은 기기에서 여러 계정을 만들어 서로 초대',
                  '같은 전화번호/이메일로 여러 계정 생성 후 초대',
                ],
                result: '모든 어뷰징 계정 정지 및 보상 무효 처리',
              ),
              const SizedBox(height: 12),
              _AbuseItem(
                title: 'IP 주소 조작',
                items: const [
                  'VPN, 프록시 등을 이용한 동일 IP 초대',
                  '같은 Wi-Fi 네트워크에서 의도적 다계정 생성',
                ],
                result: '어뷰징 계정 적발 시 경고 후 정지',
              ),
              const SizedBox(height: 12),
              _AbuseItem(
                title: '자동화 도구 사용',
                items: const [
                  '봇, 매크로, 자동 초대 프로그램 사용',
                  '초대 링크를 스팸 채널에 대량 배포',
                ],
                result: '계정 영구 정지',
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '정상적인 초대',
                      style: tt.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final text in [
                      '서로 다른 기기에서 각각 가입',
                      '서로 다른 IP 주소 사용 (다른 집, 학교, 회사 등)',
                      '실제 친구/가족에게만 공유',
                      '친구가 자발적으로 앱 설치 및 참여',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check, size: 14, color: Colors.green.shade700),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(text,
                                  style: tt.bodySmall?.copyWith(
                                      color: Colors.green.shade800)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // FAQ 바로가기 버튼
          OutlinedButton.icon(
            onPressed: () => context.push('/referral/faq'),
            icon: const Icon(Icons.help_outline),
            label: const Text('자주 묻는 질문(FAQ) 보기'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
          const SizedBox(height: 16),

          // 초대하러 가기
          FilledButton.icon(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.share),
            label: const Text('지금 친구 초대하기'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ===================== 하위 위젯 =====================

class _StepCard extends StatelessWidget {
  final int step;
  final IconData icon;
  final String title;
  final String desc;
  final ColorScheme colorScheme;

  const _StepCard({
    required this.step,
    required this.icon,
    required this.title,
    required this.desc,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 스텝 번호 원형
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 16, color: colorScheme.primary),
                    const SizedBox(width: 6),
                    Text(
                      title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
                  style: tt.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccordionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final bool expanded;
  final VoidCallback onTap;
  final List<Widget> children;

  const _AccordionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.expanded,
    required this.onTap,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border.all(color: cs.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (expanded) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConditionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _ConditionItem({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final String timing;
  final String status;
  final ColorScheme cs;
  final bool highlight;

  const _ScheduleRow(this.timing, this.status, this.cs,
      {this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              timing,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Text(
            status,
            style: tt.bodySmall?.copyWith(
              fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              color: highlight ? cs.primary : cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AbuseItem extends StatelessWidget {
  final String title;
  final List<String> items;
  final String result;

  const _AbuseItem({
    required this.title,
    required this.items,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.red.shade700,
            ),
          ),
          const SizedBox(height: 6),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('❌ ', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Text(
                      item,
                      style: tt.bodySmall?.copyWith(color: cs.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.warning_amber, size: 14, color: Colors.orange),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '결과: $result',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.orange.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
