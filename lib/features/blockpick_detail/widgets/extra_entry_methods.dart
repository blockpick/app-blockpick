import 'package:flutter/material.dart';

/// 추가 참여 방법 위젯 (기획 4-1)
/// 친구 초대 / 광고 시청 / 미션 수행 — enabled 여부에 따라 active / disabled
class ExtraEntryMethods extends StatelessWidget {
  final bool referralEnabled;
  final bool adRewardEnabled;
  final bool missionEnabled;

  const ExtraEntryMethods({
    super.key,
    required this.referralEnabled,
    required this.adRewardEnabled,
    required this.missionEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MethodCard(
            icon: Icons.people,
            label: '친구 초대',
            enabled: referralEnabled,
            onTap: () => _showSnackBar(context, '친구 초대'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MethodCard(
            icon: Icons.play_circle,
            label: '광고 시청',
            enabled: adRewardEnabled,
            onTap: () => _showSnackBar(context, '광고 시청'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _MethodCard(
            icon: Icons.task_alt,
            label: '미션 수행',
            enabled: missionEnabled,
            onTap: () => _showSnackBar(context, '미션 수행'),
          ),
        ),
      ],
    );
  }

  void _showSnackBar(BuildContext context, String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label 기능은 준비 중입니다.')),
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final activeColor = cs.primary;
    final disabledColor = cs.onSurfaceVariant.withValues(alpha: 0.4);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: enabled
              ? cs.primaryContainer.withValues(alpha: 0.3)
              : cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? activeColor.withValues(alpha: 0.4) : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: enabled ? activeColor : disabledColor,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: enabled ? cs.onSurface : disabledColor,
              ),
              textAlign: TextAlign.center,
            ),
            if (!enabled)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '준비 중',
                  style: TextStyle(fontSize: 11, color: disabledColor),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
