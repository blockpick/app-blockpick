import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/auth/domain/providers/auth_provider.dart';

/// SC-011-20: 이벤트 포인트 화면
class EventPointsScreen extends ConsumerWidget {
  const EventPointsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.valueOrNull?.user;
    final balance = user?.eventPoint.toInt() ?? 0;
    final formatter = NumberFormat('#,###');

    // TODO: 실제 API 연동
    final transactions = _mockPointTransactions;
    final now = DateTime.now();
    final dateLabel =
        '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} 기준';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            '이벤트 포인트',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 총 포인트 섹션
                    _buildTotalPoints(context, formatter.format(balance)),

                    const SizedBox(height: 24),

                    // 적립/사용 내역 섹션
                    _buildTransactionSection(
                        context, transactions, dateLabel),

                    const SizedBox(height: 24),

                    // AD 배너 영역
                    _buildAdBanner(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 총 포인트 섹션
  Widget _buildTotalPoints(BuildContext context, String formattedBalance) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 24),
          // 포인트 금액
          Text(
            '${formattedBalance}P',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),
          // 포인트 충전하기 버튼
          OutlinedButton(
            onPressed: () {
              // TODO: 포인트 충전 화면 이동 (쇼핑 캐시 충전 기능이 있기 전까지 비노출)
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkBlue,
              side: const BorderSide(color: AppColors.gray300),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.radiusFull),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 10),
            ),
            child: const Text(
              '포인트 충전하기',
              style: AppTextStyles.title3,
            ),
          ),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  /// 적립/사용 내역 섹션
  Widget _buildTransactionSection(
    BuildContext context,
    List<_PointTransaction> transactions,
    String dateLabel,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 섹션 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '적립/사용 내역',
                style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
              ),
              Text(
                dateLabel,
                style: AppTextStyles.body4.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // 테이블 헤더
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.gray300, width: 1),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    '일자',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '내역',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 70,
                  child: Text(
                    '포인트',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.gray600,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),

          // 내역 리스트
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Text(
                '포인트 내역이 없습니다.',
                style: AppTextStyles.body3.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            )
          else
            ...transactions.map((tx) => _buildTransactionRow(tx)),
        ],
      ),
    );
  }

  /// 내역 행
  Widget _buildTransactionRow(_PointTransaction tx) {
    final isPositive = tx.points > 0;
    final pointText = '${isPositive ? '+' : ''}${tx.points}P';

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.gray100, width: 1),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              tx.date,
              style: AppTextStyles.body4.copyWith(
                color: AppColors.gray600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              tx.description,
              style: AppTextStyles.body3.copyWith(
                color: AppColors.darkBlue,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              pointText,
              style: AppTextStyles.caption2,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  /// AD 배너 영역
  Widget _buildAdBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
        child: Center(
          child: Text(
            'AD Banner',
            style: AppTextStyles.body3.copyWith(
              color: AppColors.gray500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ========== 내부 데이터 모델 ==========

class _PointTransaction {
  final String date;
  final String description;
  final int points;

  const _PointTransaction({
    required this.date,
    required this.description,
    required this.points,
  });
}

// ========== Mock 데이터 ==========

final _mockPointTransactions = [
  _PointTransaction(
    date: '2026.01.21',
    description: '광고시청',
    points: 30,
  ),
  _PointTransaction(
    date: '2026.01.21',
    description: '광고시청',
    points: 30,
  ),
  _PointTransaction(
    date: '2026.01.21',
    description: 'DAILY 이벤트 참여',
    points: -200,
  ),
  _PointTransaction(
    date: '2026.01.21',
    description: '1일차 출석 보상',
    points: 10,
  ),
  _PointTransaction(
    date: '2026.01.21',
    description: 'SELECT 이벤트 참여',
    points: -300,
  ),
];
