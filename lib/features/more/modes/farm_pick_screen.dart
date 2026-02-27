import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Farm Pick - 좌표를 심고 키우는 농장 게임
class FarmPickScreen extends StatefulWidget {
  const FarmPickScreen({super.key});

  @override
  State<FarmPickScreen> createState() => _FarmPickScreenState();
}

class _FarmPickScreenState extends State<FarmPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.mint;
  static const int gridSize = 1000;
  static const int visualGridSize = 8; // 시각화용 8x8 그리드

  final Set<String> _plantedCells = {};
  int _waterCount = 3;
  int _seedRow = 0;
  int _seedCol = 0;
  bool _hasPlanted = false;
  final _random = Random();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _growController;
  late Animation<double> _growAnimation;

  Timer? _sparkleTimer;
  final List<_Sparkle> _sparkles = [];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadFarmState();
    _startSparkleEffect();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _growController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _growAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _growController, curve: Curves.elasticOut),
    );
  }

  void _startSparkleEffect() {
    _sparkleTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (_plantedCells.isNotEmpty && _random.nextDouble() > 0.7) {
        setState(() {
          _sparkles.add(_Sparkle(
            x: _random.nextDouble(),
            y: _random.nextDouble(),
            size: 2 + _random.nextDouble() * 4,
            opacity: 1.0,
          ));

          _sparkles.removeWhere((s) => s.opacity <= 0);
          for (var sparkle in _sparkles) {
            sparkle.opacity -= 0.05;
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _growController.dispose();
    _sparkleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFarmState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCells = prefs.getStringList('farm_cells') ?? [];
    final savedWater = prefs.getInt('farm_water') ?? 3;
    final savedSeedRow = prefs.getInt('farm_seed_row') ?? 0;
    final savedSeedCol = prefs.getInt('farm_seed_col') ?? 0;
    final hasPlanted = prefs.getBool('farm_has_planted') ?? false;

    setState(() {
      _plantedCells.addAll(savedCells);
      _waterCount = savedWater;
      _seedRow = savedSeedRow;
      _seedCol = savedSeedCol;
      _hasPlanted = hasPlanted;
    });
  }

  Future<void> _saveFarmState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('farm_cells', _plantedCells.toList());
    await prefs.setInt('farm_water', _waterCount);
    await prefs.setInt('farm_seed_row', _seedRow);
    await prefs.setInt('farm_seed_col', _seedCol);
    await prefs.setBool('farm_has_planted', _hasPlanted);
  }

  void _plantSeed() {
    if (_hasPlanted) return;

    HapticFeedback.mediumImpact();
    final row = _random.nextInt(visualGridSize);
    final col = _random.nextInt(visualGridSize);
    final key = '$row,$col';

    setState(() {
      _seedRow = row;
      _seedCol = col;
      _plantedCells.add(key);
      _hasPlanted = true;
    });

    _growController.forward(from: 0);
    _saveFarmState();
  }

  void _waterPlant() {
    if (_waterCount <= 0 || !_hasPlanted) return;

    HapticFeedback.lightImpact();

    // 랜덤하게 인접 셀로 확장
    final newCells = <String>[];
    for (final cell in _plantedCells.toList()) {
      final parts = cell.split(',');
      final row = int.parse(parts[0]);
      final col = int.parse(parts[1]);

      final directions = [
        [0, 1],
        [0, -1],
        [1, 0],
        [-1, 0],
      ];
      directions.shuffle(_random);

      for (final dir in directions.take(1)) {
        final newRow = (row + dir[0]).clamp(0, visualGridSize - 1);
        final newCol = (col + dir[1]).clamp(0, visualGridSize - 1);
        final newKey = '$newRow,$newCol';

        if (!_plantedCells.contains(newKey)) {
          newCells.add(newKey);
          break;
        }
      }
    }

    setState(() {
      _plantedCells.addAll(newCells);
      _waterCount--;
    });

    _growController.forward(from: 0);
    _saveFarmState();
  }

  void _harvest() {
    if (_plantedCells.isEmpty) return;

    HapticFeedback.heavyImpact();

    // 영역의 중심 계산
    int sumRow = 0, sumCol = 0;
    for (final cell in _plantedCells) {
      final parts = cell.split(',');
      sumRow += int.parse(parts[0]);
      sumCol += int.parse(parts[1]);
    }
    final avgRow = sumRow ~/ _plantedCells.length;
    final avgCol = sumCol ~/ _plantedCells.length;

    // 8x8 그리드를 1000x1000으로 변환
    final finalRow =
        ((avgRow / visualGridSize) * gridSize).round().clamp(1, gridSize);
    final finalCol =
        ((avgCol / visualGridSize) * gridSize).round().clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: finalRow,
      col: finalCol,
      modeName: 'Farm',
      modeColor: modeColor,
      subtitle: 'Harvested from ${_plantedCells.length} plots',
      onRetry: _resetFarm,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  Future<void> _resetFarm() async {
    HapticFeedback.mediumImpact();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('farm_cells');
    await prefs.remove('farm_water');
    await prefs.remove('farm_seed_row');
    await prefs.remove('farm_seed_col');
    await prefs.remove('farm_has_planted');

    setState(() {
      _plantedCells.clear();
      _waterCount = 3;
      _hasPlanted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 중심 좌표 계산
    int? currentRow, currentCol;
    if (_plantedCells.isNotEmpty) {
      int sumRow = 0, sumCol = 0;
      for (final cell in _plantedCells) {
        final parts = cell.split(',');
        sumRow += int.parse(parts[0]);
        sumCol += int.parse(parts[1]);
      }
      final avgRow = sumRow ~/ _plantedCells.length;
      final avgCol = sumCol ~/ _plantedCells.length;
      currentRow =
          ((avgRow / visualGridSize) * gridSize).round().clamp(1, gridSize);
      currentCol =
          ((avgCol / visualGridSize) * gridSize).round().clamp(1, gridSize);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: AppColors.textBlack,
      appBar: GameAppBar(
        title: 'FARM',
        emoji: '🌱',
        accentColor: modeColor,
        actions: [
          GestureDetector(
            onTap: _resetFarm,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.white.withValues(alpha: 0.2),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: AppColors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'RESET',
                    style: TextStyle(
                      color: AppColors.white,
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
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: currentRow != null && currentCol != null,
        currentRow: currentRow,
        currentCol: currentCol,
        child: Column(
          children: [
            // 상태 표시
            _buildStatusBar(),

            // 농장 그리드
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1a3a1a).withValues(alpha: 0.8),
                      const Color(0xFF0d1f0d).withValues(alpha: 0.9),
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
                  child: Stack(
                    children: [
                      // 배경 패턴
                      CustomPaint(
                        size: Size.infinite,
                        painter: _FarmBackgroundPainter(modeColor),
                      ),

                      // 아이소메트릭 그리드
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return AnimatedBuilder(
                            animation: Listenable.merge(
                                [_pulseAnimation, _growAnimation]),
                            builder: (context, _) {
                              return CustomPaint(
                                size: Size(
                                    constraints.maxWidth, constraints.maxHeight),
                                painter: _IsometricFarmPainter(
                                  plantedCells: _plantedCells,
                                  gridSize: visualGridSize,
                                  pulseValue: _pulseAnimation.value,
                                  growValue: _growAnimation.value,
                                  sparkles: _sparkles,
                                  accentColor: modeColor,
                                ),
                              );
                            },
                          );
                        },
                      ),

                      // 안내 텍스트
                      if (!_hasPlanted)
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco_rounded,
                                size: 64,
                                color: AppColors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Plant your first seed',
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.3),
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
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

  Widget _buildStatusBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 100, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatusItem('💧', 'WATER', '$_waterCount'),
          Container(
            width: 1,
            height: 30,
            color: AppColors.white.withValues(alpha: 0.2),
          ),
          _buildStatusItem('🌿', 'PLOTS', '${_plantedCells.length}'),
          Container(
            width: 1,
            height: 30,
            color: AppColors.white.withValues(alpha: 0.2),
          ),
          _buildStatusItem(
            '🌾',
            'STATUS',
            _hasPlanted ? 'GROWING' : 'READY',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.white.withValues(alpha: 0.5),
            letterSpacing: 1,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ],
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
                AppColors.textBlack.withValues(alpha: 0.5),
                AppColors.textBlack.withValues(alpha: 0.8),
              ],
            ),
            border: Border(
              top: BorderSide(
                color: modeColor.withValues(alpha: 0.3),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 버튼 Row
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.eco_rounded,
                      label: 'PLANT',
                      emoji: '🌱',
                      color: modeColor,
                      onTap: _plantSeed,
                      enabled: !_hasPlanted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.water_drop_rounded,
                      label: 'WATER',
                      emoji: '💧',
                      color: AppColors.blue,
                      onTap: _waterPlant,
                      enabled: _waterCount > 0 && _hasPlanted,
                      badge: _waterCount.toString(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 수확 버튼
              GestureDetector(
                onTap: _plantedCells.isNotEmpty ? _harvest : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: _plantedCells.isNotEmpty
                        ? LinearGradient(
                            colors: [
                              AppColors.yellow,
                              AppColors.yellow.withValues(alpha: 0.7),
                            ],
                          )
                        : null,
                    color: _plantedCells.isEmpty
                        ? AppColors.white.withValues(alpha: 0.1)
                        : null,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _plantedCells.isNotEmpty
                        ? [
                            BoxShadow(
                              color:
                                  AppColors.yellow.withValues(alpha: 0.4),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌾', style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text(
                        'HARVEST',
                        style: TextStyle(
                          color: _plantedCells.isNotEmpty
                              ? AppColors.white
                              : AppColors.white.withValues(alpha: 0.3),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
    required bool enabled,
    String? badge,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: enabled
              ? LinearGradient(
                  colors: [
                    color,
                    color.withValues(alpha: 0.7),
                  ],
                )
              : null,
          color: enabled ? null : AppColors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: enabled
                        ? AppColors.white
                        : AppColors.white.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            if (badge != null)
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        color: enabled
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.3),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Sparkle {
  double x;
  double y;
  double size;
  double opacity;

  _Sparkle({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
  });
}

class _FarmBackgroundPainter extends CustomPainter {
  final Color color;

  _FarmBackgroundPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    // 배경 그리드 패턴
    final paint = Paint()
      ..color = color.withValues(alpha: 0.05)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const spacing = 30.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _IsometricFarmPainter extends CustomPainter {
  final Set<String> plantedCells;
  final int gridSize;
  final double pulseValue;
  final double growValue;
  final List<_Sparkle> sparkles;
  final Color accentColor;

  _IsometricFarmPainter({
    required this.plantedCells,
    required this.gridSize,
    required this.pulseValue,
    required this.growValue,
    required this.sparkles,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / gridSize;
    final cellHeight = size.height / gridSize;

    // 그리드 셀 그리기
    for (int row = 0; row < gridSize; row++) {
      for (int col = 0; col < gridSize; col++) {
        final key = '$row,$col';
        final isPlanted = plantedCells.contains(key);

        final x = col * cellWidth;
        final y = row * cellHeight;

        // 셀 배경
        final cellRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x + 4, y + 4, cellWidth - 8, cellHeight - 8),
          const Radius.circular(8),
        );

        if (isPlanted) {
          // 심어진 셀 - 글로우 효과
          final glowPaint = Paint()
            ..color = accentColor.withValues(alpha: 0.3 * pulseValue)
            ..style = PaintingStyle.fill
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

          canvas.drawRRect(cellRect, glowPaint);

          // 셀 배경
          final bgPaint = Paint()
            ..shader = LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accentColor.withValues(alpha: 0.4),
                accentColor.withValues(alpha: 0.2),
              ],
            ).createShader(cellRect.outerRect);

          canvas.drawRRect(cellRect, bgPaint);

          // 테두리
          final borderPaint = Paint()
            ..color = accentColor.withValues(alpha: 0.6)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2;

          canvas.drawRRect(cellRect, borderPaint);
        } else {
          // 빈 셀
          final bgPaint = Paint()
            ..color = AppColors.white.withValues(alpha: 0.05);

          canvas.drawRRect(cellRect, bgPaint);

          final borderPaint = Paint()
            ..color = AppColors.white.withValues(alpha: 0.1)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;

          canvas.drawRRect(cellRect, borderPaint);
        }
      }
    }

    // 식물 아이콘 그리기
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    final plantEmojis = ['🌱', '🌿', '🍀', '🌾'];

    for (final cell in plantedCells) {
      final parts = cell.split(',');
      final row = int.parse(parts[0]);
      final col = int.parse(parts[1]);

      final x = col * cellWidth + cellWidth / 2;
      final y = row * cellHeight + cellHeight / 2;

      final emojiIndex = (row * gridSize + col) % plantEmojis.length;
      final scale = pulseValue;

      textPainter.text = TextSpan(
        text: plantEmojis[emojiIndex],
        style: TextStyle(fontSize: 24 * scale),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }

    // 스파클 효과
    for (final sparkle in sparkles) {
      if (sparkle.opacity <= 0) continue;

      final sparkleX = sparkle.x * size.width;
      final sparkleY = sparkle.y * size.height;

      final sparklePaint = Paint()
        ..color = AppColors.white.withValues(alpha: sparkle.opacity * 0.8)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(sparkleX, sparkleY), sparkle.size, sparklePaint);
    }

    // 중심점 표시 (심어진 셀이 있을 때)
    if (plantedCells.isNotEmpty) {
      int sumRow = 0, sumCol = 0;
      for (final cell in plantedCells) {
        final parts = cell.split(',');
        sumRow += int.parse(parts[0]);
        sumCol += int.parse(parts[1]);
      }
      final avgRow = sumRow / plantedCells.length;
      final avgCol = sumCol / plantedCells.length;

      final centerX = (avgCol + 0.5) * cellWidth;
      final centerY = (avgRow + 0.5) * cellHeight;

      // 중심 글로우
      final centerGlow = Paint()
        ..color = AppColors.yellow.withValues(alpha: 0.3 * pulseValue)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(Offset(centerX, centerY), 25 * pulseValue, centerGlow);

      // 중심 원
      final centerPaint = Paint()
        ..color = AppColors.yellow
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(centerX, centerY), 8, centerPaint);

      // 중심 테두리
      final centerBorder = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(centerX, centerY), 12, centerBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _IsometricFarmPainter oldDelegate) => true;
}
