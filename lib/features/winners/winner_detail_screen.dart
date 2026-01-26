import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/winner_model.dart';
import '../../data/mock_winner_data.dart';

/// 역대 당첨자 상세 화면
class WinnerDetailScreen extends StatelessWidget {
  final String winnerId;

  const WinnerDetailScreen({
    super.key,
    required this.winnerId,
  });

  @override
  Widget build(BuildContext context) {
    final detail = MockWinnerData.getWinnerDetail(winnerId);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 당첨 이벤트 정보
            _buildEventInfo(detail.winner),

            // 당첨자 프로필 + 축하 애니메이션
            _buildWinnerProfile(detail),

            // 선택 좌표 보기 버튼
            _buildCoordinateButton(context, detail),

            const SizedBox(height: 24),

            // 최종 결과 리스트
            _buildResultSection(detail),
          ],
        ),
      ),
    );
  }

  /// App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
        onPressed: () => context.pop(),
      ),
      title: Text(
        '역대 당첨자',
        style: AppTextStyles.medium.copyWith(
          color: AppColors.darkBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
    );
  }

  /// 당첨 이벤트 정보
  Widget _buildEventInfo(WinnerModel winner) {
    final dateFormat = DateFormat('yyyy.MM.dd');

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 상품 이미지 (썸네일)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: winner.productImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                    child: Image.asset(
                      winner.productImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.card_giftcard,
                          color: AppColors.medium,
                        );
                      },
                    ),
                  )
                : const Icon(
                    Icons.card_giftcard,
                    color: AppColors.medium,
                  ),
          ),
          const SizedBox(width: 12),

          // 이벤트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  winner.productName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      winner.eventType.displayName,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.medium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '•',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.medium,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      dateFormat.format(winner.winDate),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.medium,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 당첨자 프로필 + 축하 애니메이션
  Widget _buildWinnerProfile(WinnerDetailModel detail) {
    final winner = detail.winner;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          // 축하 애니메이션 배경 + 프로필
          Stack(
            alignment: Alignment.center,
            children: [
              // 축하 일러스트 (Lottie 또는 이미지)
              // TODO: Lottie 애니메이션 추가
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      AppColors.yellow.withValues(alpha: 0.2),
                      AppColors.pink.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),

              // 프로필 이미지
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgWhite,
                  border: Border.all(
                    color: AppColors.yellow,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.yellow.withValues(alpha: 0.3),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: winner.hasProfileImage
                      ? Image.network(
                          winner.profileImageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildInitialAvatar(winner);
                          },
                        )
                      : _buildInitialAvatar(winner),
                ),
              ),

              // 뱃지 아이콘
              Positioned(
                bottom: 45,
                right: 45,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.yellow,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white,
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.emoji_events,
                    size: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 닉네임
          Text(
            winner.nickName,
            style: AppTextStyles.medium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 초성 아바타
  Widget _buildInitialAvatar(WinnerModel winner) {
    return Container(
      color: AppColors.blue,
      alignment: Alignment.center,
      child: Text(
        winner.initial,
        style: AppTextStyles.large.copyWith(
          color: AppColors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// 선택 좌표 보기 버튼
  Widget _buildCoordinateButton(BuildContext context, WinnerDetailModel detail) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: 블록체인 WebView로 이동
          if (detail.blockchainViewUrl != null) {
            // context.push('/webview', extra: detail.blockchainViewUrl);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusFull),
            border: Border.all(color: AppColors.bgWhite),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '선택 좌표 보기',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.yellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.search,
                  size: 12,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 최종 결과 섹션
  Widget _buildResultSection(WinnerDetailModel detail) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Text(
                '최종 결과',
                style: AppTextStyles.medium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(총 ${_formatNumber(detail.totalParticipants)}명 참여)',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 결과 테이블
          _buildResultTable(detail.topRankers),
        ],
      ),
    );
  }

  /// 결과 테이블
  Widget _buildResultTable(List<WinnerRankModel> rankers) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.bgWhite),
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        children: [
          // 테이블 헤더
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.radiusMd),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 40,
                  child: Text(
                    '순위',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '아이디',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text(
                    '시간(UTC)',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    '중복 인원',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.medium,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
          ),

          // 테이블 바디
          ...rankers.map((ranker) => _buildResultRow(ranker)),
        ],
      ),
    );
  }

  /// 결과 테이블 행
  Widget _buildResultRow(WinnerRankModel ranker) {
    final timeFormat = DateFormat('HH:mm:ss');
    final isWinner = ranker.rank == 1;

    return InkWell(
      onTap: () {
        // TODO: 블록체인 기록 열람
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isWinner ? AppColors.yellow.withValues(alpha: 0.1) : null,
          border: Border(
            bottom: BorderSide(
              color: AppColors.bgWhite,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '${ranker.rank}',
                style: AppTextStyles.body.copyWith(
                  fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                  color: isWinner ? AppColors.yellow : AppColors.darkBlue,
                ),
              ),
            ),
            Expanded(
              child: Text(
                ranker.nickName,
                style: AppTextStyles.body.copyWith(
                  fontWeight: isWinner ? FontWeight.w600 : FontWeight.normal,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                timeFormat.format(ranker.selectedTime),
                style: AppTextStyles.body.copyWith(
                  color: AppColors.medium,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                ranker.duplicateCount == 1
                    ? '1명 (독점)'
                    : '${ranker.duplicateCount}명',
                style: AppTextStyles.bodySmall.copyWith(
                  color: ranker.duplicateCount == 1
                      ? AppColors.green
                      : AppColors.medium,
                  fontWeight: ranker.duplicateCount == 1
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 숫자 포맷팅 (1,000 형식)
  String _formatNumber(int number) {
    return NumberFormat('#,###').format(number);
  }
}
