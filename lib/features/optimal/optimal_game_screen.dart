import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/price_wheel_selector.dart';
import 'widgets/price_keypad_input.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/optimal_game_model.dart';
import '../../data/mock_optimal_game_data.dart';

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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
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
              key: ValueKey(_selectedPrice), // 선택된 가격이 바뀌면 휠을 다시 빌드
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
        children: [
          // 상품 이미지 (작게)
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.buleGray.withOpacity(0.3)),
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

          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _game!.title,
                  style: AppTextStyles.medium.copyWith(
                    color: AppColors.darkBlue,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      LucideIcons.users,
                      size: 12,
                      color: AppColors.grayBlue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_game!.participants}명',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.grayBlue,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      LucideIcons.clock,
                      size: 12,
                      color: AppColors.yellow,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _game!.timeLeft,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.yellow,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: AppColors.deepWhite,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: PriceKeypadInput(
          initialPrice: _selectedPrice,
          minPrice: _game!.minPrice,
          maxPrice: _game!.maxPrice,
          backgroundImageUrl: _game!.imageUrl,
          onPriceChanged: (price) {
            setState(() {
              _selectedPrice = price;
            });
          },
          onConfirm: () {
            // 확인 버튼을 누르면 바텀시트 닫기
            Navigator.of(context).pop();
          },
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
    return '${price.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}원';
  }
}
