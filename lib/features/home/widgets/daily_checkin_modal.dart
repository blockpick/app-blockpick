import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/analytics/analytics_service.dart';
import '../../../providers/point_provider.dart';

/// SC-008-02 출석체크 화면
/// - claimDailyCheckIn GraphQL 뮤테이션 실제 호출
/// - 중복 체크인 시 친절한 안내 메시지
/// - 성공 시 +10P 보상 화면 → 광고 2배 옵션
class DailyCheckinScreen extends ConsumerStatefulWidget {
  const DailyCheckinScreen({super.key});

  /// 페이지로 이동
  static void show(BuildContext context) {
    context.push('/point/check-in');
  }

  @override
  ConsumerState<DailyCheckinScreen> createState() =>
      _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends ConsumerState<DailyCheckinScreen> {
  bool _adWatched = false;

  @override
  Widget build(BuildContext context) {
    final checkInState = ref.watch(checkInProvider);

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: _buildBody(checkInState),
      ),
    );
  }

  Widget _buildBody(CheckInState state) {
    if (state.result != null) {
      return _buildRewardContent(state.result!.pointsEarned);
    }
    if (state.errorMessage != null) {
      return _buildAlreadyCheckedIn(state.errorMessage!);
    }
    return _buildCheckinContent(state.isLoading);
  }

  // ──────────────────────────────────────────
  // 출석체크 메인 화면
  // ──────────────────────────────────────────
  Widget _buildCheckinContent(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseButton(),
          const SizedBox(height: 24),
          const Text(
            'Daily Check-in',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
              children: [
                const TextSpan(text: '1일 출석 체크하면 '),
                TextSpan(
                  text: '10P',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                const TextSpan(text: ' 적립!\n7일 동안 연속으로 출석 체크하면 '),
                TextSpan(
                  text: '500P',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                const TextSpan(text: ' 추가 적립!'),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildCheckinGrid(),
          const SizedBox(height: 24),
          _buildDay7BonusCard(),
          const Spacer(),
          _buildCheckInButton(isLoading),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // 이미 체크인 안내
  // ──────────────────────────────────────────
  Widget _buildAlreadyCheckedIn(String message) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCloseButton(),
          const Spacer(),
          Center(
            child: Column(
              children: [
                const Text('✅', style: TextStyle(fontSize: 64)),
                const SizedBox(height: 24),
                Text(
                  '오늘 출석 완료!',
                  style: AppTextStyles.heading2.copyWith(
                    color: AppColors.textBlack,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildOutlineButton(label: '닫기', onTap: () => context.pop()),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // 포인트 획득 보상 화면
  // ──────────────────────────────────────────
  Widget _buildRewardContent(int points) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCloseButton(),
          ),
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.yellow500, Color(0xFFFFAA00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow500.withValues(alpha: 0.5),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            '${points}P',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '출석 포인트 적립 완료!',
            style: AppTextStyles.heading3.copyWith(color: AppColors.textBlack),
          ),
          const SizedBox(height: 12),
          Text(
            '광고를 시청하면 포인트를 2배로 받을 수 있어요!',
            textAlign: TextAlign.center,
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),
          const Spacer(),
          if (!_adWatched) ...[
            _buildPrimaryButton(
              label: '포인트 2배로 받기',
              onTap: _handleWatchAd,
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.pop(),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '오늘은 괜찮아요',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.gray500,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ] else
            _buildPrimaryButton(
              label: '완료',
              onTap: () => context.pop(),
              color: AppColors.green500,
            ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // 7일 체크인 그리드
  // ──────────────────────────────────────────
  Widget _buildCheckinGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (i) => i + 1).expand((day) {
              final widgets = <Widget>[Expanded(child: _buildDayItem(day))];
              if (day < 3) widgets.add(const SizedBox(width: 12));
              return widgets;
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(3, (i) => i + 4).expand((day) {
              final widgets = <Widget>[Expanded(child: _buildDayItem(day))];
              if (day < 6) widgets.add(const SizedBox(width: 12));
              return widgets;
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(int day) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('DAY $day', style: AppTextStyles.caption4),
          const SizedBox(height: 8),
          const Icon(Icons.lock_rounded, size: 20, color: AppColors.gray300),
        ],
      ),
    );
  }

  Widget _buildDay7BonusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAY 7 Reward',
                  style: AppTextStyles.body4.copyWith(color: AppColors.gray500),
                ),
                const SizedBox(height: 4),
                const Text(
                  '500P 추가 적립',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.yellow500, Color(0xFFFFAA00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow500.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // 공통 위젯
  // ──────────────────────────────────────────
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.gray300,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.close_rounded, size: 18, color: AppColors.white),
      ),
    );
  }

  Widget _buildCheckInButton(bool isLoading) {
    return GestureDetector(
      onTap: isLoading ? null : _handleCheckIn,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: isLoading ? AppColors.gray300 : AppColors.darkBlue,
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
                  'CHECK-IN NOW',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required VoidCallback onTap,
    Color color = AppColors.darkBlue,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
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
  Future<void> _handleCheckIn() async {
    await ref.read(checkInProvider.notifier).claimCheckIn();
    final state = ref.read(checkInProvider);
    if (state.result != null) {
      AnalyticsService.track('point_check_in_claimed', {
        'amount': state.result!.pointsEarned,
        'streak': state.result!.currentStreak,
        'bonus_awarded': state.result!.bonusAwarded,
      });
    }
  }

  void _handleWatchAd() {
    // AdMob 미연동 시점 — 광고 시청 시뮬레이션
    setState(() => _adWatched = true);
  }
}

// 이전 버전 호환성을 위한 alias
typedef DailyCheckinModal = DailyCheckinScreen;
