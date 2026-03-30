import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_treemap/treemap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/event_cash_model.dart';

/// 이벤트 캐시 위젯 (아코디언 형태)
class EventCashWidget extends StatefulWidget {
  final EventCashModel cashData;

  const EventCashWidget({
    super.key,
    required this.cashData,
  });

  @override
  State<EventCashWidget> createState() => _EventCashWidgetState();
}

class _EventCashWidgetState extends State<EventCashWidget> {
  bool _isExpanded = false;
  String _selectedPeriod = '1D'; // 1D, 1W, 1M, 6M

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: Column(
        children: [
          // 헤더 (항상 표시)
          _buildHeader(),

          // 차트 (확장 시 표시) - 부드러운 애니메이션
          AnimatedSize(
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            child: _isExpanded ? _buildChart() : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// 헤더 영역
  Widget _buildHeader() {
    final isPositive = widget.cashData.todayChange >= 0;

    return InkWell(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'Est total value',
                      style: AppTextStyles.body4.copyWith(
                        color: AppColors.medium,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      size: 16,
                      color: AppColors.medium,
                    ),
                  ],
                ),
                // 오른쪽에 미니 차트 아이콘
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.pink.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    size: 20,
                    color: AppColors.pink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _formatCurrency(widget.cashData.totalAmount),
                  style: AppTextStyles.heading1.copyWith(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.cashData.currency,
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.navy,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  '오늘의 변동: ',
                  style: AppTextStyles.body4.copyWith(
                    color: AppColors.medium,
                  ),
                ),
                Text(
                  '${isPositive ? '+' : ''}${_formatCurrency(widget.cashData.todayChange)}',
                  style: AppTextStyles.body4.copyWith(
                    color: isPositive ? AppColors.green500 : AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(${isPositive ? '+' : ''}${widget.cashData.todayChangePercent.toStringAsFixed(1)}%)',
                  style: AppTextStyles.body4.copyWith(
                    color: isPositive ? AppColors.green500 : AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 차트 영역
  Widget _buildChart() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.pink.withValues(alpha: 0.05),
            AppColors.white,
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            // 차트
            SizedBox(
              height: 250,
              child: _buildTreemapChart(),
            ),

            const SizedBox(height: 24),

            // 기간 선택 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildPeriodButton('1D'),
                const SizedBox(width: 8),
                _buildPeriodButton('1W'),
                const SizedBox(width: 8),
                _buildPeriodButton('1M'),
                const SizedBox(width: 8),
                _buildPeriodButton('6M'),
              ],
            ),

            const SizedBox(height: 16),

            // 통계 정보
            _buildStatistics(),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  /// 통계 정보 위젯
  Widget _buildStatistics() {
    // 최신 데이터 가져오기
    final latestData = widget.cashData.history.isNotEmpty
        ? widget.cashData.history.last
        : null;

    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            icon: '🎁',
            label: '당첨',
            value: '${latestData?.winCount ?? 0}회',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            icon: '🎮',
            label: '참가',
            value: '${latestData?.participationCount ?? 0}회',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            icon: '⭐',
            label: '당첨률',
            value: '${latestData?.winRate.toStringAsFixed(1) ?? '0.0'}%',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            icon: '💎',
            label: 'ROI',
            value: '${latestData?.roi.toStringAsFixed(0) ?? '0'}%',
          ),
        ),
      ],
    );
  }

  /// 통계 박스
  Widget _buildStatBox({
    required String icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.body4.copyWith(
              color: AppColors.medium,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: AppTextStyles.body4.copyWith(
              color: AppColors.navy,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  /// 기간 선택 버튼
  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [
                    AppColors.pink,
                    AppColors.red,
                  ],
                )
              : null,
          color: isSelected ? null : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.pink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          period,
          style: AppTextStyles.body4.copyWith(
            color: isSelected ? Colors.white : AppColors.medium,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// Treemap 차트 생성
  Widget _buildTreemapChart() {
    // 최신 데이터 가져오기
    final latestData = widget.cashData.history.isNotEmpty
        ? widget.cashData.history.last
        : null;

    if (latestData == null) {
      return const Center(child: Text('데이터가 없습니다'));
    }

    // 차트 데이터 (정규화하여 비율 맞춤)
    final chartData = [
      _ChartData(
        '참가\n${latestData.participationCount}회',
        latestData.participationCount.toDouble(),
        AppColors.blue,
      ),
      _ChartData(
        '당첨\n${latestData.winCount}회',
        latestData.winCount.toDouble(),
        AppColors.green500,
      ),
      _ChartData(
        '당첨률\n${latestData.winRate.toStringAsFixed(1)}%',
        latestData.winRate * 0.5, // 당첨률을 시각적으로 조정
        AppColors.pink,
      ),
      _ChartData(
        'ROI\n${latestData.roi.toStringAsFixed(0)}%',
        latestData.roi * 0.2, // ROI를 시각적으로 조정
        AppColors.primaryLight,
      ),
    ];

    return SfTreemap(
      dataCount: chartData.length,
      weightValueMapper: (int index) => chartData[index].value,
      levels: [
        TreemapLevel(
          groupMapper: (int index) => chartData[index].label,
          colorValueMapper: (TreemapTile tile) {
            return chartData[tile.indices[0]].color;
          },
          tooltipBuilder: (BuildContext context, TreemapTile tile) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                chartData[tile.indices[0]].label,
                style: AppTextStyles.caption2.copyWith(color: Colors.white),
              ),
            );
          },
          labelBuilder: (BuildContext context, TreemapTile tile) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                chartData[tile.indices[0]].label,
                style: AppTextStyles.body4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            );
          },
        ),
      ],
    );
  }

  /// 통화 포맷팅
  String _formatCurrency(double amount) {
    if (amount >= 10000) {
      return '${(amount / 1000).toStringAsFixed(0)},${(amount % 1000).toStringAsFixed(0).padLeft(3, '0')}';
    }
    return amount.toStringAsFixed(0);
  }
}

/// 차트 데이터 모델
class _ChartData {
  final String label;
  final double value;
  final Color color;

  _ChartData(this.label, this.value, this.color);
}
