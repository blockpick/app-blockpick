import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/mission_provider.dart';
import 'widgets/mission_card.dart';

class MissionListScreen extends ConsumerStatefulWidget {
  final String? blockpickId;

  const MissionListScreen({super.key, this.blockpickId});

  @override
  ConsumerState<MissionListScreen> createState() => _MissionListScreenState();
}

class _MissionListScreenState extends ConsumerState<MissionListScreen> {
  @override
  Widget build(BuildContext context) {
    final missionsAsync = ref.watch(myMissionsProvider(widget.blockpickId));

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('미션 수행'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 안내 문구
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              '미션을 완료하면 추가 참여권을 받을 수 있어요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),

          // 미션 리스트
          Expanded(
            child: missionsAsync.when(
              data: (missions) {
                if (missions.isEmpty) {
                  return _buildEmptyState(context);
                }
                return RefreshIndicator(
                  onRefresh: () async {
                    // ignore: unused_result
                    ref.invalidate(myMissionsProvider(widget.blockpickId));
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: missions.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      return MissionCard(mission: missions[index]);
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _buildErrorState(context, error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(myMissionsProvider(widget.blockpickId));
      },
      child: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.2),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  '지금 가능한 미션이 없어요',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '다음에 다시 확인해 주세요',
                  style: textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '미션 목록을 불러오지 못했어요',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {
                ref.invalidate(myMissionsProvider(widget.blockpickId));
              },
              child: const Text('다시 시도하기'),
            ),
          ],
        ),
      ),
    );
  }
}
