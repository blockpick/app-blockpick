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
  final GlobalKey _tutorialBlockKey = GlobalKey();

  // 상품 선택 (SELECT 게임용)
  int _selectedProductIndex = 0;

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

  /// 선택 수량 배지 (왼쪽 상단) - 글래스 스타일 + 진행 도트
  Widget _buildSelectionBadge(int selected, int max) {
    final isComplete = selected >= max;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.textBlack.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.2),
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
                      ? AppColors.green.withValues(alpha: 0.3)
                      : AppColors.blue.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : Icons.touch_app_rounded,
                  size: 14,
                  color: isComplete ? AppColors.green : Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              // 카운트
              Text(
                '$selected',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isComplete ? AppColors.green : Colors.white,
                ),
              ),
              Text(
                '/$max',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // 진행 도트 (●●●○○)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(max, (index) {
            final isFilled = index < selected;
            return Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isComplete
                    ? AppColors.green
                    : (isFilled ? AppColors.blue : AppColors.gray300),
              ),
            );
          }),
        ),
      ],
    );
  }

  /// 안내 바 (인스트럭션) - 상단 중앙
  Widget _buildInstructionBar(int selected, int max) {
    String text;
    IconData? icon;

    if (selected == 0) {
      text = '원하는 블록 ${max}개를 선택하세요';
      icon = Icons.touch_app_rounded;
    } else if (selected < max) {
      text = '$selected/${max}개 선택됨 — 더 선택해주세요';
      icon = null;
    } else {
      text = '선택 완료! 참가하기를 눌러주세요';
      icon = Icons.check_circle_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textBlack.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.9)),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.9),
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

          // 바텀시트는 showModalBottomSheet로 표시

          // 안내 바 (상단 중앙)
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Center(
              child: _buildInstructionBar(selectedCount, _pickMax),
            ),
          ),

          // 선택 수량 배지 (왼쪽 상단, 안내 바 아래) - 탭하면 바텀시트 열림
          Positioned(
            top: 56,
            left: 16,
            child: GestureDetector(
              onTap: selectedCount > 0 ? _showSelectedBlocksModal : null,
              child: _buildSelectionBadge(selectedCount, _pickMax),
            ),
          ),

          // 상품 선택 버튼 (우상단, 안내 바 아래) - SELECT 게임인 경우
          if (_fullGame != null &&
              _fullGame!.gameType?.toUpperCase() == 'SELECT' &&
              _fullGame!.gameProducts != null &&
              _fullGame!.gameProducts!.isNotEmpty)
            Positioned(
              top: 56,
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

  /// FAB - 선택 미완료 시 "N개 선택됨", 완료 시 "참가하기"
  Widget _buildSelectionFAB(int selected, int max) {
    final isComplete = selected >= max;

    return GestureDetector(
      onTap: _showSelectedBlocksModal,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          gradient: isComplete
              ? const LinearGradient(
                  colors: [AppColors.mint, AppColors.mint],
                )
              : null,
          color: isComplete ? null : AppColors.textBlack.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: isComplete
                  ? AppColors.green.withValues(alpha: 0.4)
                  : AppColors.black.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: isComplete
              ? [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '참가하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ]
              : [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '$selected개 선택됨',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    size: 20,
                    color: Colors.white,
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

  /// 상품 선택 버튼 (우상단) - 글래스 스타일 + 상품명
  Widget _buildCompactProductSelector() {
    if (_fullGame == null ||
        _fullGame!.gameProducts == null ||
        _fullGame!.gameProducts!.isEmpty) {
      return const SizedBox.shrink();
    }

    final productCount = _fullGame!.gameProducts!.length;
    final selectedProduct = _fullGame!.gameProducts![_selectedProductIndex];
    final productName = selectedProduct.product.name ?? '';

    return GestureDetector(
      onTap: _showProductSelector,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.textBlack.withValues(alpha: 0.75),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 상품 썸네일 (40x40)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 40,
                height: 40,
                color: Colors.white.withValues(alpha: 0.1),
                child: selectedProduct.product.defaultImage != null
                    ? Image.network(
                        selectedProduct.product.defaultImage!.replaceAll(' ', '%20'),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.inventory_2_outlined,
                            size: 20,
                            color: Colors.white54,
                          );
                        },
                      )
                    : const Icon(
                        Icons.inventory_2_outlined,
                        size: 20,
                        color: Colors.white54,
                      ),
              ),
            ),
            const SizedBox(width: 8),
            // 상품명 + 인덱스
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (productName.isNotEmpty)
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 72),
                    child: Text(
                      productName,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Text(
                  '${_selectedProductIndex + 1}/$productCount',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            // 변경 아이콘
            Icon(
              Icons.swap_horiz_rounded,
              size: 18,
              color: Colors.white.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
}

