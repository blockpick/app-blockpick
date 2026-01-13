import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/game_canvas.dart';

/// 좌표 선택 시 효과 타입
enum HighlightEffect {
  // 기존 효과
  ping('🎯 핑', '원형 파동이 퍼지는 효과'),
  glow('✨ 강조', '해당 위치가 빛나며 깜빡임'),
  crosshair('🔍 크로스헤어', 'ROW/COL 라인이 이동'),
  marker('📍 마커', '좌표에 마커가 계속 표시'),
  zoom('🗺️ 미니맵', '해당 영역이 확대 표시'),
  // 블록 스타일 효과
  blockWave('🧱 블록파동', '사각형 블록이 퍼져나감'),
  pixelBurst('💥 픽셀폭발', '블록이 사방으로 튀어나감'),
  hitbox('🎯 히트박스', '당첨 범위를 블록으로 표시'),
  blockDrill('⛏️ 드릴', '위에서 블록을 파내려감'),
  gridCapture('🏁 그리드점령', '블록이 순차 점등'),
  cube3d('📦 3D큐브', '회전하는 3D 큐브'),
  blockScan('📡 스캔', '블록 단위 스캔 라인');

  final String label;
  final String description;
  const HighlightEffect(this.label, this.description);
}

/// Treasure Hunt - 보물찾기 스타일 게임
/// 100x100 그리드에 랜덤으로 보물이 숨겨져 있음
/// 사용자가 선택한 좌표가 보물 위치면 특별 보상!
class TreasurePickScreen extends StatefulWidget {
  const TreasurePickScreen({super.key});

  @override
  State<TreasurePickScreen> createState() => _TreasurePickScreenState();
}

class _TreasurePickScreenState extends State<TreasurePickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = Color(0xFFFFD700); // Gold
  static const Color accentColor = Color(0xFFFF6B35); // Orange accent
  static const int gridSize = 100; // 100x100 그리드
  static const int treasureCount = 15; // 숨겨진 보물 개수

  // 보물 위치들 (Set으로 중복 방지)
  late Set<int> _treasurePositions;

  late AnimationController _rowController;
  late AnimationController _colController;
  late AnimationController _glowController;
  late AnimationController _radarController;
  late AnimationController _digController;
  late AnimationController _celebrationController;

  late Animation<double> _glowAnimation;
  late Animation<double> _radarAnimation;

  // 0: ROW 선택 중, 1: COL 선택 중, 2: 발굴 중, 3: 결과 표시
  int _phase = 0;
  double _fixedRow = 0.5;
  double _fixedCol = 0.5;

  bool _isDigging = false;
  bool? _foundTreasure;

  // === 개발자 테스트 옵션들 ===
  bool _showDevPanel = false; // 개발자 패널 표시 여부

  // 효과 설정
  HighlightEffect _selectedEffect = HighlightEffect.ping;

  // 선택된 좌표 (효과 표시용)
  (int, int)? _highlightedCoord;
  final List<(int, int)> _markedCoords = []; // 마커 효과용 (여러 개)

  // 속도 설정 (밀리초)
  double _rowSpeed = 2500;
  double _colSpeed = 2500;

  // 보물 크기 설정 (히트박스 크기: 1=1x1, 3=3x3, 5=5x5, 10=10x10)
  int _treasureSize = 1;

  // 효과용 애니메이션
  late AnimationController _highlightController;
  late AnimationController _crosshairMoveController;
  double? _targetRowPos;
  double? _targetColPos;

  // 파티클 시스템
  List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _generateTreasures();

    // ROW 선택 애니메이션
    _rowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);

    // COL 선택 애니메이션
    _colController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    // 글로우 펄스 애니메이션
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // 레이더 스캔 애니메이션
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _radarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _radarController, curve: Curves.linear));

    // 발굴 애니메이션
    _digController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // 축하 애니메이션
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 하이라이트 효과 애니메이션
    _highlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    // 크로스헤어 이동 애니메이션
    _crosshairMoveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  // 속도 변경 시 애니메이션 컨트롤러 업데이트
  void _updateRowSpeed(double speed) {
    setState(() {
      _rowSpeed = speed;
    });
    if (_phase == 0) {
      _rowController.duration = Duration(milliseconds: speed.round());
      _rowController.repeat(reverse: true);
    }
  }

  void _updateColSpeed(double speed) {
    setState(() {
      _colSpeed = speed;
    });
    if (_phase == 1) {
      _colController.duration = Duration(milliseconds: speed.round());
      _colController.repeat(reverse: true);
    }
  }

  // 좌표 선택 시 효과 트리거
  void _onCoordinateTap(int row, int col) {
    HapticFeedback.mediumImpact();

    switch (_selectedEffect) {
      case HighlightEffect.ping:
      case HighlightEffect.glow:
      case HighlightEffect.zoom:
      case HighlightEffect.blockWave:
      case HighlightEffect.pixelBurst:
      case HighlightEffect.hitbox:
      case HighlightEffect.blockDrill:
      case HighlightEffect.gridCapture:
      case HighlightEffect.cube3d:
      case HighlightEffect.blockScan:
        setState(() {
          _highlightedCoord = (row, col);
        });
        _highlightController.forward(from: 0).then((_) {
          if (mounted) {
            setState(() {
              _highlightedCoord = null;
            });
          }
        });
        break;

      case HighlightEffect.crosshair:
        setState(() {
          _targetRowPos = (row - 0.5) / gridSize;
          _targetColPos = (col - 0.5) / gridSize;
        });
        _crosshairMoveController.forward(from: 0).then((_) {
          Future.delayed(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _targetRowPos = null;
                _targetColPos = null;
              });
            }
          });
        });
        break;

      case HighlightEffect.marker:
        setState(() {
          final coord = (row, col);
          if (_markedCoords.contains(coord)) {
            _markedCoords.remove(coord);
          } else {
            _markedCoords.add(coord);
          }
        });
        break;
    }
  }

  void _generateTreasures() {
    final random = Random();
    _treasurePositions = {};
    while (_treasurePositions.length < treasureCount) {
      final row = random.nextInt(gridSize) + 1;
      final col = random.nextInt(gridSize) + 1;
      _treasurePositions.add(row * 1000 + col); // 고유 키로 저장
    }
  }

  /// 선택한 좌표가 보물의 히트박스 범위 안에 있는지 확인
  bool _checkTreasureInRange(int selectedRow, int selectedCol) {
    final halfSize = _treasureSize ~/ 2;

    for (final treasureKey in _treasurePositions) {
      final treasureRow = treasureKey ~/ 1000;
      final treasureCol = treasureKey % 1000;

      // 보물 중심에서 히트박스 범위 계산
      final minRow = treasureRow - halfSize;
      final maxRow = treasureRow + halfSize;
      final minCol = treasureCol - halfSize;
      final maxCol = treasureCol + halfSize;

      // 선택한 좌표가 히트박스 범위 안에 있는지 확인
      if (selectedRow >= minRow &&
          selectedRow <= maxRow &&
          selectedCol >= minCol &&
          selectedCol <= maxCol) {
        return true;
      }
    }
    return false;
  }

  // === 테스트 메서드들 ===
  /// 당첨 테스트: 보물 좌표 중 하나를 선택하여 당첨 결과 테스트
  void _testWin() {
    if (_treasurePositions.isEmpty) return;

    // 보물 좌표 중 첫 번째를 선택
    final treasureKey = _treasurePositions.first;
    final row = treasureKey ~/ 1000;
    final col = treasureKey % 1000;

    // 해당 좌표로 직접 설정하고 발굴 시작
    setState(() {
      _fixedRow = (row - 0.5) / gridSize;
      _fixedCol = (col - 0.5) / gridSize;
      _phase = 2;
      _isDigging = true;
    });

    _rowController.stop();
    _colController.stop();
    _startDigging();
  }

  /// 꽝 테스트: 보물이 없는 좌표를 선택하여 꽝 결과 테스트
  void _testLose() {
    // 보물이 없는 좌표 찾기
    int row = 1;
    int col = 1;

    // 보물이 없는 좌표를 찾을 때까지 반복
    for (int r = 1; r <= gridSize; r++) {
      for (int c = 1; c <= gridSize; c++) {
        final key = r * 1000 + c;
        if (!_treasurePositions.contains(key)) {
          row = r;
          col = c;
          break;
        }
      }
      if (row > 1 || col > 1) break;
    }

    // 해당 좌표로 직접 설정하고 발굴 시작
    setState(() {
      _fixedRow = (row - 0.5) / gridSize;
      _fixedCol = (col - 0.5) / gridSize;
      _phase = 2;
      _isDigging = true;
    });

    _rowController.stop();
    _colController.stop();
    _startDigging();
  }

  @override
  void dispose() {
    _rowController.dispose();
    _colController.dispose();
    _glowController.dispose();
    _radarController.dispose();
    _digController.dispose();
    _celebrationController.dispose();
    _highlightController.dispose();
    _crosshairMoveController.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    HapticFeedback.heavyImpact();

    if (_phase == 0) {
      // ROW 고정
      setState(() {
        _fixedRow = _rowController.value;
        _phase = 1;
      });
      _rowController.stop();
      _colController.repeat(reverse: true);
    } else if (_phase == 1) {
      // COL 고정 → 발굴 시작
      setState(() {
        _fixedCol = _colController.value;
        _phase = 2;
        _isDigging = true;
      });
      _colController.stop();
      _startDigging();
    }
  }

  void _startDigging() {
    _digController.forward().then((_) {
      // 보물 확인
      final row = (_fixedRow * gridSize).round().clamp(1, gridSize);
      final col = (_fixedCol * gridSize).round().clamp(1, gridSize);

      // 히트박스 범위 내에 보물이 있는지 확인
      final found = _checkTreasureInRange(row, col);

      setState(() {
        _foundTreasure = found;
        _phase = 3;
      });

      if (found) {
        HapticFeedback.heavyImpact();
        _celebrationController.forward();
        _spawnCelebrationParticles();
      } else {
        HapticFeedback.lightImpact();
      }

      Future.delayed(const Duration(milliseconds: 800), () {
        _showResultDialog();
      });
    });
  }

  void _spawnCelebrationParticles() {
    final random = Random();
    setState(() {
      _particles = List.generate(50, (index) {
        return _Particle(
          x: 0.5,
          y: 0.5,
          vx: (random.nextDouble() - 0.5) * 0.03,
          vy: (random.nextDouble() - 0.5) * 0.03,
          life: 1.0,
          decay: 0.008 + random.nextDouble() * 0.01,
          color: [
            modeColor,
            Colors.orange,
            Colors.yellow,
            Colors.white,
          ][random.nextInt(4)],
          size: 4 + random.nextDouble() * 8,
        );
      });
    });
    _animateParticles();
  }

  void _animateParticles() {
    if (_particles.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 16), () {
      if (!mounted) return;
      setState(() {
        _particles = _particles.where((p) {
          p.x += p.vx;
          p.y += p.vy;
          p.vy += 0.001; // 중력
          p.life -= p.decay;
          return p.life > 0;
        }).toList();
      });
      if (_particles.isNotEmpty) {
        _animateParticles();
      }
    });
  }

  void _showResultDialog() {
    final row = (_fixedRow * gridSize).round().clamp(1, gridSize);
    final col = (_fixedCol * gridSize).round().clamp(1, gridSize);

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      transitionDuration: const Duration(milliseconds: 500),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.elasticOut),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return _TreasureResultDialog(
          row: row,
          col: col,
          foundTreasure: _foundTreasure!,
          onRetry: () {
            Navigator.of(context).pop();
            _reset();
          },
          onClose: () {
            Navigator.of(context).pop();
            Navigator.of(this.context).pop();
          },
        );
      },
    );
  }

  void _reset() {
    HapticFeedback.mediumImpact();
    _generateTreasures(); // 새로운 보물 위치 생성
    setState(() {
      _phase = 0;
      _fixedRow = 0.5;
      _fixedCol = 0.5;
      _isDigging = false;
      _foundTreasure = null;
      _particles = [];
    });
    _digController.reset();
    _celebrationController.reset();
    _colController.stop();
    _colController.reset();
    _rowController.repeat(reverse: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: const Color(0xFF0D1117),
      appBar: GameAppBar(
        title: 'TREASURE',
        emoji: '💎',
        accentColor: modeColor,
        actions: [
          if (_phase > 0 && _phase < 3)
            GestureDetector(
              onTap: _reset,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 6),
                    Text(
                      'RESET',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _rowController,
          _colController,
          _glowAnimation,
          _radarAnimation,
          _digController,
          _celebrationController,
          _highlightController,
          _crosshairMoveController,
        ]),
        builder: (context, _) {
          final currentRow = _phase == 0
              ? (_rowController.value * gridSize).round().clamp(1, gridSize)
              : (_fixedRow * gridSize).round().clamp(1, gridSize);
          final currentCol = _phase < 1
              ? null
              : _phase == 1
              ? (_colController.value * gridSize).round().clamp(1, gridSize)
              : (_fixedCol * gridSize).round().clamp(1, gridSize);

          return GameCanvas(
            accentColor: modeColor,
            showCoordinate: false, // 자체 UI 사용
            currentRow: currentRow,
            currentCol: currentCol ?? 0,
            child: Stack(
              children: [
                // 배경
                CustomPaint(
                  size: Size.infinite,
                  painter: _TreasureBackgroundPainter(
                    color: modeColor,
                    glowValue: _glowAnimation.value,
                    radarValue: _radarAnimation.value,
                  ),
                ),

                // 메인 게임 영역
                SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 16,
                          right: 16,
                          bottom: 8,
                        ),
                        child: _buildLiveCoordinate(),
                      ),
                      // 1줄: 단계 인디케이터 + 개발자 설정 버튼
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Expanded(child: _buildPhaseIndicator()),
                            const SizedBox(width: 8),
                            // 개발자 설정 버튼
                            GestureDetector(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                setState(() {
                                  _showDevPanel = !_showDevPanel;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: _showDevPanel
                                      ? modeColor.withValues(alpha: 0.3)
                                      : Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _showDevPanel
                                        ? modeColor
                                        : Colors.white.withValues(alpha: 0.2),
                                  ),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  color: _showDevPanel
                                      ? modeColor
                                      : Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 개발자 설정 패널 (고정 높이)
                      if (_showDevPanel) _buildDevPanel(),

                      // 보물 위치 리스트 (고정 높이, 가로 스크롤)
                      _buildTreasureListBar(),

                      const SizedBox(height: 8),

                      // 게임 캔버스
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                modeColor.withValues(alpha: 0.15),
                                const Color(0xFF1A1A2E).withValues(alpha: 0.9),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: modeColor.withValues(alpha: 0.5),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: modeColor.withValues(alpha: 0.3),
                                blurRadius: 25,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(21),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: [
                                    // 그리드 배경
                                    CustomPaint(
                                      size: Size(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      ),
                                      painter: _TreasureGridPainter(
                                        color: modeColor,
                                        glowValue: _glowAnimation.value,
                                      ),
                                    ),

                                    // 레이더 스캔 효과
                                    if (_phase < 2)
                                      CustomPaint(
                                        size: Size(
                                          constraints.maxWidth,
                                          constraints.maxHeight,
                                        ),
                                        painter: _RadarScanPainter(
                                          progress: _radarAnimation.value,
                                          color: modeColor,
                                        ),
                                      ),

                                    // 보물 힌트 (깜빡이는 효과)
                                    CustomPaint(
                                      size: Size(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      ),
                                      painter: _TreasureHintPainter(
                                        treasures: _treasurePositions,
                                        gridSize: gridSize,
                                        glowValue: _glowAnimation.value,
                                        showHints: _phase < 2,
                                      ),
                                    ),

                                    // 크로스헤어 / 선택 지점
                                    CustomPaint(
                                      size: Size(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      ),
                                      painter: _TreasureCrosshairPainter(
                                        phase: _phase,
                                        rowPos: _phase == 0
                                            ? _rowController.value
                                            : _fixedRow,
                                        colPos: _phase >= 1
                                            ? (_phase == 1
                                                  ? _colController.value
                                                  : _fixedCol)
                                            : 0.5,
                                        color: modeColor,
                                        glowValue: _glowAnimation.value,
                                        digProgress: _digController.value,
                                        isDigging: _isDigging,
                                        foundTreasure: _foundTreasure,
                                        celebrationProgress:
                                            _celebrationController.value,
                                        // 크로스헤어 이동 효과용
                                        targetRowPos: _targetRowPos,
                                        targetColPos: _targetColPos,
                                        crosshairMoveProgress:
                                            _crosshairMoveController.value,
                                      ),
                                    ),

                                    // 하이라이트 효과 (좌표 선택 시)
                                    CustomPaint(
                                      size: Size(
                                        constraints.maxWidth,
                                        constraints.maxHeight,
                                      ),
                                      painter: _HighlightEffectPainter(
                                        effect: _selectedEffect,
                                        highlightedCoord: _highlightedCoord,
                                        markedCoords: _markedCoords,
                                        gridSize: gridSize,
                                        treasureSize: _treasureSize,
                                        progress: _highlightController.value,
                                        glowValue: _glowAnimation.value,
                                      ),
                                    ),

                                    // 파티클 효과
                                    if (_particles.isNotEmpty)
                                      CustomPaint(
                                        size: Size(
                                          constraints.maxWidth,
                                          constraints.maxHeight,
                                        ),
                                        painter: _ParticlePainter(
                                          particles: _particles,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // 하단 컨트롤
                      _buildBottomPanel(),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhaseIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildPhaseChip(0, 'ROW', Icons.swap_vert_rounded),
        const SizedBox(width: 10),
        Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: 18,
        ),
        const SizedBox(width: 10),
        _buildPhaseChip(1, 'COL', Icons.swap_horiz_rounded),
        const SizedBox(width: 10),
        Icon(
          Icons.arrow_forward_rounded,
          color: Colors.white.withValues(alpha: 0.3),
          size: 18,
        ),
        const SizedBox(width: 10),
        _buildPhaseChip(2, 'DIG!', Icons.explore_rounded),
      ],
    );
  }

  Widget _buildPhaseChip(int phaseNum, String label, IconData icon) {
    final isActive = _phase == phaseNum;
    final isDone = _phase > phaseNum;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  modeColor.withValues(alpha: 0.4),
                  accentColor.withValues(alpha: 0.3),
                ],
              )
            : null,
        color: isActive
            ? null
            : isDone
            ? modeColor.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? modeColor
              : isDone
              ? modeColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isActive ? 2 : 1,
        ),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: modeColor.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : icon,
            size: 16,
            color: isActive
                ? Colors.white
                : isDone
                ? modeColor
                : Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : isDone
                  ? modeColor
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  /// 좌표 행 위젯 빌더
  Widget _buildCoordRow(String label, String value, bool isActive) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label:',
          style: TextStyle(
            color: isActive ? modeColor : Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  /// 실시간 좌표 표시 위젯
  Widget _buildLiveCoordinate() {
    // 현재 애니메이션 값에서 좌표 계산
    final currentRowValue = _phase == 0 ? _rowController.value : _fixedRow;
    final currentColValue = _phase == 1
        ? _colController.value
        : (_phase > 1 ? _fixedCol : 0.5);

    final currentRow = (currentRowValue * gridSize).round().clamp(1, gridSize);
    final currentCol = (currentColValue * gridSize).round().clamp(1, gridSize);

    return AnimatedBuilder(
      animation: _phase == 0
          ? _rowController
          : (_phase == 1 ? _colController : _glowController),
      builder: (context, child) {
        final row = _phase == 0
            ? (_rowController.value * gridSize).round().clamp(1, gridSize)
            : currentRow;
        final col = _phase == 1
            ? (_colController.value * gridSize).round().clamp(1, gridSize)
            : currentCol;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: modeColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 섹션 헤더
              Text(
                '실시간좌표',
                style: TextStyle(
                  color: modeColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
              // ROW
              _buildCoordRow('R', row.toString().padLeft(2, '0'), _phase == 0),
              const SizedBox(width: 20),
              // COL
              _buildCoordRow(
                'C',
                _phase >= 1 ? col.toString().padLeft(2, '0') : '--',
                _phase == 1,
              ),
              const SizedBox(width: 20),
              // DIGI
              _buildCoordRow('D', _phase >= 2 ? '!' : '--', _phase == 2),
            ],
          ),
        );
      },
    );
  }

  // === 개발자 설정 패널 ===
  Widget _buildDevPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 효과 선택
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.cyan, size: 16),
              const SizedBox(width: 8),
              Text(
                '효과 선택',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: HighlightEffect.values.map((effect) {
              final isSelected = _selectedEffect == effect;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedEffect = effect;
                    _markedCoords.clear(); // 마커 초기화
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.cyan.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.cyan
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    effect.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 11,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // 속도 조절
          Row(
            children: [
              Icon(Icons.speed, color: Colors.orange, size: 16),
              const SizedBox(width: 8),
              Text(
                '속도 조절',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // ROW 속도
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  'ROW',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.cyan,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.cyan,
                    overlayColor: Colors.cyan.withValues(alpha: 0.2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: _rowSpeed,
                    min: 500,
                    max: 5000,
                    onChanged: _updateRowSpeed,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${(_rowSpeed / 1000).toStringAsFixed(1)}s',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          // COL 속도
          Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  'COL',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    activeTrackColor: Colors.orange,
                    inactiveTrackColor: Colors.white24,
                    thumbColor: Colors.orange,
                    overlayColor: Colors.orange.withValues(alpha: 0.2),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                  ),
                  child: Slider(
                    value: _colSpeed,
                    min: 500,
                    max: 5000,
                    onChanged: _updateColSpeed,
                  ),
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  '${(_colSpeed / 1000).toStringAsFixed(1)}s',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          ),

          // 마커 초기화 버튼 (마커 모드일 때만)
          if (_selectedEffect == HighlightEffect.marker &&
              _markedCoords.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _markedCoords.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.red.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.clear_all, color: Colors.red, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '마커 전체 삭제 (${_markedCoords.length})',
                        style: TextStyle(color: Colors.red, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // 보물 크기 설정
          Row(
            children: [
              Icon(Icons.crop_square, color: Colors.amber, size: 16),
              const SizedBox(width: 8),
              Text(
                '보물 크기 (히트박스)',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [1, 3, 5, 10, 20].map((size) {
              final isSelected = _treasureSize == size;
              final probability =
                  (size * size * treasureCount / (gridSize * gridSize) * 100);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _treasureSize = size;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.amber.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? Colors.amber
                          : Colors.white.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$size×$size',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${probability.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: isSelected ? Colors.amber : Colors.white54,
                          fontSize: 9,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 12),

          // 결과 테스트
          Row(
            children: [
              Icon(Icons.science, color: Colors.pink, size: 16),
              const SizedBox(width: 8),
              Text(
                '결과 테스트',
                style: TextStyle(
                  color: Colors.pink,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              // 당첨 테스트
              Expanded(
                child: GestureDetector(
                  onTap: _testWin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.withValues(alpha: 0.3),
                          Colors.orange.withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('🎉', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '당첨 테스트',
                          style: TextStyle(
                            color: Colors.amber,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // 꽝 테스트
              Expanded(
                child: GestureDetector(
                  onTap: _testLose,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('💨', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '꽝 테스트',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // === 보물 위치 리스트 바 (고정 높이, 가로 스크롤) ===
  Widget _buildTreasureListBar() {
    final treasureList =
        _treasurePositions.map((posKey) {
          final row = posKey ~/ 1000;
          final col = posKey % 1000;
          return (row, col);
        }).toList()..sort(
          (a, b) => a.$1 != b.$1 ? a.$1.compareTo(b.$1) : a.$2.compareTo(b.$2),
        );

    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: modeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // 라벨
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: modeColor.withValues(alpha: 0.2),
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                const Text('💎', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  '$treasureCount',
                  style: TextStyle(
                    color: modeColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // 좌표 리스트 (가로 스크롤)
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: treasureList.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final pos = treasureList[index];
                final isMarked = _markedCoords.contains(pos);

                return GestureDetector(
                  onTap: () => _onCoordinateTap(pos.$1, pos.$2),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: isMarked
                            ? LinearGradient(
                                colors: [
                                  Colors.green.withValues(alpha: 0.4),
                                  Colors.teal.withValues(alpha: 0.3),
                                ],
                              )
                            : LinearGradient(
                                colors: [
                                  Colors.amber.withValues(alpha: 0.15),
                                  Colors.orange.withValues(alpha: 0.1),
                                ],
                              ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isMarked
                              ? Colors.green
                              : Colors.amber.withValues(alpha: 0.4),
                          width: isMarked ? 2 : 1,
                        ),
                      ),
                      child: Text(
                        '(${pos.$1}, ${pos.$2})',
                        style: TextStyle(
                          color: isMarked ? Colors.white : Colors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF1A1A2E).withValues(alpha: 0.7),
                const Color(0xFF0D1117).withValues(alpha: 0.95),
              ],
            ),
            border: Border(
              top: BorderSide(color: modeColor.withValues(alpha: 0.3)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상태 표시
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatChip(
                    Icons.grid_on_rounded,
                    'ROW: ${_phase >= 1 ? (_fixedRow * gridSize).round().clamp(1, gridSize) : "---"}',
                    _phase >= 1,
                  ),
                  const SizedBox(width: 16),
                  _buildStatChip(
                    Icons.grid_on_rounded,
                    'COL: ${_phase >= 2 ? (_fixedCol * gridSize).round().clamp(1, gridSize) : "---"}',
                    _phase >= 2,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 메인 버튼
              GestureDetector(
                onTap: _phase < 2 ? _onButtonPressed : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    gradient: _phase < 2
                        ? LinearGradient(colors: [modeColor, accentColor])
                        : LinearGradient(
                            colors: [
                              Colors.grey.shade700,
                              Colors.grey.shade800,
                            ],
                          ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _phase < 2
                        ? [
                            BoxShadow(
                              color: modeColor.withValues(alpha: 0.5),
                              blurRadius: 25,
                              offset: const Offset(0, 10),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _phase == 0
                            ? Icons.swap_vert_rounded
                            : _phase == 1
                            ? Icons.swap_horiz_rounded
                            : _phase == 2
                            ? Icons.hourglass_top_rounded
                            : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _phase == 0
                            ? 'LOCK ROW'
                            : _phase == 1
                            ? 'LOCK COL & DIG!'
                            : _phase == 2
                            ? 'DIGGING...'
                            : 'COMPLETE!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 안내 텍스트
              Text(
                _phase == 0
                    ? '버튼을 눌러 ROW 위치를 고정하세요'
                    : _phase == 1
                    ? '버튼을 눌러 COL 위치를 고정하고 발굴!'
                    : _phase == 2
                    ? '보물을 찾고 있어요...'
                    : '발굴 완료!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(IconData icon, String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isActive
            ? LinearGradient(
                colors: [
                  modeColor.withValues(alpha: 0.25),
                  accentColor.withValues(alpha: 0.15),
                ],
              )
            : null,
        color: isActive ? null : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive
              ? modeColor.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isActive ? modeColor : Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: isActive
                  ? Colors.white
                  : Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}

// ============ PAINTERS ============

class _TreasureBackgroundPainter extends CustomPainter {
  final Color color;
  final double glowValue;
  final double radarValue;

  _TreasureBackgroundPainter({
    required this.color,
    required this.glowValue,
    required this.radarValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 그라데이션
    final bgPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 1.5,
        colors: [
          color.withValues(alpha: 0.08 * glowValue),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 별 효과
    final starPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * glowValue)
      ..style = PaintingStyle.fill;

    final random = Random(42);
    for (int i = 0; i < 30; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height * 0.5;
      final starSize = 1 + random.nextDouble() * 2;
      canvas.drawCircle(Offset(x, y), starSize, starPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreasureBackgroundPainter oldDelegate) => true;
}

class _TreasureGridPainter extends CustomPainter {
  final Color color;
  final double glowValue;

  _TreasureGridPainter({required this.color, required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    // 10x10 그리드 라인
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 중앙 십자 강조
    final centerPaint = Paint()
      ..color = color.withValues(alpha: 0.2)
      ..strokeWidth = 1.5;

    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      centerPaint,
    );
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      centerPaint,
    );

    // 코너 장식
    final cornerSize = 30.0;
    final cornerPaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 좌상단
    canvas.drawLine(const Offset(8, 8), Offset(8, cornerSize), cornerPaint);
    canvas.drawLine(const Offset(8, 8), Offset(cornerSize, 8), cornerPaint);

    // 우상단
    canvas.drawLine(
      Offset(size.width - 8, 8),
      Offset(size.width - 8, cornerSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 8, 8),
      Offset(size.width - cornerSize, 8),
      cornerPaint,
    );

    // 좌하단
    canvas.drawLine(
      Offset(8, size.height - 8),
      Offset(8, size.height - cornerSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(8, size.height - 8),
      Offset(cornerSize, size.height - 8),
      cornerPaint,
    );

    // 우하단
    canvas.drawLine(
      Offset(size.width - 8, size.height - 8),
      Offset(size.width - 8, size.height - cornerSize),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(size.width - 8, size.height - 8),
      Offset(size.width - cornerSize, size.height - 8),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TreasureGridPainter oldDelegate) => true;
}

class _RadarScanPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RadarScanPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius =
        sqrt(size.width * size.width + size.height * size.height) / 2;
    final currentRadius = maxRadius * progress;

    // 스캔 링
    final scanPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.1),
          color.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 0.85, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: currentRadius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40;

    canvas.drawCircle(center, currentRadius, scanPaint);

    // 스캔 라인
    final angle = progress * 2 * pi;
    final linePaint = Paint()
      ..shader =
          LinearGradient(
            begin: Alignment.center,
            end: Alignment.centerRight,
            colors: [color.withValues(alpha: 0.5), Colors.transparent],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: maxRadius * 2,
              height: maxRadius * 2,
            ),
          )
      ..strokeWidth = 2;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawLine(Offset.zero, Offset(maxRadius, 0), linePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RadarScanPainter oldDelegate) => true;
}

class _TreasureHintPainter extends CustomPainter {
  final Set<int> treasures;
  final int gridSize;
  final double glowValue;
  final bool showHints;

  _TreasureHintPainter({
    required this.treasures,
    required this.gridSize,
    required this.glowValue,
    required this.showHints,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!showHints) return;

    final hintPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.15 * glowValue)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    for (final posKey in treasures) {
      final row = posKey ~/ 1000;
      final col = posKey % 1000;
      final x = (col - 0.5) / gridSize * size.width;
      final y = (row - 0.5) / gridSize * size.height;

      canvas.drawCircle(Offset(x, y), 8, hintPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TreasureHintPainter oldDelegate) => true;
}

class _TreasureCrosshairPainter extends CustomPainter {
  final int phase;
  final double rowPos;
  final double colPos;
  final Color color;
  final double glowValue;
  final double digProgress;
  final bool isDigging;
  final bool? foundTreasure;
  final double celebrationProgress;
  // 크로스헤어 이동 효과용
  final double? targetRowPos;
  final double? targetColPos;
  final double crosshairMoveProgress;

  _TreasureCrosshairPainter({
    required this.phase,
    required this.rowPos,
    required this.colPos,
    required this.color,
    required this.glowValue,
    required this.digProgress,
    required this.isDigging,
    required this.foundTreasure,
    required this.celebrationProgress,
    this.targetRowPos,
    this.targetColPos,
    this.crosshairMoveProgress = 0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 크로스헤어 이동 효과가 활성화된 경우
    if (targetRowPos != null &&
        targetColPos != null &&
        crosshairMoveProgress > 0) {
      _drawTargetCrosshair(canvas, size);
    }

    final y = rowPos * size.height;
    final x = colPos * size.width;

    // ROW 라인
    if (phase >= 0) {
      final isMoving = phase == 0;
      final lineColor = isMoving ? Colors.cyan : color;

      // 글로우
      final glowPaint = Paint()
        ..color = lineColor.withValues(
          alpha: 0.3 * (isMoving ? glowValue : 1.0),
        )
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);

      // 메인 라인
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: isMoving ? 0.8 : 1.0)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

      // 끝 마커
      _drawMarker(canvas, Offset(12, y), lineColor, isMoving);
      _drawMarker(canvas, Offset(size.width - 12, y), lineColor, isMoving);
    }

    // COL 라인
    if (phase >= 1) {
      final isMoving = phase == 1;
      final lineColor = isMoving ? Colors.orange : color;

      // 글로우
      final glowPaint = Paint()
        ..color = lineColor.withValues(
          alpha: 0.3 * (isMoving ? glowValue : 1.0),
        )
        ..strokeWidth = 20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowPaint);

      // 메인 라인
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: isMoving ? 0.8 : 1.0)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

      // 끝 마커
      _drawMarker(canvas, Offset(x, 12), lineColor, isMoving);
      _drawMarker(canvas, Offset(x, size.height - 12), lineColor, isMoving);
    }

    // 교차점
    if (phase >= 1) {
      final crossPoint = Offset(x, y);

      // 발굴 효과
      if (isDigging) {
        _drawDiggingEffect(canvas, crossPoint, digProgress);
      }

      // 결과 효과
      if (foundTreasure != null) {
        _drawResultEffect(
          canvas,
          crossPoint,
          foundTreasure!,
          celebrationProgress,
        );
      }

      // 기본 타겟 (발굴 전)
      if (!isDigging && foundTreasure == null) {
        // 큰 글로우
        final bigGlowPaint = Paint()
          ..color = color.withValues(alpha: 0.25 * glowValue)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);

        canvas.drawCircle(crossPoint, 35, bigGlowPaint);

        // 타겟 원들
        for (int i = 3; i >= 1; i--) {
          final ringPaint = Paint()
            ..color = color.withValues(alpha: 0.25 + (3 - i) * 0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

          canvas.drawCircle(crossPoint, 12.0 * i, ringPaint);
        }

        // 중앙 점
        final centerPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

        canvas.drawCircle(crossPoint, 5, centerPaint);
      }
    }
  }

  void _drawMarker(
    Canvas canvas,
    Offset position,
    Color markerColor,
    bool animate,
  ) {
    final markerSize = animate ? 7 + glowValue * 3 : 8.0;

    final paint = Paint()
      ..color = markerColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(position, markerSize / 2, paint);

    if (animate) {
      final glowPaint = Paint()
        ..color = markerColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(position, markerSize, glowPaint);
    }
  }

  void _drawDiggingEffect(Canvas canvas, Offset center, double progress) {
    // 진동 효과
    final shake = sin(progress * 20) * (1 - progress) * 5;

    // 파동 효과
    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress - i * 0.2).clamp(0.0, 1.0);
      if (waveProgress > 0) {
        final radius = 20 + waveProgress * 60;
        final alpha = (1 - waveProgress) * 0.5;

        final wavePaint = Paint()
          ..color = color.withValues(alpha: alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;

        canvas.drawCircle(
          Offset(center.dx + shake, center.dy),
          radius,
          wavePaint,
        );
      }
    }

    // 삽 아이콘 효과 (간단한 삼각형)
    final digY = center.dy - 30 + progress * 40;
    final shovelPaint = Paint()
      ..color = Colors.grey.shade400.withValues(alpha: 1 - progress * 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(center.dx, digY)
      ..lineTo(center.dx - 10, digY - 20)
      ..lineTo(center.dx + 10, digY - 20)
      ..close();

    canvas.drawPath(path, shovelPaint);
  }

  void _drawResultEffect(
    Canvas canvas,
    Offset center,
    bool found,
    double progress,
  ) {
    if (found) {
      // 보물 발견! 빛 폭발 효과
      final explosionRadius = 30 + progress * 100;

      // 외부 글로우
      final glowPaint = Paint()
        ..shader =
            RadialGradient(
              colors: [
                Colors.amber.withValues(alpha: (1 - progress) * 0.8),
                Colors.orange.withValues(alpha: (1 - progress) * 0.4),
                Colors.transparent,
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: explosionRadius),
            );

      canvas.drawCircle(center, explosionRadius, glowPaint);

      // 빛줄기
      final rayPaint = Paint()
        ..color = Colors.yellow.withValues(alpha: (1 - progress) * 0.6)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 12; i++) {
        final angle = i * pi / 6 + progress * pi;
        final innerRadius = 15.0;
        final outerRadius = 30 + progress * 80;

        canvas.drawLine(
          Offset(
            center.dx + cos(angle) * innerRadius,
            center.dy + sin(angle) * innerRadius,
          ),
          Offset(
            center.dx + cos(angle) * outerRadius,
            center.dy + sin(angle) * outerRadius,
          ),
          rayPaint,
        );
      }

      // 보석 아이콘
      _drawGem(canvas, center, 1 - progress * 0.3);
    } else {
      // 꽝 - 작은 X 표시
      final xSize = 20.0;
      final xPaint = Paint()
        ..color = Colors.grey.withValues(alpha: 0.6)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(center.dx - xSize / 2, center.dy - xSize / 2),
        Offset(center.dx + xSize / 2, center.dy + xSize / 2),
        xPaint,
      );
      canvas.drawLine(
        Offset(center.dx + xSize / 2, center.dy - xSize / 2),
        Offset(center.dx - xSize / 2, center.dy + xSize / 2),
        xPaint,
      );

      // 먼지 효과
      final dustPaint = Paint()
        ..color = Colors.brown.withValues(alpha: (1 - progress) * 0.3)
        ..style = PaintingStyle.fill;

      final random = Random(42);
      for (int i = 0; i < 8; i++) {
        final angle = random.nextDouble() * 2 * pi;
        final dist = 20 + progress * 40 * random.nextDouble();
        canvas.drawCircle(
          Offset(center.dx + cos(angle) * dist, center.dy + sin(angle) * dist),
          3 + random.nextDouble() * 3,
          dustPaint,
        );
      }
    }
  }

  void _drawGem(Canvas canvas, Offset center, double scale) {
    final gemPaint = Paint()
      ..shader =
          const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFF6B35)],
          ).createShader(
            Rect.fromCenter(
              center: center,
              width: 40 * scale,
              height: 40 * scale,
            ),
          );

    final path = Path()
      ..moveTo(center.dx, center.dy - 18 * scale)
      ..lineTo(center.dx + 15 * scale, center.dy - 5 * scale)
      ..lineTo(center.dx + 10 * scale, center.dy + 18 * scale)
      ..lineTo(center.dx - 10 * scale, center.dy + 18 * scale)
      ..lineTo(center.dx - 15 * scale, center.dy - 5 * scale)
      ..close();

    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawPath(path.shift(const Offset(3, 3)), shadowPaint);

    // 보석
    canvas.drawPath(path, gemPaint);

    // 하이라이트
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final highlightPath = Path()
      ..moveTo(center.dx - 5 * scale, center.dy - 10 * scale)
      ..lineTo(center.dx + 2 * scale, center.dy - 10 * scale)
      ..lineTo(center.dx - 2 * scale, center.dy)
      ..lineTo(center.dx - 8 * scale, center.dy)
      ..close();

    canvas.drawPath(highlightPath, highlightPaint);
  }

  void _drawTargetCrosshair(Canvas canvas, Size size) {
    final targetY = targetRowPos! * size.height;
    final targetX = targetColPos! * size.width;
    final progress = Curves.easeOutBack.transform(crosshairMoveProgress);

    // 보라색 크로스헤어
    final targetColor = Colors.purple;
    final alpha = (1 - crosshairMoveProgress * 0.3);

    // 글로우
    final glowPaint = Paint()
      ..color = targetColor.withValues(alpha: 0.4 * alpha)
      ..strokeWidth = 25
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawLine(Offset(0, targetY), Offset(size.width, targetY), glowPaint);
    canvas.drawLine(
      Offset(targetX, 0),
      Offset(targetX, size.height),
      glowPaint,
    );

    // 메인 라인
    final linePaint = Paint()
      ..color = targetColor.withValues(alpha: alpha)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, targetY), Offset(size.width, targetY), linePaint);
    canvas.drawLine(
      Offset(targetX, 0),
      Offset(targetX, size.height),
      linePaint,
    );

    // 중앙 타겟 마커
    final markerSize = 20 + progress * 15;
    final markerPaint = Paint()
      ..color = targetColor.withValues(alpha: alpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(Offset(targetX, targetY), markerSize, markerPaint);

    // 내부 점
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: alpha)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(targetX, targetY), 6, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _TreasureCrosshairPainter oldDelegate) => true;
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;

  _ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.life)
        ..style = PaintingStyle.fill;

      final x = p.x * size.width;
      final y = p.y * size.height;

      canvas.drawCircle(Offset(x, y), p.size * p.life, paint);

      // 글로우
      final glowPaint = Paint()
        ..color = p.color.withValues(alpha: p.life * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(x, y), p.size * p.life * 1.5, glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}

// ============ HIGHLIGHT EFFECT PAINTER ============

class _HighlightEffectPainter extends CustomPainter {
  final HighlightEffect effect;
  final (int, int)? highlightedCoord;
  final List<(int, int)> markedCoords;
  final int gridSize;
  final int treasureSize;
  final double progress;
  final double glowValue;

  _HighlightEffectPainter({
    required this.effect,
    required this.highlightedCoord,
    required this.markedCoords,
    required this.gridSize,
    required this.treasureSize,
    required this.progress,
    required this.glowValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 마커 모드: 고정된 마커들 그리기
    if (effect == HighlightEffect.marker) {
      _drawMarkers(canvas, size);
    }

    // 하이라이트된 좌표가 있으면 효과 그리기
    if (highlightedCoord != null && progress > 0) {
      final (row, col) = highlightedCoord!;
      final x = (col - 0.5) / gridSize * size.width;
      final y = (row - 0.5) / gridSize * size.height;

      switch (effect) {
        case HighlightEffect.ping:
          _drawPingEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.glow:
          _drawGlowEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.crosshair:
          // 크로스헤어는 _TreasureCrosshairPainter에서 처리
          break;
        case HighlightEffect.marker:
          // 마커는 위에서 처리
          break;
        case HighlightEffect.zoom:
          _drawZoomEffect(canvas, Offset(x, y), size, row, col);
          break;
        // === 블록 스타일 효과 ===
        case HighlightEffect.blockWave:
          _drawBlockWaveEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.pixelBurst:
          _drawPixelBurstEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.hitbox:
          _drawHitboxEffect(canvas, Offset(x, y), size, row, col);
          break;
        case HighlightEffect.blockDrill:
          _drawBlockDrillEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.gridCapture:
          _drawGridCaptureEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.cube3d:
          _drawCube3dEffect(canvas, Offset(x, y), size);
          break;
        case HighlightEffect.blockScan:
          _drawBlockScanEffect(canvas, Offset(x, y), size);
          break;
      }
    }
  }

  // 1. 핑/마커 효과 - 원형 파동
  void _drawPingEffect(Canvas canvas, Offset center, Size size) {
    final waveCount = 3;

    for (int i = 0; i < waveCount; i++) {
      final waveProgress = (progress - i * 0.2).clamp(0.0, 1.0);
      if (waveProgress <= 0) continue;

      final radius = 20 + waveProgress * 80;
      final alpha = (1 - waveProgress) * 0.8;

      // 파동 링
      final ringPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 - waveProgress * 2;

      canvas.drawCircle(center, radius, ringPaint);

      // 글로우
      final glowPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: alpha * 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 15
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, radius, glowPaint);
    }

    // 중앙 마커
    if (progress < 0.5) {
      final markerAlpha = 1 - progress * 2;
      final markerPaint = Paint()
        ..color = Colors.white.withValues(alpha: markerAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(center, 8, markerPaint);

      // 외부 링
      final outerPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: markerAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(center, 15, outerPaint);
    }
  }

  // 2. 강조 효과 - 빛나며 깜빡임
  void _drawGlowEffect(Canvas canvas, Offset center, Size size) {
    final pulseValue = sin(progress * pi * 4) * 0.5 + 0.5;
    final fadeOut = 1 - progress;

    // 큰 글로우
    for (int i = 3; i >= 1; i--) {
      final glowPaint = Paint()
        ..color = Colors.amber.withValues(alpha: fadeOut * 0.2 * pulseValue / i)
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * i);

      canvas.drawCircle(center, 30.0 * i, glowPaint);
    }

    // 중앙 빛
    final centerPaint = Paint()
      ..color = Colors.white.withValues(alpha: fadeOut * pulseValue)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 12, centerPaint);

    // 별 모양 빛줄기
    final rayPaint = Paint()
      ..color = Colors.amber.withValues(alpha: fadeOut * 0.6 * pulseValue)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4 + progress * pi;
      final innerRadius = 15.0;
      final outerRadius = 30 + pulseValue * 20;

      canvas.drawLine(
        Offset(
          center.dx + cos(angle) * innerRadius,
          center.dy + sin(angle) * innerRadius,
        ),
        Offset(
          center.dx + cos(angle) * outerRadius,
          center.dy + sin(angle) * outerRadius,
        ),
        rayPaint,
      );
    }
  }

  // 4. 마커 고정 효과
  void _drawMarkers(Canvas canvas, Size size) {
    for (final coord in markedCoords) {
      final (row, col) = coord;
      final x = (col - 0.5) / gridSize * size.width;
      final y = (row - 0.5) / gridSize * size.height;

      // 글로우
      final glowPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.3 * glowValue)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

      canvas.drawCircle(Offset(x, y), 20, glowPaint);

      // 마커 핀
      final pinPaint = Paint()
        ..color = Colors.green
        ..style = PaintingStyle.fill;

      // 핀 머리
      canvas.drawCircle(Offset(x, y - 8), 10, pinPaint);

      // 핀 몸통
      final pinPath = Path()
        ..moveTo(x - 6, y - 8)
        ..lineTo(x, y + 10)
        ..lineTo(x + 6, y - 8)
        ..close();

      canvas.drawPath(pinPath, pinPaint);

      // 하이라이트
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x - 3, y - 11), 3, highlightPaint);
    }
  }

  // 5. 줌/미니맵 효과
  void _drawZoomEffect(
    Canvas canvas,
    Offset center,
    Size size,
    int row,
    int col,
  ) {
    final zoomProgress = Curves.easeOutBack.transform(
      progress.clamp(0, 0.5) * 2,
    );
    final fadeOut = progress > 0.7 ? (1 - progress) / 0.3 : 1.0;

    // 확대된 영역 표시
    final zoomSize = 120.0 * zoomProgress;
    final zoomRect = Rect.fromCenter(
      center: center,
      width: zoomSize,
      height: zoomSize,
    );

    // 배경
    final bgPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8 * fadeOut)
      ..style = PaintingStyle.fill;

    final rrect = RRect.fromRectAndRadius(zoomRect, const Radius.circular(16));
    canvas.drawRRect(rrect, bgPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.teal.withValues(alpha: fadeOut)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(rrect, borderPaint);

    // 내부 그리드 (3x3)
    final gridPaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.3 * fadeOut)
      ..strokeWidth = 1;

    for (int i = 1; i < 3; i++) {
      final offset = zoomSize / 3 * i;
      canvas.drawLine(
        Offset(zoomRect.left + offset, zoomRect.top),
        Offset(zoomRect.left + offset, zoomRect.bottom),
        gridPaint,
      );
      canvas.drawLine(
        Offset(zoomRect.left, zoomRect.top + offset),
        Offset(zoomRect.right, zoomRect.top + offset),
        gridPaint,
      );
    }

    // 좌표 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: '($row, $col)',
        style: TextStyle(
          color: Colors.white.withValues(alpha: fadeOut),
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );

    // 확대 아이콘
    final iconPaint = Paint()
      ..color = Colors.teal.withValues(alpha: fadeOut)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 돋보기 모양
    canvas.drawCircle(
      Offset(zoomRect.right - 20, zoomRect.top + 20),
      8,
      iconPaint,
    );
    canvas.drawLine(
      Offset(zoomRect.right - 14, zoomRect.top + 26),
      Offset(zoomRect.right - 8, zoomRect.top + 32),
      iconPaint,
    );

    // 연결선 (중앙에서 원래 위치로)
    final linePaint = Paint()
      ..color = Colors.teal.withValues(alpha: 0.5 * fadeOut)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // 점선 효과
    final dashPath = Path()
      ..moveTo(center.dx, zoomRect.bottom)
      ..lineTo(center.dx, center.dy + 50);

    canvas.drawPath(dashPath, linePaint);

    // 원래 위치 표시
    final originalPaint = Paint()
      ..color = Colors.teal.withValues(alpha: fadeOut)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(center.dx, center.dy + 60), 5, originalPaint);
  }

  // === 블록 스타일 효과들 ===

  // 6. 블록 파동 - 사각형 블록이 퍼져나감
  void _drawBlockWaveEffect(Canvas canvas, Offset center, Size size) {
    final waveCount = 4;
    final blockSize = size.width / gridSize;

    for (int i = 0; i < waveCount; i++) {
      final waveProgress = (progress - i * 0.15).clamp(0.0, 1.0);
      if (waveProgress <= 0) continue;

      final expansion = (waveProgress * 8).floor(); // 0~8 블록 확장
      final alpha = (1 - waveProgress) * 0.7;

      final rectPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      final glowPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: alpha * 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      final rect = Rect.fromCenter(
        center: center,
        width: blockSize * (1 + expansion * 2),
        height: blockSize * (1 + expansion * 2),
      );

      canvas.drawRect(rect, glowPaint);
      canvas.drawRect(rect, rectPaint);

      // 모서리 강조
      final cornerSize = blockSize * 0.3;
      final cornerPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      // 좌상단
      canvas.drawLine(
        Offset(rect.left, rect.top + cornerSize),
        Offset(rect.left, rect.top),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(rect.left, rect.top),
        Offset(rect.left + cornerSize, rect.top),
        cornerPaint,
      );
      // 우상단
      canvas.drawLine(
        Offset(rect.right - cornerSize, rect.top),
        Offset(rect.right, rect.top),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(rect.right, rect.top),
        Offset(rect.right, rect.top + cornerSize),
        cornerPaint,
      );
      // 좌하단
      canvas.drawLine(
        Offset(rect.left, rect.bottom - cornerSize),
        Offset(rect.left, rect.bottom),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(rect.left, rect.bottom),
        Offset(rect.left + cornerSize, rect.bottom),
        cornerPaint,
      );
      // 우하단
      canvas.drawLine(
        Offset(rect.right - cornerSize, rect.bottom),
        Offset(rect.right, rect.bottom),
        cornerPaint,
      );
      canvas.drawLine(
        Offset(rect.right, rect.bottom),
        Offset(rect.right, rect.bottom - cornerSize),
        cornerPaint,
      );
    }

    // 중앙 블록
    if (progress < 0.6) {
      final centerAlpha = 1 - progress / 0.6;
      final centerPaint = Paint()
        ..color = Colors.white.withValues(alpha: centerAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(center: center, width: blockSize, height: blockSize),
        centerPaint,
      );
    }
  }

  // 7. 픽셀 폭발 - 블록이 사방으로 튀어나감
  void _drawPixelBurstEffect(Canvas canvas, Offset center, Size size) {
    final blockSize = size.width / gridSize;
    final random = Random(42); // 고정 시드로 일관된 패턴

    final particleCount = 16;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * pi * 2;
      final speed = 0.5 + random.nextDouble() * 0.5;
      final distance = progress * 100 * speed;

      final px = center.dx + cos(angle) * distance;
      final py = center.dy + sin(angle) * distance;

      final alpha = (1 - progress) * 0.9;
      final particleSize =
          blockSize * (0.5 + random.nextDouble() * 0.5) * (1 - progress * 0.5);

      // 블록 그림자
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: alpha * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(px + 2, py + 2),
          width: particleSize,
          height: particleSize,
        ),
        shadowPaint,
      );

      // 블록
      final colors = [Colors.orange, Colors.amber, Colors.yellow, Colors.red];
      final blockPaint = Paint()
        ..color = colors[i % colors.length].withValues(alpha: alpha)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(px, py),
          width: particleSize,
          height: particleSize,
        ),
        blockPaint,
      );

      // 하이라이트
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.6)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(px - particleSize * 0.2, py - particleSize * 0.2),
          width: particleSize * 0.3,
          height: particleSize * 0.3,
        ),
        highlightPaint,
      );
    }

    // 중앙 폭발 효과
    if (progress < 0.3) {
      final burstAlpha = 1 - progress / 0.3;
      final burstPaint = Paint()
        ..color = Colors.white.withValues(alpha: burstAlpha)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(center, 30 * (1 - progress), burstPaint);
    }
  }

  // 8. 히트박스 표시 - 당첨 범위를 블록으로 표시
  void _drawHitboxEffect(
    Canvas canvas,
    Offset center,
    Size size,
    int row,
    int col,
  ) {
    final blockWidth = size.width / gridSize;
    final blockHeight = size.height / gridSize;
    final halfSize = treasureSize ~/ 2;

    final appearProgress = Curves.easeOutBack.transform(
      progress.clamp(0, 0.4) * 2.5,
    );
    final fadeOut = progress > 0.7 ? (1 - progress) / 0.3 : 1.0;

    // 히트박스 영역 계산
    final hitboxRect = Rect.fromLTWH(
      (col - halfSize - 1) * blockWidth,
      (row - halfSize - 1) * blockHeight,
      treasureSize * blockWidth,
      treasureSize * blockHeight,
    );

    // 영역 배경 (그리드 패턴)
    for (int r = 0; r < treasureSize; r++) {
      for (int c = 0; c < treasureSize; c++) {
        final cellX = hitboxRect.left + c * blockWidth;
        final cellY = hitboxRect.top + r * blockHeight;
        final isCenter = r == halfSize && c == halfSize;

        final cellAlpha = fadeOut * appearProgress * (isCenter ? 0.6 : 0.3);
        final cellPaint = Paint()
          ..color = (isCenter ? Colors.amber : Colors.green).withValues(
            alpha: cellAlpha,
          )
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromLTWH(cellX + 1, cellY + 1, blockWidth - 2, blockHeight - 2),
          cellPaint,
        );
      }
    }

    // 히트박스 테두리
    final borderPaint = Paint()
      ..color = Colors.green.withValues(alpha: fadeOut * appearProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRect(hitboxRect, borderPaint);

    // 글로우
    final glowPaint = Paint()
      ..color = Colors.green.withValues(alpha: fadeOut * appearProgress * 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawRect(hitboxRect, glowPaint);

    // 크기 텍스트
    final textPainter = TextPainter(
      text: TextSpan(
        text: '$treasureSize×$treasureSize',
        style: TextStyle(
          color: Colors.white.withValues(alpha: fadeOut * appearProgress),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Offset(hitboxRect.right + 8, hitboxRect.top));

    // 중앙 타겟 마커
    final targetPaint = Paint()
      ..color = Colors.amber.withValues(alpha: fadeOut * appearProgress)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, 8, targetPaint);
    canvas.drawLine(
      Offset(center.dx - 12, center.dy),
      Offset(center.dx + 12, center.dy),
      targetPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - 12),
      Offset(center.dx, center.dy + 12),
      targetPaint,
    );
  }

  // 9. 블록 드릴 - 위에서 블록을 파내려감
  void _drawBlockDrillEffect(Canvas canvas, Offset center, Size size) {
    final blockSize = size.width / gridSize;
    final drillProgress = progress;

    // 드릴 위치
    final drillY = center.dy - 80 + drillProgress * 100;
    final drillWidth = blockSize * 2;

    // 파편 효과
    if (drillProgress > 0.2) {
      final debrisCount = 8;
      final random = Random(42);
      for (int i = 0; i < debrisCount; i++) {
        final debrisProgress = ((drillProgress - 0.2) * 1.25).clamp(0.0, 1.0);
        final dx = (random.nextDouble() - 0.5) * 60 * debrisProgress;
        final dy = random.nextDouble() * 40 * debrisProgress;
        final debrisSize = blockSize * 0.3 * (1 - debrisProgress);

        final debrisPaint = Paint()
          ..color = Colors.brown.withValues(alpha: (1 - debrisProgress) * 0.8)
          ..style = PaintingStyle.fill;

        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(center.dx + dx, drillY + dy),
            width: debrisSize,
            height: debrisSize,
          ),
          debrisPaint,
        );
      }
    }

    // 드릴 본체
    final drillPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = PaintingStyle.fill;

    // 드릴 머리 (삼각형)
    final drillHead = Path()
      ..moveTo(center.dx, drillY + 20)
      ..lineTo(center.dx - drillWidth / 2, drillY - 10)
      ..lineTo(center.dx + drillWidth / 2, drillY - 10)
      ..close();

    canvas.drawPath(drillHead, drillPaint);

    // 드릴 몸통
    canvas.drawRect(
      Rect.fromLTWH(center.dx - drillWidth / 2, drillY - 50, drillWidth, 40),
      drillPaint,
    );

    // 드릴 나선
    final spiralPaint = Paint()
      ..color = Colors.amber.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (int i = 0; i < 3; i++) {
      final spiralY = drillY - 10 + i * 10 + (drillProgress * 20) % 10;
      canvas.drawLine(
        Offset(center.dx - drillWidth / 3, spiralY),
        Offset(center.dx + drillWidth / 3, spiralY + 5),
        spiralPaint,
      );
    }

    // 충격파
    if (drillProgress > 0.5) {
      final shockProgress = (drillProgress - 0.5) * 2;
      final shockPaint = Paint()
        ..color = Colors.orange.withValues(alpha: (1 - shockProgress) * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawCircle(
        Offset(center.dx, drillY + 20),
        20 + shockProgress * 40,
        shockPaint,
      );
    }
  }

  // 10. 그리드 점령 - 블록이 순차 점등
  void _drawGridCaptureEffect(Canvas canvas, Offset center, Size size) {
    final blockSize = size.width / gridSize;

    // 점등 순서 (시계방향 나선, 5x5 영역)
    final sequence = <(int, int)>[
      (0, 0), // 중앙
      (0, 1),
      (1, 1),
      (1, 0),
      (1, -1),
      (0, -1),
      (-1, -1),
      (-1, 0),
      (-1, 1), // 1층
      (-1, 2), (0, 2), (1, 2), (2, 2), (2, 1), (2, 0), (2, -1), (2, -2), // 2층
      (1, -2),
      (0, -2),
      (-1, -2),
      (-2, -2),
      (-2, -1),
      (-2, 0),
      (-2, 1),
      (-2, 2), // 2층 계속
    ];

    final totalBlocks = sequence.length;
    final litBlocks = (progress * totalBlocks * 1.5).floor().clamp(
      0,
      totalBlocks,
    );

    for (int i = 0; i < litBlocks; i++) {
      final (dr, dc) = sequence[i];
      final blockX = center.dx + dc * blockSize;
      final blockY = center.dy + dr * blockSize;

      final isRecent = i >= litBlocks - 3;
      final blockAlpha = isRecent ? 0.9 : 0.5 + (i / totalBlocks) * 0.3;

      // 블록 글로우
      final glowPaint = Paint()
        ..color = (isRecent ? Colors.cyan : Colors.teal).withValues(
          alpha: blockAlpha * 0.5,
        )
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(blockX, blockY),
          width: blockSize + 4,
          height: blockSize + 4,
        ),
        glowPaint,
      );

      // 블록 본체
      final blockPaint = Paint()
        ..color = (isRecent ? Colors.cyan : Colors.teal).withValues(
          alpha: blockAlpha,
        )
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(blockX, blockY),
          width: blockSize - 2,
          height: blockSize - 2,
        ),
        blockPaint,
      );

      // 하이라이트
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: blockAlpha * 0.4)
        ..style = PaintingStyle.fill;

      canvas.drawRect(
        Rect.fromLTWH(
          blockX - blockSize / 2 + 2,
          blockY - blockSize / 2 + 2,
          blockSize * 0.3,
          blockSize * 0.15,
        ),
        highlightPaint,
      );
    }

    // 점령 완료 표시
    if (progress > 0.8) {
      final completeAlpha = (progress - 0.8) / 0.2;
      final completePaint = Paint()
        ..color = Colors.green.withValues(alpha: completeAlpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      // 체크마크
      final checkPath = Path()
        ..moveTo(center.dx - 15, center.dy)
        ..lineTo(center.dx - 5, center.dy + 10)
        ..lineTo(center.dx + 15, center.dy - 10);

      canvas.drawPath(checkPath, completePaint);
    }
  }

  // 11. 3D 큐브 - 회전하는 3D 큐브
  void _drawCube3dEffect(Canvas canvas, Offset center, Size size) {
    final cubeSize = 40.0;
    final rotation = progress * pi * 2; // 1회전
    final fadeOut = progress > 0.8 ? (1 - progress) / 0.2 : 1.0;

    // 3D 변환 시뮬레이션
    final cosR = cos(rotation);
    final sinR = sin(rotation);

    // 큐브 꼭지점 (2D 투영)
    final front = [
      Offset(center.dx - cubeSize * cosR, center.dy - cubeSize),
      Offset(center.dx + cubeSize * cosR, center.dy - cubeSize),
      Offset(center.dx + cubeSize * cosR, center.dy + cubeSize * 0.3),
      Offset(center.dx - cubeSize * cosR, center.dy + cubeSize * 0.3),
    ];

    final top = [
      front[0],
      front[1],
      Offset(
        center.dx + cubeSize * sinR * 0.5,
        center.dy - cubeSize - cubeSize * 0.5,
      ),
      Offset(
        center.dx - cubeSize * sinR * 0.5,
        center.dy - cubeSize - cubeSize * 0.5,
      ),
    ];

    // 윗면
    final topPaint = Paint()
      ..color = Colors.amber.withValues(alpha: fadeOut * 0.9)
      ..style = PaintingStyle.fill;

    final topPath = Path()
      ..moveTo(top[0].dx, top[0].dy)
      ..lineTo(top[1].dx, top[1].dy)
      ..lineTo(top[2].dx, top[2].dy)
      ..lineTo(top[3].dx, top[3].dy)
      ..close();

    canvas.drawPath(topPath, topPaint);

    // 앞면
    final frontPaint = Paint()
      ..color = Colors.orange.withValues(alpha: fadeOut * 0.8)
      ..style = PaintingStyle.fill;

    final frontPath = Path()
      ..moveTo(front[0].dx, front[0].dy)
      ..lineTo(front[1].dx, front[1].dy)
      ..lineTo(front[2].dx, front[2].dy)
      ..lineTo(front[3].dx, front[3].dy)
      ..close();

    canvas.drawPath(frontPath, frontPaint);

    // 옆면 (회전에 따라)
    if (cosR > 0) {
      final sidePaint = Paint()
        ..color = Colors.deepOrange.withValues(alpha: fadeOut * 0.7)
        ..style = PaintingStyle.fill;

      final sidePath = Path()
        ..moveTo(front[1].dx, front[1].dy)
        ..lineTo(top[2].dx, top[2].dy)
        ..lineTo(top[2].dx, top[2].dy + cubeSize * 1.3)
        ..lineTo(front[2].dx, front[2].dy)
        ..close();

      canvas.drawPath(sidePath, sidePaint);
    }

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: fadeOut * 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(frontPath, borderPaint);
    canvas.drawPath(topPath, borderPaint);

    // 글로우
    final glowPaint = Paint()
      ..color = Colors.amber.withValues(alpha: fadeOut * 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    canvas.drawCircle(center, cubeSize * 1.2, glowPaint);

    // 물음표 또는 보물 아이콘
    final iconPaint = Paint()
      ..color = Colors.white.withValues(alpha: fadeOut)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // ? 마크
    final qPath = Path()
      ..moveTo(center.dx - 8, center.dy - 25)
      ..quadraticBezierTo(
        center.dx - 8,
        center.dy - 35,
        center.dx,
        center.dy - 35,
      )
      ..quadraticBezierTo(
        center.dx + 12,
        center.dy - 35,
        center.dx + 8,
        center.dy - 20,
      )
      ..quadraticBezierTo(
        center.dx + 5,
        center.dy - 12,
        center.dx,
        center.dy - 10,
      );

    canvas.drawPath(qPath, iconPaint);
    canvas.drawCircle(
      Offset(center.dx, center.dy),
      3,
      iconPaint..style = PaintingStyle.fill,
    );
  }

  // 12. 블록 스캔 - 블록 단위 스캔 라인
  void _drawBlockScanEffect(Canvas canvas, Offset center, Size size) {
    final blockSize = size.width / gridSize;
    final scanWidth = blockSize * 10; // 10블록 너비 스캔
    final scanX = center.dx - scanWidth / 2 + progress * scanWidth;

    // 스캔 라인
    final scanPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawLine(
      Offset(scanX, center.dy - 60),
      Offset(scanX, center.dy + 60),
      scanPaint,
    );

    // 스캔 글로우
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Colors.green.withValues(alpha: 0.3),
          Colors.green.withValues(alpha: 0.5),
          Colors.green.withValues(alpha: 0.3),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      ).createShader(Rect.fromLTWH(scanX - 30, center.dy - 60, 60, 120));

    canvas.drawRect(
      Rect.fromLTWH(scanX - 30, center.dy - 60, 60, 120),
      glowPaint,
    );

    // 스캔된 영역 (왼쪽)
    final scannedPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.15)
      ..style = PaintingStyle.fill;

    canvas.drawRect(
      Rect.fromLTWH(
        center.dx - scanWidth / 2,
        center.dy - 60,
        scanX - (center.dx - scanWidth / 2),
        120,
      ),
      scannedPaint,
    );

    // 스캔 완료된 블록 표시
    final completedBlocks = (progress * 10).floor();
    for (int i = 0; i < completedBlocks; i++) {
      final bx = center.dx - scanWidth / 2 + (i + 0.5) * blockSize;

      // 블록 테두리
      final blockBorderPaint = Paint()
        ..color = Colors.green.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;

      for (int j = -3; j <= 3; j++) {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(bx, center.dy + j * blockSize),
            width: blockSize - 2,
            height: blockSize - 2,
          ),
          blockBorderPaint,
        );
      }
    }

    // 타겟 발견 효과 (중앙 부근에서)
    if (progress > 0.4 && progress < 0.6) {
      final targetAlpha = sin((progress - 0.4) / 0.2 * pi);
      final targetPaint = Paint()
        ..color = Colors.red.withValues(alpha: targetAlpha * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;

      canvas.drawRect(
        Rect.fromCenter(
          center: center,
          width: blockSize + 4,
          height: blockSize + 4,
        ),
        targetPaint,
      );

      // "TARGET" 텍스트
      final textPainter = TextPainter(
        text: TextSpan(
          text: 'TARGET',
          style: TextStyle(
            color: Colors.red.withValues(alpha: targetAlpha),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(center.dx - textPainter.width / 2, center.dy + blockSize),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HighlightEffectPainter oldDelegate) => true;
}

// ============ RESULT DIALOG ============

class _TreasureResultDialog extends StatefulWidget {
  final int row;
  final int col;
  final bool foundTreasure;
  final VoidCallback onRetry;
  final VoidCallback onClose;

  const _TreasureResultDialog({
    required this.row,
    required this.col,
    required this.foundTreasure,
    required this.onRetry,
    required this.onClose,
  });

  @override
  State<_TreasureResultDialog> createState() => _TreasureResultDialogState();
}

class _TreasureResultDialogState extends State<_TreasureResultDialog>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _shineController;
  late AnimationController _sparkleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat();

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _shineController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.foundTreasure
        ? const Color(0xFFFFD700)
        : Colors.grey.shade600;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.foundTreasure ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 380),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: widget.foundTreasure
                        ? [
                            color.withValues(alpha: 0.35),
                            const Color(0xFF1A1A2E).withValues(alpha: 0.9),
                            const Color(0xFFFF6B35).withValues(alpha: 0.2),
                          ]
                        : [
                            color.withValues(alpha: 0.2),
                            const Color(0xFF1A1A2E).withValues(alpha: 0.95),
                            color.withValues(alpha: 0.1),
                          ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: color.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(
                        alpha: widget.foundTreasure ? 0.5 : 0.2,
                      ),
                      blurRadius: 60,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // 빛나는 효과 (보물 발견 시)
                    if (widget.foundTreasure)
                      AnimatedBuilder(
                        animation: _shineAnimation,
                        builder: (context, child) {
                          return Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(32),
                              child: ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment(
                                      _shineAnimation.value - 1,
                                      -0.5,
                                    ),
                                    end: Alignment(_shineAnimation.value, 0.5),
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withValues(alpha: 0.15),
                                      Colors.transparent,
                                    ],
                                  ).createShader(bounds);
                                },
                                blendMode: BlendMode.srcATop,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                    // 반짝이 효과 (보물 발견 시)
                    if (widget.foundTreasure)
                      AnimatedBuilder(
                        animation: _sparkleController,
                        builder: (context, _) {
                          return CustomPaint(
                            size: const Size(380, 500),
                            painter: _SparklePainter(
                              progress: _sparkleController.value,
                              color: color,
                            ),
                          );
                        },
                      ),

                    // 메인 컨텐츠
                    Padding(
                      padding: const EdgeInsets.fromLTRB(28, 40, 28, 28),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // 결과 아이콘
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  color.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                widget.foundTreasure ? '💎' : '💨',
                                style: const TextStyle(fontSize: 56),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // 결과 텍스트
                          ShaderMask(
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                colors: widget.foundTreasure
                                    ? [Colors.white, color]
                                    : [Colors.white, Colors.grey],
                              ).createShader(bounds);
                            },
                            child: Text(
                              widget.foundTreasure
                                  ? 'TREASURE!'
                                  : 'NOT THIS TIME',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 3,
                              ),
                            ),
                          ),

                          const SizedBox(height: 8),

                          Text(
                            widget.foundTreasure
                                ? '축하해요! 보물을 찾았어요!'
                                : '아쉽지만 다음 기회에!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 15,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // 좌표 표시
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: color.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildCoordBox('ROW', widget.row, color),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: color,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: color,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: color,
                                              blurRadius: 8,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                _buildCoordBox('COL', widget.col, color),
                              ],
                            ),
                          ),

                          // 보상 정보 (보물 발견 시)
                          if (widget.foundTreasure) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    color.withValues(alpha: 0.2),
                                    const Color(
                                      0xFFFF6B35,
                                    ).withValues(alpha: 0.15),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: color.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '🎁',
                                    style: TextStyle(fontSize: 22),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    '특별 보상 + 참가 보상 획득!',
                                    style: TextStyle(
                                      color: color,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // 버튼들
                          Row(
                            children: [
                              Expanded(
                                child: _buildButton(
                                  label: 'RETRY',
                                  icon: Icons.refresh_rounded,
                                  onTap: widget.onRetry,
                                  isPrimary: false,
                                  color: color,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildButton(
                                  label: 'CONFIRM',
                                  icon: Icons.check_rounded,
                                  onTap: widget.onClose,
                                  isPrimary: true,
                                  color: color,
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
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoordBox(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: color.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.toString().padLeft(3, '0'),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            fontFamily: 'monospace',
            letterSpacing: 3,
          ),
        ),
      ],
    );
  }

  Widget _buildButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isPrimary,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withValues(alpha: 0.7)],
                )
              : null,
          color: isPrimary ? null : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary
                ? color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.15),
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withValues(alpha: isPrimary ? 1 : 0.8),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: isPrimary ? 1 : 0.8),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklePainter extends CustomPainter {
  final double progress;
  final Color color;

  _SparklePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(42);

    for (int i = 0; i < 20; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final phase = (progress + i * 0.1) % 1.0;
      final sparkleSize = sin(phase * pi) * 4;

      if (sparkleSize > 0) {
        final paint = Paint()
          ..color = color.withValues(alpha: sin(phase * pi) * 0.8)
          ..style = PaintingStyle.fill;

        // 별 모양
        _drawStar(canvas, Offset(x, y), sparkleSize, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * pi / 2;
      final outerX = center.dx + cos(angle) * size;
      final outerY = center.dy + sin(angle) * size;
      final innerAngle = angle + pi / 4;
      final innerX = center.dx + cos(innerAngle) * size * 0.3;
      final innerY = center.dy + sin(innerAngle) * size * 0.3;

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklePainter oldDelegate) => true;
}

// ============ PARTICLE CLASS ============

class _Particle {
  double x;
  double y;
  double vx;
  double vy;
  double life;
  double decay;
  Color color;
  double size;

  _Particle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.life,
    required this.decay,
    required this.color,
    required this.size,
  });
}
