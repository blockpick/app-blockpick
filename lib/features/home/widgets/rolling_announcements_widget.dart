import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/announcement_model.dart';

/// 롤링 공지사항 위젯 (상하 스크롤 애니메이션)
class RollingAnnouncementsWidget extends StatefulWidget {
  final List<AnnouncementModel> announcements;
  final Duration duration;
  final VoidCallback? onTap;

  const RollingAnnouncementsWidget({
    super.key,
    required this.announcements,
    this.duration = const Duration(seconds: 3),
    this.onTap,
  });

  @override
  State<RollingAnnouncementsWidget> createState() =>
      _RollingAnnouncementsWidgetState();
}

class _RollingAnnouncementsWidgetState
    extends State<RollingAnnouncementsWidget> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: 1.0,
      initialPage: 0,
    );
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    if (widget.announcements.length <= 1) return;

    _timer = Timer.periodic(widget.duration, (_) {
      if (!mounted) return;

      _currentPage = (_currentPage + 1) % widget.announcements.length;

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.announcements.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 48,
        color: AppColors.blueWhite,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // 확성기 아이콘
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                LucideIcons.megaphone,
                color: AppColors.blue,
                size: 18,
              ),
            ),

            const SizedBox(width: 12),

            // 롤링 텍스트
            Expanded(
              child: ClipRect(
                child: SizedBox(
                  height: 48,
                  child: PageView.builder(
                    controller: _pageController,
                    scrollDirection: Axis.vertical,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: widget.announcements.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final announcement = widget.announcements[index];
                      return Center(
                        child: Text(
                          announcement.title,
                          style: AppTextStyles.body3.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // 페이지 인디케이터 (선택적)
            if (widget.announcements.length > 1) ...[
              const SizedBox(width: 8),
              Text(
                '${_currentPage + 1}/${widget.announcements.length}',
                style: AppTextStyles.body4.copyWith(
                  color: AppColors.grayBlue,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
