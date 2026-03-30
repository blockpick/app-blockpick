import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 리스트 샘플 #1 - 카드형 리스트 + 탭 애니메이션
class ListSample1 extends StatefulWidget {
  const ListSample1({super.key});

  @override
  State<ListSample1> createState() => _ListSample1State();
}

class _ListSample1State extends State<ListSample1> {
  int? _selectedIndex;

  final List<_ListItem> _items = [
    _ListItem(
      icon: Icons.shopping_bag,
      title: '쇼핑',
      subtitle: '최신 상품을 확인하세요',
      color: AppColors.blue,
      count: '12',
    ),
    _ListItem(
      icon: Icons.notifications,
      title: '알림',
      subtitle: '새로운 알림이 있습니다',
      color: AppColors.yellow500,
      count: '5',
    ),
    _ListItem(
      icon: Icons.favorite,
      title: '좋아요',
      subtitle: '관심 항목을 모아보세요',
      color: AppColors.pink,
      count: '28',
    ),
    _ListItem(
      icon: Icons.chat,
      title: '메시지',
      subtitle: '읽지 않은 메시지가 있습니다',
      color: AppColors.green500,
      count: '3',
    ),
    _ListItem(
      icon: Icons.bookmark,
      title: '북마크',
      subtitle: '저장한 콘텐츠',
      color: AppColors.purple,
      count: '15',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'List #1',
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
              color: AppColors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '카드형 리스트\n• 탭 애니메이션\n• 선택 상태 표시',
              style: AppTextStyles.body3.copyWith(
                color: AppColors.darkBlue,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 카드 리스트
          ...List.generate(_items.length, (index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildCardItem(index),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCardItem(int index) {
    final item = _items[index];
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = isSelected ? null : index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? item.color.withValues(alpha: 0.1) : AppColors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(
            color: isSelected ? item.color : AppColors.buleGray,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: item.color.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            // 아이콘
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? item.color : item.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              child: Icon(
                item.icon,
                color: isSelected ? AppColors.white : item.color,
                size: 28,
              ),
            ),
            SizedBox(width: 16),
            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: AppTextStyles.heading1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? item.color : AppColors.darkBlue,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                ],
              ),
            ),
            // 카운트 배지
            AnimatedScale(
              scale: isSelected ? 1.1 : 1.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? item.color : AppColors.bgWhite,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
                child: Text(
                  item.count,
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.white : AppColors.medium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String count;

  _ListItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.count,
  });
}
