import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../components/minimap/grid_minimap.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/auth/domain/providers/auth_provider.dart';
import '../auth/presentation/dialogs/auth_dialogs.dart';
import '../../models/block_model.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../models/grid_section_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/grid_state_provider.dart';
import '../../utils/adaptive_zoom_system.dart';
import '../../utils/debouncer.dart';
import '../../utils/zoom_calculator.dart';
import '../../widgets/grid_section_overlay.dart';
import '../../widgets/zoom_controls.dart';
import '../grid/game_grid_widget.dart';
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
  Game? _fullGame; // 전체 게임 정보 (contract address 포함)

  // 그리드 크기
  int _gridWidth = 100;
  int _gridHeight = 100;

  // GridConfig
  GridConfig? _gridConfig;

  // Zoom 시스템
  ZoomSpec? _zoomSpec;
  ZoomMapper? _zoomMapper;
  int _currentZoomLevel = 1;
  bool _isInitialized = false;

  // Pick 최대치
  int _pickMax = 5;

  // 섹션 (3x3 구역)
  List<GridSection> _sections = [];

  // 디바운서
  final _zoomDebouncer = Debouncer(500);
  final _tapDebouncer = Debouncer(150);

  // Tutorial
  TutorialCoachMark? _tutorialCoachMark;
  final GlobalKey _minimapKey = GlobalKey();
  final GlobalKey _zoomControlKey = GlobalKey();
  final GlobalKey _gridKey = GlobalKey();
  final GlobalKey _hudKey = GlobalKey();
  final GlobalKey _tutorialBlockKey = GlobalKey();

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
    _tutorialCoachMark?.finish();
    super.dispose();
  }

  /// 초기 줌 설정 및 섹션 생성
  void _setInitialZoom() {
    debugPrint('🔧 _setInitialZoom() 호출');

    if (_gridConfig == null) {
      debugPrint('⚠️ _setInitialZoom: _gridConfig is null');
      return;
    }

    try {
      final gridNotifier = ref.read(gridStateProvider(_gridConfig!).notifier);
      final screenSize = MediaQuery.of(context).size;

      // Zoom Spec 계산
      _zoomSpec = computeZoomSpec(
        grid: GridSize(_gridWidth, _gridHeight),
        viewportShortSidePx: screenSize.shortestSide,
        cellSelectPx: 16.0,
      );

      _zoomMapper = ZoomMapper(
        minLevel: _zoomSpec!.minLevel,
        maxLevel: _zoomSpec!.maxLevel,
        baseScale: _gridConfig!.baseZoom,
      );

      // 초기 레벨은 선택 가능 레벨로 설정 (축소/확대 모두 가능하도록)
      _currentZoomLevel = _zoomSpec!.selectLevel;
      final initialZoom = _zoomMapper!.levelToScale(_currentZoomLevel);

      // 섹션 생성 (3x3)
      if (_sections.isEmpty) {
        _sections = GridSectionManager.createSections(
          gridWidth: _gridWidth,
          gridHeight: _gridHeight,
          sectionsPerSide: 3,
        );
        debugPrint('📍 Sections created: ${_sections.length}');
      }

      // 그리드 중앙 배치
      final gridCenterX = (_gridWidth * AppConstants.cellSize) / 2;
      final gridCenterY = (_gridHeight * AppConstants.cellSize) / 2;
      final screenCenterX = screenSize.width / 2;
      final screenCenterY = screenSize.height / 2;
      final initialPanX = screenCenterX - gridCenterX * initialZoom;
      final initialPanY = screenCenterY - gridCenterY * initialZoom;

      gridNotifier.setZoom(initialZoom);
      gridNotifier.setPan(initialPanX, initialPanY);

      debugPrint('✅ _setInitialZoom 완료!');
      debugPrint('   - Zoom Level: $_currentZoomLevel');
      debugPrint('   - Zoom: ${initialZoom.toStringAsFixed(4)}');
      debugPrint('   - Sections: ${_sections.length}');

      // UI 업데이트를 위해 rebuild 트리거
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      debugPrint('❌ _setInitialZoom error: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Zoom In
  void _handleZoomIn() {
    if (!_zoomDebouncer.allow || _zoomSpec == null || _zoomMapper == null)
      return;
    _zoomDebouncer.hit();

    if (_currentZoomLevel >= _zoomSpec!.maxLevel) {
      _showSnackBar('최대 확대입니다');
      return;
    }

    setState(() {
      _currentZoomLevel++;
    });
    _snapToLevel(_currentZoomLevel);
  }

  /// Zoom Out
  void _handleZoomOut() {
    if (!_zoomDebouncer.allow || _zoomSpec == null || _zoomMapper == null)
      return;
    _zoomDebouncer.hit();

    if (_currentZoomLevel <= _zoomSpec!.minLevel) {
      _showSnackBar('최소 축소입니다');
      return;
    }

    setState(() {
      _currentZoomLevel--;
    });
    _snapToLevel(_currentZoomLevel);
  }

  /// 레벨로 스냅 (뷰포트 중심 기준 줌)
  void _snapToLevel(int level) {
    if (_gridConfig == null || _zoomMapper == null) return;

    final gridNotifier = ref.read(gridStateProvider(_gridConfig!).notifier);
    final gridState = ref.read(gridStateProvider(_gridConfig!));

    // 그리드 위젯의 실제 렌더박스 가져오기
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;

    double viewportCenterX;
    double viewportCenterY;

    if (gridBox != null) {
      // 그리드 위젯의 실제 크기
      final gridSize = gridBox.size;
      viewportCenterX = gridSize.width / 2;
      viewportCenterY = gridSize.height / 2;

      debugPrint(
        '📐 Grid viewport size: ${gridSize.width.toStringAsFixed(1)} x ${gridSize.height.toStringAsFixed(1)}',
      );
    } else {
      // fallback: 전체 화면 크기 사용
      final screenSize = MediaQuery.of(context).size;
      viewportCenterX = screenSize.width / 2;
      viewportCenterY = screenSize.height / 2;

      debugPrint('⚠️ Grid RenderBox not found, using screen size');
    }

    // 현재 줌과 새로운 줌
    final oldZoom = gridState.zoom;
    final newZoom = _zoomMapper!.levelToScale(level);

    // 뷰포트 중심점의 그리드 좌표 계산 (줌 전)
    final gridCenterX = (viewportCenterX - gridState.panX) / oldZoom;
    final gridCenterY = (viewportCenterY - gridState.panY) / oldZoom;

    // 새로운 pan 계산 (뷰포트 중심이 같은 그리드 좌표를 가리키도록)
    final newPanX = viewportCenterX - gridCenterX * newZoom;
    final newPanY = viewportCenterY - gridCenterY * newZoom;

    // 줌과 pan을 동시에 업데이트
    gridNotifier.setZoom(newZoom);
    gridNotifier.setPan(newPanX, newPanY);

    debugPrint(
      '🔍 Snapped to Level $level (zoom: ${newZoom.toStringAsFixed(4)})',
    );
    debugPrint(
      '   - Viewport center: (${viewportCenterX.toStringAsFixed(1)}, ${viewportCenterY.toStringAsFixed(1)})',
    );
    debugPrint(
      '   - Grid center coord: (${gridCenterX.toStringAsFixed(1)}, ${gridCenterY.toStringAsFixed(1)})',
    );
    debugPrint(
      '   - oldZoom: ${oldZoom.toStringAsFixed(4)}, newZoom: ${newZoom.toStringAsFixed(4)}',
    );
    debugPrint(
      '   - oldPan: (${gridState.panX.toStringAsFixed(1)}, ${gridState.panY.toStringAsFixed(1)})',
    );
    debugPrint(
      '   - newPan: (${newPanX.toStringAsFixed(1)}, ${newPanY.toStringAsFixed(1)})',
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

  /// 튜토리얼 자동 줌인 (중앙 블록으로 이동)
  void _performTutorialZoomIn() {
    if (_gridConfig == null || _zoomMapper == null || _zoomSpec == null) return;

    final gridNotifier = ref.read(gridStateProvider(_gridConfig!).notifier);

    final targetRow = (_gridHeight / 2).floor();
    final targetCol = (_gridWidth / 2).floor();

    debugPrint('🎯 Tutorial zoom-in to block: Row $targetRow, Col $targetCol');

    // 그리드 위젯의 실제 렌더박스 가져오기
    final RenderBox? gridBox =
        _gridKey.currentContext?.findRenderObject() as RenderBox?;

    double screenWidth;
    double screenHeight;

    if (gridBox != null) {
      screenWidth = gridBox.size.width;
      screenHeight = gridBox.size.height;
    } else {
      final size = MediaQuery.of(context).size;
      screenWidth = size.width;
      screenHeight = size.height;
    }

    // 선택 가능한 줌 레벨로 이동하면서 블록 중앙에 배치
    final targetZoomLevel = _zoomSpec!.selectLevel; // 선택 가능한 레벨
    final targetZoom = _zoomMapper!.levelToScale(targetZoomLevel);

    // 블록의 중심 좌표 계산 (그리드 좌표계)
    final blockCenterX = (targetCol - 0.5) * AppConstants.cellSize;
    final blockCenterY = (targetRow - 0.5) * AppConstants.cellSize;

    // 블록이 화면 중앙에 오도록 pan 계산
    final newPanX = screenWidth / 2 - blockCenterX * targetZoom;
    final newPanY = screenHeight / 2 - blockCenterY * targetZoom;

    // 애니메이션으로 이동
    gridNotifier.setZoom(targetZoom);
    gridNotifier.setPan(newPanX, newPanY);

    // 줌 레벨도 업데이트
    setState(() {
      _currentZoomLevel = targetZoomLevel;
    });

    debugPrint(
      '✅ Tutorial zoom-in complete: Level $_currentZoomLevel, Zoom ${targetZoom.toStringAsFixed(4)}',
    );
  }

  /// 튜토리얼 체크 및 표시
  Future<void> _checkAndShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasSeenTutorial = prefs.getBool('game_tutorial_completed') ?? false;

    if (!hasSeenTutorial && mounted) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) _showTutorial();
      });
    }
  }

  /// 튜토리얼 표시
  void _showTutorial() {
    // 튜토리얼 시작 시 목표 블록을 미리 설정 (블록 위젯이 렌더링되어야 키가 유효)
    if (_gridConfig != null) {
      final targetRow = (_gridHeight / 2).floor();
      final targetCol = (_gridWidth / 2).floor();
      final targetBlock = BlockModel.fromPosition(
        targetRow,
        targetCol,
        state: BlockState.selected,
      );
      ref
          .read(gridStateProvider(_gridConfig!).notifier)
          .setTutorialTargetBlock(targetBlock);
    }

    final targets = <TargetFocus>[];

    // 미니맵
    if (_minimapKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "minimap",
          keyTarget: _minimapKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return _tutorialContent(
                  '미니맵',
                  '현재 위치를 확인하고 드래그로 빠르게 이동할 수 있습니다',
                  LucideIcons.map,
                );
              },
            ),
          ],
        ),
      );
    }

    // Zoom 컨트롤
    if (_zoomControlKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "zoom",
          keyTarget: _zoomControlKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.left,
              builder: (context, controller) {
                return _tutorialContent(
                  '줌 컨트롤',
                  '핀치 제스처 또는 +/- 버튼으로 확대/축소할 수 있습니다',
                  LucideIcons.zoomIn,
                );
              },
            ),
          ],
        ),
      );
    }

    // 블록 선택 (특정 블록 셀을 스포트라이트)
    // 줌 단계 완료 시 자동 줌인 후 표시됨 → _tutorialBlockKey에 해당 블록 위젯이 할당됨
    targets.add(
      TargetFocus(
        identify: "block_select",
        keyTarget: _tutorialBlockKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        radius: 8,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _tutorialContent(
                '블록 선택',
                '이 블록을 탭하여 선택해보세요!\n원하는 블록을 골라 게임에 참가합니다.',
                LucideIcons.fingerprint,
              );
            },
          ),
        ],
      ),
    );

    // HUD
    if (_hudKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "hud",
          keyTarget: _hudKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          radius: 12,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _tutorialContent(
                  '선택 상태',
                  '최대 $_pickMax개 선택 후 Submit 버튼을 눌러 제출하세요',
                  LucideIcons.checkCircle,
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
      onClickTarget: (target) {
        // 줌 컨트롤 단계 완료 → 즉시 줌인하여 목표 블록으로 이동
        if (target.identify == "zoom") {
          _performTutorialZoomIn();
        }
      },
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('game_tutorial_completed', true);
        // 튜토리얼 완료 시 목표 블록 제거
        if (_gridConfig != null) {
          ref
              .read(gridStateProvider(_gridConfig!).notifier)
              .setTutorialTargetBlock(null);
        }
      },
      onSkip: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('game_tutorial_completed', true);
        });
        // 스킵 시에도 목표 블록 제거
        if (_gridConfig != null) {
          ref
              .read(gridStateProvider(_gridConfig!).notifier)
              .setTutorialTargetBlock(null);
        }
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

        // 초기 줌 설정 (한 번만)
        if (!_isInitialized && _gridConfig != null) {
          _isInitialized = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              debugPrint('🚀 PostFrameCallback 실행 - _setInitialZoom 호출');
              _setInitialZoom();
              _checkAndShowTutorial();
            }
          });
        }

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
    if (_gridConfig == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final gridState = ref.watch(gridStateProvider(_gridConfig!));
    final selectedCount = ref.watch(selectedBlockCountProvider(_gridConfig!));
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isPrimeGame = _fullGame != null &&
        _fullGame!.gameType?.toUpperCase() == 'PRIME';

    // 현재 줌을 레벨로 변환 (핀치 줌과 버튼 줌 동기화)
    final currentZoomLevel =
        _zoomMapper?.scaleToNearestLevel(gridState.zoom) ?? _currentZoomLevel;

    // 레벨이 변경되었으면 상태 업데이트 (다음 프레임에)
    if (currentZoomLevel != _currentZoomLevel && _zoomMapper != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentZoomLevel = currentZoomLevel;
          });
        }
      });
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 게임 그리드
          Positioned.fill(
            key: _gridKey,
            child: Builder(
              builder: (context) {
                // SELECT 게임인 경우 선택된 상품의 이미지 사용
                String? backgroundImagePath;
                if (_fullGame != null &&
                    _fullGame!.gameType?.toUpperCase() == 'SELECT' &&
                    _fullGame!.gameProducts != null &&
                    _fullGame!.gameProducts!.isNotEmpty) {
                  final selectedProduct =
                      _fullGame!.gameProducts![_selectedProductIndex];
                  backgroundImagePath =
                      selectedProduct.product.defaultImage ??
                      selectedProduct.product.imageUrl;
                } else {
                  backgroundImagePath = _game?.imageUrl;
                }

                return GameGridWidget(
                  gameId: gameId,
                  gridWidth: _gridWidth,
                  gridHeight: _gridHeight,
                  backgroundImagePath: backgroundImagePath,
                  tutorialBlockKey: _tutorialBlockKey,
                  onBlockTap: (block) {
                    debugPrint('Block tapped: ${block.row}, ${block.col}');

                    // 게임 상태 체크 — 참여 불가 게임은 블록 선택 차단
                    if (_fullGame != null && !_fullGame!.isJoinable) {
                      final statusText = _game?.status.bannerMessage() ?? '참여할 수 없는 게임입니다.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(statusText),
                          backgroundColor: AppColors.gray800,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                      return false;
                    }

                    // 로그인 체크 — false 반환 시 블록 선택 안 됨
                    final isAuthenticated = ref.read(isAuthenticatedProvider);
                    if (!isAuthenticated) {
                      showLoginDialog(context);
                      return false;
                    }

                    // 튜토리얼 목표 블록을 탭했는지 확인
                    final gridState = ref.read(gridStateProvider(_gridConfig!));
                    if (gridState.tutorialTargetBlock != null &&
                        gridState.tutorialTargetBlock!.id == block.id) {
                      // 튜토리얼 목표 블록을 선택했으면 다음 단계로
                      debugPrint('✅ Tutorial target block selected!');
                      ref
                          .read(gridStateProvider(_gridConfig!).notifier)
                          .setTutorialTargetBlock(null);
                      _tutorialCoachMark?.next();
                    }

                    // 블록 선택 허용
                    return true;
                  },
                );
              },
            ),
          ),

          // 섹션 오버레이 (항상 표시, 실시간 업데이트)
          if (_sections.isNotEmpty)
            Positioned.fill(child: _buildSectionOverlay(gridState)),

          // (i) 정보 아이콘 (좌상단) - 튜토리얼 트리거
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: () {
                _tutorialCoachMark?.finish();
                _showTutorial();
              },
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

          // 상품 정보 버튼 (우상단)
          Positioned(
            top: 16,
            right: 16,
            child: GestureDetector(
              onTap: _showProductInfo,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '상품 정보',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkBlue,
                      ),
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

          // 입찰 범위 칩 (PRIME 게임, 상단 중앙)
          if (isPrimeGame)
            Positioned(
              top: 16,
              left: 56,
              right: 56,
              child: Center(
                child: Builder(
                  builder: (context) {
                    final bidRange = _getPrimeBidRange();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '입찰가능 ${_formatBidPrice(bidRange.$1)}~${_formatBidPrice(bidRange.$2)}원',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

          // 미니맵 (좌하단)
          Positioned(
            bottom: 100 + bottomPadding + 16,
            left: 16,
            child: Builder(
              builder: (context) {
                // SELECT 게임인 경우 선택된 상품의 이미지 사용
                String? minimapImage;
                if (_fullGame != null &&
                    _fullGame!.gameType?.toUpperCase() == 'SELECT' &&
                    _fullGame!.gameProducts != null &&
                    _fullGame!.gameProducts!.isNotEmpty) {
                  final selectedProduct =
                      _fullGame!.gameProducts![_selectedProductIndex];
                  minimapImage = selectedProduct.product.defaultImage ??
                      selectedProduct.product.imageUrl;
                } else {
                  minimapImage = _game?.imageUrl;
                }
                return GridMinimap(
                  key: _minimapKey,
                  gridWidth: _gridWidth,
                  gridHeight: _gridHeight,
                  zoom: gridState.zoom,
                  panX: gridState.panX,
                  panY: gridState.panY,
                  screenSize: MediaQuery.of(context).size,
                  backgroundImagePath: minimapImage,
                  selectedBlocks: gridState.selectedBlocks,
                );
              },
            ),
          ),

          // Zoom Controls (우하단)
          if (_zoomSpec != null)
            Positioned(
              bottom: 100 + bottomPadding + 16,
              right: 16,
              child: ZoomControls(
                key: _zoomControlKey,
                onZoomIn: _handleZoomIn,
                onZoomOut: _handleZoomOut,
                currentLevel: currentZoomLevel,
                maxLevel: _zoomSpec!.maxLevel,
                minLevel: _zoomSpec!.minLevel,
                lodLevel: gridState.lodLevel,
              ),
            ),

          // 하단 버튼
          if (isPrimeGame)
            // PRIME: 입찰하기 + 직접입력
            Positioned(
              bottom: bottomPadding + 24,
              left: 16,
              right: 16,
              child: _buildPrimeBidButtons(),
            )
          else
            // SELECT/기타: N/5개 선택 >
            Positioned(
              bottom: bottomPadding + 24,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: selectedCount > 0 ? _showSelectedBlocksModal : null,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.textBlack.withValues(alpha: 0.85),
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$selectedCount',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: selectedCount > 0
                                ? AppColors.blue
                                : Colors.white,
                          ),
                        ),
                        Text(
                          '/$_pickMax개 선택',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 섹션 오버레이 빌드 (항상 표시, 실시간 업데이트)
  Widget _buildSectionOverlay(GridState gridState) {
    // 픽을 섹션별로 그룹화 (실시간 업데이트)
    final picksBySection = GridSectionManager.groupPicksBySection(
      gridState.selectedBlocks,
      _sections,
    );

    return GridSectionOverlay(
      sections: _sections,
      picksBySection: picksBySection,
      zoom: gridState.zoom,
      panX: gridState.panX,
      panY: gridState.panY,
      screenSize: MediaQuery.of(context).size,
      show: false, // 초록색 배경/테두리 제거
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
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 22,
                        color: AppColors.darkBlue,
                      ),
                    ),

                    // 제목 (가운데 정렬)
                    Expanded(
                      child: Text(
                        appBarTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.darkBlue,
                        ),
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
        decoration: const BoxDecoration(
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkBlue,
                    ),
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
      decoration: const BoxDecoration(
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
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
              const SizedBox(width: 4),
              Text(
                _formatRemainingTime(remaining),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: remaining.inMinutes < 30
                      ? AppColors.red
                      : AppColors.gray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
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
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppColors.gray600,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          _formatPrice(value),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
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
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.gray600,
          ),
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
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: Colors.white,
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
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '직접입력',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkBlue,
                  ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '입찰 가격 입력',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '입찰가능 ${_formatBidPrice(bidRange.$1)}~${_formatBidPrice(bidRange.$2)}원',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
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
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppColors.gray200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
                    backgroundColor: AppColors.darkBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '확인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
      barrierColor: Colors.black.withValues(alpha: 0.2),
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
                    borderRadius: BorderRadius.circular(16),
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
                          borderRadius: BorderRadius.circular(12),
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
                              borderRadius: BorderRadius.circular(12),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.darkBlue, width: 1.5)
                                  : null,
                            ),
                            child: Row(
                              children: [
                                // 썸네일
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
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
                                const SizedBox(width: 12),
                                // 상품명 + 포인트
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.darkBlue,
                                        ),
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
                                          const SizedBox(width: 4),
                                          Text(
                                            _formatPrice(
                                                product.price ?? 0),
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: AppColors.gray600,
                                            ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                  borderRadius: BorderRadius.circular(2),
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
              const SizedBox(height: 16),
              // 상품명 (전체 출력, 말줄임 없음)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    selectedProduct.name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: AppColors.darkBlue,
                    ),
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
                          borderRadius: BorderRadius.circular(12),
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
                        backgroundColor: AppColors.darkBlue,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
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
      barrierColor: Colors.black.withValues(alpha: 0.3),
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

