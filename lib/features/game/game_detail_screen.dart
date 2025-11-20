import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/grid_state_provider.dart';
import '../grid/game_grid_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'widgets/product_selector_overlay.dart';
import '../../components/minimap/grid_minimap.dart';
import '../../widgets/zoom_controls.dart';
import '../../utils/zoom_calculator.dart';

/// 게임 상세 화면
class GameDetailScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameDetailScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  int _selectedProductIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  void _showProductSelector(Game game) {
    if (game.gameProducts == null || game.gameProducts!.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: ProductSelectorOverlay(
          products: game.gameProducts!,
          initialIndex: _selectedProductIndex,
          onProductSelected: (index, product) {
            setState(() {
              _selectedProductIndex = index;
            });
            debugPrint('✅ Product selected: ${product.product.name} (index: $index)');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(gameProvider(widget.gameId));

    return gameAsync.when(
      data: (game) {
        debugPrint('📊 GameDetailScreen.build():');
        debugPrint('   - game: ${game?.id}');
        debugPrint('   - game != null: ${game != null}');

        if (game == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Game Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 64,
                    color: AppColors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Game not found',
                    style: AppTextStyles.large.copyWith(
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final gameRound = game.toGameRound();

        debugPrint('🎯 GameDetailScreen - gameRound 생성 완료:');
        debugPrint('   - gameRound.id: ${gameRound.id}');
        debugPrint('   - gameRound.imageUrl: ${gameRound.imageUrl}');
        debugPrint('   - gameRound.imageUrl.isEmpty: ${gameRound.imageUrl.isEmpty}');

        return Scaffold(
          backgroundColor: AppColors.deepWhite,
          appBar: AppBar(
            title: Text(gameRound.title),
            backgroundColor: AppColors.white,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.share2),
                onPressed: () {
                  // TODO: 공유 기능
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // 배경 (Vibe의 경우 이미지 표시)
              if (gameRound.type == GameType.vibe && gameRound.vibeImageUrl != null)
                Positioned.fill(
                  child: gameRound.vibeImageUrl!.isEmpty
                      ? Container(color: AppColors.blueWhite)
                      : Image.network(
                          gameRound.vibeImageUrl!.replaceAll(' ', '%20'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: AppColors.blueWhite);
                          },
                        ),
                ),

              // 게임 그리드
              Builder(
                builder: (context) {
                  // SELECT 게임인 경우 선택된 상품의 이미지 사용
                  String? imageUrl;
                  if (game.gameType?.toUpperCase() == 'SELECT' &&
                      game.gameProducts != null &&
                      game.gameProducts!.isNotEmpty) {
                    final selectedProduct = game.gameProducts![_selectedProductIndex];
                    imageUrl = selectedProduct.product.defaultImage ??
                        selectedProduct.product.imageUrl;
                  } else {
                    imageUrl = gameRound.imageUrl.isEmpty ? null : gameRound.imageUrl;
                  }

                  debugPrint('🎮 GameGrid 빌드:');
                  debugPrint('   - gameType: ${game.gameType}');
                  debugPrint('   - selectedProductIndex: $_selectedProductIndex');
                  debugPrint('   - backgroundImagePath: $imageUrl');
                  debugPrint('   - gridWidth: ${gameRound.gridWidth}');
                  debugPrint('   - gridHeight: ${gameRound.gridHeight}');
                  return GameGridWidget(
                    gameId: widget.gameId,
                    gridWidth: gameRound.gridWidth ?? 10,
                    gridHeight: gameRound.gridHeight ?? 10,
                    backgroundImagePath: imageUrl,
                    onBlockTap: (block) {
                      debugPrint('Block tapped: ${block.row}, ${block.col}');
                    },
                  );
                },
              ),

              // 상단 정보 패널
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildInfoPanel(gameRound, game),
              ),

              // 하단 UI 요소들
              ..._buildBottomUI(context, game, gameRound),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: AppColors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading game',
                style: AppTextStyles.large.copyWith(
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.medium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(gameProvider(widget.gameId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 상품 선택 버튼 (작은 아이콘 버튼)
  Widget _buildProductSelectorButton(Game game) {
    final selectedProduct = game.gameProducts![_selectedProductIndex];

    return GestureDetector(
      onTap: () => _showProductSelector(game),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF7C4DFF), Color(0xFF9B7EFF)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: selectedProduct.product.defaultImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    selectedProduct.product.defaultImage!.replaceAll(' ', '%20'),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        LucideIcons.package,
                        size: 28,
                        color: AppColors.white,
                      );
                    },
                  ),
                )
              : const Icon(
                  LucideIcons.package,
                  size: 28,
                  color: AppColors.white,
                ),
        ),
      ),
    );
  }

  /// 정보 패널
  Widget _buildInfoPanel(GameRound game, Game gameData) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(game.type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getTypeText(game.type),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(LucideIcons.clock, size: 16, color: AppColors.red),
              const SizedBox(width: 4),
              Text(
                game.timeLeft,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            game.title,
            style: AppTextStyles.medium.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            LucideIcons.users,
            'Participants',
            '${game.participants} / ${game.maxParticipants}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            LucideIcons.trophy,
            'Winners',
            '${game.winners}명',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            LucideIcons.coins,
            'Entry Fee',
            '₩${_formatNumber(game.currentPrice)}',
          ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.blue),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.medium),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 참가 버튼
  Widget _buildParticipateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientBluePurplePink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 참가 로직
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('게임 참가 기능은 곧 추가됩니다!'),
                backgroundColor: AppColors.green,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.zap,
                  size: 24,
                  color: AppColors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'Participate Now',
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

  /// 타입 색상
  Color _getTypeColor(GameType type) {
    switch (type) {
      case GameType.daily:
        return AppColors.pink;
      case GameType.select:
        return AppColors.purple;
      case GameType.vibe:
        return AppColors.blue;
    }
  }

  /// 타입 텍스트
  String _getTypeText(GameType type) {
    switch (type) {
      case GameType.daily:
        return 'DAILY';
      case GameType.select:
        return 'SELECT';
      case GameType.vibe:
        return 'VIBE';
    }
  }

  /// 숫자 포맷팅
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }

  /// 하단 UI 요소들 (상품 선택, 미니맵, 줌 컨트롤, 참가 버튼)
  List<Widget> _buildBottomUI(BuildContext context, Game game, GameRound gameRound) {
    final widgets = <Widget>[];
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final baseBottom = 100.0 + bottomPadding + 16;

    // GridConfig 생성
    final screenSize = MediaQuery.of(context).size;
    final baseZoom = ZoomCalculator.calculateBaseZoom(
      gridWidth: gameRound.gridWidth ?? 10,
      gridHeight: gameRound.gridHeight ?? 10,
      screenWidth: screenSize.width,
      screenHeight: screenSize.height,
    );
    final gridConfig = GridConfig(
      gameId: widget.gameId,
      gridWidth: gameRound.gridWidth ?? 10,
      gridHeight: gameRound.gridHeight ?? 10,
      baseZoom: baseZoom,
    );
    final gridState = ref.watch(gridStateProvider(gridConfig));

    // SELECT 게임인 경우 상품 선택 버튼 (중하단)
    if (game.gameType?.toUpperCase() == 'SELECT' &&
        game.gameProducts != null &&
        game.gameProducts!.length > 1) {
      widgets.add(
        Positioned(
          bottom: baseBottom,
          left: 0,
          right: 0,
          child: Center(
            child: _buildProductSelectorButton(game),
          ),
        ),
      );
    }

    // 미니맵 (좌하단)
    widgets.add(
      Positioned(
        bottom: baseBottom,
        left: 16,
        child: GridMinimap(
          gridWidth: gameRound.gridWidth ?? 10,
          gridHeight: gameRound.gridHeight ?? 10,
          zoom: gridState.zoom,
          panX: gridState.panX,
          panY: gridState.panY,
          screenSize: screenSize,
          backgroundImagePath: gameRound.imageUrl.isEmpty ? null : gameRound.imageUrl,
          selectedBlocks: gridState.selectedBlocks,
        ),
      ),
    );

    // Zoom 컨트롤 (우하단)
    widgets.add(
      Positioned(
        bottom: baseBottom,
        right: 16,
        child: ZoomControls(
          onZoomIn: () {
            // TODO: 줌 인 구현
          },
          onZoomOut: () {
            // TODO: 줌 아웃 구현
          },
          currentLevel: 1,
          maxLevel: 10,
          minLevel: 1,
        ),
      ),
    );

    // 참가 버튼 (최하단)
    widgets.add(
      Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: _buildParticipateButton(),
      ),
    );

    return widgets;
  }
}
