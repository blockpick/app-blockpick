import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_optimal_game_data.dart';
import '../../models/optimal_game_model.dart';
import 'widgets/price_keypad_input.dart';
import 'widgets/price_wheel_selector.dart';
import '../../core/constants/app_constants.dart';

/// 최적가 게임 화면
class OptimalGameScreen extends ConsumerStatefulWidget {
  final String gameId;

  const OptimalGameScreen({super.key, required this.gameId});

  @override
  ConsumerState<OptimalGameScreen> createState() => _OptimalGameScreenState();
}

class _OptimalGameScreenState extends ConsumerState<OptimalGameScreen> {
  int? _selectedPrice;
  OptimalGame? _game;
  bool _isKeypadMode = false; // 키패드 모드 vs 휠 모드

  @override
  void initState() {
    super.initState();
    _game = MockOptimalGameData.getGameById(widget.gameId);
  }

  @override
  Widget build(BuildContext context) {
    if (_game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 상품 정보 헤더
          _buildMinimalHeader(),

          // 가격 휠 + 오버레이 버튼 + 하단 버튼 (SC-009-18)
          Expanded(
            child: Stack(
              children: [
                // 가격 휠 선택기 (전체 영역)
                Positioned.fill(
                  child: PriceWheelSelector(
                    prices: _game!.availablePrices,
                    selectedPrice: _selectedPrice,
                    backgroundImageUrl: _game!.imageUrl,
                    onPriceSelected: (price) {
                      setState(() {
                        _selectedPrice = price;
                      });
                    },
                  ),
                ),

                // (i) 정보 아이콘 (좌상단)
                Positioned(
                  top: 16,
                  left: 16,
                  child: GestureDetector(
                    onTap: _showGameInfo,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                ),

                // 입찰 범위 칩 (왼쪽 정렬)
                Positioned(
                  top: 16,
                  left: 56,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '입찰가능 ${_formatBidPrice(_game!.minPrice)}~${_formatBidPrice(_game!.maxPrice)}원',
                      style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),

                // 상품 정보 버튼 (우상단)
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: _showProductInfo,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '상품 정보',
                            style: AppTextStyles.body4.copyWith(color: AppColors.darkBlue),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AppColors.darkBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // 하단 버튼 (floating)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                      child: _buildBottomButtons(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 상품 정보 바 (SC-009-18: 상품명 + 참여수 + 그리드 + 남은시간 + 진행바)
  Widget _buildMinimalHeader() {
    final priceCount = _game!.availablePrices.length;
    final remaining = _parseRemainingDuration(_game!.timeLeft);
    final progress = _getTimeProgress();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.gray200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: 상품명
          Text(
            _game!.title,
            style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          // Row 2: 참여수 + 그리드 + 남은시간
          Row(
            children: [
              _buildInfoChip(
                Icons.people_outline_rounded,
                '${_formatCount(_game!.participants)}/${_formatCount(_game!.maxParticipants)}',
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                Icons.grid_view_rounded,
                '1×$priceCount',
              ),
              const Spacer(),
              Icon(
                Icons.access_time_rounded,
                size: 14,
                color: remaining.inMinutes < 30
                    ? AppColors.red
                    : AppColors.gray600,
              ),
              SizedBox(width: 4),
              Text(
                _formatRemainingTime(remaining),
                style: AppTextStyles.caption2.copyWith(color: remaining.inMinutes < 30 ? AppColors.red : AppColors.gray600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation<Color>(
                progress > 0.8 ? AppColors.red : AppColors.blue,
              ),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }

  /// 정보 칩 (아이콘 + 텍스트)
  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gray600),
        SizedBox(width: 4),
        Text(
          text,
          style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
        ),
      ],
    );
  }

  /// 참여자 수 포맷 (만 단위 이상 K/M 표기)
  String _formatCount(int count) {
    if (count >= 1000000) {
      final value = count / 1000000;
      return value == value.truncateToDouble()
          ? '${value.toInt()}M'
          : '${value.toStringAsFixed(1)}M';
    } else if (count >= 10000) {
      final value = count / 1000;
      return value == value.truncateToDouble()
          ? '${value.toInt()}K'
          : '${value.toStringAsFixed(1)}K';
    }
    return count.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// timeLeft 문자열에서 Duration 파싱
  Duration _parseRemainingDuration(String timeLeft) {
    final weekMatch = RegExp(r'(\d+)주').firstMatch(timeLeft);
    final dayMatch = RegExp(r'(\d+)일').firstMatch(timeLeft);
    final hourMatch = RegExp(r'(\d+)시간').firstMatch(timeLeft);
    final minuteMatch = RegExp(r'(\d+)분').firstMatch(timeLeft);
    final secMatch = RegExp(r'(\d+)초').firstMatch(timeLeft);

    int weeks = weekMatch != null ? int.parse(weekMatch.group(1)!) : 0;
    int days = dayMatch != null ? int.parse(dayMatch.group(1)!) : 0;
    int hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
    int minutes = minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;
    int seconds = secMatch != null ? int.parse(secMatch.group(1)!) : 0;

    return Duration(
      days: (weeks * 7) + days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    );
  }

  /// 남은 시간 포맷 (HH:MM:SS 남음)
  String _formatRemainingTime(Duration remaining) {
    if (remaining == Duration.zero) return '종료';
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds 남음';
  }

  /// 시간 진행률 (0.0 ~ 1.0, mock에서는 timeLeft 기반 추정)
  double _getTimeProgress() {
    final remaining = _parseRemainingDuration(_game!.timeLeft);
    // 전체 기간을 알 수 없으므로 24시간 기준으로 추정
    final totalSeconds = 24 * 60 * 60;
    final elapsed = totalSeconds - remaining.inSeconds;
    return (elapsed / totalSeconds).clamp(0.0, 1.0);
  }

  /// 입찰 가격 포맷 (만원 단위)
  String _formatBidPrice(int price) {
    if (price >= 100000000) {
      final eok = price / 100000000;
      return eok == eok.truncateToDouble()
          ? '${eok.toInt()}억'
          : '${eok.toStringAsFixed(1)}억';
    }
    if (price >= 10000) {
      final man = price / 10000;
      return man == man.truncateToDouble()
          ? '${man.toInt()}만'
          : '${man.toStringAsFixed(0)}만';
    }
    return _formatPrice(price);
  }

  /// 게임 참여 방법 안내 (SC-009-18 (i) 버튼)
  void _showGameInfo() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radius2Xl)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '경품 참여 방법',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, color: AppColors.gray600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInfoStep('1', '본인이 원하는 입찰 가격의 블록을 선택하세요.'),
            const SizedBox(height: 12),
            _buildInfoStep('2', '직접 입찰 가격을 입력하여 참여할 수 있어요.'),
            const SizedBox(height: 12),
            _buildInfoStep('3', '최대 인원을 달성하면 이벤트는 즉시 종료 및 정산을 합니다.'),
            const SizedBox(height: 12),
            _buildInfoStep('4', '가장 낮은 금액을 입찰한 단독 1인이 경품의 주인공이 돼요.'),
            SizedBox(height: 12),
            _buildInfoStep('5', '전략적으로 입찰 금액을 선택해서 참여해보세요.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          number,
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.gray800,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  /// 상품 정보 보기 (SC-009-18 상품 정보 버튼)
  void _showProductInfo() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusBottomSheet)),
          ),
          child: Column(
            children: [
              // 핸들 바
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.gray200,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
              ),
              // 타이틀
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '상품 정보',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 상품명
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _game!.title,
                    style: AppTextStyles.body2.copyWith(color: AppColors.darkBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 상품 이미지
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        child: Image.asset(
                          _game!.imageUrl,
                          fit: BoxFit.fitWidth,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            height: 200,
                            color: AppColors.gray100,
                            child: const Center(
                              child: Icon(Icons.image_not_supported_outlined,
                                  size: 48, color: AppColors.gray600),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // 확인 버튼
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                        ),
                      ),
                      child: Text(
                        '확인',
                        style: AppTextStyles.title2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        'PRIME Events',
        style: AppTextStyles.buttonLarge.copyWith(color: AppColors.darkBlue),
      ),
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: AppColors.darkBlue),
        onPressed: () => context.go('/'),
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.share2, color: AppColors.darkBlue),
          onPressed: () {
            // TODO: 공유 기능
          },
        ),
      ],
    );
  }

  /// 하단 버튼들 (SC-009-18: 입찰하기 + 직접입력)
  Widget _buildBottomButtons() {
    final hasBid = _selectedPrice != null;

    return Row(
      children: [
        // 입찰하기 버튼 (메인)
        Expanded(
          child: GestureDetector(
            onTap: hasBid ? _handleSubmit : null,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: hasBid
                    ? AppColors.textBlack.withValues(alpha: 0.85)
                    : AppColors.gray400.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      hasBid
                          ? '${_formatPrice(_selectedPrice!)}에 입찰하기'
                          : '가격을 선택하세요',
                      style: AppTextStyles.title3.copyWith(color: AppColors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // 직접입력 버튼
        GestureDetector(
          onTap: _showKeypadBottomSheet,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppConstants.radiusFull),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '직접입력',
                  style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: AppColors.darkBlue,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 키패드 하단 시트 표시
  void _showKeypadBottomSheet() {
    int? tempPrice; // 임시로 저장할 가격 (확인 전까지는 휠에 반영 안 함)

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.darkBlue.withValues(alpha: 0.3), // 반투명 배경
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: 0.95), // 약간 투명하게
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radius2Xl)),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withValues(alpha: 0.1),
                blurRadius: 30,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: PriceKeypadInput(
              initialPrice: _selectedPrice,
              minPrice: _game!.minPrice,
              maxPrice: _game!.maxPrice,
              priceStep: _game!.priceStep, // 호가 단위 전달
              backgroundImageUrl: _game!.imageUrl,
              onPriceChanged: (price) {
                // 입력하는 동안은 임시 변수에만 저장 (휠은 업데이트 안 함)
                tempPrice = price;
              },
              onConfirm: () async {
                // 확인 버튼을 누르면 바텀시트 닫기
                Navigator.of(context).pop();

                // 바텀시트가 닫히는 애니메이션이 끝날 때까지 대기
                await Future.delayed(const Duration(milliseconds: 300));

                // 확인 버튼을 눌렀을 때만 휠 업데이트
                if (mounted && tempPrice != null) {
                  setState(() {
                    _selectedPrice = tempPrice;
                  });
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  /// 입찰 제출
  void _handleSubmit() {
    if (_selectedPrice == null) return;

    // TODO: 실제 입찰 API 호출
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_formatPrice(_selectedPrice!)}에 입찰되었습니다!'),
        backgroundColor: AppColors.green500,
      ),
    );

    // 홈으로 돌아가기
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        context.go('/');
      }
    });
  }

  /// 가격 포맷
  String _formatPrice(int price) {
    return '${price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원';
  }
}

/// 애니메이션으로 순환하는 트렌드 정보 위젯
class _AnimatedTrendInfo extends StatefulWidget {
  @override
  State<_AnimatedTrendInfo> createState() => _AnimatedTrendInfoState();
}

class _AnimatedTrendInfoState extends State<_AnimatedTrendInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 0;

  final List<_TrendData> _trendInfoList = [
    _TrendData(
      icon: Icons.trending_up,
      text: '최근 1시간 15명 입찰 중',
      color: AppColors.purple,
    ),
    _TrendData(
      icon: Icons.local_fire_department,
      text: '지금 가장 인기있는 구간',
      color: AppColors.red,
    ),
    _TrendData(
      icon: Icons.flash_on,
      text: '5분 전 3명 새로 참여',
      color: AppColors.yellow500,
    ),
    _TrendData(
      icon: Icons.analytics,
      text: '평균가 대비 -2%',
      color: AppColors.green500,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _startAnimation();
  }

  void _startAnimation() async {
    while (mounted) {
      _controller.forward(from: 0.0);
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        await _controller.reverse();
        setState(() {
          _currentIndex = (_currentIndex + 1) % _trendInfoList.length;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final trend = _trendInfoList[_currentIndex];

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(trend.icon, size: 11, color: trend.color),
          SizedBox(width: 3),
          Flexible(
            child: Text(
              trend.text,
              style: AppTextStyles.body4.copyWith(
                color: trend.color,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// 트렌드 데이터 모델
class _TrendData {
  final IconData icon;
  final String text;
  final Color color;

  _TrendData({required this.icon, required this.text, required this.color});
}

/// 참여자 수 카운트업 애니메이션
class _AnimatedParticipantCount extends StatefulWidget {
  final int participants;

  const _AnimatedParticipantCount({required this.participants});

  @override
  State<_AnimatedParticipantCount> createState() =>
      _AnimatedParticipantCountState();
}

class _AnimatedParticipantCountState extends State<_AnimatedParticipantCount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;
  int _currentCount = 0;

  @override
  void initState() {
    super.initState();
    _currentCount = widget.participants;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _countAnimation = IntTween(
      begin: widget.participants - 50, // 초기값 (약간 적게 시작)
      end: widget.participants,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // 주기적으로 참여자 수 증가 애니메이션
    _startPeriodicUpdate();
  }

  void _startPeriodicUpdate() async {
    await Future.delayed(const Duration(seconds: 5));
    while (mounted) {
      await Future.delayed(const Duration(seconds: 3));
      if (mounted) {
        setState(() {
          _currentCount += 1;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countAnimation,
      builder: (context, child) {
        return Row(
          children: [
            const Icon(LucideIcons.users, size: 14, color: AppColors.grayBlue),
            SizedBox(width: 4),
            Text(
              '${_controller.isAnimating ? _countAnimation.value : _currentCount}명',
              style: AppTextStyles.title1.copyWith(
                color: AppColors.grayBlue,
                fontSize: 13,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// 실시간 카운트다운 타이머 (시간별 긴박감 효과)
class _CountdownTimer extends StatefulWidget {
  final String timeLeft;

  const _CountdownTimer({required this.timeLeft});

  @override
  State<_CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<_CountdownTimer>
    with TickerProviderStateMixin {
  late AnimationController _blinkController;
  late AnimationController _fireController;
  late AnimationController _shakeController;
  late Animation<double> _blinkAnimation;
  late Animation<double> _shakeAnimation;

  Duration _remainingTime = Duration.zero;
  late Duration _initialTime;

  @override
  void initState() {
    super.initState();
    _initialTime = _parseTimeLeft(widget.timeLeft);
    _remainingTime = _initialTime;

    // 깜빡임 애니메이션
    _blinkController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);

    _blinkAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    // 파이어 애니메이션 컨트롤러
    _fireController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 흔들림 애니메이션 (매우 격렬할 때)
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _shakeAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    // 카운트다운 시작
    _startCountdown();
    _startShakeAnimation();
  }

  void _startShakeAnimation() async {
    while (mounted) {
      if (_remainingTime.inMinutes < 10) {
        // 10분 미만일 때만 흔들림
        await _shakeController.forward();
        await _shakeController.reverse();
        await Future.delayed(const Duration(milliseconds: 200));
      } else {
        await Future.delayed(const Duration(seconds: 1));
      }
    }
  }

  Duration _parseTimeLeft(String timeLeft) {
    // "2주 3일", "1일 3시간", "2시간 30분" 형식 파싱
    final weekMatch = RegExp(r'(\d+)주').firstMatch(timeLeft);
    final dayMatch = RegExp(r'(\d+)일').firstMatch(timeLeft);
    final hourMatch = RegExp(r'(\d+)시간').firstMatch(timeLeft);
    final minuteMatch = RegExp(r'(\d+)분').firstMatch(timeLeft);

    int weeks = weekMatch != null ? int.parse(weekMatch.group(1)!) : 0;
    int days = dayMatch != null ? int.parse(dayMatch.group(1)!) : 0;
    int hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
    int minutes = minuteMatch != null ? int.parse(minuteMatch.group(1)!) : 0;

    return Duration(days: (weeks * 7) + days, hours: hours, minutes: minutes);
  }

  void _startCountdown() async {
    while (mounted && _remainingTime.inSeconds > 0) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          _remainingTime -= const Duration(seconds: 1);
        });
      }
    }
  }

  Color _getTimeColor() {
    final minutes = _remainingTime.inMinutes;
    if (minutes < 30) return AppColors.red;
    if (minutes < 60) return AppColors.yellow500; // 주황색
    return AppColors.yellow500;
  }

  int _getFireIntensity() {
    final minutes = _remainingTime.inMinutes;
    if (minutes < 10) return 4; // 매우 격렬
    if (minutes < 30) return 3; // 격렬
    if (minutes < 60) return 2; // 중간
    return 0; // 없음
  }

  String _formatTime() {
    final days = _remainingTime.inDays;
    final hours = _remainingTime.inHours % 24;
    final minutes = _remainingTime.inMinutes % 60;
    final seconds = _remainingTime.inSeconds % 60;

    if (days > 7) {
      final weeks = days ~/ 7;
      final remainingDays = days % 7;
      if (remainingDays > 0) {
        return '$weeks주 $remainingDays일';
      }
      return '$weeks주';
    } else if (days > 0) {
      if (hours > 0) {
        return '$days일 $hours시간';
      }
      return '$days일';
    } else if (hours > 0) {
      return '$hours시간 $minutes분';
    } else if (minutes > 0) {
      return '$minutes분 $seconds초';
    } else {
      return '$seconds초';
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _fireController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final intensity = _getFireIntensity();
    final shouldBlink = _remainingTime.inMinutes < 30;

    Widget timeWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 시계 아이콘
        Icon(LucideIcons.clock, size: 14, color: _getTimeColor()),
        const SizedBox(width: 4),

        // 시간 텍스트 + 파이어 배경
        Stack(
          clipBehavior: Clip.none,
          children: [
            // 파이어 아이콘들 (뒤에 배치)
            if (intensity > 0)
              Positioned.fill(
                child: SizedBox(
                  width: 80,
                  height: 30,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: List.generate(
                      intensity,
                      (index) => Positioned(
                        left: index * 8.0,
                        child: _FireParticle(
                          delay: index * 200,
                          controller: _fireController,
                          speed: intensity > 2 ? 1.5 : 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // 시간 텍스트 (앞에 배치) + 흔들림 효과
            AnimatedBuilder(
              animation: _shakeAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(
                    intensity >= 4 ? _shakeAnimation.value : 0, // 매우 격렬할 때만
                    0,
                  ),
                  child: child,
                );
              },
              child: Text(
                _formatTime(),
                style: AppTextStyles.title1.copyWith(
                  color: _getTimeColor(),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
    );

    // 30분 미만일 때 깜빡임 효과
    if (shouldBlink) {
      return FadeTransition(opacity: _blinkAnimation, child: timeWidget);
    }

    return timeWidget;
  }
}

/// 파이어 파티클 애니메이션 (연속으로 올라가는 불꽃)
class _FireParticle extends StatefulWidget {
  final int delay;
  final AnimationController controller;
  final double speed;

  const _FireParticle({
    required this.delay,
    required this.controller,
    this.speed = 1.0,
  });

  @override
  State<_FireParticle> createState() => _FireParticleState();
}

class _FireParticleState extends State<_FireParticle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: (800 / widget.speed).round()),
      vsync: this,
    );

    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: -20.0, // 위로 20px 이동
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _startAnimation();
  }

  void _startAnimation() async {
    await Future.delayed(Duration(milliseconds: widget.delay));
    while (mounted) {
      await _controller.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _positionAnimation.value),
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: const Icon(
              Icons.local_fire_department,
              size: 12,
              color: AppColors.red,
            ),
          ),
        );
      },
    );
  }
}
