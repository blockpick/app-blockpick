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
      backgroundColor: AppColors.deepWhite,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // 상품 정보 헤더 (미니멀)
          _buildMinimalHeader(),

          // 가격 휠 선택기 (항상 표시)
          Expanded(
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

          // 하단 버튼 (입찰하기 + 키패드 토글)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
              child: _buildBottomButtons(),
            ),
          ),
        ],
      ),
    );
  }

  /// 미니멀 헤더
  Widget _buildMinimalHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 왼쪽: 상품 이미지 + (참여자 수 / 타임) 수직 정렬
          Row(
            children: [
              // 상품 이미지
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.buleGray.withOpacity(0.3),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    _game!.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        LucideIcons.package,
                        size: 24,
                        color: AppColors.grayBlue,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 참여자 수 + 타임 (수직 정렬)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 참여자 수 (카운트업 애니메이션)
                  _AnimatedParticipantCount(participants: _game!.participants),
                  const SizedBox(height: 4),
                  // 실시간 카운트다운 타이머
                  _CountdownTimer(timeLeft: _game!.timeLeft),
                ],
              ),
            ],
          ),

          // 오른쪽: 트렌드 정보만
          _AnimatedTrendInfo(),
        ],
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_game?.title ?? '최적가 게임'),
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

  /// 하단 버튼들 (입찰하기 80% + 키패드 토글 20%)
  Widget _buildBottomButtons() {
    final isDisabled = _selectedPrice == null;

    return Row(
      children: [
        // 입찰하기 버튼 (80%)
        Expanded(
          flex: 80,
          child: Container(
            decoration: BoxDecoration(
              gradient: isDisabled
                  ? AppColors.gradientDisable
                  : AppColors.gradientBluePurplePink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: AppColors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isDisabled ? null : _handleSubmit,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isDisabled ? LucideIcons.lock : LucideIcons.checkCircle,
                        size: 24,
                        color: AppColors.white,
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          isDisabled
                              ? '가격을 선택하세요'
                              : '${_formatPrice(_selectedPrice!)}에 입찰하기',
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: AppColors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // 키패드 토글 버튼 (20%)
        Expanded(
          flex: 20,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppColors.gradientBluePurplePink,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showKeypadBottomSheet,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Icon(
                    LucideIcons.calculator,
                    size: 24,
                    color: AppColors.white,
                  ),
                ),
              ),
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
      barrierColor: AppColors.darkBlue.withOpacity(0.3), // 반투명 배경
      builder: (context) => SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          decoration: BoxDecoration(
            color: AppColors.white.withOpacity(0.95), // 약간 투명하게
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkBlue.withOpacity(0.1),
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
        backgroundColor: AppColors.green,
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
      color: AppColors.yellow,
    ),
    _TrendData(
      icon: Icons.analytics,
      text: '평균가 대비 -2%',
      color: AppColors.green,
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
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              trend.text,
              style: AppTextStyles.bodySmall.copyWith(
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
            const SizedBox(width: 4),
            Text(
              '${_controller.isAnimating ? _countAnimation.value : _currentCount}명',
              style: AppTextStyles.medium.copyWith(
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
    if (minutes < 60) return AppColors.yellow; // 주황색
    return AppColors.yellow;
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
                style: AppTextStyles.medium.copyWith(
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
