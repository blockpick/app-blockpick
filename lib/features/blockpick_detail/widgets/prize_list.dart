import 'package:flutter/material.dart';
import '../../../data/blockpick/blockpick_models.dart';

/// 혜택 / 상품 리스트 위젯 (기획 4-1)
class PrizeList extends StatelessWidget {
  final List<BlockpickPrize> prizes;

  const PrizeList({super.key, required this.prizes});

  static const _tierOrder = {
    PrizeTier.grand: 0,
    PrizeTier.first: 1,
    PrizeTier.second: 2,
    PrizeTier.third: 3,
    PrizeTier.participation: 4,
  };

  static const _tierLabels = {
    PrizeTier.grand: 'GRAND',
    PrizeTier.first: '1등',
    PrizeTier.second: '2등',
    PrizeTier.third: '3등',
    PrizeTier.participation: '참여상',
  };

  static const _prizeTypeLabels = {
    PrizeType.coupon: '쿠폰',
    PrizeType.physical: '실물',
    PrizeType.code: '코드',
    PrizeType.point: '포인트',
  };

  IconData _tierIcon(PrizeTier tier) {
    switch (tier) {
      case PrizeTier.grand:
        return Icons.emoji_events;
      case PrizeTier.first:
        return Icons.workspace_premium;
      case PrizeTier.second:
        return Icons.military_tech;
      case PrizeTier.third:
        return Icons.stars;
      case PrizeTier.participation:
        return Icons.card_giftcard;
    }
  }

  Color _tierColor(PrizeTier tier, ColorScheme cs) {
    switch (tier) {
      case PrizeTier.grand:
        return const Color(0xFFFFD700);
      case PrizeTier.first:
        return const Color(0xFFC0C0C0);
      case PrizeTier.second:
        return const Color(0xFFCD7F32);
      case PrizeTier.third:
        return cs.primary;
      case PrizeTier.participation:
        return cs.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [...prizes]
      ..sort((a, b) =>
          (_tierOrder[a.tier] ?? 99).compareTo(_tierOrder[b.tier] ?? 99));

    if (sorted.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(
          '등록된 상품이 없습니다.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    final cs = Theme.of(context).colorScheme;

    return Column(
      children: sorted.map((bp) {
        final faceValue = bp.prize.faceValue;
        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(_tierIcon(bp.tier), color: _tierColor(bp.tier, cs)),
          title: Text(
            '${_tierLabels[bp.tier] ?? bp.tier.name} - ${bp.prize.name}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            '${_prizeTypeLabels[bp.prize.prizeType] ?? bp.prize.prizeType.name} • 수량 ${bp.quantity}',
            style: TextStyle(color: cs.onSurfaceVariant, fontSize: 13),
          ),
          trailing: faceValue != null
              ? Text(
                  '₩${faceValue.toInt()}',
                  style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.w700,
                  ),
                )
              : null,
        );
      }).toList(),
    );
  }
}
