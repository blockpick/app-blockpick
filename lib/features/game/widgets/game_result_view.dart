import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56 + 16,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Column(
        children: [
          // 상태 안내 배너
          _buildStatusBanner(),

          const SizedBox(height: 20),

          // 게임 정보 요약
          resultsAsync.when(
            data: (data) => _buildGameSummary(data.totalElements),
            loading: () => _buildGameSummary(0),
            error: (_, __) => _buildGameSummary(0),
          ),

          // 총 보상 풀 (P0)
          if (game.rewardPoint != null && game.rewardPoint! > 0) ...[
            const SizedBox(height: 12),
            _buildRewardPool(),
          ],

          // 당첨 셀 정보 (P0)
          if (game.winningCell != null && game.winningCell!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildWinningCell(),
          ],

          // 게임 기간 (P1)
          if (game.startTime != null || game.endTime != null) ...[
            const SizedBox(height: 12),
            _buildGamePeriod(),
          ],

          // 경품 정보 (P1)
          if (game.gameProducts != null && game.gameProducts!.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildPrizeSection(),
          ],

          // 블록체인 검증 (P2)
          if (game.onchainTxHash != null || game.onchainContractAddr != null) ...[
            const SizedBox(height: 12),
            _buildBlockchainSection(),
          ],

          const SizedBox(height: 24),

          // 참가자 결과 목록
          resultsAsync.when(
            data: (data) {
              if (data.results.isEmpty) {
                return _buildEmptyResults();
              }
              return _buildResultsList(data.results);
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

  /// 상태 안내 배너
  Widget _buildStatusBanner() {
    final isCompleted = gameRound.status == GameStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.green500.withValues(alpha: 0.15)
                  : AppColors.gray200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? LucideIcons.trophy : LucideIcons.flagTriangleRight,
              size: 20,
              color: isCompleted ? AppColors.green500 : AppColors.gray500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 게임 타입 뱃지 (P2)
                    if (game.gameType != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: _getGameTypeColor(game.gameType!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          game.gameType!.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                    // 즉석 경품 뱃지 (P2)
                    if (game.hasInstantPrize) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '즉석경품',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        gameRound.title,
                        style: AppTextStyles.body3.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (game.description != null &&
                    game.description!.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    game.description!,
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.gray600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  SizedBox(height: 2),
                  Text(
                    gameRound.status.bannerMessage(),
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 게임 정보 요약
  Widget _buildGameSummary(int totalElements) {
    // 참가자 표시: totalElements 기반, maxEntries가 있으면 비율 표시 (P1)
    String participantText;
    if (totalElements > 0) {
      if (game.maxEntries != null && game.maxEntries! > 0) {
        participantText = '$totalElements/${game.maxEntries}명';
      } else {
        participantText = '${totalElements}명';
      }
    } else {
      if (game.maxEntries != null && game.maxEntries! > 0) {
        participantText = '${gameRound.participants}/${game.maxEntries}명';
      } else {
        participantText = '${gameRound.participants}명';
      }
    }

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
              participantText,
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
        SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.caption1.copyWith(color: AppColors.gray500),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.body3.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
      ],
    );
  }

  /// 총 보상 풀 (P0)
  Widget _buildRewardPool() {
    final formatted = NumberFormat('#,###').format(game.rewardPoint!);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.blue.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.gift, size: 20, color: AppColors.blue),
          SizedBox(width: 10),
          Text(
            '총 보상',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.gray600,
            ),
          ),
          Spacer(),
          Text(
            '$formatted P',
            style: AppTextStyles.body3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.blue,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 당첨 셀 정보 (P0)
  Widget _buildWinningCell() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.yellow500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.yellow500.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.mapPin, size: 20, color: AppColors.orange),
          SizedBox(width: 10),
          Text(
            '당첨 위치',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.gray600,
            ),
          ),
          Spacer(),
          Text(
            _formatWinningCell(game.winningCell!),
            style: AppTextStyles.body3.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.orange,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  /// 게임 기간 표시 (P1)
  Widget _buildGamePeriod() {
    String periodText = '';
    try {
      if (game.startTime != null && game.endTime != null) {
        final start = DateTime.parse(game.startTime!);
        final end = DateTime.parse(game.endTime!);
        final fmt = DateFormat('MM/dd HH:mm');
        periodText = '${fmt.format(start)} ~ ${fmt.format(end)}';
      } else if (game.startTime != null) {
        final start = DateTime.parse(game.startTime!);
        periodText = '${DateFormat('MM/dd HH:mm').format(start)} ~';
      } else if (game.endTime != null) {
        final end = DateTime.parse(game.endTime!);
        periodText = '~ ${DateFormat('MM/dd HH:mm').format(end)}';
      }
    } catch (_) {
      periodText = '기간 정보 없음';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.calendar, size: 18, color: AppColors.gray500),
          SizedBox(width: 10),
          Text(
            '게임 기간',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          Spacer(),
          Text(
            periodText,
            style: AppTextStyles.body3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 경품 정보 섹션 (P1)
  Widget _buildPrizeSection() {
    final products = game.gameProducts!;
    // sequence 기준 정렬
    final sorted = List<GameProduct>.from(products)
      ..sort((a, b) => (a.sequence ?? 0).compareTo(b.sequence ?? 0));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '경품 정보',
          style: AppTextStyles.title1.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 12),
        ...sorted.map((gp) => _buildPrizeItem(gp)),
      ],
    );
  }

  Widget _buildPrizeItem(GameProduct gp) {
    final product = gp.product;
    final isGrand = gp.isGrandPrize ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGrand
            ? AppColors.yellow500.withValues(alpha: 0.08)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isGrand
              ? AppColors.yellow500.withValues(alpha: 0.4)
              : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          // 상품 이미지
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 56,
              height: 56,
              color: AppColors.gray100,
              child: product.defaultImage != null
                  ? Image.network(
                      product.defaultImage!.replaceAll(' ', '%20'),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        LucideIcons.package,
                        size: 24,
                        color: AppColors.gray400,
                      ),
                    )
                  : const Icon(
                      LucideIcons.package,
                      size: 24,
                      color: AppColors.gray400,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (isGrand) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.yellow500,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '대상',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textBlack,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                    ],
                    Flexible(
                      child: Text(
                        product.name,
                        style: AppTextStyles.body3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                if (product.brand != null && product.brand!.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    product.brand!,
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 가격
          if (product.price != null && product.price! > 0)
            Text(
              '${NumberFormat('#,###').format(product.price)}원',
              style: AppTextStyles.body3.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
        ],
      ),
    );
  }

  /// 블록체인 검증 섹션 (P2)
  Widget _buildBlockchainSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.shield, size: 16, color: AppColors.gray600),
              SizedBox(width: 6),
              Text(
                '블록체인 검증',
                style: AppTextStyles.caption1.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          if (game.onchainTxHash != null) ...[
            const SizedBox(height: 8),
            _buildBlockchainLink(
              label: 'TX',
              hash: game.onchainTxHash!,
            ),
          ],
          if (game.onchainContractAddr != null) ...[
            SizedBox(height: 4),
            _buildBlockchainLink(
              label: 'Contract',
              hash: game.onchainContractAddr!,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBlockchainLink({
    required String label,
    required String hash,
  }) {
    final shortHash = hash.length > 16
        ? '${hash.substring(0, 8)}...${hash.substring(hash.length - 6)}'
        : hash;

    return GestureDetector(
      onTap: () => _openExplorer(hash),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: AppTextStyles.caption1.copyWith(
              color: AppColors.gray500,
              fontSize: 11,
            ),
          ),
          Flexible(
            child: Text(
              shortHash,
              style: AppTextStyles.caption1.copyWith(
                color: AppColors.blue,
                fontSize: 11,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.blue,
              ),
            ),
          ),
          SizedBox(width: 4),
          Icon(LucideIcons.externalLink, size: 12, color: AppColors.blue),
        ],
      ),
    );
  }

  /// 결과 목록
  Widget _buildResultsList(List<GameResultItem> results) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '참가자 결과',
          style: AppTextStyles.title1.copyWith(
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
    final isWinner = result.isWinner;
    final displayName =
        result.nickname ?? '참가자 ${result.id.substring(0, 6)}';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isWinner
            ? AppColors.yellow500.withValues(alpha: 0.1)
            : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner
              ? AppColors.yellow500.withValues(alpha: 0.5)
              : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          // 프로필 이미지 / 순위 (P1)
          _buildProfileAvatar(result),
          SizedBox(width: 12),

          // 닉네임 + txHash + 참여시각
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: AppTextStyles.body3.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isWinner) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.yellow500,
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
                if (result.txHash != null) ...[
                  SizedBox(height: 2),
                  Text(
                    'tx: ${result.txHash!.length > 14 ? '${result.txHash!.substring(0, 14)}...' : result.txHash!}',
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.gray400,
                      fontSize: 10,
                    ),
                  ),
                ],
                // 참여 시각 (P2)
                if (result.joinedAt.isNotEmpty) ...[
                  SizedBox(height: 2),
                  Text(
                    _formatDateTime(result.joinedAt),
                    style: AppTextStyles.caption1.copyWith(
                      color: AppColors.gray400,
                      fontSize: 10,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 보상 + 점수
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (result.reward != null && result.reward! > 0)
                Text(
                  '${NumberFormat('#,###').format(result.reward!.toInt())} P',
                  style: AppTextStyles.body3.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isWinner ? AppColors.orange : AppColors.gray600,
                  ),
                ),
              // 점수 (P2)
              if (result.score != null)
                Text(
                  '${result.score}점',
                  style: AppTextStyles.caption1.copyWith(
                    color: AppColors.gray500,
                    fontSize: 11,
                  ),
                ),
            ],
          ),

          // 당첨 아이콘
          if (isWinner) ...[
            const SizedBox(width: 8),
            const Icon(
              LucideIcons.trophy,
              size: 20,
              color: AppColors.orange,
            ),
          ],
        ],
      ),
    );
  }

  /// 프로필 아바타 (P1)
  Widget _buildProfileAvatar(GameResultItem result) {
    final isWinner = result.isWinner;
    final hasImage =
        result.profileImageUrl != null && result.profileImageUrl!.isNotEmpty;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: isWinner ? AppColors.yellow500 : AppColors.gray100,
        shape: BoxShape.circle,
        border: isWinner
            ? Border.all(color: AppColors.orange, width: 2)
            : null,
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                result.profileImageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildRankText(result),
              ),
            )
          : _buildRankText(result),
    );
  }

  Widget _buildRankText(GameResultItem result) {
    return Center(
      child: Text(
        result.rank != null ? '${result.rank}' : '-',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: result.isWinner ? AppColors.textBlack : AppColors.gray600,
        ),
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
          SizedBox(height: 12),
          Text(
            '결과 데이터가 아직 없습니다',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ],
      ),
    );
  }

  // ─── 헬퍼 메서드 ───

  /// 당첨 셀 좌표 포맷 (예: "3,5" → "(3, 5)")
  String _formatWinningCell(String cell) {
    final parts = cell.split(',');
    if (parts.length == 2) {
      return '(${parts[0].trim()}, ${parts[1].trim()})';
    }
    return cell;
  }

  /// DateTime 문자열 포맷
  String _formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('MM/dd HH:mm').format(dt);
    } catch (_) {
      return dateTimeStr;
    }
  }

  /// 블록 익스플로러 열기
  Future<void> _openExplorer(String hash) async {
    // Base Sepolia 기본 (프로젝트에 맞게 변경 가능)
    final url = Uri.parse('https://sepolia.basescan.org/search?q=$hash');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// 게임 타입별 색상
  Color _getGameTypeColor(String gameType) {
    switch (gameType.toUpperCase()) {
      case 'DAILY':
        return AppColors.pink;
      case 'SELECT':
        return AppColors.purple;
      case 'VIBE':
        return AppColors.blue;
      case 'PRIME':
        return AppColors.yellow500;
      default:
        return AppColors.gray500;
    }
  }
}
