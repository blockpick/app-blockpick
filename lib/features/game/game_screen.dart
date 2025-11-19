import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../grid/game_grid_widget.dart';
import 'selected_blocks_sheet.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/grid_state_provider.dart';
import '../../providers/game_provider.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../models/block_model.dart';
import '../../components/minimap/grid_minimap.dart';
import '../../utils/zoom_calculator.dart';
import '../../utils/adaptive_zoom_system.dart';
import '../../utils/debouncer.dart';
import '../../widgets/pick_hud.dart';
import '../../widgets/zoom_controls.dart';
import '../../models/grid_section_model.dart';
import '../../widgets/grid_section_overlay.dart';

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
    if (!_zoomDebouncer.allow || _zoomSpec == null || _zoomMapper == null) return;
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
    if (!_zoomDebouncer.allow || _zoomSpec == null || _zoomMapper == null) return;
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
    final RenderBox? gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;

    double viewportCenterX;
    double viewportCenterY;

    if (gridBox != null) {
      // 그리드 위젯의 실제 크기
      final gridSize = gridBox.size;
      viewportCenterX = gridSize.width / 2;
      viewportCenterY = gridSize.height / 2;

      debugPrint('📐 Grid viewport size: ${gridSize.width.toStringAsFixed(1)} x ${gridSize.height.toStringAsFixed(1)}');
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

    debugPrint('🔍 Snapped to Level $level (zoom: ${newZoom.toStringAsFixed(4)})');
    debugPrint('   - Viewport center: (${viewportCenterX.toStringAsFixed(1)}, ${viewportCenterY.toStringAsFixed(1)})');
    debugPrint('   - Grid center coord: (${gridCenterX.toStringAsFixed(1)}, ${gridCenterY.toStringAsFixed(1)})');
    debugPrint('   - oldZoom: ${oldZoom.toStringAsFixed(4)}, newZoom: ${newZoom.toStringAsFixed(4)}');
    debugPrint('   - oldPan: (${gridState.panX.toStringAsFixed(1)}, ${gridState.panY.toStringAsFixed(1)})');
    debugPrint('   - newPan: (${newPanX.toStringAsFixed(1)}, ${newPanY.toStringAsFixed(1)})');
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

    // 그리드 중앙 근처의 블록을 목표로 설정 (예: 50행 50열)
    final targetRow = (_gridHeight / 2).floor();
    final targetCol = (_gridWidth / 2).floor();
    final targetBlock = BlockModel.fromPosition(targetRow, targetCol, state: BlockState.selected);

    debugPrint('🎯 Tutorial zoom-in to block: Row $targetRow, Col $targetCol');

    // 튜토리얼 목표 블록 설정
    gridNotifier.setTutorialTargetBlock(targetBlock);

    // 그리드 위젯의 실제 렌더박스 가져오기
    final RenderBox? gridBox = _gridKey.currentContext?.findRenderObject() as RenderBox?;

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

    debugPrint('✅ Tutorial zoom-in complete: Level $_currentZoomLevel, Zoom ${targetZoom.toStringAsFixed(4)}');
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

    // 그리드 - 1단계: 줌 안내
    if (_gridKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "grid_zoom",
          keyTarget: _gridKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _tutorialContent(
                  '줌 레벨 안내',
                  '축소된 상태에서 블록을 선택하면 자동으로 해당 구역으로 확대됩니다\n\n다음 단계에서 직접 체험해보세요!',
                  LucideIcons.zoomIn,
                );
              },
            ),
          ],
        ),
      );
    }

    // 그리드 - 2단계: 블록 선택 실습
    if (_gridKey.currentContext != null) {
      targets.add(
        TargetFocus(
          identify: "grid_select",
          keyTarget: _gridKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          enableOverlayTab: true, // 오버레이를 통해 탭 가능하게
          contents: [
            TargetContent(
              align: ContentAlign.bottom,
              builder: (context, controller) {
                return _tutorialContent(
                  '블록 선택 실습',
                  '화면 중앙에 노란색으로 표시된 셀을 탭해보세요!\n이 셀을 선택하면 다음 단계로 진행됩니다.',
                  LucideIcons.target,
                );
              },
            ),
          ],
        ),
      );
    }

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
        // "grid_zoom" 단계가 끝나고 다음으로 넘어갈 때 자동 줌인
        if (target.identify == "grid_zoom") {
          debugPrint('🎯 Tutorial: grid_zoom step completed, performing auto zoom-in');
          Future.delayed(const Duration(milliseconds: 300), () {
            _performTutorialZoomIn();
          });
        }
      },
      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('game_tutorial_completed', true);
        // 튜토리얼 완료 시 목표 블록 제거
        if (_gridConfig != null) {
          ref.read(gridStateProvider(_gridConfig!).notifier).setTutorialTargetBlock(null);
        }
      },
      onSkip: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool('game_tutorial_completed', true);
        });
        // 스킵 시에도 목표 블록 제거
        if (_gridConfig != null) {
          ref.read(gridStateProvider(_gridConfig!).notifier).setTutorialTargetBlock(null);
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
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.navy,
            ),
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gridState = ref.watch(gridStateProvider(_gridConfig!));
    final selectedCount = ref.watch(selectedBlockCountProvider(_gridConfig!));
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.deepWhite,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          // 게임 그리드
          Positioned.fill(
            key: _gridKey,
            child: GameGridWidget(
              gameId: gameId,
              gridWidth: _gridWidth,
              gridHeight: _gridHeight,
              backgroundImagePath: _game?.imageUrl,
              onBlockTap: (block) {
                debugPrint('Block tapped: ${block.row}, ${block.col}');

                // 튜토리얼 목표 블록을 탭했는지 확인
                final gridState = ref.read(gridStateProvider(_gridConfig!));
                if (gridState.tutorialTargetBlock != null &&
                    gridState.tutorialTargetBlock!.id == block.id) {
                  // 튜토리얼 목표 블록을 선택했으면 다음 단계로
                  debugPrint('✅ Tutorial target block selected!');
                  ref.read(gridStateProvider(_gridConfig!).notifier).setTutorialTargetBlock(null);
                  _tutorialCoachMark?.next();
                }

                ref.read(gridStateProvider(_gridConfig!).notifier).showBottomSheet();
              },
            ),
          ),

          // 섹션 오버레이 (항상 표시, 실시간 업데이트)
          if (_sections.isNotEmpty)
            Positioned.fill(
              child: _buildSectionOverlay(gridState),
            ),

          // 바텀시트
          if (selectedCount > 0 && gridState.showBottomSheet)
            SelectedBlocksSheet(
              gridConfig: _gridConfig!,
              game: _game,
              fullGame: _fullGame,
            ),

          // HUD (상단 중앙)
          if (_zoomSpec != null)
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: PickHud(
                  key: _hudKey,
                  selected: selectedCount,
                  pickMax: _pickMax,
                  zoomLevel: _currentZoomLevel,
                  onSubmit: selectedCount >= _pickMax ? () {
                    _showSnackBar('$selectedCount개 블록 제출됨!');
                  } : null,
                ),
              ),
            ),

          // 미니맵 (좌하단)
          Positioned(
            bottom: selectedCount > 0 && gridState.showBottomSheet
                ? 350 + bottomPadding + 16
                : 100 + bottomPadding + 16,
            left: 16,
            child: GridMinimap(
              key: _minimapKey,
              gridWidth: _gridWidth,
              gridHeight: _gridHeight,
              zoom: gridState.zoom,
              panX: gridState.panX,
              panY: gridState.panY,
              screenSize: MediaQuery.of(context).size,
              backgroundImagePath: _game?.imageUrl,
            ),
          ),

          // Zoom Controls (우하단)
          if (_zoomSpec != null)
            Positioned(
              bottom: selectedCount > 0 && gridState.showBottomSheet
                  ? 350 + bottomPadding + 16
                  : 100 + bottomPadding + 16,
              right: 16,
              child: ZoomControls(
                key: _zoomControlKey,
                onZoomIn: _handleZoomIn,
                onZoomOut: _handleZoomOut,
                currentLevel: _currentZoomLevel,
                maxLevel: _zoomSpec!.maxLevel,
                minLevel: _zoomSpec!.minLevel,
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
      show: false,  // 초록색 배경/테두리 제거
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
        // 튜토리얼 다시 보기
        IconButton(
          icon: const Icon(LucideIcons.helpCircle, color: AppColors.blue),
          onPressed: () {
            _tutorialCoachMark?.finish();
            _showTutorial();
          },
        ),
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

}
