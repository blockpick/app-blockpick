import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/game_participation_provider.dart';
import '../../providers/game_join_progress_provider.dart';
import '../../widgets/gacha_coordinate_picker.dart';
import '../../widgets/confetti_celebration.dart';
import 'models/event_prize.dart';
import 'widgets/event_prize_popup.dart';
import 'widgets/game_join_progress_overlay.dart';
import 'widgets/game_join_result_overlay.dart';
import 'widgets/product_selector_overlay.dart';

/// Gacha 스타일 게임 화면 (토스 디자인)
class GachaGameScreen extends ConsumerStatefulWidget {
  final String? gameId;

  const GachaGameScreen({super.key, this.gameId});

  @override
  ConsumerState<GachaGameScreen> createState() => _GachaGameScreenState();
}

class _GachaGameScreenState extends ConsumerState<GachaGameScreen> {
  GameRound? _gameRound;
  Game? _game;
  int _selectedProductIndex = 0;

  final GlobalKey<GachaCoordinatePickerState> _pickerKey = GlobalKey();
  final _priceFormatter = NumberFormat('#,###');
  final _random = Random();

  // 이벤트 모드 설정
  bool _eventMode = false;
  bool _showTarget = true;
  List<EventTarget> _eventTargets = [];
  int _targetCount = 3;
  int _allowedRange = 50;
  int _rowSpeed = 2500;
  int _colSpeed = 2200;

  // 상품군 설정 (나중에 게임별로 API에서 가져올 예정)
  EventPrizePool _selectedPrizePool = EventPrizePool.defaultPool;

  @override
  void initState() {
    super.initState();
  }

  /// 랜덤 타겟 좌표들 생성 (각각 랜덤 상품 포함)
  void _generateRandomTargets() {
    final gridSize = _game?.gridRows ?? 1000;
    // targetCount는 최대 상품 수를 초과할 수 없음
    final actualCount = _targetCount.clamp(1, _selectedPrizePool.maxPrizeCount);
    setState(() {
      _eventTargets = List.generate(actualCount, (index) => EventTarget(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        row: _random.nextInt(gridSize) + 1,
        col: _random.nextInt(gridSize) + 1,
        prize: _selectedPrizePool.getRandomPrize(),
      ));
    });
  }

  /// 당첨된 타겟 제거
  void _removeWonTarget(EventTarget target) {
    setState(() {
      _eventTargets.removeWhere((t) => t.id == target.id);
    });
  }

  /// 이벤트 당첨 체크 - 당첨된 타겟 반환
  EventTarget? _checkEventWin(int row, int col) {
    if (!_eventMode || _eventTargets.isEmpty) return null;

    for (final target in _eventTargets) {
      final rowDiff = (row - target.row).abs();
      final colDiff = (col - target.col).abs();

      if (rowDiff <= _allowedRange && colDiff <= _allowedRange) {
        return target;
      }
    }
    return null;
  }

  /// 이벤트 성공 시 축하 효과 (레거시 - picker에서 호출)
  void _onEventSuccess() {
    // 이제 _onCoordinateSelected에서 처리하므로 여기서는 아무것도 안 함
  }

  void _onCoordinateSelected(int row, int col) {
    // 이벤트 당첨 체크
    final wonTarget = _checkEventWin(row, col);

    if (wonTarget != null) {
      // 당첨된 타겟 제거 (화면에서 사라짐)
      _removeWonTarget(wonTarget);

      // 당첨! → 축하 효과 + 팝업 → 기존 바텀시트
      ConfettiCelebration.show(context);
      EventPrizePopup.show(
        context,
        prize: wonTarget.prize,
        onContinue: () {
          _showCoordinateConfirmDialog(row, col);
        },
      );
    } else {
      // 미당첨 → 바로 기존 바텀시트
      _showCoordinateConfirmDialog(row, col);
    }
  }

  void _showCoordinateConfirmDialog(int row, int col) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TossStyleConfirmSheet(
        row: row,
        col: col,
        productName: _gameRound?.title ?? '상품',
        productImage: _gameRound?.imageUrl ?? '',
        price: _gameRound?.currentPrice ?? 0,
        onConfirm: () {
          context.pop();
          _joinGame(row, col);
        },
        onRetry: () {
          context.pop();
          _pickerKey.currentState?.reset();
        },
      ),
    );
  }

  Future<void> _joinGame(int row, int col) async {
    if (_game == null || _gameRound == null) return;

    final contractAddress = _game!.onchainContractAddr;
    final gameProducts = _game!.gameProducts;

    if (contractAddress == null || contractAddress.isEmpty) {
      _showErrorSnackBar('컨트랙트 주소가 없습니다.');
      _pickerKey.currentState?.reset();
      return;
    }

    if (gameProducts == null || gameProducts.isEmpty) {
      _showErrorSnackBar('게임 상품 정보가 없습니다.');
      _pickerKey.currentState?.reset();
      return;
    }

    // 선택된 상품 사용 (SELECT 타입에서 변경 가능)
    final selectedGameProductId = gameProducts[_selectedProductIndex].id;

    OverlayEntry? progressOverlay;

    try {
      progressOverlay = GameJoinProgressOverlay.show(
        context,
        currentStep: GameJoinStep.walletCheck,
        statusMessage: '게임 참여를 준비하고 있습니다...',
      );

      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: _game!.id,
            selectedGameProductId: selectedGameProductId,
            row: row,
            col: col,
            contractAddress: contractAddress,
          );

      progressOverlay.remove();
      progressOverlay = null;

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        if (result.success) {
          GameJoinResultOverlay.showSuccess(
            context,
            entryId: result.entryId,
            txHash: result.txHash,
            onConfirm: () {
              context.go('/');
            },
          );
        } else {
          GameJoinResultOverlay.showError(
            context,
            errorMessage: result.message,
            onRetry: () {
              _pickerKey.currentState?.reset();
            },
          );
        }
      }
    } catch (e) {
      progressOverlay?.remove();
      progressOverlay = null;

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;
        GameJoinResultOverlay.showError(
          context,
          errorMessage: '알 수 없는 오류가 발생했습니다.\n$e',
          onRetry: () {
            _pickerKey.currentState?.reset();
          },
        );
      }
    } finally {
      ref.read(gameJoinProgressNotifierProvider.notifier).reset();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// SELECT 타입 게임에서 상품 선택 오버레이 표시
  void _showProductSelector() {
    final products = _game?.gameProducts;
    if (products == null || products.length <= 1) return;

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ProductSelectorOverlay(
        products: products,
        initialIndex: _selectedProductIndex,
        onProductSelected: (index, product) {
          setState(() {
            _selectedProductIndex = index;
            // 선택된 상품으로 GameRound 정보 업데이트
            if (_game != null) {
              _gameRound = _createGameRoundFromProduct(_game!, product);
            }
          });
        },
      ),
    );
  }

  /// 선택된 상품으로 GameRound 생성
  GameRound _createGameRoundFromProduct(Game game, GameProduct gameProduct) {
    final product = gameProduct.product;

    GameType type = GameType.daily;
    if (game.gameType != null) {
      switch (game.gameType!.toUpperCase()) {
        case 'DAILY':
          type = GameType.daily;
          break;
        case 'SELECT':
          type = GameType.select;
          break;
        case 'VIBE':
          type = GameType.vibe;
          break;
      }
    }

    return GameRound(
      id: game.id,
      title: product.name,
      description: product.description ?? '',
      imageUrl: product.defaultImage ?? product.imageUrl ?? '',
      participants: game.minEntries ?? 0,
      maxParticipants: game.maxEntries ?? 0,
      totalBlocks: (game.gridRows ?? 0) * (game.gridCols ?? 0),
      requiredPicks: 1,
      winners: 1,
      originalPrice: product.originalPrice ?? product.price ?? 0,
      currentPrice: game.entryFee ?? 0,
      timeLeft: '0h 0m',
      type: type,
      status: GameStatus.active,
      category: product.category ?? 'Digital',
      gridSize: null,
      gridWidth: game.gridCols,
      gridHeight: game.gridRows,
      vibeImageUrl: null,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameId == null) {
      return _buildErrorScreen('게임 ID가 없습니다');
    }

    final gameAsync = ref.watch(gameProvider(widget.gameId!));

    return gameAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.gray100,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
          ),
        ),
      ),
      error: (error, stack) => _buildErrorScreen('게임을 불러올 수 없습니다'),
      data: (game) {
        if (game == null) {
          return _buildErrorScreen('게임을 찾을 수 없습니다');
        }
        _game = game;
        final gameRound = game.toGameRound();
        _gameRound = gameRound;
        return _buildGameContent(gameRound);
      },
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/');
            }
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkBlue),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent(GameRound game) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: _buildAppBar(game),
      body: Column(
        children: [
          // 상품 정보 카드
          _buildProductCard(game),

          // Gacha 좌표 선택기
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBlue.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GachaCoordinatePicker(
                  key: _pickerKey,
                  imageUrl: game.imageUrl,
                  gridSize: 1000,
                  accentColor: AppColors.darkBlue,
                  rowSpeed: _rowSpeed,
                  colSpeed: _colSpeed,
                  eventMode: _eventMode,
                  targetCoordinates: _eventTargets.map((t) => Point(t.row, t.col)).toList(),
                  allowedRange: _allowedRange,
                  showTarget: _showTarget,
                  onEventSuccess: _onEventSuccess,
                  onCoordinateSelected: _onCoordinateSelected,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(GameRound game) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: AppColors.white,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/');
                    }
                  },
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: AppColors.darkBlue,
                  ),
                ),
                Expanded(
                  child: Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 설정 버튼 (이벤트 모드)
                IconButton(
                  onPressed: () => _showSettingsSheet(),
                  icon: Icon(
                    Icons.tune_rounded,
                    size: 22,
                    color: _eventMode ? AppColors.orange : AppColors.gray500,
                  ),
                ),
                // 도움말 버튼
                IconButton(
                  onPressed: () => _showHelpSheet(),
                  icon: Icon(
                    Icons.help_outline_rounded,
                    size: 22,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(GameRound game) {
    // SELECT 타입이고 상품이 여러 개인지 확인
    final isSelectType = game.type == GameType.select;
    final hasMultipleProducts = (_game?.gameProducts?.length ?? 0) > 1;
    final canChangeProduct = isSelectType && hasMultipleProducts;

    final cardContent = Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        // SELECT 타입일 때 테두리 강조
        border: canChangeProduct
            ? Border.all(color: AppColors.purple.withValues(alpha: 0.3), width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 상품 이미지
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: AppColors.gray100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: game.imageUrl.isNotEmpty
                      ? Image.network(
                          game.imageUrl.replaceAll(' ', '%20'),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
              ),

              const SizedBox(width: 16),

              // 상품 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 태그
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            game.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blue,
                            ),
                          ),
                        ),
                        if (canChangeProduct) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.purple.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.swap_horiz_rounded,
                                  size: 12,
                                  color: AppColors.purple,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '${_selectedProductIndex + 1}/${_game!.gameProducts!.length}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.purple,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    // 상품명
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // 그리드 정보
                    Text(
                      '${game.actualGridWidth} × ${game.actualGridHeight} 그리드',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),

              // 참가비
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '참가비',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_priceFormatter.format(game.currentPrice)}원',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // SELECT 타입일 때 상품 변경 안내
          if (canChangeProduct) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.purple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 16,
                    color: AppColors.purple,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '탭하여 다른 상품으로 변경',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.purple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    // SELECT 타입이면 탭 가능하게
    if (canChangeProduct) {
      return GestureDetector(
        onTap: _showProductSelector,
        child: cardContent,
      );
    }

    return cardContent;
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: Icon(
        Icons.card_giftcard_rounded,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _EventSettingsSheet(
        eventMode: _eventMode,
        showTarget: _showTarget,
        eventTargets: _eventTargets,
        targetCount: _targetCount,
        allowedRange: _allowedRange,
        rowSpeed: _rowSpeed,
        colSpeed: _colSpeed,
        gridSize: _game?.gridRows ?? 1000,
        selectedPrizePool: _selectedPrizePool,
        onSettingsChanged: (settings) {
          setState(() {
            _eventMode = settings.eventMode;
            _showTarget = settings.showTarget;
            _eventTargets = settings.eventTargets;
            _targetCount = settings.targetCount;
            _allowedRange = settings.allowedRange;
            _rowSpeed = settings.rowSpeed;
            _colSpeed = settings.colSpeed;
            _selectedPrizePool = settings.selectedPrizePool;
          });
          // 속도 변경 적용
          _pickerKey.currentState?.setRowSpeed(settings.rowSpeed);
          _pickerKey.currentState?.setColSpeed(settings.colSpeed);
        },
        onGenerateTargets: _generateRandomTargets,
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '게임 방법',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 20),
            _buildHelpStep(1, 'ROW 선택', '버튼을 눌러 가로줄(ROW)을 고정하세요'),
            const SizedBox(height: 16),
            _buildHelpStep(2, 'COL 선택', '버튼을 눌러 세로줄(COL)을 고정하세요'),
            const SizedBox(height: 16),
            _buildHelpStep(3, '참가 완료', '선택한 좌표로 게임에 참가합니다'),
            const SizedBox(height: 24),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpStep(int step, String title, String description) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 토스 스타일 확인 바텀시트
class _TossStyleConfirmSheet extends StatelessWidget {
  final int row;
  final int col;
  final String productName;
  final String productImage;
  final int price;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _TossStyleConfirmSheet({
    required this.row,
    required this.col,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat('#,###');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // 체크 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // 타이틀
          const Text(
            '좌표 선택 완료',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택한 좌표로 게임에 참가하시겠습니까?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),

          const SizedBox(height: 24),

          // 좌표 정보 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCoordBox('ROW', row),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                _buildCoordBox('COL', col),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 참가비 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '참가비',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '${priceFormatter.format(price)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 버튼들
          Row(
            children: [
              // 다시하기 버튼
              Expanded(
                child: GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        '다시 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 참가하기 버튼
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        '참가하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildCoordBox(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString().padLeft(4, '0'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// 이벤트 설정 데이터
class _EventSettings {
  final bool eventMode;
  final bool showTarget;
  final List<EventTarget> eventTargets;
  final int targetCount;
  final int allowedRange;
  final int rowSpeed;
  final int colSpeed;
  final EventPrizePool selectedPrizePool;

  _EventSettings({
    required this.eventMode,
    required this.showTarget,
    required this.eventTargets,
    required this.targetCount,
    required this.allowedRange,
    required this.rowSpeed,
    required this.colSpeed,
    required this.selectedPrizePool,
  });
}

/// 이벤트 설정 바텀시트
class _EventSettingsSheet extends StatefulWidget {
  final bool eventMode;
  final bool showTarget;
  final List<EventTarget> eventTargets;
  final int targetCount;
  final int allowedRange;
  final int rowSpeed;
  final int colSpeed;
  final int gridSize;
  final EventPrizePool selectedPrizePool;
  final Function(_EventSettings) onSettingsChanged;
  final VoidCallback onGenerateTargets;

  const _EventSettingsSheet({
    required this.eventMode,
    required this.showTarget,
    required this.eventTargets,
    required this.targetCount,
    required this.allowedRange,
    required this.rowSpeed,
    required this.colSpeed,
    required this.gridSize,
    required this.selectedPrizePool,
    required this.onSettingsChanged,
    required this.onGenerateTargets,
  });

  @override
  State<_EventSettingsSheet> createState() => _EventSettingsSheetState();
}

class _EventSettingsSheetState extends State<_EventSettingsSheet> {
  late bool _eventMode;
  late bool _showTarget;
  late List<EventTarget> _eventTargets;
  late int _targetCount;
  late int _allowedRange;
  late int _rowSpeed;
  late int _colSpeed;
  late EventPrizePool _selectedPrizePool;

  @override
  void initState() {
    super.initState();
    _eventMode = widget.eventMode;
    _showTarget = widget.showTarget;
    _eventTargets = List.from(widget.eventTargets);
    _targetCount = widget.targetCount;
    _allowedRange = widget.allowedRange;
    _rowSpeed = widget.rowSpeed;
    _colSpeed = widget.colSpeed;
    _selectedPrizePool = widget.selectedPrizePool;
  }

  void _notifyChange() {
    widget.onSettingsChanged(_EventSettings(
      eventMode: _eventMode,
      showTarget: _showTarget,
      eventTargets: _eventTargets,
      targetCount: _targetCount,
      allowedRange: _allowedRange,
      rowSpeed: _rowSpeed,
      colSpeed: _colSpeed,
      selectedPrizePool: _selectedPrizePool,
    ));
  }

  void _generateRandomTargets() {
    final random = Random();
    final actualCount = _targetCount.clamp(1, _selectedPrizePool.maxPrizeCount);
    setState(() {
      _eventTargets = List.generate(actualCount, (index) => EventTarget(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        row: random.nextInt(widget.gridSize) + 1,
        col: random.nextInt(widget.gridSize) + 1,
        prize: _selectedPrizePool.getRandomPrize(),
      ));
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 타이틀
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: AppColors.darkBlue),
              const SizedBox(width: 8),
              const Text(
                '이벤트 설정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 이벤트 모드 토글
          _buildToggleRow(
            '이벤트 모드',
            '타겟 좌표를 맞추면 축하 효과!',
            _eventMode,
            (value) {
              setState(() => _eventMode = value);
              _notifyChange();
            },
          ),
          const SizedBox(height: 16),

          // 타겟 표시 토글
          if (_eventMode) ...[
            _buildToggleRow(
              '타겟 좌표 표시',
              '화면에 목표 좌표를 표시합니다',
              _showTarget,
              (value) {
                setState(() => _showTarget = value);
                _notifyChange();
              },
            ),
            const SizedBox(height: 20),

            // 상품군 선택
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상품군 선택',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: DropdownButton<EventPrizePool>(
                    value: _selectedPrizePool,
                    isExpanded: true,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: EventPrizePool.availablePools.map((pool) {
                      return DropdownMenuItem(
                        value: pool,
                        child: Row(
                          children: [
                            Text(
                              pool.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '최대 ${pool.maxPrizeCount}개',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (pool) {
                      if (pool != null) {
                        setState(() {
                          _selectedPrizePool = pool;
                          // 개수가 새 풀의 최대를 초과하면 조정
                          if (_targetCount > pool.maxPrizeCount) {
                            _targetCount = pool.maxPrizeCount;
                          }
                          // 기존 타겟 초기화
                          _eventTargets = [];
                        });
                        _notifyChange();
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 타겟 개수 슬라이더 (최대값은 선택된 상품군의 maxPrizeCount)
            _buildSliderRow(
              '타겟 좌표 개수',
              '$_targetCount개 (최대 ${_selectedPrizePool.maxPrizeCount}개)',
              _targetCount.toDouble(),
              1,
              _selectedPrizePool.maxPrizeCount.toDouble(),
              (value) {
                setState(() => _targetCount = value.round());
                _notifyChange();
              },
            ),
            const SizedBox(height: 16),

            // 현재 타겟 좌표 및 상품
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '보너스 타겟 (${_eventTargets.length}개)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _eventTargets.isNotEmpty
                                  ? '랜덤 좌표에 보너스 상품이 숨겨져 있어요!'
                                  : '랜덤 버튼을 눌러 상품을 배치하세요',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: _eventTargets.isNotEmpty ? AppColors.darkBlue : AppColors.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: _generateRandomTargets,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.shuffle_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                '랜덤',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // 타겟 상품 리스트
                  if (_eventTargets.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _eventTargets.map((target) {
                        final (r, g, b) = EventPrize.getGradeColor(target.prize.grade);
                        final gradeColor = Color.fromRGBO(r, g, b, 1);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: gradeColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: gradeColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(target.prize.emoji, style: const TextStyle(fontSize: 14)),
                              const SizedBox(width: 6),
                              Text(
                                target.prize.name,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: gradeColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 허용 범위 슬라이더
            _buildSliderRow(
              '허용 범위',
              '±$_allowedRange 칸',
              _allowedRange.toDouble(),
              1,
              200,
              (value) {
                setState(() => _allowedRange = value.round());
                _notifyChange();
              },
            ),
          ],

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // 속도 조절 섹션
          const Text(
            '속도 조절',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),

          // ROW 속도
          _buildSliderRow(
            'ROW (세로) 속도',
            '${(_rowSpeed / 1000).toStringAsFixed(1)}초',
            _rowSpeed.toDouble(),
            500,
            5000,
            (value) {
              setState(() => _rowSpeed = value.round());
              _notifyChange();
            },
          ),
          const SizedBox(height: 16),

          // COL 속도
          _buildSliderRow(
            'COL (가로) 속도',
            '${(_colSpeed / 1000).toStringAsFixed(1)}초',
            _colSpeed.toDouble(),
            500,
            5000,
            (value) {
              setState(() => _colSpeed = value.round());
              _notifyChange();
            },
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }

  Widget _buildToggleRow(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: AppColors.darkBlue,
          thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected) ? AppColors.white : AppColors.gray400,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderRow(
    String title,
    String valueText,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.gray700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                valueText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            activeColor: AppColors.darkBlue,
            inactiveColor: AppColors.gray200,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
