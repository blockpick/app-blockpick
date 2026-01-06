import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// RPG Pick - 캐릭터로 이미지 탐험
class RpgPickScreen extends StatefulWidget {
  const RpgPickScreen({super.key});

  @override
  State<RpgPickScreen> createState() => _RpgPickScreenState();
}

class _RpgPickScreenState extends State<RpgPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = Color(0xFFEF4444);
  static const int gridSize = 1000;
  static const int visualGridSize = 20;

  double _playerX = 0.5;
  double _playerY = 0.5;
  final Set<String> _footprints = {};
  final List<_Treasure> _treasures = [];
  int _score = 0;
  final _random = Random();

  // 조이스틱 상태
  Offset _joystickDirection = Offset.zero;
  bool _isJoystickActive = false;
  Timer? _moveTimer;

  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _footprintController;
  late Animation<double> _footprintAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _generateTreasures();
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _glowController.dispose();
    _footprintController.dispose();
    _moveTimer?.cancel();
    super.dispose();
  }

  void _initAnimations() {
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: -8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    _bounceController.repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _footprintController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _footprintAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _footprintController, curve: Curves.easeOut),
    );
  }

  void _generateTreasures() {
    _treasures.clear();
    for (int i = 0; i < 5; i++) {
      _treasures.add(_Treasure(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        type: _random.nextInt(3),
        collected: false,
      ));
    }
  }

  void _startMove(Offset direction) {
    _joystickDirection = direction;
    _isJoystickActive = true;
    _moveTimer?.cancel();
    _moveTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      _movePlayer(_joystickDirection);
    });
  }

  void _stopMove() {
    _isJoystickActive = false;
    _moveTimer?.cancel();
    _joystickDirection = Offset.zero;
  }

  void _movePlayer(Offset direction) {
    if (direction == Offset.zero) return;

    HapticFeedback.selectionClick();

    setState(() {
      _playerX = (_playerX + direction.dx * 0.02).clamp(0.05, 0.95);
      _playerY = (_playerY + direction.dy * 0.02).clamp(0.05, 0.95);

      // 발자국 추가
      final gridX = (_playerX * visualGridSize).floor();
      final gridY = (_playerY * visualGridSize).floor();
      _footprints.add('$gridX,$gridY');

      // 보물 체크
      _checkTreasure();
    });

    _footprintController.forward(from: 0);
  }

  void _checkTreasure() {
    for (final treasure in _treasures) {
      if (treasure.collected) continue;

      final distance = (Offset(_playerX, _playerY) -
              Offset(treasure.x, treasure.y))
          .distance;

      if (distance < 0.08) {
        treasure.collected = true;
        _score += [10, 25, 50][treasure.type];
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _confirmPosition() {
    HapticFeedback.heavyImpact();
    final row = (_playerY * gridSize).round().clamp(1, gridSize);
    final col = (_playerX * gridSize).round().clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'RPG',
      modeColor: modeColor,
      subtitle: 'Score: $_score • ${_footprints.length} steps',
      onRetry: _resetGame,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _resetGame() {
    HapticFeedback.mediumImpact();
    setState(() {
      _playerX = 0.5;
      _playerY = 0.5;
      _footprints.clear();
      _score = 0;
      _generateTreasures();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentRow = (_playerY * gridSize).round().clamp(1, gridSize);
    final currentCol = (_playerX * gridSize).round().clamp(1, gridSize);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'RPG',
        emoji: '🗺️',
        accentColor: modeColor,
        actions: [
          // 스코어 표시
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, _) {
              return Container(
                margin: const EdgeInsets.only(right: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.3),
                      const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF59E0B)
                        .withValues(alpha: 0.5 * _glowAnimation.value),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF59E0B)
                          .withValues(alpha: 0.3 * _glowAnimation.value),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⭐', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        color: Color(0xFFF59E0B),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: true,
        currentRow: currentRow,
        currentCol: currentCol,
        child: Column(
          children: [
            // 게임 영역
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 100, 16, 16),
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    colors: [
                      const Color(0xFF1a2a1a).withValues(alpha: 0.8),
                      const Color(0xFF0d150d).withValues(alpha: 0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: modeColor.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: modeColor.withValues(alpha: 0.2),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedBuilder(
                        animation: Listenable.merge([
                          _bounceAnimation,
                          _glowAnimation,
                          _footprintAnimation,
                        ]),
                        builder: (context, _) {
                          return CustomPaint(
                            size: Size(
                                constraints.maxWidth, constraints.maxHeight),
                            painter: _RPGMapPainter(
                              playerX: _playerX,
                              playerY: _playerY,
                              footprints: _footprints,
                              treasures: _treasures,
                              bounceValue: _bounceAnimation.value,
                              glowValue: _glowAnimation.value,
                              footprintValue: _footprintAnimation.value,
                              accentColor: modeColor,
                            ),
                          );
                        },
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
            20,
            24,
            MediaQuery.of(context).padding.bottom + 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.5),
                Colors.black.withValues(alpha: 0.8),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: modeColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Row(
            children: [
              // 조이스틱
              _buildJoystick(),

              const Spacer(),

              // 정보 & 확정 버튼
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 발자국 & 보물 정보
                  Row(
                    children: [
                      _buildInfoChip(
                          '👣', '${_footprints.length}', 'STEPS'),
                      const SizedBox(width: 12),
                      _buildInfoChip(
                          '💎',
                          '${_treasures.where((t) => t.collected).length}/${_treasures.length}',
                          'GEMS'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 확정 버튼
                  GestureDetector(
                    onTap: _confirmPosition,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            modeColor,
                            modeColor.withValues(alpha: 0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: modeColor.withValues(alpha: 0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.flag_rounded,
                              color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'SET FLAG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJoystick() {
    return GestureDetector(
      onPanStart: (details) {
        _updateJoystick(details.localPosition);
      },
      onPanUpdate: (details) {
        _updateJoystick(details.localPosition);
      },
      onPanEnd: (_) {
        _stopMove();
        setState(() {});
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              Colors.white.withValues(alpha: 0.1),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
          border: Border.all(
            color: modeColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 방향 표시
            ..._buildDirectionIndicators(),

            // 조이스틱 노브
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 50,
              height: 50,
              transform: Matrix4.translationValues(
                _joystickDirection.dx * 35,
                _joystickDirection.dy * 35,
                0,
              ),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _isJoystickActive
                        ? modeColor
                        : Colors.white.withValues(alpha: 0.3),
                    _isJoystickActive
                        ? modeColor.withValues(alpha: 0.7)
                        : Colors.white.withValues(alpha: 0.1),
                  ],
                ),
                boxShadow: _isJoystickActive
                    ? [
                        BoxShadow(
                          color: modeColor.withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  Icons.control_camera_rounded,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDirectionIndicators() {
    final directions = [
      (Offset(0, -1), Icons.keyboard_arrow_up),
      (Offset(0, 1), Icons.keyboard_arrow_down),
      (Offset(-1, 0), Icons.keyboard_arrow_left),
      (Offset(1, 0), Icons.keyboard_arrow_right),
    ];

    return directions.map((dir) {
      final isActive = _isJoystickActive &&
          (dir.$1.dx != 0
              ? (_joystickDirection.dx * dir.$1.dx > 0.3)
              : (_joystickDirection.dy * dir.$1.dy > 0.3));

      return Positioned(
        top: dir.$1.dy == -1 ? 8 : null,
        bottom: dir.$1.dy == 1 ? 8 : null,
        left: dir.$1.dx == -1 ? 8 : null,
        right: dir.$1.dx == 1 ? 8 : null,
        child: Icon(
          dir.$2,
          size: 24,
          color: isActive
              ? modeColor
              : Colors.white.withValues(alpha: 0.2),
        ),
      );
    }).toList();
  }

  void _updateJoystick(Offset localPosition) {
    final center = const Offset(70, 70);
    final diff = localPosition - center;
    final distance = diff.distance.clamp(0.0, 45.0);
    final normalized =
        distance > 0 ? diff / diff.distance * (distance / 45) : Offset.zero;

    setState(() {
      _joystickDirection = normalized;
    });

    if (normalized.distance > 0.2) {
      if (!_isJoystickActive) {
        _startMove(normalized);
      } else {
        _joystickDirection = normalized;
      }
    } else {
      _stopMove();
    }
  }

  Widget _buildInfoChip(String emoji, String value, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Treasure {
  double x;
  double y;
  int type; // 0: bronze, 1: silver, 2: gold
  bool collected;

  _Treasure({
    required this.x,
    required this.y,
    required this.type,
    required this.collected,
  });
}

class _RPGMapPainter extends CustomPainter {
  final double playerX;
  final double playerY;
  final Set<String> footprints;
  final List<_Treasure> treasures;
  final double bounceValue;
  final double glowValue;
  final double footprintValue;
  final Color accentColor;

  _RPGMapPainter({
    required this.playerX,
    required this.playerY,
    required this.footprints,
    required this.treasures,
    required this.bounceValue,
    required this.glowValue,
    required this.footprintValue,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 그리드
    _drawGrid(canvas, size);

    // 발자국
    _drawFootprints(canvas, size);

    // 보물
    _drawTreasures(canvas, size);

    // 플레이어
    _drawPlayer(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    const divisions = 20;
    for (int i = 0; i <= divisions; i++) {
      final x = size.width * i / divisions;
      final y = size.height * i / divisions;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawFootprints(Canvas canvas, Size size) {
    final cellWidth = size.width / 20;
    final cellHeight = size.height / 20;

    for (final key in footprints) {
      final parts = key.split(',');
      final x = int.parse(parts[0]) * cellWidth + cellWidth / 2;
      final y = int.parse(parts[1]) * cellHeight + cellHeight / 2;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.1)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);

      canvas.drawCircle(Offset(x, y), 8, glowPaint);

      // 발자국
      final paint = Paint()
        ..color = accentColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  void _drawTreasures(Canvas canvas, Size size) {
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final treasureEmojis = ['🥉', '🥈', '🥇'];

    for (final treasure in treasures) {
      final x = treasure.x * size.width;
      final y = treasure.y * size.height;

      if (treasure.collected) {
        // 수집된 보물 - 희미한 링
        final paint = Paint()
          ..color = const Color(0xFFF59E0B).withValues(alpha: 0.1)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(Offset(x, y), 15, paint);
      } else {
        // 글로우 효과
        final glowPaint = Paint()
          ..color =
              const Color(0xFFF59E0B).withValues(alpha: 0.3 * glowValue)
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

        canvas.drawCircle(Offset(x, y), 25 * glowValue, glowPaint);

        // 보물 아이콘
        textPainter.text = TextSpan(
          text: treasureEmojis[treasure.type],
          style: const TextStyle(fontSize: 28),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }
  }

  void _drawPlayer(Canvas canvas, Size size) {
    final x = playerX * size.width;
    final y = playerY * size.height + bounceValue;

    // 그림자
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(x, playerY * size.height + 20),
        width: 30,
        height: 10,
      ),
      shadowPaint,
    );

    // 플레이어 글로우
    final glowPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.4 * glowValue)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

    canvas.drawCircle(Offset(x, y), 30 * glowValue, glowPaint);

    // 플레이어 아이콘
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '🧙',
        style: TextStyle(fontSize: 40),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2 - 5),
    );

    // 현재 위치 표시
    final indicatorPaint = Paint()
      ..color = accentColor.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(Offset(x, playerY * size.height), 25, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant _RPGMapPainter oldDelegate) => true;
}
