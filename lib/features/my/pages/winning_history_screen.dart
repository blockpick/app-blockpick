import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 당첨 내역 화면
class WinningHistoryScreen extends ConsumerWidget {
  const WinningHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 실제 당첨 내역 API 연동
    final winnings = _mockWinnings;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
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
        body: winnings.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: winnings.length,
                itemBuilder: (context, index) {
                  final winning = winnings[index];
                  return _WinningItem(winning: winning);
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          SizedBox(height: 16),
          Text(
            '당첨 내역이 없습니다',
            style: AppTextStyles.body2.copyWith(color: AppColors.gray500),
          ),
          const SizedBox(height: 8),
          Text(
            '게임에 참여하고 행운을 잡아보세요!',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray400,
            ),
          ),
        ],
      ),
    );
  }
}

class _WinningItem extends StatelessWidget {
  final Map<String, dynamic> winning;

  const _WinningItem({required this.winning});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.green500.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.green500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.green500,
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      winning['gameTitle'] as String,
                      style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      winning['date'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '당첨 상품',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  winning['prize'] as String,
                  style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// 임시 데이터
final _mockWinnings = [
  {
    'id': '1',
    'gameTitle': '상품 픽 게임 #45',
    'date': '2025.01.04 15:30',
    'prize': 'iPad Pro 12.9"',
  },
  {
    'id': '2',
    'gameTitle': '데일리 게임 #98',
    'date': '2025.01.02 11:20',
    'prize': '캐시 50,000원',
  },
];
