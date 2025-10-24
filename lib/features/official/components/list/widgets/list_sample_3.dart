import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/constants/app_constants.dart';

/// 리스트 샘플 #3 - 그리드 카드 + 스케일 애니메이션
class ListSample3 extends StatefulWidget {
  const ListSample3({super.key});

  @override
  State<ListSample3> createState() => _ListSample3State();
}

class _ListSample3State extends State<ListSample3>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int? _pressedIndex;

  final List<_GridItem> _items = [
    _GridItem(
      icon: Icons.home,
      title: '홈',
      count: '124',
      gradient: LinearGradient(colors: [AppColors.blue, AppColors.purple]),
    ),
    _GridItem(
      icon: Icons.explore,
      title: '탐색',
      count: '89',
      gradient: LinearGradient(colors: [AppColors.green, AppColors.blue]),
    ),
    _GridItem(
      icon: Icons.favorite,
      title: '좋아요',
      count: '256',
      gradient: LinearGradient(colors: [AppColors.pink, AppColors.purple]),
    ),
    _GridItem(
      icon: Icons.shopping_cart,
      title: '장바구니',
      count: '12',
      gradient: LinearGradient(colors: [AppColors.yellow, AppColors.pink]),
    ),
    _GridItem(
      icon: Icons.message,
      title: '메시지',
      count: '45',
      gradient: LinearGradient(colors: [AppColors.blue, AppColors.green]),
    ),
    _GridItem(
      icon: Icons.notifications,
      title: '알림',
      count: '8',
      gradient: LinearGradient(colors: [AppColors.purple, AppColors.pink]),
    ),
    _GridItem(
      icon: Icons.settings,
      title: '설정',
      count: '-',
      gradient: LinearGradient(colors: [AppColors.darkBlue, AppColors.blue]),
    ),
    _GridItem(
      icon: Icons.person,
      title: '프로필',
      count: '-',
      gradient: LinearGradient(colors: [AppColors.green, AppColors.yellow]),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
          'List #3',
          style: AppTextStyles.large.copyWith(
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
              gradient: AppColors.gradientBluePurplePink,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            ),
            child: Text(
              '그리드 카드 리스트\n• 스케일 애니메이션\n• 그라데이션 효과',
              style: AppTextStyles.body.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 그리드 뷰
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return _buildGridCard(index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGridCard(int index) {
    final item = _items[index];

    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.1,
            0.5 + (index * 0.05),
            curve: Curves.elasticOut,
          ),
        ),
      ),
      child: GestureDetector(
        onTapDown: (_) {
          setState(() {
            _pressedIndex = index;
          });
        },
        onTapUp: (_) {
          setState(() {
            _pressedIndex = null;
          });
        },
        onTapCancel: () {
          setState(() {
            _pressedIndex = null;
          });
        },
        child: AnimatedScale(
          scale: _pressedIndex == index ? 0.95 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            decoration: BoxDecoration(
              gradient: item.gradient,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: item.gradient.colors.first.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              children: [
                // 배경 패턴
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPatternPainter(),
                  ),
                ),
                // 내용
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 아이콘
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                        ),
                        child: Icon(
                          item.icon,
                          color: AppColors.white,
                          size: 32,
                        ),
                      ),
                      const Spacer(),
                      // 타이틀
                      Text(
                        item.title,
                        style: AppTextStyles.large.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // 카운트
                      Text(
                        item.count,
                        style: AppTextStyles.display.copyWith(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // 우상단 배지
                if (item.count != '-')
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.white.withValues(alpha: 0.8),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GridItem {
  final IconData icon;
  final String title;
  final String count;
  final Gradient gradient;

  _GridItem({
    required this.icon,
    required this.title,
    required this.count,
    required this.gradient,
  });
}

// 그리드 패턴 페인터
class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 대각선 그리드 패턴
    for (int i = -10; i < 20; i++) {
      canvas.drawLine(
        Offset(i * 20.0, 0),
        Offset(i * 20.0 + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
