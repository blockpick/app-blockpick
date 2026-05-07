import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/winning_provider.dart';
import 'widgets/winning_card.dart';
import 'winning_detail_screen.dart';

/// 당첨 내역 리스트 화면 (기획 7-3)
class WinningListScreen extends ConsumerWidget {
  const WinningListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winningsAsync = ref.watch(myWinningsProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        title: Text(
          '당첨 내역',
          style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
        ),
        backgroundColor: AppColors.gray100,
        foregroundColor: AppColors.darkBlue,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: winningsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 12),
              Text(
                '당첨 내역을 불러오지 못했어요',
                style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(myWinningsProvider),
                child: const Text('다시 시도'),
              ),
            ],
          ),
        ),
        data: (winnings) {
          if (winnings.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events_outlined,
                      color: AppColors.gray400, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    '아직 당첨된 내역이 없어요\n지금 바로 참여해 보세요',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((r) => r.isFirst);
                    },
                    child: const Text('지금 참여하러 가기'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(myWinningsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: winnings.length,
              itemBuilder: (context, index) {
                final winning = winnings[index];
                return WinningCard(
                  winning: winning,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => WinningDetailScreen(winning: winning),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
