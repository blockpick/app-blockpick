import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/blockpick/blockpick_models.dart';
import '../../data/entry/entry_models.dart';
import '../../providers/entry_provider.dart';
import 'entry_result_screen.dart';
import 'widgets/grid_board.dart';
import 'widgets/ticket_picker.dart';

/// 5-1. 블록 선택 화면
class BlockSelectScreen extends ConsumerStatefulWidget {
  final BlockpickDetail detail;

  const BlockSelectScreen({super.key, required this.detail});

  @override
  ConsumerState<BlockSelectScreen> createState() => _BlockSelectScreenState();
}

class _BlockSelectScreenState extends ConsumerState<BlockSelectScreen> {
  int? _selectedRow;
  int? _selectedCol;
  EntryTicket? _selectedTicket;
  bool _isSubmitting = false;

  void _resetSelection() {
    setState(() {
      _selectedRow = null;
      _selectedCol = null;
    });
  }

  bool get _canSubmit =>
      _selectedTicket != null &&
      _selectedRow != null &&
      _selectedCol != null;

  Future<void> _onConfirm(EntryTicket ticket) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('블록 선택 확인'),
        content: Text(
          '선택 블록: R${_selectedRow! + 1}-C${_selectedCol! + 1}\n'
          '티켓: ${_ticketLabel(ticket)}\n\n'
          '이 블록으로 참여할게요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('다시 고를래요'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('이 블록으로 참여할게요'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);
    try {
      final ds = await ref.read(entryRemoteDataSourceProvider.future);
      final entry = await ds.joinBlockpick(
        blockpickId: widget.detail.id,
        ticketId: ticket.id,
        selectedRow: _selectedRow!,
        selectedCol: _selectedCol!,
        encryptedCoordinates: null,
      );

      if (!mounted) return;
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) =>
              EntryResultScreen(entry: entry, detail: widget.detail),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('참여 실패: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _ticketLabel(EntryTicket ticket) {
    switch (ticket.sourceType) {
      case TicketSourceType.free:
        return '무료 티켓';
      case TicketSourceType.referral:
        return '친구초대 티켓';
      case TicketSourceType.ad:
        return '광고 티켓';
      case TicketSourceType.mission:
        return '미션 티켓';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ticketsAsync = ref.watch(
      myTicketsProvider(
        MyTicketsInput(
          blockpickId: widget.detail.id,
          status: TicketStatus.available,
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('블록 선택'),
        centerTitle: true,
      ),
      body: ticketsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('티켓 불러오기 실패: $e')),
        data: (tickets) {
          // 초기 선택: free 우선
          if (_selectedTicket == null && tickets.isNotEmpty) {
            final free = tickets.where(
              (t) => t.sourceType == TicketSourceType.free,
            );
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _selectedTicket =
                      free.isNotEmpty ? free.first : tickets.first;
                });
              }
            });
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 블록픽 제목 요약 카드
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.detail.title,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.detail.partner.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 티켓 선택
                      Text(
                        '참여 티켓 선택',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TicketPicker(
                        tickets: tickets,
                        selected: _selectedTicket,
                        onChanged: (t) => setState(() => _selectedTicket = t),
                      ),
                      const SizedBox(height: 24),

                      // 그리드 안내
                      Text(
                        '원하는 블록 1개를 선택하세요',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 그리드 보드
                      GridBoard(
                        rows: widget.detail.gridRows,
                        cols: widget.detail.gridCols,
                        selectedRow: _selectedRow,
                        selectedCol: _selectedCol,
                        onTap: (r, c) =>
                            setState(() {
                              _selectedRow = r;
                              _selectedCol = c;
                            }),
                      ),
                      const SizedBox(height: 12),

                      // 선택된 블록 표시
                      Center(
                        child: Text(
                          _selectedRow != null && _selectedCol != null
                              ? '선택: R${_selectedRow! + 1}-C${_selectedCol! + 1}'
                              : '선택해 주세요',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _selectedRow != null
                                ? colorScheme.primary
                                : Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 유의사항
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '• 한 번 확정하면 변경할 수 없어요\n'
                          '• 좌표는 암호화되어 서버로 전송됩니다',
                          style: TextStyle(fontSize: 13, height: 1.6),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // 하단 고정 버튼 영역
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _resetSelection,
                          child: const Text('다시 선택하기'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: (_canSubmit && !_isSubmitting)
                              ? () => _onConfirm(_selectedTicket!)
                              : null,
                          child: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text('선택 완료'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
