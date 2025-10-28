import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../grid/game_grid_widget.dart';
import 'selected_blocks_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/grid_state_provider.dart';
import '../../providers/game_provider.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../components/minimap/grid_minimap.dart';

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

  // 그리드 크기
  int _gridSize = 100;
  int _gridWidth = 100;
  int _gridHeight = 100;

  @override
  void initState() {
    super.initState();
    // 초기 줌 레벨은 데이터 로드 후 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setInitialZoom();
      }
    });
  }

  /// 초기 줌 레벨을 그리드 크기에 맞게 설정하고 화면 중앙에 배치
  void _setInitialZoom() {
    final gameId = widget.gameId ?? 'unknown';
    final gridNotifier = ref.read(gridStateProvider(gameId).notifier);
    final screenSize = MediaQuery.of(context).size;

    // 그리드 전체가 화면에 들어가도록 줌 계산
    // cellSize(30) * gridWidth * zoom = screenWidth
    const cellSize = 30.0; // AppConstants.cellSize
    final zoomToFitWidth = screenSize.width / (cellSize * _gridWidth);
    final zoomToFitHeight = screenSize.height / (cellSize * _gridHeight);

    // 작은 값 선택 (양쪽 다 화면에 들어가도록)
    final initialZoom = (zoomToFitWidth < zoomToFitHeight ? zoomToFitWidth : zoomToFitHeight) * 0.9; // 90%로 여유

    // 그리드를 화면 중앙에 배치하기 위한 pan 계산
    // 그리드 중심 좌표
    final gridCenterX = (_gridWidth * cellSize) / 2;
    final gridCenterY = (_gridHeight * cellSize) / 2;

    // 화면 중심 좌표
    final screenCenterX = screenSize.width / 2;
    final screenCenterY = screenSize.height / 2;

    // pan 계산: screenCenter = gridCenter * zoom + pan
    // => pan = screenCenter - gridCenter * zoom
    final initialPanX = screenCenterX - gridCenterX * initialZoom;
    final initialPanY = screenCenterY - gridCenterY * initialZoom;

    // 줌과 pan 동시 설정
    gridNotifier.setZoom(initialZoom);
    gridNotifier.setPan(initialPanX, initialPanY);

    debugPrint('📐 Grid: ${_gridWidth}x$_gridHeight, Initial Zoom: ${initialZoom.toStringAsFixed(4)}');
    debugPrint('📍 Initial Pan: (${initialPanX.toStringAsFixed(2)}, ${initialPanY.toStringAsFixed(2)})');
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

        // GameRound로 변환
        final gameRound = game.toGameRound();
        _game = gameRound;
        _gridWidth = gameRound.actualGridWidth;
        _gridHeight = gameRound.actualGridHeight;
        _gridSize = _gridWidth == _gridHeight ? _gridWidth : _gridWidth;

        return _buildGameScreen(context, gameId);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading...')),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildGameScreen(BuildContext context, String gameId) {
    final gridState = ref.watch(gridStateProvider(gameId));
    final gridNotifier = ref.read(gridStateProvider(gameId).notifier);
    final selectedCount = ref.watch(selectedBlockCountProvider(gameId));

    // SafeArea 패딩 가져오기
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 게임 그리드 (배경 그라데이션 제거 - 이미지가 배경 역할)
          GameGridWidget(
            gameId: gameId,
            gridWidth: _gridWidth,
            gridHeight: _gridHeight,
            backgroundImagePath: _game?.imageUrl,
            onBlockTap: (block) {
              debugPrint('Block tapped: ${block.row}, ${block.col}');
              // 블록 탭 시 바텀시트 표시
              gridNotifier.showBottomSheet();
            },
          ),

          // 바텀시트 (선택된 블록이 있고 showBottomSheet가 true일 때 표시)
          if (selectedCount > 0 && gridState.showBottomSheet)
            SelectedBlocksSheet(gameId: gameId),

          // 좌하단 미니맵
          Positioned(
            bottom: selectedCount > 0 && gridState.showBottomSheet
                ? 350 + bottomPadding + 16
                : 100 + bottomPadding + 16,
            left: 16,
            child: GridMinimap(
              gridWidth: _gridWidth,
              gridHeight: _gridHeight,
              zoom: gridState.zoom,
              panX: gridState.panX,
              panY: gridState.panY,
              screenSize: MediaQuery.of(context).size,
            ),
          ),

          // 우측 줌 컨트롤 (SafeArea 적용)
          Positioned(
            bottom: selectedCount > 0 && gridState.showBottomSheet
                ? 350 + bottomPadding
                : 100 + bottomPadding,
            right: 16,
            child: _buildZoomControls(gridNotifier, gridState),
          ),
        ],
      ),
    );
  }

  /// AppBar 구성
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(_game?.title ?? 'BlockPick Game'),
      backgroundColor: AppColors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft, color: AppColors.darkBlue),
        onPressed: () => context.go('/'),
      ),
      actions: [
        // 공유 버튼
        IconButton(
          icon: const Icon(LucideIcons.share2, color: AppColors.darkBlue),
          onPressed: () {
            // TODO: 공유 기능
          },
        ),
      ],
    );
  }

  /// 정보 패널 (좌상단)
  Widget _buildInfoPanel(GridState gridState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.grid, size: 16, color: AppColors.blue),
              const SizedBox(width: 8),
              Text(
                'Grid: $_gridWidth × $_gridHeight',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.zoomIn, size: 16, color: AppColors.purple),
              const SizedBox(width: 8),
              Text(
                'Zoom: ${gridState.zoom.toStringAsFixed(2)}x',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.hash, size: 16, color: AppColors.green),
              const SizedBox(width: 8),
              Text(
                'Selected: ${gridState.selectedBlocks.length}',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 하단 컨트롤 버튼들
  Widget _buildBottomControls(
    GridStateNotifier gridNotifier,
    int selectedCount,
  ) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 모두 지우기
          if (selectedCount > 0)
            _buildControlButton(
              icon: LucideIcons.trash2,
              label: 'Clear',
              color: AppColors.red,
              onPressed: () {
                gridNotifier.clearBlocks();
              },
            ),

          if (selectedCount > 0) const SizedBox(width: 12),

          // 참가하기 버튼
          _buildMainButton(
            selectedCount: selectedCount,
            onPressed: () {
              // TODO: 게임 참가 로직
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$selectedCount blocks selected!'),
                  backgroundColor: AppColors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// 줌 컨트롤 (우측)
  Widget _buildZoomControls(
    GridStateNotifier gridNotifier,
    GridState gridState,
  ) {
    // 화면 크기 가져오기
    final screenSize = MediaQuery.of(context).size;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In (화면 중앙 기준)
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 20),
            onPressed: () => gridNotifier.zoomIn(
              screenWidth: screenSize.width,
              screenHeight: screenSize.height,
            ),
            color: AppColors.blue,
          ),

          // Zoom 레벨 표시
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: Text(
              '${(gridState.zoom * 100).toInt()}%',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.navy,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Zoom Out (화면 중앙 기준)
          IconButton(
            icon: const Icon(LucideIcons.minus, size: 20),
            onPressed: () => gridNotifier.zoomOut(
              screenWidth: screenSize.width,
              screenHeight: screenSize.height,
            ),
            color: AppColors.blue,
          ),
        ],
      ),
    );
  }

  /// 컨트롤 버튼
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: AppTextStyles.button.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 메인 버튼 (참가하기)
  Widget _buildMainButton({
    required int selectedCount,
    required VoidCallback onPressed,
  }) {
    final isDisabled = selectedCount == 0;

    return Container(
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
          onTap: isDisabled ? null : onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isDisabled ? LucideIcons.lock : LucideIcons.zap,
                  size: 20,
                  color: AppColors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  isDisabled
                      ? 'Select blocks to play'
                      : 'Play with $selectedCount blocks',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
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
