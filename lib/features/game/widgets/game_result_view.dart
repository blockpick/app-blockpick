import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/game_model.dart';
import '../../../models/game_round_model.dart';
import '../../../providers/game_result_provider.dart';

/// 종료된 게임 결과 화면
class GameResultView extends ConsumerWidget {
  final Game game;
  final GameRound gameRound;

  const GameResultView({
    super.key,
    required this.game,
    required this.gameRound,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(gameResultsProvider(game.id));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),

          // 상태 아이콘
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: gameRound.status == GameStatus.completed
                  ? AppColors.green.withValues(alpha: 0.1)
                  : AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              gameRound.status == GameStatus.completed
                  ? LucideIcons.trophy
                  : LucideIcons.flagTriangleRight,
              size: 40,
              color: gameRound.status == GameStatus.completed
                  ? AppColors.green
                  : AppColors.gray500,
            ),
          ),
          const SizedBox(height: 20),

          // 상태 문구
          Text(
            gameRound.status.bannerMessage(),
            style: AppTextStyles.large.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            gameRound.title,
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // 당첨 위치 카드
          if (game.winningCell != null) _buildWinningCellCard(),

          const SizedBox(height: 20),

          // 게임 정보 요약
          _buildGameSummary(),

          const SizedBox(height: 24),

          // 참가자 결과 목록
          resultsAsync.when(
            data: (results) {
              if (results.isEmpty) {
                return _buildEmptyResults();
              }
              return _buildResultsList(results);
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(40),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
              ),
            ),
            error: (error, _) => _buildEmptyResults(),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 당첨 위치 카드
  Widget _buildWinningCellCard() {
    // winningCell 파싱 (예: "50,30" 또는 "1530" 등)
    final cellInfo = _parseWinningCell(game.winningCell!);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF9C4), Color(0xFFFFE082)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.yellow.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            LucideIcons.mapPin,
            size: 28,
            color: AppColors.orange,
          ),
          const SizedBox(height: 8),
          Text(
            '당첨 위치',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.gray800,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cellInfo,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
        ],
      ),
    );
  }

  /// winningCell 문자열 파싱
  String _parseWinningCell(String cell) {
    // "row,col" 형식
    if (cell.contains(',')) {
      final parts = cell.split(',');
      if (parts.length == 2) {
        return 'X ${parts[0].trim()}  |  Y ${parts[1].trim()}';
      }
    }
    // 단일 셀 번호
    return '셀 #$cell';
  }

  /// 게임 정보 요약
  Widget _buildGameSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryItem(
              LucideIcons.users,
              '참가자',
              '${gameRound.participants}명',
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.gray200),
          Expanded(
            child: _buildSummaryItem(
              LucideIcons.grid,
              '그리드',
              '${gameRound.gridWidth ?? 100}×${gameRound.gridHeight ?? 100}',
            ),
          ),
          Container(width: 1, height: 36, color: AppColors.gray200),
          Expanded(
            child: _buildSummaryItem(
              LucideIcons.coins,
              '참가비',
              '${gameRound.currentPrice} P',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 18, color: AppColors.gray500),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.gray500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  /// 결과 목록
  Widget _buildResultsList(List<GameResultItem> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가자 결과',
          style: AppTextStyles.medium.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        ...results.map((r) => _buildResultItem(r)),
      ],
    );
  }

  Widget _buildResultItem(GameResultItem result) {
    final isWinner = result.rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner ? AppColors.yellow.withValues(alpha: 0.1) : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? AppColors.yellow.withValues(alpha: 0.5) : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          // 순위
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isWinner ? AppColors.yellow : AppColors.gray100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                result.rank != null ? '${result.rank}' : '-',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isWinner ? AppColors.textBlack : AppColors.gray600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // 닉네임
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      result.nickname,
                      style: AppTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.yellow,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '당첨',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (result.reward != null && result.reward! > 0)
                  Text(
                    '보상: ${result.reward!.toInt()} P',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
              ],
            ),
          ),

          // 점수
          if (result.score != null)
            Text(
              '${result.score}점',
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.blue,
              ),
            ),
        ],
      ),
    );
  }

  /// 결과 없음
  Widget _buildEmptyResults() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            LucideIcons.fileSearch,
            size: 48,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 12),
          Text(
            '결과 데이터가 아직 없습니다',
            style: AppTextStyles.body.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }
}
