import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// SC-008-02 출석체크 페이지
class DailyCheckinScreen extends StatefulWidget {
  final int currentStreak;
  final bool todayChecked;
  final VoidCallback? onCheckIn;
  final VoidCallback? onWatchAd;

  const DailyCheckinScreen({
    super.key,
    this.currentStreak = 2,
    this.todayChecked = false,
    this.onCheckIn,
    this.onWatchAd,
  });

  /// 페이지로 이동
  static void show(BuildContext context) {
    context.push('/checkin');
  }

  @override
  State<DailyCheckinScreen> createState() => _DailyCheckinScreenState();
}

class _DailyCheckinScreenState extends State<DailyCheckinScreen> {
  bool _showRewardDialog = false;
  int _earnedPoints = 10;

  void _handleCheckIn() {
    setState(() {
      _showRewardDialog = true;
      _earnedPoints = 10;
    });
    widget.onCheckIn?.call();
  }

  void _handleWatchAd() {
    widget.onWatchAd?.call();
    context.pop();
  }

  void _handleSkipAd() {
    context.pop();
  }

  void _handleClose() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: SafeArea(
        child: _showRewardDialog ? _buildRewardDialog() : _buildCheckinContent(),
      ),
    );
  }

  /// 출석체크 메인 화면
  Widget _buildCheckinContent() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 닫기 버튼
          _buildCloseButton(),

          const SizedBox(height: 24),

          // 제목
          const Text(
            'Daily Check-in',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkBlue,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 8),

          // 설명
          RichText(
            text: TextSpan(
              style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
              children: [
                const TextSpan(text: '1일 출석 체크하면 '),
                TextSpan(
                  text: '10P',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                const TextSpan(text: ' 적립!\n7일 동안 연속으로 출석 체크하면 '),
                TextSpan(
                  text: '500P',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                const TextSpan(text: ' 추가 적립!'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 7일 출석 체크 그리드
          _buildCheckinGrid(),

          const SizedBox(height: 24),

          // DAY 7 보너스 카드
          _buildDay7BonusCard(),

          const Spacer(),

          // CHECK-IN NOW 버튼
          _buildCheckInButton(),
        ],
      ),
    );
  }

  /// 닫기 버튼
  Widget _buildCloseButton() {
    return GestureDetector(
      onTap: _handleClose,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.gray300,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.close_rounded,
          size: 18,
          color: AppColors.white,
        ),
      ),
    );
  }

  /// 7일 출석 체크 그리드
  Widget _buildCheckinGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
          // 첫 번째 줄: DAY 1, 2, 3
          Row(
            children: [
              Expanded(child: _buildDayItem(1)),
              const SizedBox(width: 12),
              Expanded(child: _buildDayItem(2)),
              const SizedBox(width: 12),
              Expanded(child: _buildDayItem(3)),
            ],
          ),
          const SizedBox(height: 12),
          // 두 번째 줄: DAY 4, 5, 6
          Row(
            children: [
              Expanded(child: _buildDayItem(4)),
              const SizedBox(width: 12),
              Expanded(child: _buildDayItem(5)),
              const SizedBox(width: 12),
              Expanded(child: _buildDayItem(6)),
            ],
          ),
        ],
      ),
    );
  }

  /// 개별 날짜 아이템
  Widget _buildDayItem(int day) {
    final isCompleted = day <= widget.currentStreak;
    final isToday = day == widget.currentStreak + 1 && !widget.todayChecked;

    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.yellow500.withValues(alpha: 0.15)
            : AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
        border: isToday
            ? Border.all(color: AppColors.yellow500, width: 2)
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'DAY $day',
            style: AppTextStyles.caption4,
          ),
          SizedBox(height: 8),
          if (isCompleted)
            Icon(
              Icons.check_rounded,
              size: 24,
              color: AppColors.gray500,
            )
          else if (isToday)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.yellow500,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+10P',
                style: AppTextStyles.caption3.copyWith(color: Color(0xFF664D03)),
              ),
            )
          else
            Icon(
              Icons.lock_rounded,
              size: 24,
              color: AppColors.gray300,
            ),
        ],
      ),
    );
  }

  /// DAY 7 보너스 카드
  Widget _buildDay7BonusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
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
          // 코인 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.yellow500, AppColors.yellow500.withValues(alpha: 0.7)],
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
            child: Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: Colors.orange.shade700,
                      offset: Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// CHECK-IN NOW 버튼
  Widget _buildCheckInButton() {
    final canCheckIn = !widget.todayChecked;

    return GestureDetector(
      onTap: canCheckIn ? _handleCheckIn : null,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: canCheckIn ? AppColors.darkBlue : AppColors.gray300,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            canCheckIn ? 'CHECK-IN NOW' : 'CHECKED IN',
            style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
          ),
        ),
      ),
    );
  }

  /// 포인트 획득 다이얼로그
  Widget _buildRewardDialog() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 상단: 닫기 버튼
          Align(
            alignment: Alignment.centerLeft,
            child: _buildCloseButton(),
          ),

          const Spacer(),

          // 코인 이미지
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.yellow500, AppColors.yellow500.withValues(alpha: 0.7)],
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
            child: Center(
              child: Text(
                'P',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  shadows: [
                    Shadow(
                      color: Colors.orange.shade700,
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // 포인트 텍스트
          Text(
            '${_earnedPoints}P',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: AppColors.darkBlue,
            ),
          ),

          SizedBox(height: 24),

          // 설명 텍스트
          Text(
            '오늘의 포인트 도착! 2배로 더 채워볼까요?\n광고 시청하고 포인트 2배 혜택을 누려보세요.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body3.copyWith(color: AppColors.gray600),
          ),

          const Spacer(),

          // 포인트 2배로 받기 버튼
          GestureDetector(
            onTap: _handleWatchAd,
            child: Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '포인트 2배로 받기',
                  style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
                ),
              ),
            ),
          ),

          SizedBox(height: 16),

          // 오늘은 괜찮아요 텍스트 버튼
          GestureDetector(
            onTap: _handleSkipAd,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '오늘은 괜찮아요.',
                    style: AppTextStyles.title3.copyWith(color: AppColors.gray500),
                  ),
                  SizedBox(width: 4),
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppColors.gray300,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '6',
                        style: AppTextStyles.caption4.copyWith(color: AppColors.gray600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 이전 버전 호환성을 위한 alias
typedef DailyCheckinModal = DailyCheckinScreen;
