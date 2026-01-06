import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Predict Pick - 다음 당첨 좌표 예언 (데이터 비주얼라이제이션 스타일)
class PredictPickScreen extends StatefulWidget {
  const PredictPickScreen({super.key});

  @override
  State<PredictPickScreen> createState() => _PredictPickScreenState();
}

class _PredictPickScreenState extends State<PredictPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = Color(0xFF14B8A6);
  static const int gridSize = 1000;

  final _rowController = TextEditingController();
  final _colController = TextEditingController();
  final FocusNode _rowFocus = FocusNode();
  final FocusNode _colFocus = FocusNode();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _scanController;
  late Animation<double> _scanAnimation;

  final List<_DataParticle> _particles = [];
  Timer? _particleTimer;
  final _random = Random();

  // 샘플 과거 당첨 데이터
  final List<Map<String, int>> _pastWinners = [
    {'row': 234, 'col': 567},
    {'row': 789, 'col': 123},
    {'row': 456, 'col': 890},
    {'row': 321, 'col': 654},
    {'row': 987, 'col': 210},
    {'row': 147, 'col': 852},
    {'row': 369, 'col': 741},
    {'row': 582, 'col': 963},
  ];

  int? _previewRow;
  int? _previewCol;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_scanController);

    _startParticleAnimation();

    _rowController.addListener(_updatePreview);
    _colController.addListener(_updatePreview);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    _particleTimer?.cancel();
    _rowController.dispose();
    _colController.dispose();
    _rowFocus.dispose();
    _colFocus.dispose();
    super.dispose();
  }

  void _startParticleAnimation() {
    _particleTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() {
        // Add new particles
        if (_particles.length < 30) {
          _particles.add(_DataParticle(
            x: _random.nextDouble(),
            y: _random.nextDouble(),
            size: 2 + _random.nextDouble() * 3,
            speed: 0.002 + _random.nextDouble() * 0.005,
            opacity: 0.3 + _random.nextDouble() * 0.5,
          ));
        }

        // Update particles
        for (final particle in _particles) {
          particle.y -= particle.speed;
          particle.opacity -= 0.01;
        }

        // Remove dead particles
        _particles.removeWhere((p) => p.y < 0 || p.opacity <= 0);
      });
    });
  }

  void _updatePreview() {
    final row = int.tryParse(_rowController.text);
    final col = int.tryParse(_colController.text);

    setState(() {
      _previewRow = (row != null && row >= 1 && row <= gridSize) ? row : null;
      _previewCol = (col != null && col >= 1 && col <= gridSize) ? col : null;
    });
  }

  void _submitPrediction() {
    final row = int.tryParse(_rowController.text);
    final col = int.tryParse(_colController.text);

    if (row == null ||
        col == null ||
        row < 1 ||
        row > gridSize ||
        col < 1 ||
        col > gridSize) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter coordinates between 1-1000'),
          backgroundColor: modeColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Predict',
      modeColor: modeColor,
      subtitle: 'Your prophecy has been recorded',
      onRetry: _resetPrediction,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _resetPrediction() {
    HapticFeedback.mediumImpact();
    _rowController.clear();
    _colController.clear();
    setState(() {
      _previewRow = null;
      _previewCol = null;
    });
  }

  void _quickSelect(int row, int col) {
    HapticFeedback.lightImpact();
    _rowController.text = row.toString();
    _colController.text = col.toString();
  }

  void _randomPrediction() {
    HapticFeedback.mediumImpact();
    _rowController.text = (_random.nextInt(gridSize) + 1).toString();
    _colController.text = (_random.nextInt(gridSize) + 1).toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'PREDICT',
        emoji: '🌀',
        accentColor: modeColor,
        actions: [
          GestureDetector(
            onTap: _randomPrediction,
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                  Text('🎲', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'RANDOM',
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
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: _previewRow != null && _previewCol != null,
        currentRow: _previewRow,
        currentCol: _previewCol,
        child: Stack(
          children: [
            // Animated background
            AnimatedBuilder(
              animation: Listenable.merge([_pulseAnimation, _scanAnimation]),
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _DataBackgroundPainter(
                    particles: _particles,
                    pulseValue: _pulseAnimation.value,
                    scanValue: _scanAnimation.value,
                    color: modeColor,
                  ),
                );
              },
            ),

            // Main content
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 60),

                  // Heatmap visualization
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            modeColor.withValues(alpha: 0.1),
                            Colors.black.withValues(alpha: 0.5),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: modeColor.withValues(alpha: 0.3),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Stack(
                          children: [
                            // Animated heatmap
                            AnimatedBuilder(
                              animation: _pulseAnimation,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: Size.infinite,
                                  painter: _HeatmapPainter(
                                    winners: _pastWinners,
                                    color: modeColor,
                                    pulseValue: _pulseAnimation.value,
                                    previewRow: _previewRow,
                                    previewCol: _previewCol,
                                  ),
                                );
                              },
                            ),

                            // Scan line effect
                            AnimatedBuilder(
                              animation: _scanAnimation,
                              builder: (context, _) {
                                return CustomPaint(
                                  size: Size.infinite,
                                  painter: _ScanLinePainter(
                                    scanValue: _scanAnimation.value,
                                    color: modeColor,
                                  ),
                                );
                              },
                            ),

                            // Legend
                            Positioned(
                              top: 16,
                              left: 16,
                              child: _buildLegend(),
                            ),

                            // Stats
                            Positioned(
                              top: 16,
                              right: 16,
                              child: _buildStats(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom panel
                  _buildBottomPanel(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HEATMAP',
                style: TextStyle(
                  color: modeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildLegendItem(modeColor, 'Past Winners'),
              const SizedBox(height: 4),
              _buildLegendItem(Colors.amber, 'Your Prediction'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'DATA POINTS',
                style: TextStyle(
                  color: modeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_pastWinners.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
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
            24,
            24,
            MediaQuery.of(context).padding.bottom + 24,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Past winners quick select
              SizedBox(
                height: 40,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _pastWinners.length,
                  itemBuilder: (context, index) {
                    final winner = _pastWinners[index];
                    return GestureDetector(
                      onTap: () => _quickSelect(winner['row']!, winner['col']!),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: modeColor.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '(${winner['row']}, ${winner['col']})',
                          style: TextStyle(
                            color: modeColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Input fields
              Row(
                children: [
                  Expanded(child: _buildInputField('ROW', _rowController, _rowFocus)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildInputField('COL', _colController, _colFocus)),
                ],
              ),

              const SizedBox(height: 20),

              // Submit button
              GestureDetector(
                onTap: _submitPrediction,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
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
                        color: modeColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 10),
                      Text(
                        'SUBMIT PROPHECY',
                        style: TextStyle(
                          color: Colors.white,
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

  Widget _buildInputField(String label, TextEditingController controller, FocusNode focusNode) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: modeColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: modeColor.withValues(alpha: 0.1),
            blurRadius: 10,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: modeColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                TextField(
                  controller: controller,
                  focusNode: focusNode,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                  ],
                  decoration: InputDecoration(
                    hintText: '1-1000',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                      fontSize: 24,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DataParticle {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  _DataParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class _DataBackgroundPainter extends CustomPainter {
  final List<_DataParticle> particles;
  final double pulseValue;
  final double scanValue;
  final Color color;

  _DataBackgroundPainter({
    required this.particles,
    required this.pulseValue,
    required this.scanValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw floating particles
    for (final particle in particles) {
      final paint = Paint()
        ..color = color.withValues(alpha: particle.opacity * 0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(particle.x * size.width, particle.y * size.height),
        particle.size,
        paint,
      );
    }

    // Draw grid connections
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.03)
      ..strokeWidth = 1;

    for (int i = 0; i < 20; i++) {
      final y = size.height * i / 20;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    for (int i = 0; i < 20; i++) {
      final x = size.width * i / 20;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _DataBackgroundPainter oldDelegate) => true;
}

class _HeatmapPainter extends CustomPainter {
  final List<Map<String, int>> winners;
  final Color color;
  final double pulseValue;
  final int? previewRow;
  final int? previewCol;

  _HeatmapPainter({
    required this.winners,
    required this.color,
    required this.pulseValue,
    this.previewRow,
    this.previewCol,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Grid lines
    final gridPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..strokeWidth = 1;

    for (int i = 0; i <= 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw heatmap circles for past winners
    for (int i = 0; i < winners.length; i++) {
      final winner = winners[i];
      final x = (winner['col']! / 1000) * size.width;
      final y = (winner['row']! / 1000) * size.height;

      // Outer glow
      final glowRadius = 30 + pulseValue * 10;
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.1 * pulseValue)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

      canvas.drawCircle(Offset(x, y), glowRadius, glowPaint);

      // Heat gradient
      for (int r = 3; r >= 1; r--) {
        final paint = Paint()
          ..color = color.withValues(alpha: 0.1 + (3 - r) * 0.1)
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 10.0 * r, paint);
      }

      // Center point
      final centerPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 4, centerPaint);
    }

    // Draw preview point
    if (previewRow != null && previewCol != null) {
      final px = (previewCol! / 1000) * size.width;
      final py = (previewRow! / 1000) * size.height;

      // Pulsing outer ring
      final ringRadius = 25 + pulseValue * 15;
      final ringPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.3 * pulseValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset(px, py), ringRadius, ringPaint);

      // Glow
      final previewGlow = Paint()
        ..color = Colors.amber.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      canvas.drawCircle(Offset(px, py), 20, previewGlow);

      // Center
      final previewCenter = Paint()
        ..color = Colors.amber
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(px, py), 8, previewCenter);

      // Cross hairs
      final crossPaint = Paint()
        ..color = Colors.amber.withValues(alpha: 0.5)
        ..strokeWidth = 1;

      canvas.drawLine(Offset(px, 0), Offset(px, size.height), crossPaint);
      canvas.drawLine(Offset(0, py), Offset(size.width, py), crossPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeatmapPainter oldDelegate) => true;
}

class _ScanLinePainter extends CustomPainter {
  final double scanValue;
  final Color color;

  _ScanLinePainter({
    required this.scanValue,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = size.height * scanValue;

    // Scan line
    final scanGradient = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          color.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, y - 30, size.width, 60));

    canvas.drawRect(Rect.fromLTWH(0, y - 30, size.width, 60), scanGradient);

    // Main line
    final linePaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
  }

  @override
  bool shouldRepaint(covariant _ScanLinePainter oldDelegate) => true;
}
