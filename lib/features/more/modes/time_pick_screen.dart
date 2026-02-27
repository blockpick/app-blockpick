import 'dart:async';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Time Pick - 누른 순간의 밀리초가 좌표
class TimePickScreen extends StatefulWidget {
  const TimePickScreen({super.key});

  @override
  State<TimePickScreen> createState() => _TimePickScreenState();
}

class _TimePickScreenState extends State<TimePickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.yellow;
  static const int gridSize = 1000;

  Timer? _timer;
  int _milliseconds = 0;
  bool _isRunning = true;
  int? _capturedRow;
  int? _capturedCol;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startTimer();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 10), (_) {
      if (_isRunning) {
        setState(() {
          _milliseconds = DateTime.now().millisecondsSinceEpoch % 1000000;
        });
      }
    });
  }

  void _captureTime() {
    HapticFeedback.heavyImpact();
    setState(() {
      _isRunning = false;
    });

    final now = DateTime.now();
    final row = ((now.millisecond * 10 + now.second) % gridSize) + 1;
    final col = ((now.microsecond ~/ 1000 + now.minute * 10) % gridSize) + 1;

    _capturedRow = row;
    _capturedCol = col;

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Time',
      modeColor: modeColor,
      subtitle: 'Captured at ${now.hour}:${now.minute}:${now.second}.${now.millisecond}',
      onRetry: () {
        setState(() {
          _isRunning = true;
          _capturedRow = null;
          _capturedCol = null;
        });
      },
      onClose: () => Navigator.of(context).pop(),
    );
  }

  String _formatMilliseconds(int ms) {
    return ms.toString().padLeft(6, '0');
  }

  @override
  Widget build(BuildContext context) {
    final displayMs = _formatMilliseconds(_milliseconds);
    final currentRow = _capturedRow ?? ((_milliseconds % gridSize) + 1);
    final currentCol = _capturedCol ?? (((_milliseconds ~/ 1000) % gridSize) + 1);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'TIME',
        emoji: '⏱️',
        accentColor: modeColor,
      ),
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: true,
        currentRow: currentRow,
        currentCol: currentCol,
        child: Column(
          children: [
            const Spacer(),

            // 타이머 디스플레이
            _buildTimerDisplay(displayMs),

            const SizedBox(height: 48),

            // 상태 텍스트
            _buildStatusText(),

            const Spacer(),

            // 하단 컨트롤
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimerDisplay(String displayMs) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
      builder: (context, child) {
        return Transform.scale(
          scale: _isRunning ? _pulseAnimation.value : 1.0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: modeColor.withValues(alpha: 0.4),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: modeColor.withValues(alpha: 0.3 * _glowAnimation.value),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                // MILLISECONDS 라벨
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'MILLISECONDS',
                    style: TextStyle(
                      color: modeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 숫자 디스플레이
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: displayMs.split('').asMap().entries.map((entry) {
                    final index = entry.key;
                    final char = entry.value;
                    final isHighlight = index < 3;

                    return Container(
                      width: 44,
                      height: 64,
                      margin: EdgeInsets.only(
                        left: 3,
                        right: index == 2 ? 12 : 3,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            (isHighlight ? modeColor : Colors.white)
                                .withValues(alpha: 0.15),
                            (isHighlight ? modeColor : Colors.white)
                                .withValues(alpha: 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: (isHighlight ? modeColor : Colors.white)
                              .withValues(alpha: 0.3),
                        ),
                        boxShadow: isHighlight
                            ? [
                                BoxShadow(
                                  color: modeColor.withValues(alpha: 0.3),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          char,
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: isHighlight ? modeColor : Colors.white,
                            fontFamily: 'monospace',
                            shadows: isHighlight
                                ? [
                                    Shadow(
                                      color: modeColor.withValues(alpha: 0.8),
                                      blurRadius: 15,
                                    ),
                                  ]
                                : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // 구분선
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLabelChip('ROW', true),
                    const SizedBox(width: 80),
                    _buildLabelChip('COL', false),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabelChip(String label, bool isRow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildStatusText() {
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _isRunning ? 'CATCH THE MOMENT' : 'TIME CAPTURED',
            key: ValueKey(_isRunning),
            style: TextStyle(
              color: _isRunning ? Colors.white : modeColor,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isRunning
              ? 'The exact moment you tap becomes your coordinate'
              : 'Your moment has been locked',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
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
            28,
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
          child: GestureDetector(
            onTap: _isRunning ? _captureTime : null,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isRunning ? 1.0 + (_pulseAnimation.value - 1.0) * 0.3 : 1.0,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      gradient: _isRunning
                          ? LinearGradient(
                              colors: [
                                modeColor,
                                modeColor.withValues(alpha: 0.7),
                              ],
                            )
                          : null,
                      color: _isRunning ? null : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: _isRunning
                          ? [
                              BoxShadow(
                                color: modeColor.withValues(alpha: 0.5),
                                blurRadius: 25,
                                offset: const Offset(0, 8),
                              ),
                            ]
                          : null,
                      border: _isRunning
                          ? null
                          : Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRunning ? Icons.touch_app_rounded : Icons.check_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _isRunning ? 'CAPTURE NOW' : 'CAPTURED',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
