import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../grid/game_grid_widget.dart';
import 'selected_blocks_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/grid_state_provider.dart';
import '../../data/mock_game_data.dart';
import '../../models/game_round_model.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.gameId != null) {
      _game = MockGameData.getGameById(widget.gameId!);
      if (_game != null && _game!.gridSize != null) {
        _gridSize = _game!.gridSize!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridState = ref.watch(gridStateProvider);
    final gridNotifier = ref.read(gridStateProvider.notifier);
    final selectedCount = ref.watch(selectedBlockCountProvider);

    // SafeArea 패딩 가져오기
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 게임 그리드 (배경 그라데이션 제거 - 이미지가 배경 역할)
          GameGridWidget(
            gridSize: _gridSize,
            backgroundImagePath: _game?.imageUrl,
            onBlockTap: (block) {
              debugPrint('Block tapped: ${block.row}, ${block.col}');
              // 블록 탭 시 바텀시트 표시
              gridNotifier.showBottomSheet();
            },
          ),

          // 바텀시트 (선택된 블록이 있고 showBottomSheet가 true일 때 표시)
          if (selectedCount > 0 && gridState.showBottomSheet)
            const SelectedBlocksSheet(),

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
        onPressed: () => Navigator.pop(context),
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
                'Grid: $_gridSize × $_gridSize',
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
          // Zoom In
          IconButton(
            icon: const Icon(LucideIcons.plus, size: 20),
            onPressed: gridNotifier.zoomIn,
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

          // Zoom Out
          IconButton(
            icon: const Icon(LucideIcons.minus, size: 20),
            onPressed: gridNotifier.zoomOut,
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
