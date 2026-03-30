import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/event_banner_model.dart';

/// 이벤트 배너 슬라이드
class EventBannerCarousel extends StatefulWidget {
  final List<EventBannerModel> banners;

  const EventBannerCarousel({
    super.key,
    required this.banners,
  });

  @override
  State<EventBannerCarousel> createState() => _EventBannerCarouselState();
}

class _EventBannerCarouselState extends State<EventBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  /// 자동 슬라이드 시작
  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_currentPage < widget.banners.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }

      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // 배너 슬라이드
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.banners.length,
              itemBuilder: (context, index) {
                return _buildBanner(widget.banners[index]);
              },
            ),
          ),

          const SizedBox(height: 12),

          // 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.banners.length,
              (index) => _buildIndicator(index == _currentPage),
            ),
          ),
        ],
      ),
    );
  }

  /// 배너 아이템
  Widget _buildBanner(EventBannerModel banner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _parseColor(banner.backgroundColor),
            _parseColor(banner.backgroundColor).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              banner.title,
              style: AppTextStyles.heading1.copyWith(
                color: _parseColor(banner.textColor),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              banner.subtitle,
              style: AppTextStyles.body3.copyWith(
                color: _parseColor(banner.textColor).withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 인디케이터
  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryMain : AppColors.gray200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  /// 헥스 컬러 파싱
  Color _parseColor(String hexColor) {
    final hex = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
