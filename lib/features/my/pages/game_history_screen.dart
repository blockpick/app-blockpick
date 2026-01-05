import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

/// 게임 참여 내역 화면
class GameHistoryScreen extends ConsumerWidget {
  const GameHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: 실제 게임 내역 API 연동
    final games = _mockGameHistory;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: const Text(
            '게임 참여 내역',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: games.isEmpty
            ? _buildEmptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return _GameHistoryItem(game: game);
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
            Icons.videogame_asset_outlined,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            '참여한 게임이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '홈에서 게임에 참여해보세요!',
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

class _GameHistoryItem extends StatelessWidget {
  final Map<String, dynamic> game;

  const _GameHistoryItem({required this.game});

  @override
  Widget build(BuildContext context) {
    final status = game['status'] as String;
    final isWinner = game['isWinner'] as bool;

    Color statusColor;
    String statusText;
    if (status == 'completed') {
      statusColor = isWinner ? AppColors.green : AppColors.gray500;
      statusText = isWinner ? '당첨' : '미당첨';
    } else {
      statusColor = AppColors.blue;
      statusText = '진행중';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  game['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem('참여일', game['date'] as String),
              const SizedBox(width: 24),
              _buildInfoItem('사용 캐시', '${game['usedCash']}원'),
              const SizedBox(width: 24),
              _buildInfoItem('선택 블록', game['selectedBlock'] as String),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.gray500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }
}

// 임시 데이터
final _mockGameHistory = [
  {
    'id': '1',
    'title': '데일리 게임 #123',
    'date': '2025.01.05',
    'usedCash': '1,000',
    'selectedBlock': 'A-15',
    'status': 'in_progress',
    'isWinner': false,
  },
  {
    'id': '2',
    'title': '상품 픽 게임 #45',
    'date': '2025.01.04',
    'usedCash': '2,000',
    'selectedBlock': 'B-22',
    'status': 'completed',
    'isWinner': true,
  },
  {
    'id': '3',
    'title': '바이브 게임 #12',
    'date': '2025.01.03',
    'usedCash': '500',
    'selectedBlock': 'C-8',
    'status': 'completed',
    'isWinner': false,
  },
];
