import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';
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
import 'widgets/game_result_view.dart';

/// 게임 상세 화면 (토스 스타일)
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
  bool _isInfoExpanded = true;

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
              title: Text('Game Not Found'),
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
                  SizedBox(height: 16),
                  Text(
                    'Game not found',
                    style: AppTextStyles.heading1.copyWith(
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

        // 종료된 게임은 결과 화면 표시
        if (gameRound.status.isEnded) {
          return Scaffold(
            backgroundColor: AppColors.white,
            body: Stack(
              children: [
                // 결과 화면
                GameResultView(game: game, gameRound: gameRound),

                // 토스 스타일 커스텀 헤더
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: _buildTossHeader(gameRound),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.white,
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

                  return GameGridWidget(
                    gameId: widget.gameId,
                    gridWidth: gameRound.gridWidth ?? 10,
                    gridHeight: gameRound.gridHeight ?? 10,
                    backgroundImagePath: imageUrl,
                    onBlockTap: (block) {
                      // 게임 상태 체크 — 참여 불가 게임은 블록 선택 차단
                      if (!game.isJoinable) {
                        final statusText = gameRound.status.bannerMessage();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(statusText.isNotEmpty ? statusText : '참여할 수 없는 게임입니다.'),
                            backgroundColor: AppColors.gray800,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
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
                      return true;
                    },
                  );
                },
              ),

              // 토스 스타일 커스텀 헤더
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _buildTossHeader(gameRound),
              ),

              // 게임 상태 안내 배너 (참여 불가 시)
              if (!gameRound.status.isJoinable)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 56,
                  left: 16,
                  right: 16,
                  child: _buildStatusBanner(gameRound, game),
                ),

              // 토스 스타일 정보 패널 (접기/펼치기 가능)
              Positioned(
                top: MediaQuery.of(context).padding.top + 56 + (!gameRound.status.isJoinable ? 60 : 0),
                left: 16,
                right: 16,
                child: _buildTossInfoPanel(gameRound, game),
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
          title: Text('Error'),
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
              SizedBox(height: 16),
              Text(
                'Error loading game',
                style: AppTextStyles.heading1.copyWith(
                  color: AppColors.darkBlue,
                ),
              ),
              SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.body4.copyWith(
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

  /// 토스 스타일 상품 선택 버튼
  Widget _buildProductSelectorButton(Game game) {
    final selectedProduct = game.gameProducts![_selectedProductIndex];
    final productCount = game.gameProducts!.length;

    return GestureDetector(
      onTap: () => _showProductSelector(game),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상품 이미지
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 44,
                height: 44,
                color: AppColors.gray100,
                child: selectedProduct.product.defaultImage != null
                    ? Image.network(
                        selectedProduct.product.defaultImage!.replaceAll(' ', '%20'),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2_outlined,
                            size: 22,
                            color: AppColors.gray400,
                          );
                        },
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        size: 22,
                        color: AppColors.gray400,
                      ),
              ),
            ),
            SizedBox(width: 12),
            // 상품 정보
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  selectedProduct.product.name,
                  style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$productCount개 중 ${_selectedProductIndex + 1}번째',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 8),
            // 변경 아이콘
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.gray100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                size: 18,
                color: AppColors.darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 토스 스타일 커스텀 헤더
  Widget _buildTossHeader(GameRound game) {
    return Container(
      color: AppColors.white,
      child: SafeArea(
        bottom: false,
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              // 뒤로가기
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 22,
                  color: AppColors.darkBlue,
                ),
              ),

              // 제목 + 타입 배지
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getTypeColor(game.type),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeText(game.type),
                        style: AppTextStyles.caption4.copyWith(color: AppColors.white),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        game.title,
                        style: AppTextStyles.buttonLarge.copyWith(color: AppColors.darkBlue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              // 액션 버튼들
              IconButton(
                onPressed: () {
                  // TODO: 공유 기능
                },
                icon: const Icon(
                  Icons.share_outlined,
                  size: 22,
                  color: AppColors.darkBlue,
                ),
              ),
              IconButton(
                onPressed: () {
                  // TODO: 찜하기 기능
                },
                icon: const Icon(
                  Icons.bookmark_border_rounded,
                  size: 24,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 토스 스타일 정보 패널 (접기/펼치기 가능)
  Widget _buildTossInfoPanel(GameRound game, Game gameData) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isInfoExpanded = !_isInfoExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(_isInfoExpanded ? 16 : 12),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상단 요약 (항상 표시)
            Row(
              children: [
                // 남은 시간
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule_rounded, size: 14, color: AppColors.red),
                      SizedBox(width: 4),
                      Text(
                        game.timeLeft,
                        style: AppTextStyles.caption2.copyWith(color: AppColors.red),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // 참가비
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gray100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: AppColors.darkBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'P',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${game.currentPrice}',
                        style: AppTextStyles.caption2.copyWith(color: AppColors.darkBlue),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // 접기/펼치기 아이콘
                AnimatedRotation(
                  turns: _isInfoExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 300),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.gray500,
                    size: 24,
                  ),
                ),
              ],
            ),

            // 확장된 상세 정보
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  children: [
                    // 구분선
                    Container(
                      height: 1,
                      color: AppColors.gray200,
                    ),
                    const SizedBox(height: 16),
                    // 정보 그리드
                    Row(
                      children: [
                        Expanded(
                          child: _buildTossInfoItem(
                            Icons.people_outline_rounded,
                            '참가자',
                            '${game.participants.toInt()}명',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.gray200,
                        ),
                        Expanded(
                          child: _buildTossInfoItem(
                            Icons.emoji_events_outlined,
                            '당첨자',
                            '${game.winners}명',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: AppColors.gray200,
                        ),
                        Expanded(
                          child: _buildTossInfoItem(
                            Icons.grid_view_rounded,
                            '그리드',
                            '${game.gridWidth ?? 100}×${game.gridHeight ?? 100}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              crossFadeState: _isInfoExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  /// 토스 스타일 정보 아이템
  Widget _buildTossInfoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.gray500),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.gray500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.title3.copyWith(color: AppColors.darkBlue),
        ),
      ],
    );
  }

  /// 토스 스타일 참가 버튼
  Widget _buildParticipateButton() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // 로그인 체크
            final isAuthenticated = ref.read(isAuthenticatedProvider);
            if (!isAuthenticated) {
              showLoginDialog(context);
              return;
            }
            // TODO: 참가 로직
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('블록을 선택해주세요'),
                backgroundColor: AppColors.darkBlue,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  size: 22,
                  color: AppColors.white,
                ),
                SizedBox(width: 10),
                Text(
                  '블록 선택하고 참가하기',
                  style: AppTextStyles.buttonLarge.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 게임 상태 안내 배너
  Widget _buildStatusBanner(GameRound gameRound, Game game) {
    final statusColor = _getStatusBannerColor(gameRound.status);
    final message = gameRound.status.bannerMessage(startTime: game.startTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getStatusBannerIcon(gameRound.status),
            size: 20,
            color: statusColor,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.caption2.copyWith(color: statusColor.withValues(alpha: 0.1)),
            ),
          ),
        ],
      ),
    );
  }

  /// 비활성화된 참여 버튼
  Widget _buildDisabledButton(GameStatus status) {
    final buttonText = status.isEnded ? '종료된 게임' : status.badgeText;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.gray200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusBannerIcon(status),
              size: 22,
              color: AppColors.gray500,
            ),
            SizedBox(width: 10),
            Text(
              buttonText,
              style: AppTextStyles.buttonLarge.copyWith(color: AppColors.gray500),
            ),
          ],
        ),
      ),
    );
  }

  /// 상태 배너 색상
  Color _getStatusBannerColor(GameStatus status) {
    switch (status) {
      case GameStatus.scheduled:
        return AppColors.blue;
      case GameStatus.active:
        return AppColors.green500;
      case GameStatus.paused:
        return AppColors.orange;
      case GameStatus.settling:
        return AppColors.orange;
      case GameStatus.ended:
      case GameStatus.completed:
        return AppColors.gray600;
      case GameStatus.failed:
        return AppColors.red;
    }
  }

  /// 상태 배너 아이콘
  IconData _getStatusBannerIcon(GameStatus status) {
    switch (status) {
      case GameStatus.scheduled:
        return Icons.schedule_rounded;
      case GameStatus.active:
        return Icons.play_circle_outline_rounded;
      case GameStatus.paused:
        return Icons.pause_circle_outline_rounded;
      case GameStatus.settling:
        return Icons.hourglass_top_rounded;
      case GameStatus.ended:
      case GameStatus.completed:
        return Icons.check_circle_outline_rounded;
      case GameStatus.failed:
        return Icons.error_outline_rounded;
    }
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
      case GameType.prime:
        return AppColors.yellow500;
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
      case GameType.prime:
        return 'PRIME';
    }
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

    // 참가 버튼 (최하단) — 참여 가능한 게임만 표시
    final isJoinable = game.isJoinable;
    widgets.add(
      Positioned(
        bottom: 24,
        left: 16,
        right: 16,
        child: isJoinable
            ? _buildParticipateButton()
            : _buildDisabledButton(gameRound.status),
      ),
    );

    return widgets;
  }
}
