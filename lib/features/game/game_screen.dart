import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';
import '../../models/block_model.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/grid_state_provider.dart';
import '../../utils/zoom_calculator.dart';
import '../wish/widgets/buzz_canvas.dart';
import 'selected_blocks_sheet.dart';

/// 게임 메인 화면
class GameScreen extends ConsumerStatefulWidget {
  final String? gameId;

  const GameScreen({super.key, this.gameId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // 게임 데이터
  GameRound? _game;
  Game? _fullGame;

  // 그리드 크기
  int _gridWidth = 100;
  int _gridHeight = 100;

  // GridConfig (제출용)
  GridConfig? _gridConfig;
  bool _isInitialized = false;

  // Pick 최대치
  int _pickMax = 5;

  // BuzzCanvas 키 (위시와 동일한 캔버스)
  final _canvasKey = GlobalKey<BuzzCanvasState>();
  final _minimapNotifier = ValueNotifier<int>(0);

  // 상품 선택 (SELECT 게임용)
  int _selectedProductIndex = 0;

  // PRIME 게임용 입찰 가격
  int? _selectedBidPrice;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _minimapNotifier.dispose();
    super.dispose();
  }

  /// BuzzCanvas 블록 탭 핸들러 — gridStateProvider와 동기화
  bool _handleBuzzBlockTap(int x, int y) {
    // 게임 상태 체크
    if (_fullGame != null && !_fullGame!.isJoinable) {
      final statusText = _game?.status.bannerMessage() ?? '참여할 수 없는 게임입니다.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(statusText),
          backgroundColor: AppColors.gray800,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          ),
        ),
      );
      return false;
    }

    // 로그인 체크
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      showLoginDialog(context);
      return false;
    }

    if (_gridConfig == null) return false;

    // BlockModel 생성 (BuzzCanvas: x=col, y=row)
    final block = BlockModel.fromPosition(y, x);
    final gridNotifier = ref.read(gridStateProvider(_gridConfig!).notifier);
    final gridState = ref.read(gridStateProvider(_gridConfig!));

    // pickMax 체크 (이미 선택된 블록 해제는 허용)
    final isAlreadySelected = gridState.selectedBlocks.any((b) => b.id == block.id);
    if (!isAlreadySelected && gridState.selectedBlocks.length >= _pickMax) {
      _showSnackBar('최대 $_pickMax개까지 선택할 수 있습니다');
      return false;
    }

    gridNotifier.toggleBlock(block);
    setState(() {}); // BuzzCanvas 리빌드
    return true;
  }

  /// gridState 선택 블록을 BuzzCanvas용 Set<(int,int)>로 변환
  Set<(int, int)> _getSelectedBlockCoords() {
    if (_gridConfig == null) return {};
    final gridState = ref.read(gridStateProvider(_gridConfig!));
    return gridState.selectedBlocks.map((b) => (b.col, b.row)).toSet();
  }

  /// 현재 게임의 배경 이미지 URL
  String? _getBackgroundImageUrl() {
    if (_fullGame != null &&
        _fullGame!.gameType?.toUpperCase() == 'SELECT' &&
        _fullGame!.gameProducts != null &&
        _fullGame!.gameProducts!.isNotEmpty) {
      final selectedProduct = _fullGame!.gameProducts![_selectedProductIndex];
      return selectedProduct.product.defaultImage ?? selectedProduct.product.imageUrl;
    }
    return _game?.imageUrl;
  }

  /// 미니맵 (위시 소문내기와 동일한 스타일)
  Widget _buildBuzzMinimap() {
    const minimapSize = 100.0;
    return GestureDetector(
      onTapDown: (details) {
        final fractionX = details.localPosition.dx / minimapSize;
        final fractionY = details.localPosition.dy / minimapSize;
        _canvasKey.currentState?.navigateTo(fractionX, fractionY);
      },
      onPanUpdate: (details) {
        final fractionX = details.localPosition.dx / minimapSize;
        final fractionY = details.localPosition.dy / minimapSize;
        if (fractionX >= 0 && fractionX <= 1 && fractionY >= 0 && fractionY <= 1) {
          _canvasKey.currentState?.navigateTo(fractionX, fractionY);
        }
      },
      child: Container(
        width: minimapSize,
        height: minimapSize,
        decoration: BoxDecoration(
          color: const Color(0xCC1B1D21),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: const Color(0xFF3E4149), width: 0.5),
        ),
        child: CustomPaint(
          size: const Size(minimapSize, minimapSize),
          painter: _GameMinimapPainter(
            canvasState: _canvasKey.currentState,
            gridSize: _gridWidth,
            selectedBlocks: _getSelectedBlockCoords(),
            backgroundImage: _canvasKey.currentState?.bgImage,
          ),
        ),
      ),
    );
  }

  /// 줌 버튼 (위시와 동일한 다크 스타일)
  Widget _buildBuzzZoomButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xCC2A2D33),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: const Color(0xFF3E4149), width: 0.5),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF8B8F96)),
      ),
    );
  }

  /// 스낵바 표시
  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // gameId가 없으면 임시 ID 사용
    final gameId = widget.gameId ?? 'unknown';

    // GraphQL에서 게임 데이터 가져오기
    final gameAsync = ref.watch(gameProvider(gameId));

    return gameAsync.when(
      data: (game) {
        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Game Not Found')),
            body: const Center(child: Text('Game not found')),
          );
        }

        // 전체 게임 정보 저장 (contract address, gameProducts 등)
        _fullGame = game;

        // GameRound로 변환
        final gameRound = game.toGameRound();
        _game = gameRound;
        _gridWidth = gameRound.actualGridWidth;
        _gridHeight = gameRound.actualGridHeight;

        // GridConfig 생성 (baseZoom 계산)
        final screenSize = MediaQuery.of(context).size;
        final baseZoom = ZoomCalculator.calculateBaseZoom(
          gridWidth: _gridWidth,
          gridHeight: _gridHeight,
          screenWidth: screenSize.width,
          screenHeight: screenSize.height,
        );

        _gridConfig = GridConfig(
          gameId: gameId,
          gridWidth: _gridWidth,
          gridHeight: _gridHeight,
          baseZoom: baseZoom,
        );

        // 초기화 플래그
        if (!_isInitialized && _gridConfig != null) {
          _isInitialized = true;
        }

        return _buildGameScreen(context, gameId);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('불러오는 중...')),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('오류')),
        body: Center(child: Text('오류: $error')),
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, String gameId) {
    if (_gridConfig == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final gridState = ref.watch(gridStateProvider(_gridConfig!));
    final selectedCount = ref.watch(selectedBlockCountProvider(_gridConfig!));
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isPrimeGame = _fullGame != null &&
        _fullGame!.gameType?.toUpperCase() == 'PRIME';
    final hasSelection = selectedCount > 0;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // 1. 상단 바
          _buildCleanHeader(context),
          // 2. 상품 정보 카드
          _buildProductInfoCard(),
          // 3. 캔버스 그리드 영역 (위시 소문내기와 동일한 BuzzCanvas)
          Expanded(
            child: ClipRect(
              child: Stack(
                children: [
                  // BuzzCanvas 그리드 (위시와 동일)
                  BuzzCanvas(
                    key: _canvasKey,
                    gridSize: _gridWidth,
                    selectedBlocks: _getSelectedBlockCoords(),
                    backgroundImageUrl: _getBackgroundImageUrl(),
                    onViewChanged: () => _minimapNotifier.value++,
                    onBlockTap: (x, y) => _handleBuzzBlockTap(x, y),
                  ),

                  // 상단 안내 텍스트
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xCC2A2D33),
                          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                        ),
                        child: isPrimeGame
                            ? Builder(
                                builder: (context) {
                                  final bidRange = _getPrimeBidRange();
                                  return Text(
                                    '입찰가능 ${_formatBidPrice(bidRange.$1)}~${_formatBidPrice(bidRange.$2)}원',
                                    style: AppTextStyles.caption2.copyWith(
                                      color: const Color(0xFF8B8F96),
                                    ),
                                  );
                                },
                              )
                            : Text(
                                hasSelection
                                    ? '$selectedCount/$_pickMax개 선택됨 · 탭하여 추가/해제'
                                    : '확대하고 블록을 탭하세요',
                                style: AppTextStyles.caption2.copyWith(
                                  color: hasSelection
                                      ? AppColors.primaryLight
                                      : const Color(0xFF8B8F96),
                                ),
                              ),
                      ),
                    ),
                  ),

                  // 상품 정보 버튼 (우상단)
                  Positioned(
                    top: 12,
                    right: 14,
                    child: GestureDetector(
                      onTap: _showProductInfo,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xCC2A2D33),
                          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                          border: Border.all(color: const Color(0xFF3E4149), width: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '상품 정보',
                              style: AppTextStyles.caption2.copyWith(color: const Color(0xFF8B8F96)),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.chevron_right_rounded, size: 14, color: Color(0xFF8B8F96)),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 미니맵 (좌하단) — 위시와 동일한 스타일
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _minimapNotifier,
                      builder: (_, __, ___) => _buildBuzzMinimap(),
                    ),
                  ),

                  // 줌 컨트롤 버튼 (우하단) — 위시와 동일
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Column(
                      children: [
                        _buildBuzzZoomButton(Icons.add, () => _canvasKey.currentState?.zoomIn()),
                        const SizedBox(height: 8),
                        _buildBuzzZoomButton(Icons.remove, () => _canvasKey.currentState?.zoomOut()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. 하단: 선택 칩 + CTA (위시와 동일한 구조)
          if (isPrimeGame)
            Container(
              color: AppColors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: _buildPrimeBidButtons(),
                ),
              ),
            )
          else
            Container(
              color: AppColors.white,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 선택된 블록 칩 리스트
                      if (hasSelection)
                        SizedBox(
                          height: 36,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: gridState.selectedBlocks.length,
                            itemBuilder: (context, index) {
                              final block = gridState.selectedBlocks[index];
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: GestureDetector(
                                  onTap: () {
                                    // 해당 블록으로 이동
                                    _canvasKey.currentState?.navigateTo(
                                      block.col / _gridWidth,
                                      block.row / _gridHeight,
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryBg,
                                      borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                                      border: Border.all(color: AppColors.primaryMain.withValues(alpha: 0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '(${block.col}, ${block.row})',
                                          style: AppTextStyles.caption2.copyWith(
                                            color: AppColors.primaryMain,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: () {
                                            if (_gridConfig == null) return;
                                            ref.read(gridStateProvider(_gridConfig!).notifier).toggleBlock(block);
                                            setState(() {});
                                          },
                                          child: Icon(
                                            Icons.close_rounded,
                                            size: 14,
                                            color: AppColors.primaryMain.withValues(alpha: 0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (hasSelection) const SizedBox(height: 8),
                      // CTA 버튼
                      GestureDetector(
                        onTap: hasSelection ? _showSelectedBlocksModal : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: double.infinity,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: hasSelection ? AppColors.textBlack : AppColors.gray200,
                            borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                          ),
                          child: Text(
                            hasSelection
                                ? '$selectedCount/$_pickMax개 선택 완료'
                                : '블록을 선택하세요',
                            style: AppTextStyles.button.copyWith(
                              color: hasSelection ? AppColors.white : AppColors.gray400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 깔끔한 상단 헤더 (buzz_game_screen 스타일)
  Widget _buildCleanHeader(BuildContext context) {
    String title;
    switch (_fullGame?.gameType?.toUpperCase()) {
      case 'SELECT':
        title = 'SELECT';
        break;
      case 'DAILY':
        title = 'DAILY';
        break;
      case 'VIBE':
        title = 'VIBE';
        break;
      case 'PRIME':
        title = 'PRIME';
        break;
      default:
        title = _game?.title ?? 'BlockPick';
    }

    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              onPressed: () => context.go('/'),
              icon: const Icon(Icons.arrow_back_ios_new,
                  size: 20, color: AppColors.textBlack),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.title1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gray100,
                  borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                ),
                child: Text(
                  '${_game?.currentPrice ?? 0}P',
                  style: AppTextStyles.caption2.copyWith(
                    color: AppColors.gray600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 상품 정보 카드 (buzz_game_screen 스타일)
  Widget _buildProductInfoCard() {
    if (_game == null) return const SizedBox.shrink();

    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
            child: SizedBox(
              width: 56,
              height: 56,
              child: _game!.imageUrl.isNotEmpty
                  ? Image.network(
                      _game!.imageUrl.replaceAll(' ', '%20'),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: AppColors.gray200,
                        child: const Icon(Icons.image_rounded, size: 24, color: AppColors.gray400),
                      ),
                    )
                  : Container(
                      color: AppColors.gray200,
                      child: const Icon(Icons.image_rounded, size: 24, color: AppColors.gray400),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _game!.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.title3.copyWith(color: AppColors.textBlack),
                ),
                if (_game!.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    _game!.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.caption1.copyWith(color: AppColors.gray600),
                  ),
                ],
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${_game!.currentPrice}P',
                      style: AppTextStyles.title2.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.people_outline_rounded, size: 13, color: AppColors.gray400),
                    const SizedBox(width: 2),
                    Text('${_game!.participants}',
                        style: AppTextStyles.caption4.copyWith(color: AppColors.gray500)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// AppBar 구성 (게임 타입 타이틀 + 알림 벨)
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final isSelectGame = _fullGame != null &&
        _fullGame!.gameType?.toUpperCase() == 'SELECT' &&
        _fullGame!.gameProducts != null &&
        _fullGame!.gameProducts!.isNotEmpty;

    final isPrimeGame = _fullGame != null &&
        _fullGame!.gameType?.toUpperCase() == 'PRIME';

    // 게임 타입 기반 타이틀
    String appBarTitle;
    switch (_fullGame?.gameType?.toUpperCase()) {
      case 'SELECT':
        appBarTitle = 'SELECT Events';
        break;
      case 'DAILY':
        appBarTitle = 'DAILY Events';
        break;
      case 'VIBE':
        appBarTitle = 'VIBE Events';
        break;
      case 'PRIME':
        appBarTitle = 'PRIME Events';
        break;
      default:
        appBarTitle = _game?.title ?? 'BlockPick Game';
    }

    return PreferredSize(
      preferredSize: Size.fromHeight(isSelectGame ? 124 : isPrimeGame ? 140 : 56),
      child: Container(
        color: AppColors.white,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // AppBar 영역
              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    // 뒤로가기
                    IconButton(
                      onPressed: () => context.go('/'),
                      icon: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                        color: AppColors.darkBlue,
                      ),
                    ),

                    // 제목 (가운데 정렬)
                    Expanded(
                      child: Text(
                        appBarTitle,
                        style: AppTextStyles.buttonLarge.copyWith(color: AppColors.darkBlue),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // 공유하기 버튼
                    IconButton(
                      onPressed: () {
                        // TODO: share_plus 패키지 추가 후 Share.share() 연동
                        _showSnackBar('공유 기능 준비 중입니다');
                      },
                      icon: const Icon(
                        LucideIcons.share2,
                        size: 22,
                        color: AppColors.darkBlue,
                      ),
                    ),
                  ],
                ),
              ),

              // 상품 정보 바 (SELECT 게임)
              if (isSelectGame) _buildProductInfoBar(),

              // PRIME 정보 바 (상품명 + 참여수 + 남은시간 + 진행바)
              if (isPrimeGame) _buildPrimeInfoBar(),
            ],
          ),
        ),
      ),
    );
  }

  /// 상품 정보 바 (AppBar 아래 전폭 스트립, 2줄)
  Widget _buildProductInfoBar() {
    final products = _fullGame!.gameProducts!;
    final selectedProduct = products[_selectedProductIndex];
    final productName = selectedProduct.product.name ?? '';
    final entryFee = _fullGame!.entryFee ?? 0;
    final maxEntries = _fullGame!.maxEntries ?? 0;
    final participants = _game?.participants ?? 0;

    return GestureDetector(
      onTap: _showProductSelector,
      child: Container(
        height: 68,
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
            // Row 1: 상품명 + 상품 변경 아이콘
            Row(
              children: [
                Expanded(
                  child: Text(
                    productName,
                    style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.tune_rounded,
                  size: 20,
                  color: AppColors.gray600,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Row 2: 가격 + 참여수 + 그리드 크기
            Row(
              children: [
                // 가격 (ⓟ)
                _buildPointBadge(entryFee),
                const SizedBox(width: 16),
                // 참여수
                _buildInfoChip(
                  Icons.people_outline_rounded,
                  '${_formatCount(participants)}/${_formatCount(maxEntries)}',
                ),
                const SizedBox(width: 16),
                // 그리드 크기
                _buildInfoChip(
                  Icons.grid_view_rounded,
                  '${_formatPrice(_gridWidth)}×${_formatPrice(_gridHeight)}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// PRIME 게임 정보 바 (상품명 + 참여수 + 그리드 + 남은시간 + 진행바)
  Widget _buildPrimeInfoBar() {
    final productName = (_fullGame!.gameProducts != null &&
            _fullGame!.gameProducts!.isNotEmpty)
        ? _fullGame!.gameProducts!.first.product.name
        : _fullGame!.title;
    final maxEntries = _fullGame!.maxEntries ?? 0;
    final participants = _game?.participants ?? 0;
    final remaining = _getRemainingDuration();
    final progress = _getTimeProgress();

    return Container(
      height: 84,
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
            productName,
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
                '${_formatCount(participants)}/${_formatCount(maxEntries)}',
              ),
              const SizedBox(width: 16),
              _buildInfoChip(
                Icons.grid_view_rounded,
                '${_formatPrice(_gridWidth)}×${_formatPrice(_gridHeight)}',
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

  /// ⓟ 포인트 뱃지
  Widget _buildPointBadge(int value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gray600, width: 1.2),
          ),
          alignment: Alignment.center,
          child: Text(
            'P',
            style: AppTextStyles.caption4.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.gray600,
            ),
          ),
        ),
        SizedBox(width: 4),
        Text(
          _formatPrice(value),
          style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
        ),
      ],
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

  /// 가격 포맷 (1000 → 1,000)
  String _formatPrice(int price) {
    return price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 참여자 수 포맷 (만 단위 이상 K/M 표기, 소수점 1자리)
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
    return _formatPrice(count);
  }

  /// 남은 시간 계산
  Duration _getRemainingDuration() {
    if (_fullGame?.endTime == null) return Duration.zero;
    try {
      final end = DateTime.parse(_fullGame!.endTime!);
      final remaining = end.difference(DateTime.now());
      return remaining.isNegative ? Duration.zero : remaining;
    } catch (e) {
      return Duration.zero;
    }
  }

  /// 남은 시간 포맷 (HH:MM:SS 남음)
  String _formatRemainingTime(Duration remaining) {
    if (remaining == Duration.zero) return '종료';
    final hours = remaining.inHours.toString().padLeft(2, '0');
    final minutes = (remaining.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (remaining.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds 남음';
  }

  /// 시간 진행률 (0.0 ~ 1.0)
  double _getTimeProgress() {
    if (_fullGame?.startTime == null || _fullGame?.endTime == null) return 0.0;
    try {
      final start = DateTime.parse(_fullGame!.startTime!);
      final end = DateTime.parse(_fullGame!.endTime!);
      final now = DateTime.now();
      final total = end.difference(start).inSeconds;
      if (total <= 0) return 1.0;
      final elapsed = now.difference(start).inSeconds;
      return (elapsed / total).clamp(0.0, 1.0);
    } catch (e) {
      return 0.0;
    }
  }

  /// PRIME 입찰 범위 파싱 (customRules에서 또는 기본값)
  (int, int, int) _getPrimeBidRange() {
    if (_fullGame?.customRules != null) {
      try {
        final rules = _fullGame!.customRules!;
        final minMatch = RegExp(r'"minPrice"\s*:\s*(\d+)').firstMatch(rules);
        final maxMatch = RegExp(r'"maxPrice"\s*:\s*(\d+)').firstMatch(rules);
        final stepMatch =
            RegExp(r'"priceStep"\s*:\s*(\d+)').firstMatch(rules);
        if (minMatch != null && maxMatch != null) {
          return (
            int.parse(minMatch.group(1)!),
            int.parse(maxMatch.group(1)!),
            stepMatch != null ? int.parse(stepMatch.group(1)!) : 10000,
          );
        }
      } catch (e) {
        // 파싱 실패 시 기본값 사용
      }
    }
    final basePrice = _fullGame?.entryFee ?? 1000000;
    return (basePrice, (basePrice * 1.2).toInt(), 10000);
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

  Widget _buildDarkZoomButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xCC2A2D33),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF3E4149), width: 0.5),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF8B8F96)),
      ),
    );
  }

  /// PRIME 하단 입찰 버튼들
  Widget _buildPrimeBidButtons() {
    final hasBid = _selectedBidPrice != null;
    return Row(
      children: [
        // 입찰하기 버튼 (메인)
        Expanded(
          child: GestureDetector(
            onTap: hasBid ? _handleBidSubmit : null,
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
                  Text(
                    hasBid
                        ? '${_formatPrice(_selectedBidPrice!)}원에 입찰하기'
                        : '가격을 선택하세요',
                    style: AppTextStyles.title3.copyWith(color: AppColors.white),
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
          onTap: _showBidKeypad,
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

  /// PRIME 직접입력 키패드 표시
  void _showBidKeypad() {
    final bidRange = _getPrimeBidRange();
    final controller = TextEditingController(
      text: _selectedBidPrice?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radius2Xl)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들 바
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.gray200,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '입찰 가격 입력',
                style: AppTextStyles.title1.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '입찰가능 ${_formatBidPrice(bidRange.$1)}~${_formatBidPrice(bidRange.$2)}원',
                style: AppTextStyles.caption1.copyWith(color: AppColors.gray600),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '금액을 입력하세요',
                  suffixText: '원',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    borderSide:
                        BorderSide(color: AppColors.darkBlue, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final price = int.tryParse(controller.text);
                    if (price == null) {
                      _showSnackBar('올바른 금액을 입력하세요');
                      return;
                    }
                    if (price < bidRange.$1 || price > bidRange.$2) {
                      _showSnackBar(
                        '입찰 범위는 ${_formatBidPrice(bidRange.$1)}~${_formatBidPrice(bidRange.$2)}원입니다',
                      );
                      return;
                    }
                    if (price % bidRange.$3 != 0) {
                      _showSnackBar(
                        '${_formatPrice(bidRange.$3)}원 단위로 입력하세요',
                      );
                      return;
                    }
                    setState(() {
                      _selectedBidPrice = price;
                    });
                    Navigator.pop(sheetContext);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: AppTextStyles.title2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// PRIME 입찰 제출
  void _handleBidSubmit() {
    if (_selectedBidPrice == null) return;
    // TODO: 실제 입찰 API 호출
    _showSnackBar('${_formatPrice(_selectedBidPrice!)}원에 입찰되었습니다!');
  }

  /// 상품 선택 드롭다운 표시 (기획 SC-009-15 #3 스위치 버튼)
  void _showProductSelector() {
    if (_fullGame == null ||
        _fullGame!.gameProducts == null ||
        _fullGame!.gameProducts!.isEmpty) {
      return;
    }

    final products = _fullGame!.gameProducts!;
    final topOffset = MediaQuery.of(context).padding.top + 56;

    showDialog(
      context: context,
      barrierColor: AppColors.textBlack.withValues(alpha: 0.2),
      builder: (dialogContext) {
        return Stack(
          children: [
            // 배경 탭 시 닫기
            Positioned.fill(
              child: GestureDetector(
                onTap: () => Navigator.pop(dialogContext),
              ),
            ),
            // 드롭다운 리스트
            Positioned(
              top: topOffset,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(products.length, (index) {
                        final product = products[index].product;
                        final isSelected = index == _selectedProductIndex;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedProductIndex = index;
                            });
                            Navigator.pop(dialogContext);
                          },
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.darkBlue, width: 1.5)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // 썸네일
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    color: AppColors.gray100,
                                    child: product.defaultImage != null
                                        ? Image.network(
                                            product.defaultImage!
                                                .replaceAll(' ', '%20'),
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Icon(
                                              Icons.inventory_2_outlined,
                                              size: 24,
                                              color: AppColors.gray600,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.inventory_2_outlined,
                                            size: 24,
                                            color: AppColors.gray600,
                                          ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                // 상품명 + 포인트
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      // ⓟ 포인트
                                      Row(
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: AppColors.gray600,
                                                width: 1,
                                              ),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'P',
                                              style: TextStyle(
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.gray600,
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            _formatPrice(
                                                product.price ?? 0),
                                            style: AppTextStyles.body4.copyWith(color: AppColors.gray600),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// 상품 정보 보기 (SC-009-16 #1 상품정보 버튼)
  void _showProductInfo() {
    if (_fullGame == null ||
        _fullGame!.gameProducts == null ||
        _fullGame!.gameProducts!.isEmpty) {
      return;
    }

    final selectedProduct =
        _fullGame!.gameProducts![_selectedProductIndex].product;
    final detailUrl = selectedProduct.detailUrl;

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
                    style: AppTextStyles.title1.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              // 상품명 (전체 출력, 말줄임 없음)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedProduct.name,
                    style: AppTextStyles.body2.copyWith(color: AppColors.darkBlue),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 상품 이미지
              if (selectedProduct.defaultImage != null)
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                          child: Image.network(
                            selectedProduct.defaultImage!
                                .replaceAll(' ', '%20'),
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
                        if (detailUrl != null && detailUrl.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              detailUrl,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.blue,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: Center(
                    child: Text(
                      '상품 상세 정보가 없습니다',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                ),
              // 확인 버튼
              SafeArea(
                top: false,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
                      child: const Text(
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

  /// 선택된 블록 바텀시트 모달 표시
  bool _isModalShowing = false;

  void _showSelectedBlocksModal() {
    if (_gridConfig == null) return;

    final selectedCount = ref.read(selectedBlockCountProvider(_gridConfig!));
    if (selectedCount == 0) return;

    // 이미 모달이 열려있으면 무시
    if (_isModalShowing) return;

    _isModalShowing = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.textBlack.withValues(alpha: 0.3),
      builder: (context) => SelectedBlocksSheet(
        gridConfig: _gridConfig!,
        game: _game,
        fullGame: _fullGame,
      ),
    ).whenComplete(() {
      _isModalShowing = false;
    });
  }

}

/// 게임 화면 미니맵 페인터 (위시 BuzzCanvas 미니맵과 동일)
class _GameMinimapPainter extends CustomPainter {
  final BuzzCanvasState? canvasState;
  final int gridSize;
  final Set<(int, int)> selectedBlocks;
  final ui.Image? backgroundImage;

  _GameMinimapPainter({
    this.canvasState,
    required this.gridSize,
    this.selectedBlocks = const {},
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2D33)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gridPaint);

    // 배경 이미지
    if (backgroundImage != null) {
      final img = backgroundImage!;
      final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        img,
        srcRect,
        dstRect,
        Paint()
          ..filterQuality = FilterQuality.low
          ..color = const Color(0xBBFFFFFF),
      );
    }

    // 그리드 경계
    final borderPaint = Paint()
      ..color = const Color(0xFF3E4149)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    if (canvasState == null) return;

    final zoom = canvasState!.currentZoom;
    final pan = canvasState!.currentPan;
    final step = canvasState!.gridStepValue;
    final totalGrid = gridSize * step;

    // 뷰포트 영역
    final ctxSize = canvasState!.context.size;
    if (ctxSize == null) return;

    final vpLeft = (-pan.dx) / (totalGrid * zoom);
    final vpTop = (-pan.dy) / (totalGrid * zoom);
    final vpWidth = ctxSize.width / (totalGrid * zoom);
    final vpHeight = ctxSize.height / (totalGrid * zoom);

    final vpRect = Rect.fromLTWH(
      vpLeft * size.width,
      vpTop * size.height,
      vpWidth * size.width,
      vpHeight * size.height,
    );

    // 뷰포트 표시
    canvas.drawRect(vpRect, Paint()..color = AppColors.primaryMain.withValues(alpha: 0.15));
    canvas.drawRect(
      vpRect,
      Paint()
        ..color = AppColors.primaryMain.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 선택된 블록들
    for (final block in selectedBlocks) {
      final dotX = (block.$1 / gridSize) * size.width;
      final dotY = (block.$2 / gridSize) * size.height;
      canvas.drawCircle(
        Offset(dotX, dotY),
        2.5,
        Paint()..color = AppColors.primaryMain,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameMinimapPainter old) => true;
}

