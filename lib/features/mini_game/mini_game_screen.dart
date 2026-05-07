import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../core/analytics/analytics_service.dart';
import '../../providers/point_provider.dart';

/// SC-POI-02: 미니게임 화면 (카드 뒤집기)
/// - 3장 카드 중 1장을 선택 → 서버에 결과 전송
/// - 성공 +5P, 실패 0P
/// - 성공 후 광고 시청 옵션 (+5P 추가 시뮬)
class MiniGameScreen extends ConsumerStatefulWidget {
  const MiniGameScreen({super.key});

  @override
  ConsumerState<MiniGameScreen> createState() => _MiniGameScreenState();
}

class _MiniGameScreenState extends ConsumerState<MiniGameScreen>
    with SingleTickerProviderStateMixin {
  // 카드 상태
  final int _totalCards = 3;
  final int _winningCardIndex = Random().nextInt(3); // 0~2 중 랜덤 당첨 카드
  int? _selectedCard;
  bool _revealed = false;
  bool _adWatched = false;

  late AnimationController _flipController;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 게임 시작 상태로 전환
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(miniGameProvider.notifier).startGame();
    });
  }

  @override
  void dispose() {
    _flipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(miniGameProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.textBlack,
          onPressed: () {
            ref.read(miniGameProvider.notifier).reset();
            context.pop();
          },
        ),
        title: Text(
          '미니게임',
          style: AppTextStyles.heading3.copyWith(color: AppColors.textBlack),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: gameState.result != null
            ? _buildResultScreen(gameState)
            : _buildGameScreen(gameState),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 게임 플레이 화면
  // ──────────────────────────────────────────
  Widget _buildGameScreen(MiniGameState gameState) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenPaddingH),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 32),
          // 제목
          Text(
            '카드를 선택하세요!',
            style: AppTextStyles.heading2.copyWith(color: AppColors.textBlack),
          ),
          const SizedBox(height: 8),
          Text(
            '3장 중 1장에 포인트가 숨어있어요.',
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 12),
          // 보상 안내
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '성공 시 +5P 적립',
              style: AppTextStyles.body4.copyWith(
                color: AppColors.primaryMain,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 48),
          // 카드 3장
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalCards, (index) {
              return Padding(
                padding: EdgeInsets.only(right: index < _totalCards - 1 ? 16 : 0),
                child: _buildCard(index),
              );
            }),
          ),
          const Spacer(),
          if (gameState.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                gameState.errorMessage!,
                style: AppTextStyles.body4.copyWith(color: AppColors.red),
                textAlign: TextAlign.center,
              ),
            ),
          // 선택 후 확인 버튼
          if (_selectedCard != null && !_revealed)
            _buildConfirmButton(gameState.isLoading),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    final isSelected = _selectedCard == index;
    final isWinner = _revealed && index == _winningCardIndex;
    final wasSelected = _revealed && _selectedCard == index;

    Color cardColor;
    if (_revealed) {
      if (isWinner) {
        cardColor = AppColors.yellow200;
      } else if (wasSelected && !isWinner) {
        cardColor = AppColors.red200;
      } else {
        cardColor = AppColors.gray200;
      }
    } else {
      cardColor = isSelected ? AppColors.primaryBg : AppColors.white;
    }

    return GestureDetector(
      onTap: (_revealed || _selectedCard == index) ? null : () {
        setState(() => _selectedCard = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 96,
        height: 140,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
          border: Border.all(
            color: isSelected && !_revealed
                ? AppColors.primaryMain
                : _revealed && isWinner
                    ? AppColors.yellow500
                    : AppColors.gray200,
            width: isSelected || isWinner ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected && !_revealed
                  ? AppColors.primaryMain.withValues(alpha: 0.2)
                  : AppColors.textBlack.withValues(alpha: 0.05),
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: _revealed
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isWinner ? '🪙' : '😢',
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isWinner ? '+5P' : '꽝',
                      style: AppTextStyles.body3.copyWith(
                        color: isWinner ? AppColors.yellow500 : AppColors.gray400,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isSelected ? '❓' : '🃏',
                      style: const TextStyle(fontSize: 36),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'CARD ${index + 1}',
                      style: AppTextStyles.caption3.copyWith(
                        color: isSelected
                            ? AppColors.primaryMain
                            : AppColors.gray400,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _handleConfirm,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: isLoading ? null : AppColors.gradientDarkPurple,
          color: isLoading ? AppColors.gray300 : null,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : Text(
                  '선택 완료!',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 결과 화면
  // ──────────────────────────────────────────
  Widget _buildResultScreen(MiniGameState gameState) {
    final result = gameState.result!;
    final won = result.won;

    return Padding(
      padding: const EdgeInsets.all(AppConstants.screenPaddingH),
      child: Column(
        children: [
          const SizedBox(height: 32),
          // 결과 아이콘
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: won
                  ? const LinearGradient(
                      colors: [AppColors.yellow500, Color(0xFFFFAA00)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [AppColors.gray300, AppColors.gray400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (won ? AppColors.yellow500 : AppColors.gray300)
                      .withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Center(
              child: Text(
                won ? '🎉' : '😅',
                style: const TextStyle(fontSize: 52),
              ),
            ),
          ),
          const SizedBox(height: 28),
          // 결과 텍스트
          Text(
            won ? '${result.pointsEarned}P 적립!' : '아쉽게 놓쳤어요',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            won
                ? '포인트 지갑에 바로 적립됐어요!'
                : '다음 번엔 꼭 성공하실 거예요. 내일 다시 도전해보세요!',
            textAlign: TextAlign.center,
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          const SizedBox(height: 32),

          // 광고 추가 적립 (성공 시만)
          if (won && !_adWatched) ...[
            _buildAdBonusCard(),
            const SizedBox(height: 16),
          ],
          if (won && _adWatched) ...[
            _buildAdCompletedCard(),
            const SizedBox(height: 16),
          ],

          const Spacer(),
          // 포인트 지갑으로 이동
          _buildPrimaryButton(
            label: '포인트 지갑 보기',
            onTap: () {
              ref.read(miniGameProvider.notifier).reset();
              context.go('/point/wallet');
            },
          ),
          const SizedBox(height: 12),
          // 닫기
          _buildOutlineButton(
            label: '닫기',
            onTap: () {
              ref.read(miniGameProvider.notifier).reset();
              context.pop();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAdBonusCard() {
    return GestureDetector(
      onTap: _handleWatchAd,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.yellow500, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.yellow500.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Text('📺', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '광고 보고 +5P 추가 적립',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.textBlack,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '짧은 광고 시청 후 보너스 포인트 지급',
                    style: AppTextStyles.caption2.copyWith(
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.yellow500,
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Text(
                '시청',
                style: AppTextStyles.caption1.copyWith(
                  color: AppColors.textBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCompletedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.green200,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Row(
        children: [
          const Text('✅', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Text(
            '광고 보상 +5P 추가 적립 완료!',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.textBlack,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppColors.gradientDarkPurple,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildOutlineButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.gray200,
          borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.buttonLarge.copyWith(color: AppColors.gray800),
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // 핸들러
  // ──────────────────────────────────────────
  Future<void> _handleConfirm() async {
    if (_selectedCard == null) return;

    // 카드 공개 애니메이션
    setState(() => _revealed = true);

    final won = _selectedCard == _winningCardIndex;

    // 500ms 후 서버 전송 (카드 뒤집기 효과 확인 시간)
    await Future.delayed(const Duration(milliseconds: 600));

    await ref.read(miniGameProvider.notifier).submitResult(
          won: won,
          watchedAd: false,
        );

    final result = ref.read(miniGameProvider).result;
    if (result != null) {
      AnalyticsService.track('mini_game_played', {
        'success': result.won,
        'points': result.pointsEarned,
        'game_type': 'CARD_FLIP',
        'watched_ad': false,
      });
    }
  }

  void _handleWatchAd() {
    // AdMob 미연동 — 광고 시청 시뮬레이션
    setState(() => _adWatched = true);
    AnalyticsService.track('mini_game_ad_watched', {
      'bonus_points': 5,
    });
  }
}
