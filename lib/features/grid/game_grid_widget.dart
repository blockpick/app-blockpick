import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'grid_painter.dart';
import '../../providers/grid_state_provider.dart';
import '../../models/block_model.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../utils/zoom_calculator.dart';

/// 게임 그리드 위젯
///
/// CustomPaint를 사용하여 대형 그리드를 렌더링하고
/// 제스처를 처리합니다.
class GameGridWidget extends ConsumerStatefulWidget {
  /// 게임 ID (라운드별 상태 분리)
  final String gameId;

  /// 그리드 가로 크기
  final int gridWidth;

  /// 그리드 세로 크기
  final int gridHeight;

  /// 블록 클릭 콜백 (false 반환 시 블록 선택 취소)
  final bool Function(BlockModel)? onBlockTap;

  /// 배경 이미지 경로 (제품 이미지)
  final String? backgroundImagePath;

  /// 튜토리얼 목표 블록에 할당할 GlobalKey (튜토리얼 스포트라이트용)
  final GlobalKey? tutorialBlockKey;

  const GameGridWidget({
    super.key,
    required this.gameId,
    required this.gridWidth,
    required this.gridHeight,
    this.onBlockTap,
    this.backgroundImagePath,
    this.tutorialBlockKey,
  });

  @override
  ConsumerState<GameGridWidget> createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends ConsumerState<GameGridWidget>
    with SingleTickerProviderStateMixin {
  // 제스처 처리
  Offset? _initialFocalPoint;
  double? _initialZoom;
  bool _isDragging = false;

  // 애니메이션
  late AnimationController _animationController;

  // 배경 이미지
  ui.Image? _backgroundImage;
  bool _imageLoading = false;

  // GridConfig (동적 생성)
  GridConfig? _gridConfig;

  // 초기화 완료 플래그
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    debugPrint('🎮 GameGridWidget.initState():');
    debugPrint('   - gameId: ${widget.gameId}');
    debugPrint('   - backgroundImagePath: ${widget.backgroundImagePath}');
    debugPrint('   - gridWidth: ${widget.gridWidth}');
    debugPrint('   - gridHeight: ${widget.gridHeight}');

    _animationController = AnimationController(
      vsync: this,
      duration: AppConstants.animationZoom,
    );

    // 배경 이미지 로드
    if (widget.backgroundImagePath != null) {
      debugPrint('   ➡️ 배경 이미지 로드 시작');
      _loadBackgroundImage();
    } else {
      debugPrint('   ⚠️ backgroundImagePath가 null - 이미지 로드 안함');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // 이미 초기화되었으면 건너뛰기
    if (_initialized) return;

    // GridConfig 생성 (화면 크기 필요)
    final size = MediaQuery.of(context).size;
    final baseZoom = ZoomCalculator.calculateBaseZoom(
      gridWidth: widget.gridWidth,
      gridHeight: widget.gridHeight,
      screenWidth: size.width,
      screenHeight: size.height,
    );

    _gridConfig = GridConfig(
      gameId: widget.gameId,
      gridWidth: widget.gridWidth,
      gridHeight: widget.gridHeight,
      baseZoom: baseZoom,
    );

    _initialized = true;
    debugPrint('   📐 baseZoom 계산됨: $baseZoom');
  }

  @override
  void didUpdateWidget(GameGridWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    debugPrint('🔄 GameGridWidget.didUpdateWidget():');
    debugPrint('   - old backgroundImagePath: ${oldWidget.backgroundImagePath}');
    debugPrint('   - new backgroundImagePath: ${widget.backgroundImagePath}');

    // 배경 이미지가 변경되면 다시 로드
    if (widget.backgroundImagePath != oldWidget.backgroundImagePath) {
      debugPrint('   ⚡ 배경 이미지 변경 감지!');
      if (widget.backgroundImagePath != null) {
        debugPrint('   ➡️ 새 이미지 로드 시작');
        _loadBackgroundImage();
      } else {
        debugPrint('   ➡️ 이미지 제거');
        setState(() {
          _backgroundImage = null;
        });
      }
    } else {
      debugPrint('   ℹ️ 배경 이미지 변경 없음');
    }
  }

  /// 배경 이미지 로드
  Future<void> _loadBackgroundImage() async {
    if (_imageLoading) return;

    debugPrint('🖼️ Starting to load background image: ${widget.backgroundImagePath}');

    setState(() {
      _imageLoading = true;
    });

    try {
      final imagePath = widget.backgroundImagePath!;
      ByteData data;

      // URL인지 로컬 asset인지 확인
      if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
        // URL 인코딩 (공백 등 특수문자 처리)
        // replaceAll을 사용하여 공백과 특수문자를 직접 인코딩
        final encodedPath = imagePath.replaceAll(' ', '%20');
        debugPrint('🖼️ Loading network image: $imagePath');
        debugPrint('🖼️ Encoded URL: $encodedPath');
        // 네트워크 이미지 로드
        final NetworkImage networkImage = NetworkImage(encodedPath);
        final ImageStream stream = networkImage.resolve(const ImageConfiguration());
        final completer = Completer<ui.Image>();

        late ImageStreamListener listener;
        listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
          completer.complete(info.image);
          stream.removeListener(listener);
        }, onError: (dynamic exception, StackTrace? stackTrace) {
          completer.completeError(exception);
          stream.removeListener(listener);
        });

        stream.addListener(listener);
        final image = await completer.future;

        debugPrint('🖼️ Network image loaded: ${image.width}x${image.height}');

        if (mounted) {
          setState(() {
            _backgroundImage = image;
            _imageLoading = false;
          });
          debugPrint('✅ Background image loaded successfully');
        }
        return;
      } else {
        debugPrint('🖼️ Loading asset from rootBundle: $imagePath');
        data = await rootBundle.load(imagePath);
        debugPrint('🖼️ Asset loaded, size: ${data.lengthInBytes} bytes');

        final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
        final frame = await codec.getNextFrame();
        debugPrint('🖼️ Image decoded: ${frame.image.width}x${frame.image.height}');

        if (mounted) {
          setState(() {
            _backgroundImage = frame.image;
            _imageLoading = false;
          });
          debugPrint('✅ Background image loaded successfully');
        }
      }
    } catch (e) {
      debugPrint('❌ Failed to load background image: $e');
      debugPrint('   Stack trace: ${StackTrace.current}');
      if (mounted) {
        setState(() {
          _imageLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // GridConfig가 초기화되지 않았으면 로딩
    if (_gridConfig == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final gridState = ref.watch(gridStateProvider(_gridConfig!));
    final gridNotifier = ref.read(gridStateProvider(_gridConfig!).notifier);

    return LayoutBuilder(
      builder: (context, constraints) {
        // 뷰포트 크기를 GridStateNotifier에 전달 (pan/zoom 클램핑용)
        gridNotifier.setViewportSize(
          constraints.biggest.width,
          constraints.biggest.height,
        );

        return GestureDetector(
          // 탭 처리 (블록 선택)
          onTapUp: (details) => _handleTap(
            details.localPosition,
            constraints.biggest,
            gridState,
            gridNotifier,
          ),

          // 스케일 제스처 (핀치 투 줌 + 팬)
          onScaleStart: (details) => _handleScaleStart(details, gridState),
          onScaleUpdate: (details) =>
              _handleScaleUpdate(details, gridState, gridNotifier),
          onScaleEnd: (details) => _handleScaleEnd(gridNotifier),

          child: Stack(
            children: [
              // 그리드 렌더링
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(
                    gridWidth: widget.gridWidth,
                    gridHeight: widget.gridHeight,
                    zoom: gridState.zoom,
                    pan: Offset(gridState.panX, gridState.panY),
                    selectedBlocks: gridState.selectedBlocks,
                    wireframeMode: gridState.wireframeMode,
                    backgroundImage: _backgroundImage,
                  ),
                ),
              ),

              // 선택된 블록 위에 SVG 아이콘 오버레이
              ..._buildBlockIcons(gridState, constraints.biggest),

              // 구역 라벨 제거 (사용자 요청)
              // ..._buildRegionLabels(gridState, constraints.biggest),
            ],
          ),
        );
      },
    );
  }

  /// 선택된 블록 위에 SVG 아이콘 렌더링 (성능 최적화)
  List<Widget> _buildBlockIcons(GridState gridState, Size size) {
    final icons = <Widget>[];
    final cellSize = AppConstants.cellSize * gridState.zoom;

    // 🚀 성능 최적화: 셀이 너무 작으면 아이콘 렌더링 생략 (4px 이하)
    if (cellSize < 4.0) {
      return icons;
    }

    // 🐛 디버그: 선택된 블록들 확인
    if (gridState.selectedBlocks.isNotEmpty) {
      debugPrint('📌 선택된 블록 ${gridState.selectedBlocks.length}개:');
      for (var block in gridState.selectedBlocks) {
        debugPrint('   - ${block.id}: row=${block.row}, col=${block.col}');
      }
    }

    // 🎯 튜토리얼 목표 블록 렌더링 (가장 먼저, 다른 아이콘보다 위에)
    if (gridState.tutorialTargetBlock != null) {
      final block = gridState.tutorialTargetBlock!;
      final x = (block.col - 1) * cellSize + gridState.panX;
      final y = (block.row - 1) * cellSize + gridState.panY;

      // 화면 밖 블록은 렌더링하지 않음
      if (x + cellSize >= 0 && x <= size.width && y + cellSize >= 0 && y <= size.height) {
        // 튜토리얼 목표 블록 하이라이트 (스포트라이트 대상)
        icons.add(
          Positioned(
            left: x,
            top: y,
            width: cellSize,
            height: cellSize,
            child: Container(
              key: widget.tutorialBlockKey,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.blue,
                  width: 3.0,
                ),
                color: AppColors.blue.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blue.withValues(alpha: 0.6),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.touch_app_rounded,
                  size: cellSize * 0.5,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        );
      }
    }

    // 🎯 적응형 아이콘 크기: 배율이 작을수록 아이콘을 상대적으로 크게 표시
    // 하지만 인접 셀과 겹치지 않도록 최대 0.9 (90%)로 제한
    double iconScale;
    if (cellSize < 8.0) {
      // 매우 작은 셀 (4-8px): 90% 크기 (겹침 방지)
      iconScale = 0.9;
    } else if (cellSize < 12.0) {
      // 작은 셀 (8-12px): 90% 크기
      iconScale = 0.9;
    } else if (cellSize < 20.0) {
      // 중간 셀 (12-20px): 85% 크기
      iconScale = 0.85;
    } else if (cellSize < 30.0) {
      // 일반 셀 (20-30px): 80% 크기
      iconScale = 0.8;
    } else {
      // 큰 셀 (30px+): 75% 크기
      iconScale = 0.75;
    }

    for (final block in gridState.selectedBlocks) {
      final x = (block.col - 1) * cellSize + gridState.panX;
      final y = (block.row - 1) * cellSize + gridState.panY;

      // 화면 밖 블록은 렌더링하지 않음 (viewport culling)
      if (x + cellSize < 0 || x > size.width || y + cellSize < 0 || y > size.height) {
        continue;
      }

      // 블록 상태에 따른 SVG 경로 결정
      String iconPath;

      // 🎯 포커스된 블록이면 list-selected.svg 사용
      if (gridState.focusedBlockId == block.id) {
        iconPath = 'assets/icons/pick/list-selected.svg';
      } else {
        switch (block.state) {
          case BlockState.selected:
            iconPath = 'assets/icons/pick/selected.svg';
            break;
          case BlockState.past:
            iconPath = 'assets/icons/pick/past.svg';
            break;
          case BlockState.winner:
          case BlockState.unique:
          case BlockState.duplicate:
            iconPath = 'assets/icons/pick/selected.svg'; // 기본값
            break;
          default:
            iconPath = 'assets/icons/pick/selected.svg';
        }
      }

      // 아이콘 크기 계산 (적응형)
      final iconSize = cellSize * iconScale;
      // 아이콘을 셀 중앙에 배치하기 위한 오프셋 계산
      final iconOffset = (cellSize - iconSize) / 2;

      icons.add(
        Positioned(
          left: x + iconOffset,
          top: y + iconOffset,
          width: iconSize,
          height: iconSize,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(iconSize * 0.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.blue.withValues(alpha: 0.5),
                  blurRadius: iconSize * 0.4,
                  spreadRadius: iconSize * 0.1,
                ),
              ],
            ),
            child: SvgPicture.asset(
              iconPath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return icons;
  }

  /// LOD 레벨 계산 (동적, 줌에 따라 무한 증가)
  int _getLODLevel(double zoom) {
    if (zoom < 0.05) return 0;
    if (zoom < 0.1) return 1;
    if (zoom < 0.3) return 2;
    if (zoom < 0.6) return 3;
    if (zoom < 1.0) return 4;
    if (zoom < 2.0) return 5;
    if (zoom < 4.0) return 6;
    if (zoom < 8.0) return 7;
    if (zoom < 16.0) return 8;
    // 줌이 계속 커지면 레벨도 계속 증가
    return (math.log(zoom) / math.log(2)).floor() + 4;
  }

  /// 구역 분할 수 계산 (동적으로 증가)
  int _getRegionDivisions(int lodLevel) {
    switch (lodLevel) {
      case 0:
        return 3;  // 3x3 = 9
      case 1:
        return 3;  // 3x3 = 9
      case 2:
        return 4;  // 4x4 = 16
      case 3:
        return 6;  // 6x6 = 36
      case 4:
        return 8;  // 8x8 = 64
      case 5:
        return 12; // 12x12 = 144
      case 6:
        return 16; // 16x16 = 256
      case 7:
        return 24; // 24x24 = 576
      case 8:
        return 32; // 32x32 = 1024
      default:
        // L9+: 동적으로 계속 증가 (2의 지수로)
        if (lodLevel > 8) {
          return math.min(64, 32 + (lodLevel - 8) * 8);
        }
        return 0; // 구역 없음
    }
  }

  /// 블록의 구역 ID 계산 (각 LOD 레벨마다 독립적인 명명)
  String _getBlockRegionId(int row, int col, int lodLevel) {
    final divisions = _getRegionDivisions(lodLevel);
    if (divisions == 0) return '';

    // 현재 LOD 레벨에서 블록이 속한 구역 계산
    final regionWidth = widget.gridWidth / divisions;
    final regionHeight = widget.gridHeight / divisions;

    final regionRow = ((row - 1) / regionHeight).floor();
    final regionCol = ((col - 1) / regionWidth).floor();

    // 숫자 기반 명명 체계: R행C열
    // 예: R1C1, R1C2, R2C1, R2C2, ...
    return 'R${regionRow + 1}C${regionCol + 1}';
  }

  /// 선택된 블록의 구역 라벨 렌더링
  List<Widget> _buildRegionLabels(GridState gridState, Size size) {
    final labels = <Widget>[];
    final cellSize = AppConstants.cellSize * gridState.zoom;
    final lodLevel = _getLODLevel(gridState.zoom);

    final divisions = _getRegionDivisions(lodLevel);

    // 디버깅: 줌/LOD/구역 출력
    debugPrint('🎯 Region Labels: zoom=${gridState.zoom.toStringAsFixed(3)}, LOD=$lodLevel, divisions=$divisions');

    if (divisions == 0) return labels;

    // 각 선택된 블록마다 구역 라벨 표시
    final Map<String, List<BlockModel>> regionGroups = {};

    for (final block in gridState.selectedBlocks) {
      final regionId = _getBlockRegionId(block.row, block.col, lodLevel);
      debugPrint('   Block(${block.row},${block.col}) → Region: $regionId');

      if (regionId.isEmpty) continue;

      if (!regionGroups.containsKey(regionId)) {
        regionGroups[regionId] = [];
      }
      regionGroups[regionId]!.add(block);
    }

    // 구역 크기 계산
    final regionWidthInCells = widget.gridWidth / divisions;
    final regionHeightInCells = widget.gridHeight / divisions;

    // 각 구역의 좌상단 모서리에 라벨 표시
    for (final entry in regionGroups.entries) {
      final regionId = entry.key;
      final blocks = entry.value;

      // 첫 번째 블록을 기준으로 구역 인덱스 계산
      final firstBlock = blocks.first;
      final regionRow = ((firstBlock.row - 1) / regionHeightInCells).floor();
      final regionCol = ((firstBlock.col - 1) / regionWidthInCells).floor();

      // 구역의 좌상단 좌표
      final regionX = regionCol * regionWidthInCells * cellSize + gridState.panX;
      final regionY = regionRow * regionHeightInCells * cellSize + gridState.panY;

      // 라벨 크기 계산
      final fontSize = (cellSize * regionWidthInCells * 0.1).clamp(14.0, 24.0);

      labels.add(
        Positioned(
          left: regionX + 12,
          top: regionY + 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green500.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: AppColors.white, width: 2),
            ),
            child: Text(
              regionId,
              style: TextStyle(
                color: AppColors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      );
    }

    return labels;
  }

  /// 탭 처리 (블록 선택)
  void _handleTap(
    Offset position,
    Size size,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    // 드래그 중이었으면 탭 무시
    if (_isDragging) return;

    // 탭 위치를 그리드 좌표로 변환
    final cellSize = AppConstants.cellSize * gridState.zoom;
    final gridX = (position.dx - gridState.panX) / cellSize;
    final gridY = (position.dy - gridState.panY) / cellSize;

    final col = (gridX + 1).floor();
    final row = (gridY + 1).floor();

    // 그리드 범위 확인
    if (row >= 1 && row <= widget.gridHeight && col >= 1 && col <= widget.gridWidth) {
      final block = BlockModel.fromPosition(row, col, state: BlockState.selected);

      // 콜백 호출 (로그인 체크 등) — false 반환 시 블록 선택 안 함
      if (widget.onBlockTap != null && !widget.onBlockTap!(block)) {
        return;
      }

      // 블록 토글 (자동 줌인 제거 - 사용자가 원하는 줌 레벨에서 선택)
      gridNotifier.toggleBlock(block);
    }
  }


  /// 스케일 시작 (핀치 투 줌 + 팬)
  void _handleScaleStart(
    ScaleStartDetails details,
    GridState gridState,
  ) {
    _initialFocalPoint = details.focalPoint;
    _initialZoom = gridState.zoom;
    _isDragging = false;
    if (_gridConfig != null) {
      ref.read(gridStateProvider(_gridConfig!).notifier).setDragging(false);
    }
  }

  /// 스케일 업데이트
  void _handleScaleUpdate(
    ScaleUpdateDetails details,
    GridState gridState,
    GridStateNotifier gridNotifier,
  ) {
    if (_initialZoom != null && _initialFocalPoint != null) {
      // 스케일이 1이 아니면 핀치 줌
      if (details.scale != 1.0) {
        final newZoom = (_initialZoom! * details.scale).clamp(
          AppConstants.minZoom,
          AppConstants.maxZoom,
        );

        // focal point 기준으로 줌 (손가락 위치 기준)
        gridNotifier.zoomAtPoint(
          newZoom: newZoom,
          focalPointX: details.focalPoint.dx,
          focalPointY: details.focalPoint.dy,
        );
      } else {
        // 줌이 없고 팬만 있는 경우 (한 손가락 드래그)
        final delta = details.focalPoint - _initialFocalPoint!;

        // 드래그 임계값 확인
        if (delta.distance > AppConstants.dragThreshold) {
          _isDragging = true;
          gridNotifier.setDragging(true);
        }

        gridNotifier.addPan(delta.dx, delta.dy);
      }

      _initialFocalPoint = details.focalPoint;
    }
  }

  /// 스케일 종료
  void _handleScaleEnd(GridStateNotifier gridNotifier) {
    _initialFocalPoint = null;
    _initialZoom = null;
    gridNotifier.setDragging(false);

    // 약간의 지연 후 드래깅 상태 초기화 (탭 무시를 위해)
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isDragging = false;
        });
      }
    });
  }
}
