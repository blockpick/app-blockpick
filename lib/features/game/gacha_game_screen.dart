import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/game_participation_provider.dart';
import '../../providers/game_join_progress_provider.dart';
import '../../providers/pending_transaction_provider.dart';
import '../../widgets/gacha_coordinate_picker.dart';
import '../../widgets/confetti_celebration.dart';
import 'models/event_prize.dart';
import 'widgets/game_join_progress_overlay.dart';
import 'widgets/game_join_result_overlay.dart';
import 'widgets/product_selector_overlay.dart';
import 'widgets/transaction_progress_modal.dart';

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

  // 튜토리얼
  TutorialCoachMark? _tutorialCoachMark;
  final GlobalKey _infoBarKey = GlobalKey();
  final GlobalKey _optionButtonsKey = GlobalKey();
  final GlobalKey _coordinatePickerKey = GlobalKey();

  // 이벤트 모드 설정
  bool _eventMode = false;
  bool _showTarget = true;
  List<EventTarget> _eventTargets = [];
  int _targetCount = 3;
  int _allowedRange = 50;
  int _rowSpeed = 2500;
  int _colSpeed = 2200;

  // 가이드선 설정
  bool _showGuideLine = false;
  int? _guideX;
  int? _guideY;

  // 전체 화면 모드
  bool _isFullScreenMode = false;

  // 상품군 설정 (나중에 게임별로 API에서 가져올 예정)
  EventPrizePool _selectedPrizePool = EventPrizePool.defaultPool;

  // 카운트다운 타이머
  Timer? _countdownTimer;
  String _countdownText = '';

  @override
  void initState() {
    super.initState();
    _startCountdown();
    _checkAndShowTutorial();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// 튜토리얼 체크 및 표시
  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial =
        prefs.getBool('gacha_tutorial_completed') ?? false;

    if (!hasSeenTutorial && mounted) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _showTutorial();
      });
    }
  }

  /// 튜토리얼 표시
  void _showTutorial() {
    final targets = <TargetFocus>[];

    // 1. 이벤트 정보 바
    if (_infoBarKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "info_bar",
          keyTarget: _infoBarKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _tutorialContent(
                  '이벤트 정보',
                  '참여 포인트, 참여자 수, 그리드 크기, 남은 시간을 확인할 수 있습니다.',
                  LucideIcons.info,
                );
              },
            ),
          ],
        ),
      );
    }

    // 2. 좌표 선택기 (메인 게임 영역)
    if (_coordinatePickerKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "picker",
          keyTarget: _coordinatePickerKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _tutorialContent(
                  '좌표 선택',
                  '화면을 탭하여 좌표를 선택하세요!\n첫 번째 탭 → 행(ROW) 결정\n두 번째 탭 → 열(COL) 결정',
                  LucideIcons.crosshair,
                );
              },
            ),
          ],
        ),
      );
    }

    // 3. 옵션 버튼
    if (_optionButtonsKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "options",
          keyTarget: _optionButtonsKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _tutorialContent(
                  '옵션 기능',
                  '즉석 결품으로 보너스 상품에 도전하거나\n가이드 라인으로 원하는 좌표를 조준할 수 있습니다.',
                  LucideIcons.settings2,
                );
              },
            ),
          ],
        ),
      );
    }

    if (targets.isEmpty) return;

    _tutorialCoachMark = TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.darkBlue,
      paddingFocus: 10,
      opacityShadow: 0.8,
      onClickTarget: (target) {},
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('gacha_tutorial_completed', true);
      },
      onSkip: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('gacha_tutorial_completed', true);
        });
        return true;
      },
    );

    _tutorialCoachMark!.show(context: context);
  }

  /// 튜토리얼 콘텐츠 위젯
  Widget _tutorialContent(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: AppTextStyles.large.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.navy),
          ),
        ],
      ),
    );
  }

  void _startCountdown() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (_game?.endTime == null) return;
    try {
      final end = DateTime.parse(_game!.endTime!);
      final remaining = end.difference(DateTime.now());
      if (remaining.isNegative) {
        setState(() => _countdownText = '종료됨');
        _countdownTimer?.cancel();
      } else {
        final hours = remaining.inHours.toString().padLeft(2, '0');
        final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
        final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
        setState(() => _countdownText = '$hours:$minutes:$seconds 남음');
      }
    } catch (_) {
      setState(() => _countdownText = '');
    }
  }

  /// 참여자 수 포맷 (만 단위 이상은 영어 숫자 단위 + 소수점 한 자리)
  String _formatParticipants(int count) {
    if (count >= 10000) {
      final value = count / 10000;
      return '${value.toStringAsFixed(1)}만';
    }
    return _priceFormatter.format(count);
  }

  /// 게임 공유
  void _shareGame() {
    final title = _gameRound?.title ?? '';
    final gameId = widget.gameId ?? '';
    final shareText = '블록픽에서 $title 이벤트에 참여해보세요!\nhttps://blockpick.io/game/$gameId';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
            const SizedBox(height: 20),
            const Text(
              '공유하기',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 20),
            // 링크 복사 버튼
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: shareText));
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('링크가 복사되었습니다'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.link_rounded, size: 20, color: AppColors.darkBlue),
                    SizedBox(width: 8),
                    Text(
                      '링크 복사',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }

  /// 랜덤 타겟 좌표들 생성 (각각 랜덤 상품 포함)
  void _generateRandomTargets() {
    final gridWidth = _game?.gridCols ?? 10000;
    final gridHeight = _game?.gridRows ?? 10000;
    // targetCount는 최대 상품 수를 초과할 수 없음
    final actualCount = _targetCount.clamp(1, _selectedPrizePool.maxPrizeCount);
    setState(() {
      _eventTargets = List.generate(actualCount, (index) => EventTarget(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        row: _random.nextInt(gridHeight) + 1,
        col: _random.nextInt(gridWidth) + 1,
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

      // 당첨! → 축하 효과 + 확인 시트에 당첨 정보 포함
      ConfettiCelebration.show(context);
      _showCoordinateConfirmDialog(row, col, wonTarget: wonTarget);
    } else {
      // 미당첨 → 바로 확인 시트
      _showCoordinateConfirmDialog(row, col);
    }
  }

  void _showCoordinateConfirmDialog(int row, int col, {EventTarget? wonTarget}) {
    final entryFee = _gameRound?.currentPrice ?? 0;
    final retryFee = (entryFee * 0.5).round();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TossStyleConfirmSheet(
        row: row,
        col: col,
        entryFee: entryFee,
        retryFee: retryFee,
        wonTarget: wonTarget,
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

    final selectedGameProductId = gameProducts[_selectedProductIndex].id;
    final gameId = _game!.id;
    final gameTitle = _gameRound?.title ?? '게임';

    OverlayEntry? progressOverlay;

    try {
      // Phase A 시작: PendingTransaction 초기화
      final pendingNotifier = ref.read(pendingTransactionNotifierProvider.notifier);
      pendingNotifier.startTransaction(gameId: gameId, gameTitle: gameTitle);

      // Phase A 로딩 표시 (기존 GameJoinProgressOverlay)
      progressOverlay = GameJoinProgressOverlay.show(
        context,
        currentStep: GameJoinStep.walletCheck,
        statusMessage: '게임 참여를 준비하고 있습니다...',
      );

      // Phase A: submitJoinGame (steps 1-5, Mutation까지만)
      final result = await ref
          .read(gameParticipationProvider.notifier)
          .submitJoinGame(
            gameId: gameId,
            selectedGameProductId: selectedGameProductId,
            row: row,
            col: col,
            contractAddress: contractAddress,
          );

      // Phase A 로딩 제거
      progressOverlay.remove();
      progressOverlay = null;

      if (!mounted) return;

      if (result.success) {
        // Phase A 성공 → TransactionProgressModal 표시
        final entryId = result.entryId;

        if (entryId != null && entryId.isNotEmpty) {
          // PendingTransaction을 Phase B(폴링)로 전환
          pendingNotifier.onMutationSuccess(
            entryId: entryId,
            txHash: result.txHash,
          );

          // TransactionProgressModal 표시
          await Future.delayed(const Duration(milliseconds: 200));
          if (!mounted) return;

          TransactionProgressModal.show(
            context,
            gameId: gameId,
            gameTitle: gameTitle,
          );

          // Phase B: 백그라운드 폴링 시작 (비동기, 기다리지 않음)
          ref.read(gameParticipationProvider.notifier).startPolling(
            entryId: entryId,
          );
        } else {
          // entryId 없음 → 성공 결과 바로 표시
          pendingNotifier.clear();
          GameJoinResultOverlay.showSuccess(
            context,
            entryId: result.entryId,
            txHash: result.txHash,
            onConfirm: () {
              context.go('/');
            },
          );
        }
      } else {
        // Phase A 실패 (서버 비즈니스 에러)
        pendingNotifier.clear();
        GameJoinResultOverlay.showError(
          context,
          errorMessage: result.message,
          onRetry: () {
            _pickerKey.currentState?.reset();
          },
        );
      }
    } catch (e) {
      progressOverlay?.remove();
      progressOverlay = null;

      // PendingTransaction 정리
      ref.read(pendingTransactionNotifierProvider.notifier).clear();

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
    // 전체 화면 모드
    if (_isFullScreenMode) {
      return _buildFullScreenMode(game);
    }

    // 기본 상세 화면
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: _buildAppBar(game),
      body: Column(
        children: [
          // 상품 정보 바
          KeyedSubtree(
            key: _infoBarKey,
            child: _buildEventInfoBar(game),
          ),

          // 옵션 토글 버튼
          KeyedSubtree(
            key: _optionButtonsKey,
            child: _buildOptionButtons(),
          ),

          // 구분선
          Container(height: 1, color: AppColors.gray200),

          // Gacha 좌표 선택기
          Expanded(
            key: _coordinatePickerKey,
            child: Container(
              color: AppColors.white,
              child: GachaCoordinatePicker(
                key: _pickerKey,
                imageUrl: game.imageUrl,
                gridWidth: game.actualGridWidth,
                gridHeight: game.actualGridHeight,
                accentColor: AppColors.darkBlue,
                rowSpeed: _rowSpeed,
                colSpeed: _colSpeed,
                eventMode: _eventMode,
                targetCoordinates: _eventTargets.map((t) => Point(t.row, t.col)).toList(),
                allowedRange: _allowedRange,
                showTarget: _showTarget,
                onEventSuccess: _onEventSuccess,
                onCoordinateSelected: _onCoordinateSelected,
                showGuideLine: _showGuideLine,
                guideX: _guideX,
                guideY: _guideY,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 전체 화면 모드
  Widget _buildFullScreenMode(GameRound game) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 전체 화면 게임 캔버스
          Positioned.fill(
            child: GachaCoordinatePicker(
              key: _pickerKey,
              imageUrl: game.imageUrl,
              gridWidth: game.actualGridWidth,
              gridHeight: game.actualGridHeight,
              accentColor: AppColors.darkBlue,
              rowSpeed: _rowSpeed,
              colSpeed: _colSpeed,
              eventMode: _eventMode,
              targetCoordinates: _eventTargets.map((t) => Point(t.row, t.col)).toList(),
              allowedRange: _allowedRange,
              showTarget: _showTarget,
              onEventSuccess: _onEventSuccess,
              onCoordinateSelected: _onCoordinateSelected,
              showGuideLine: _showGuideLine,
              guideX: _guideX,
              guideY: _guideY,
              fullScreenMode: true,
            ),
          ),

          // 상단 플로팅 버튼들
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // 전체 화면 닫기 버튼
                _buildFloatingIconButton(
                  icon: Icons.close_fullscreen_rounded,
                  onTap: () => setState(() => _isFullScreenMode = false),
                ),
                // 오른쪽 버튼들
                Row(
                  children: [
                    // 설정 버튼
                    _buildFloatingIconButton(
                      icon: Icons.tune_rounded,
                      onTap: _showSettingsSheet,
                      isActive: _eventMode,
                    ),
                    const SizedBox(width: 8),
                    // 도움말 버튼
                    _buildFloatingIconButton(
                      icon: Icons.help_outline_rounded,
                      onTap: _showHelpSheet,
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

  /// 플로팅 아이콘 버튼
  Widget _buildFloatingIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.9),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 22,
          color: isActive ? AppColors.orange : AppColors.darkBlue,
        ),
      ),
    );
  }

  /// 게임 타입에 따른 제목
  String _getGameTypeTitle(GameType type) {
    switch (type) {
      case GameType.daily:
        return 'Daily Events';
      case GameType.select:
        return 'Select Events';
      case GameType.vibe:
        return 'Vibe Events';
      case GameType.prime:
        return 'Prime Events';
    }
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
                  child: Center(
                    child: Text(
                      _getGameTypeTitle(game.type),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ),
                ),
                // 공유 버튼
                IconButton(
                  onPressed: _shareGame,
                  icon: const Icon(
                    Icons.share_outlined,
                    size: 22,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 마감 게이지 진행률 계산
  double _getDeadlineProgress() {
    if (_game == null) return 0;
    final game = _game!;

    final gameType = game.gameType?.toUpperCase();
    if (gameType == 'SELECT' || gameType == 'PRIME') {
      // Select, Prime: 남은 인원 기반
      final max = game.maxEntries ?? 1;
      final current = game.minEntries ?? 0;
      return (current / max).clamp(0.0, 1.0);
    } else {
      // Daily, Vibe: 남은 시간 기반
      if (game.startTime == null || game.endTime == null) return 0;
      try {
        final start = DateTime.parse(game.startTime!);
        final end = DateTime.parse(game.endTime!);
        final now = DateTime.now();
        final total = end.difference(start).inSeconds;
        if (total <= 0) return 1.0;
        final elapsed = now.difference(start).inSeconds;
        return (elapsed / total).clamp(0.0, 1.0);
      } catch (_) {
        return 0;
      }
    }
  }

  /// 이벤트 정보 바 (컴팩트)
  Widget _buildEventInfoBar(GameRound game) {
    final gridW = _priceFormatter.format(game.actualGridWidth);
    final gridH = _priceFormatter.format(game.actualGridHeight);

    // SELECT 타입이고 상품이 여러 개인지 확인
    final isSelectType = game.type == GameType.select;
    final hasMultipleProducts = (_game?.gameProducts?.length ?? 0) > 1;
    final canChangeProduct = isSelectType && hasMultipleProducts;

    return GestureDetector(
      onTap: canChangeProduct ? _showProductSelector : null,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
        color: AppColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 상품명 (1줄, 말줄임)
            Text(
              game.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            // 정보 행
            Row(
              children: [
                // 응모 포인트
                _buildStatChip(
                  icon: Icons.circle,
                  iconSize: 8,
                  iconColor: AppColors.green,
                  text: '${game.currentPrice}',
                ),
                const SizedBox(width: 12),
                // 참여자 수
                _buildStatChip(
                  icon: Icons.people_alt_outlined,
                  iconSize: 14,
                  iconColor: AppColors.gray500,
                  text: _formatParticipants(game.participants),
                ),
                const SizedBox(width: 12),
                // 그리드 크기
                _buildStatChip(
                  icon: Icons.grid_view_rounded,
                  iconSize: 14,
                  iconColor: AppColors.gray500,
                  text: '$gridW×$gridH',
                ),
                const Spacer(),
                // 카운트다운
                if (_countdownText.isNotEmpty)
                  Text(
                    _countdownText,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.gray600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // 마감 게이지
            ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: _getDeadlineProgress(),
                minHeight: 3,
                backgroundColor: AppColors.gray200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  /// 정보 칩 위젯
  Widget _buildStatChip({
    required IconData icon,
    required double iconSize,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
        ),
      ],
    );
  }

  /// 옵션 토글 버튼
  Widget _buildOptionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      color: AppColors.white,
      child: Row(
        children: [
          // 즉석 결품 토글
          _buildOptionChip(
            label: '즉석 결품',
            isActive: _eventMode,
            onTap: _showInstantPrizeModal,
          ),
          const SizedBox(width: 8),
          // 가이드 라인 토글
          _buildOptionChip(
            label: '가이드 라인',
            isActive: _showGuideLine,
            onTap: _showGuideLineModal,
          ),
          const Spacer(),
          // 정보 버튼
          GestureDetector(
            onTap: _showHelpSheet,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: AppColors.gray500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 옵션 칩 위젯
  Widget _buildOptionChip({
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.darkBlue.withValues(alpha: 0.08)
              : AppColors.gray100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.darkBlue.withValues(alpha: 0.3) : AppColors.gray200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive ? AppColors.green : AppColors.gray400,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isActive ? AppColors.darkBlue : AppColors.gray600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 즉석 경품 모달
  void _showInstantPrizeModal() {
    // 경품이 없으면 타겟 생성
    if (_eventTargets.isEmpty && _eventMode) {
      _generateRandomTargets();
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 토글
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '즉석 경품 표시',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      Switch(
                        value: _eventMode,
                        onChanged: (value) {
                          setState(() => _eventMode = value);
                          setDialogState(() {});
                          if (value && _eventTargets.isEmpty) {
                            _generateRandomTargets();
                            setDialogState(() {});
                          }
                        },
                        activeTrackColor: AppColors.darkBlue,
                        thumbColor: WidgetStateProperty.resolveWith((states) =>
                          states.contains(WidgetState.selected) ? AppColors.white : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '플레이 중 아래 경품 좌표를 선택하면 당첨되요!',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 경품 리스트
                  if (_eventTargets.isNotEmpty)
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _eventTargets.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final target = _eventTargets[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                // 경품 아이콘
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.gray100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: Text(
                                      target.prize.emoji,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        target.prize.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'X,Y 좌표 (${target.col},${target.row})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.gray500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  if (_eventTargets.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '등록된 즉석 경품이 없습니다',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.gray500,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 닫기 버튼
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// 가이드 라인 모달
  void _showGuideLineModal() {
    final guideXController = TextEditingController(text: _guideX?.toString() ?? '');
    final guideYController = TextEditingController(text: _guideY?.toString() ?? '');
    final gridWidth = _game?.gridCols ?? 10000;
    final gridHeight = _game?.gridRows ?? 10000;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목 + 토글
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '가이드 라인 표시',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                      Switch(
                        value: _showGuideLine,
                        onChanged: (value) {
                          setState(() => _showGuideLine = value);
                          setDialogState(() {});
                        },
                        activeTrackColor: AppColors.darkBlue,
                        thumbColor: WidgetStateProperty.resolveWith((states) =>
                          states.contains(WidgetState.selected) ? AppColors.white : AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '화면에 가이드 라인을 표시해보세요.\n(X: 0~$gridWidth, Y: 0~$gridHeight)',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.gray600,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 좌표 입력
                  Row(
                    children: [
                      // X (COL)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'X (COL)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: guideXController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: AppColors.gray400),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: AppColors.gray100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed >= 0 && parsed <= gridWidth) {
                                  setState(() => _guideX = parsed);
                                } else if (value.isEmpty) {
                                  setState(() => _guideX = null);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Y (ROW)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Y (ROW)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: guideYController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '0',
                                hintStyle: TextStyle(color: AppColors.gray400),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                filled: true,
                                fillColor: AppColors.gray100,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: AppColors.darkBlue, width: 2),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed >= 0 && parsed <= gridHeight) {
                                  setState(() => _guideY = parsed);
                                } else if (value.isEmpty) {
                                  setState(() => _guideY = null);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 초기화 링크
                  GestureDetector(
                    onTap: () {
                      guideXController.clear();
                      guideYController.clear();
                      setState(() {
                        _guideX = null;
                        _guideY = null;
                      });
                      setDialogState(() {});
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh_rounded, size: 14, color: AppColors.gray500),
                        const SizedBox(width: 4),
                        Text(
                          '초기화',
                          style: TextStyle(fontSize: 13, color: AppColors.gray500),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 닫기 버튼
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.darkBlue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          '닫기',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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
        gridWidth: _game?.gridCols ?? 10000,
        gridHeight: _game?.gridRows ?? 10000,
        selectedPrizePool: _selectedPrizePool,
        showGuideLine: _showGuideLine,
        guideX: _guideX,
        guideY: _guideY,
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
            _showGuideLine = settings.showGuideLine;
            _guideX = settings.guideX;
            _guideY = settings.guideY;
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
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (context) => Dialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 제목 + 닫기
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text('🎊 ', style: TextStyle(fontSize: 20)),
                      Text(
                        '경품 참여 방법',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close_rounded, color: AppColors.gray500),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 참여 방법
              _buildHelpItem(1, 'X (COL)과 Y (ROW) 좌표 값을 선택하세요.'),
              const SizedBox(height: 12),
              _buildHelpItem(2, '이벤트 포인트를 확인하고 최종 선택 좌표로 참여하세요.'),
              const SizedBox(height: 12),
              _buildHelpItem(3, '참여하기 버튼을 누르면 참여 포인트만큼 나의 이벤트 포인트가 차감됩니다. (재시도 포인트 : 참여 포인트의 50%)'),
              const SizedBox(height: 12),
              _buildHelpItem(4, '전략적으로 블록을 선택하여 최후의 단독 블록 당첨자가 되어보세요. (가이드를 설정하면 더 쉬어요!)'),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // 즉석 경품 안내
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('● ', style: TextStyle(fontSize: 10, color: AppColors.green)),
                    Expanded(
                      child: Text(
                        '즉석 경품 좌표를 맞추면 바로 당첨 확정!\n즉석 경품 버튼을 활성화해보세요.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.gray700,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHelpItem(int step, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.darkBlue,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            description,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.gray700,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

/// 참여하기 확인 바텀시트
class _TossStyleConfirmSheet extends StatelessWidget {
  final int row;
  final int col;
  final int entryFee;
  final int retryFee;
  final EventTarget? wonTarget;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _TossStyleConfirmSheet({
    required this.row,
    required this.col,
    required this.entryFee,
    required this.retryFee,
    this.wonTarget,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrize = wonTarget != null;

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

          if (hasPrize) ...[
            // 당첨 경품 표시
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  wonTarget!.prize.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              wonTarget!.prize.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '방금 선택한 곳에서 경품이 나왔어요!\n이 행운으로 본 이벤트에 참여하시겠어요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray700,
                height: 1.5,
              ),
            ),
          ] else ...[
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
            const SizedBox(height: 16),
            const Text(
              '선택한 좌표로 이벤트에 참여하시겠어요?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // 보유 포인트 (TODO: 실제 유저 데이터 연동)
          Text(
            '보유 포인트 : 250P (재시도 가능 2회)',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.gray500,
            ),
          ),

          const SizedBox(height: 20),

          // 좌표 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'X (COL)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  col.toString().padLeft(4, '0'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                    fontFamily: 'monospace',
                  ),
                ),
                Container(
                  width: 1,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.gray300,
                ),
                Text(
                  'Y (ROW)',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.gray500,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  row.toString().padLeft(4, '0'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 참여하기 버튼
          GestureDetector(
            onTap: onConfirm,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.darkBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  '참여하기 (${entryFee}P)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),

          // 재시도 링크
          GestureDetector(
            onTap: onRetry,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '재시도 (${retryFee}P)',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
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
  final bool showGuideLine;
  final int? guideX;
  final int? guideY;

  _EventSettings({
    required this.eventMode,
    required this.showTarget,
    required this.eventTargets,
    required this.targetCount,
    required this.allowedRange,
    required this.rowSpeed,
    required this.colSpeed,
    required this.selectedPrizePool,
    required this.showGuideLine,
    this.guideX,
    this.guideY,
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
  final int gridWidth;
  final int gridHeight;
  final EventPrizePool selectedPrizePool;
  final Function(_EventSettings) onSettingsChanged;
  final VoidCallback onGenerateTargets;
  final bool showGuideLine;
  final int? guideX;
  final int? guideY;

  const _EventSettingsSheet({
    required this.eventMode,
    required this.showTarget,
    required this.eventTargets,
    required this.targetCount,
    required this.allowedRange,
    required this.rowSpeed,
    required this.colSpeed,
    required this.gridWidth,
    required this.gridHeight,
    required this.selectedPrizePool,
    required this.onSettingsChanged,
    required this.onGenerateTargets,
    required this.showGuideLine,
    this.guideX,
    this.guideY,
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
  late bool _showGuideLine;
  int? _guideX;
  int? _guideY;

  // 텍스트 컨트롤러
  late TextEditingController _guideXController;
  late TextEditingController _guideYController;

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
    _showGuideLine = widget.showGuideLine;
    _guideX = widget.guideX;
    _guideY = widget.guideY;

    _guideXController = TextEditingController(text: _guideX?.toString() ?? '');
    _guideYController = TextEditingController(text: _guideY?.toString() ?? '');
  }

  @override
  void dispose() {
    _guideXController.dispose();
    _guideYController.dispose();
    super.dispose();
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
      showGuideLine: _showGuideLine,
      guideX: _guideX,
      guideY: _guideY,
    ));
  }

  void _generateRandomTargets() {
    final random = Random();
    final actualCount = _targetCount.clamp(1, _selectedPrizePool.maxPrizeCount);
    setState(() {
      _eventTargets = List.generate(actualCount, (index) => EventTarget(
        id: '${DateTime.now().millisecondsSinceEpoch}_$index',
        row: random.nextInt(widget.gridHeight) + 1,
        col: random.nextInt(widget.gridWidth) + 1,
        prize: _selectedPrizePool.getRandomPrize(),
      ));
    });
    _notifyChange();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들 (고정)
          Padding(
            padding: const EdgeInsets.only(top: 24, bottom: 24),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // 스크롤 가능한 콘텐츠
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),

          // 가이드선 설정 섹션
          const Text(
            '가이드선 설정',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 16),

          // 가이드선 토글
          _buildToggleRow(
            '가이드선 표시',
            '입력한 좌표에 가이드선을 표시합니다',
            _showGuideLine,
            (value) {
              setState(() => _showGuideLine = value);
              _notifyChange();
            },
          ),

          if (_showGuideLine) ...[
            const SizedBox(height: 16),

            // 좌표 입력 필드
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
                      const Icon(
                        Icons.grid_on_rounded,
                        size: 18,
                        color: Color(0xFFFFD700),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        '가이드 좌표 입력',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'X: 0~${widget.gridWidth}, Y: 0~${widget.gridHeight}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.gray500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // X 좌표 (COL) 입력
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'X (COL)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _guideXController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '세로선',
                                hintStyle: TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed >= 0 && parsed <= widget.gridWidth) {
                                  setState(() => _guideX = parsed);
                                } else if (value.isEmpty) {
                                  setState(() => _guideX = null);
                                }
                                _notifyChange();
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Y 좌표 (ROW) 입력
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Y (ROW)',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.gray600,
                              ),
                            ),
                            const SizedBox(height: 6),
                            TextField(
                              controller: _guideYController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: '가로선',
                                hintStyle: TextStyle(
                                  color: AppColors.gray400,
                                  fontSize: 14,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                filled: true,
                                fillColor: AppColors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColors.gray200),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(color: Color(0xFFFFD700), width: 2),
                                ),
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.darkBlue,
                              ),
                              onChanged: (value) {
                                final parsed = int.tryParse(value);
                                if (parsed != null && parsed >= 0 && parsed <= widget.gridHeight) {
                                  setState(() => _guideY = parsed);
                                } else if (value.isEmpty) {
                                  setState(() => _guideY = null);
                                }
                                _notifyChange();
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 초기화 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _guideX = null;
                        _guideY = null;
                        _guideXController.clear();
                        _guideYController.clear();
                      });
                      _notifyChange();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.clear_rounded,
                            size: 16,
                            color: AppColors.gray600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '초기화',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

                  SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                ],
              ),
            ),
          ),
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
