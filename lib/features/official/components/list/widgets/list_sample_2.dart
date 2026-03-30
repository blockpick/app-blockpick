import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 리스트 샘플 #2 - 타임라인 스타일 + 슬라이드 애니메이션
class ListSample2 extends StatefulWidget {
  const ListSample2({super.key});

  @override
  State<ListSample2> createState() => _ListSample2State();
}

class _ListSample2State extends State<ListSample2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_TimelineItem> _items = [
    _TimelineItem(
      time: '09:00',
      title: '프로젝트 미팅',
      description: '새로운 프로젝트 킥오프 미팅',
      color: AppColors.blue,
      icon: Icons.people,
    ),
    _TimelineItem(
      time: '11:30',
      title: '점심 약속',
      description: '팀원들과 함께하는 점심',
      color: AppColors.yellow500,
      icon: Icons.restaurant,
    ),
    _TimelineItem(
      time: '14:00',
      title: '디자인 리뷰',
      description: 'UI/UX 디자인 최종 검토',
      color: AppColors.purple,
      icon: Icons.design_services,
    ),
    _TimelineItem(
      time: '16:30',
      title: '코드 리뷰',
      description: '신규 기능 코드 리뷰 세션',
      color: AppColors.green500,
      icon: Icons.code,
    ),
    _TimelineItem(
      time: '18:00',
      title: '운동',
      description: '헬스장에서 운동하기',
      color: AppColors.pink,
      icon: Icons.fitness_center,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'List #2',
          style: AppTextStyles.heading1.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.darkBlue,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.buleGray,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 설명
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.blue, AppColors.purple],
              ),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '타임라인 리스트\n• 슬라이드 인 애니메이션\n• 타임라인 디자인',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 타임라인 리스트
          ...List.generate(_items.length, (index) {
            return _buildTimelineItem(index);
          }),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(int index) {
    final item = _items[index];
    final isLast = index == _items.length - 1;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Interval(
          index * 0.15,
          0.5 + (index * 0.1),
          curve: Curves.easeOut,
        ),
      )),
      child: FadeTransition(
        opacity: Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.15,
            0.5 + (index * 0.1),
            curve: Curves.easeIn,
          ),
        )),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 타임라인 라인
            Column(
              children: [
                // 시간 표시
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    item.time,
                    style: AppTextStyles.body2.copyWith(
                      fontWeight: FontWeight.bold,
                      color: item.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            // 타임라인 도트와 선
            Column(
              children: [
                const SizedBox(height: 8),
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: item.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: item.color.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 100,
                    color: item.color.withValues(alpha: 0.3),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // 카드 내용
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: item.color.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: item.color.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: AppTextStyles.body2.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkBlue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.description,
                            style: AppTextStyles.body3.copyWith(
                              color: AppColors.medium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem {
  final String time;
  final String title;
  final String description;
  final Color color;
  final IconData icon;

  _TimelineItem({
    required this.time,
    required this.title,
    required this.description,
    required this.color,
    required this.icon,
  });
}
