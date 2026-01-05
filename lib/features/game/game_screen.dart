import 'dart:math' as math;
import 'dart:ui' as ui;

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
import 'widgets/product_selector_overlay.dart';

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

  // 상품 선택 (SELECT 게임용)
  int _selectedProductIndex = 0;

  // 셰이더 선택
  String _currentShader = 'shaders/glow_effect.frag';

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

  /// 토스 스타일 선택 수량 배지 (왼쪽 상단)
  Widget _buildSelectionBadge(int selected, int max) {
    final isComplete = selected >= max;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
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
          // 체크 아이콘
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isComplete
                  ? AppColors.green.withValues(alpha: 0.15)
                  : AppColors.blue.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              isComplete ? Icons.check_rounded : Icons.touch_app_rounded,
              size: 14,
              color: isComplete ? AppColors.green : AppColors.blue,
            ),
          ),
          const SizedBox(width: 8),
          // 카운트
          Text(
            '$selected',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isComplete ? AppColors.green : AppColors.blue,
            ),
          ),
          Text(
            '/$max',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ],
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
    final targetBlock = BlockModel.fromPosition(
      targetRow,
      targetCol,
      state: BlockState.selected,
    );

    debugPrint('🎯 Tutorial zoom-in to block: Row $targetRow, Col $targetCol');

    // 튜토리얼 목표 블록 설정
    gridNotifier.setTutorialTargetBlock(targetBlock);

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
          debugPrint(
            '🎯 Tutorial: grid_zoom step completed, performing auto zoom-in',
          );
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
          // 배경 (셰이더 글로우 효과)
          Positioned.fill(
            child: _GlowBackground(
              key: ValueKey(_currentShader),
              shaderPath: _currentShader,
            ),
          ),

          // 테크 패턴 오버레이 (나중에 이미지로 대체 가능)
          // Positioned.fill(
          //   child: CustomPaint(
          //     painter: _TechPatternPainter(),
          //   ),
          // ),

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
                  onBlockTap: (block) {
                    debugPrint('Block tapped: ${block.row}, ${block.col}');

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

                    // 블록 선택만 하고, 바텀시트는 배지/FAB 탭으로 열림
                  },
                );
              },
            ),
          ),

          // 섹션 오버레이 (항상 표시, 실시간 업데이트)
          if (_sections.isNotEmpty)
            Positioned.fill(child: _buildSectionOverlay(gridState)),

          // 바텀시트는 showModalBottomSheet로 표시

          // 선택 수량 배지 (왼쪽 상단) - 탭하면 바텀시트 열림
          Positioned(
            top: 16,
            left: 16,
            child: GestureDetector(
              onTap: selectedCount > 0 ? _showSelectedBlocksModal : null,
              child: _buildSelectionBadge(selectedCount, _pickMax),
            ),
          ),

          // 상품 선택 버튼 (우상단) - SELECT 게임인 경우
          if (_fullGame != null &&
              _fullGame!.gameType?.toUpperCase() == 'SELECT' &&
              _fullGame!.gameProducts != null &&
              _fullGame!.gameProducts!.isNotEmpty)
            Positioned(
              top: 16,
              right: 16,
              child: _buildCompactProductSelector(),
            ),

          // 미니맵 (좌하단)
          Positioned(
            bottom: 100 + bottomPadding + 16,
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
              selectedBlocks: gridState.selectedBlocks,
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

          // FAB - 선택된 블록 보기 (선택된 블록이 있을 때만)
          if (selectedCount > 0)
            Positioned(
              bottom: bottomPadding + 24,
              left: 0,
              right: 0,
              child: Center(
                child: _buildSelectionFAB(selectedCount, _pickMax),
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

  /// 토스 스타일 AppBar 구성
  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
                // 뒤로가기
                IconButton(
                  onPressed: () => context.go('/'),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: AppColors.darkBlue,
                  ),
                ),

                // 제목
                Expanded(
                  child: Text(
                    _game?.title ?? 'BlockPick Game',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // 셰이더 변경 버튼
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.palette_outlined,
                    size: 22,
                    color: AppColors.gray600,
                  ),
                  onSelected: (String shader) {
                    debugPrint('🎨 Shader selected: $shader');
                    setState(() {
                      _currentShader = shader;
                    });
                    debugPrint('✅ State updated with new shader');
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  itemBuilder: (BuildContext context) => [
                    _buildShaderMenuItem('shaders/glow_effect.frag', '강착 디스크'),
                    _buildShaderMenuItem('shaders/flowing_waves.frag', '파도'),
                    _buildShaderMenuItem('shaders/ether.frag', '에테르'),
                    _buildShaderMenuItem('shaders/shooting_stars.frag', '유성'),
                    _buildShaderMenuItem('shaders/wavy_lines.frag', '물결선'),
                    _buildShaderMenuItem('shaders/aurora.frag', '오로라'),
                  ],
                ),

                // 튜토리얼 다시 보기
                IconButton(
                  icon: Icon(
                    Icons.help_outline_rounded,
                    size: 22,
                    color: AppColors.gray600,
                  ),
                  onPressed: () {
                    _tutorialCoachMark?.finish();
                    _showTutorial();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 셰이더 메뉴 아이템
  PopupMenuItem<String> _buildShaderMenuItem(String value, String label) {
    final isSelected = _currentShader == value;
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          if (isSelected)
            const Icon(Icons.check_rounded, size: 18, color: AppColors.blue)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? AppColors.blue : AppColors.darkBlue,
            ),
          ),
        ],
      ),
    );
  }

  /// 상품 선택 오버레이 표시
  void _showProductSelector() {
    if (_fullGame == null ||
        _fullGame!.gameProducts == null ||
        _fullGame!.gameProducts!.isEmpty) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        child: ProductSelectorOverlay(
          products: _fullGame!.gameProducts!,
          initialIndex: _selectedProductIndex,
          onProductSelected: (index, product) {
            setState(() {
              _selectedProductIndex = index;
            });
            debugPrint(
              '✅ Product selected: ${product.product.name} (index: $index)',
            );
          },
        ),
      ),
    );
  }

  /// 토스 스타일 FAB - 선택된 블록 보기
  Widget _buildSelectionFAB(int selected, int max) {
    return GestureDetector(
      onTap: _showSelectedBlocksModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.darkBlue,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: AppColors.darkBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 체크 아이콘
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 16,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 12),
            // 텍스트
            Text(
              '$selected개 선택됨',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
            // 화살표
            const Icon(
              Icons.keyboard_arrow_up_rounded,
              size: 20,
              color: AppColors.white,
            ),
          ],
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

  /// 토스 스타일 상품 선택 버튼 (우상단)
  Widget _buildCompactProductSelector() {
    if (_fullGame == null ||
        _fullGame!.gameProducts == null ||
        _fullGame!.gameProducts!.isEmpty) {
      return const SizedBox.shrink();
    }

    final productCount = _fullGame!.gameProducts!.length;
    final selectedProduct = _fullGame!.gameProducts![_selectedProductIndex];

    return GestureDetector(
      onTap: _showProductSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            // 상품 썸네일
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 32,
                height: 32,
                color: AppColors.gray100,
                child: selectedProduct.product.defaultImage != null
                    ? Image.network(
                        selectedProduct.product.defaultImage!.replaceAll(' ', '%20'),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2_outlined,
                            size: 16,
                            color: AppColors.gray400,
                          );
                        },
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        size: 16,
                        color: AppColors.gray400,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // 선택 인덱스
            Text(
              '${_selectedProductIndex + 1}/$productCount',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(width: 4),
            // 변경 아이콘
            Icon(
              Icons.swap_horiz_rounded,
              size: 18,
              color: AppColors.gray500,
            ),
          ],
        ),
      ),
    );
  }
}

/// 테크 패턴 페인터 (배경용)
class _TechPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42); // 고정 시드로 일관된 패턴

    // 메인 라인용 페인트 (두껍고 선명)
    final mainPaint = Paint()
      ..color = const Color(0xFF00ffff).withValues(alpha: 0.15)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2);

    // 보조 라인용 페인트 (얇고 흐림)
    final subPaint = Paint()
      ..color = const Color(0xFF4A90E2).withValues(alpha: 0.08)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // 강조 라인용 페인트 (밝고 굵음)
    final highlightPaint = Paint()
      ..color = const Color(0xFF00ffff).withValues(alpha: 0.25)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);

    // 1. 상단에서 아래로 내려오는 수직선들 (더 많이)
    for (int i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      final length = 60 + random.nextDouble() * 150;
      final thickness = random.nextDouble();

      final paint = thickness > 0.8
          ? highlightPaint
          : (thickness > 0.4 ? mainPaint : subPaint);

      canvas.drawLine(Offset(startX, 0), Offset(startX, length), paint);
    }

    // 2. 하단에서 위로 올라가는 수직선들
    for (int i = 0; i < 50; i++) {
      final startX = random.nextDouble() * size.width;
      final length = 60 + random.nextDouble() * 150;
      final thickness = random.nextDouble();

      final paint = thickness > 0.8
          ? highlightPaint
          : (thickness > 0.4 ? mainPaint : subPaint);

      canvas.drawLine(
        Offset(startX, size.height),
        Offset(startX, size.height - length),
        paint,
      );
    }

    // 3. 좌측에서 오른쪽으로 가는 수평선들
    for (int i = 0; i < 50; i++) {
      final startY = random.nextDouble() * size.height;
      final length = 60 + random.nextDouble() * 150;
      final thickness = random.nextDouble();

      final paint = thickness > 0.8
          ? highlightPaint
          : (thickness > 0.4 ? mainPaint : subPaint);

      canvas.drawLine(Offset(0, startY), Offset(length, startY), paint);
    }

    // 4. 우측에서 왼쪽으로 가는 수평선들
    for (int i = 0; i < 50; i++) {
      final startY = random.nextDouble() * size.height;
      final length = 60 + random.nextDouble() * 150;
      final thickness = random.nextDouble();

      final paint = thickness > 0.8
          ? highlightPaint
          : (thickness > 0.4 ? mainPaint : subPaint);

      canvas.drawLine(
        Offset(size.width, startY),
        Offset(size.width - length, startY),
        paint,
      );
    }

    // 5. L자 모양 패턴 (코너에서)
    for (int i = 0; i < 20; i++) {
      final isTopLeft = random.nextDouble() < 0.25;
      final isTopRight = random.nextDouble() < 0.5;
      final isBottomLeft = random.nextDouble() < 0.75;

      final length1 = 40 + random.nextDouble() * 80;
      final length2 = 40 + random.nextDouble() * 80;

      final path = Path();
      if (isTopLeft) {
        // 상단 왼쪽
        final startY = random.nextDouble() * (size.height * 0.3);
        path.moveTo(0, startY);
        path.lineTo(length1, startY);
        path.lineTo(length1, startY + length2);
      } else if (isTopRight) {
        // 상단 오른쪽
        final startY = random.nextDouble() * (size.height * 0.3);
        path.moveTo(size.width, startY);
        path.lineTo(size.width - length1, startY);
        path.lineTo(size.width - length1, startY + length2);
      } else if (isBottomLeft) {
        // 하단 왼쪽
        final startY =
            size.height * 0.7 + random.nextDouble() * (size.height * 0.3);
        path.moveTo(0, startY);
        path.lineTo(length1, startY);
        path.lineTo(length1, startY - length2);
      } else {
        // 하단 오른쪽
        final startY =
            size.height * 0.7 + random.nextDouble() * (size.height * 0.3);
        path.moveTo(size.width, startY);
        path.lineTo(size.width - length1, startY);
        path.lineTo(size.width - length1, startY - length2);
      }

      canvas.drawPath(path, mainPaint);
    }

    // 6. 대각선 패턴 (더 복잡한 느낌)
    for (int i = 0; i < 15; i++) {
      final fromTop = random.nextDouble() < 0.5;
      final fromLeft = random.nextDouble() < 0.5;

      final startX = fromLeft ? 0.0 : size.width;
      final startY = fromTop
          ? random.nextDouble() * (size.height * 0.3)
          : size.height * 0.7 + random.nextDouble() * (size.height * 0.3);

      final length = 50 + random.nextDouble() * 100;
      final angle =
          (random.nextDouble() * 60 - 30) * math.pi / 180; // -30도 ~ +30도

      final endX = startX + (fromLeft ? 1 : -1) * length * math.cos(angle);
      final endY = startY + (fromTop ? 1 : -1) * length * math.sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), subPaint);
    }

    // 7. 작은 사각형 테두리 (회로 느낌)
    for (int i = 0; i < 8; i++) {
      final isLeftSide = random.nextDouble() < 0.5;
      final rectX = isLeftSide
          ? random.nextDouble() * 100
          : size.width - random.nextDouble() * 100 - 20;
      final rectY = random.nextDouble() * size.height;
      final rectSize = 8 + random.nextDouble() * 12;

      canvas.drawRect(
        Rect.fromLTWH(rectX, rectY, rectSize, rectSize),
        subPaint,
      );
    }

    // 8. 점 패턴 (회로 노드처럼)
    for (int i = 0; i < 25; i++) {
      final isEdge = random.nextDouble() < 0.7;
      double dotX, dotY;

      if (isEdge) {
        final side = random.nextInt(4);
        switch (side) {
          case 0: // 상단
            dotX = random.nextDouble() * size.width;
            dotY = random.nextDouble() * 120;
            break;
          case 1: // 하단
            dotX = random.nextDouble() * size.width;
            dotY = size.height - random.nextDouble() * 120;
            break;
          case 2: // 좌측
            dotX = random.nextDouble() * 120;
            dotY = random.nextDouble() * size.height;
            break;
          default: // 우측
            dotX = size.width - random.nextDouble() * 120;
            dotY = random.nextDouble() * size.height;
        }
      } else {
        dotX = random.nextDouble() * size.width;
        dotY = random.nextDouble() * size.height;
      }

      final dotPaint = Paint()
        ..color = const Color(0xFF00ffff).withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

      canvas.drawCircle(Offset(dotX, dotY), 2, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 셰이더 기반 글로우 배경
class _GlowBackground extends StatefulWidget {
  final String shaderPath;

  const _GlowBackground({super.key, required this.shaderPath});

  @override
  State<_GlowBackground> createState() => _GlowBackgroundState();
}

class _GlowBackgroundState extends State<_GlowBackground>
    with SingleTickerProviderStateMixin {
  ui.FragmentShader? _shader;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _loadShader();
  }

  @override
  void didUpdateWidget(_GlowBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shaderPath != widget.shaderPath) {
      _loadShader();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _shader?.dispose();
    super.dispose();
  }

  Future<void> _loadShader() async {
    try {
      debugPrint('🔄 Loading shader: ${widget.shaderPath}');
      _shader?.dispose();
      final program = await ui.FragmentProgram.fromAsset(widget.shaderPath);
      if (mounted) {
        setState(() {
          _shader = program.fragmentShader();
        });
        debugPrint('✅ Shader loaded successfully: ${widget.shaderPath}');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ Failed to load shader: ${widget.shaderPath}');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_shader == null) {
      // 셰이더 로딩 중 fallback 배경
      return Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 0.8,
            colors: [
              Color(0xFF1a2332), // 중앙 - 어두운 파랑
              Color(0xFF0a0e17), // 가장자리 - 거의 검정
            ],
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _GlowPainter(_shader!, _controller.value),
          size: Size.infinite,
        );
      },
    );
  }
}

/// 셰이더를 사용한 글로우 페인터
class _GlowPainter extends CustomPainter {
  final ui.FragmentShader shader;
  final double time;

  _GlowPainter(this.shader, this.time);

  @override
  void paint(Canvas canvas, Size size) {
    // 셰이더 유니폼 설정
    shader.setFloat(0, size.width); // uSize.x
    shader.setFloat(1, size.height); // uSize.y
    shader.setFloat(2, time * 2.0 * math.pi); // uTime (0~2π)

    final paint = Paint()..shader = shader;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(_GlowPainter oldDelegate) => time != oldDelegate.time;
}
