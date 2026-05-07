import 'package:flutter/material.dart';
import '../../../data/entry/entry_models.dart';

/// 보유 티켓 선택 위젯
class TicketPicker extends StatelessWidget {
  final List<EntryTicket> tickets;
  final EntryTicket? selected;
  final void Function(EntryTicket) onChanged;

  const TicketPicker({
    super.key,
    required this.tickets,
    this.selected,
    required this.onChanged,
  });

  String _sourceLabel(TicketSourceType type) {
    switch (type) {
      case TicketSourceType.free:
        return '무료';
      case TicketSourceType.referral:
        return '친구초대';
      case TicketSourceType.ad:
        return '광고';
      case TicketSourceType.mission:
        return '미션';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (tickets.isEmpty) {
      return Row(
        children: [
          const Text(
            '참여 가능한 티켓이 없어요',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('광고/미션 화면으로 진입 — 준비 중')),
              );
            },
            child: const Text('기회 받기'),
          ),
        ],
      );
    }

    // sourceType별 그룹화 — 각 타입에서 첫 번째 티켓을 대표로 선택 칩 표시
    final grouped = <TicketSourceType, List<EntryTicket>>{};
    for (final t in tickets) {
      grouped.putIfAbsent(t.sourceType, () => []).add(t);
    }

    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: grouped.entries.map((entry) {
          final type = entry.key;
          final group = entry.value;
          final representative = group.first;
          final isSelected = selected?.sourceType == type;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('${_sourceLabel(type)} - 잔여 ${group.length}개'),
              selected: isSelected,
              onSelected: (_) => onChanged(representative),
            ),
          );
        }).toList(),
      ),
    );
  }
}
