import 'dart:async';
import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Voice Pick - 소리로 좌표 결정
class VoicePickScreen extends StatefulWidget {
  const VoicePickScreen({super.key});

  @override
  State<VoicePickScreen> createState() => _VoicePickScreenState();
}

class _VoicePickScreenState extends State<VoicePickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.primaryLight;
  static const int gridSize = 1000;

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSubscription;

  bool _isRecording = false;
  bool _hasPermission = false;
  double _currentDecibel = 0;
  double _maxDecibel = 0;
  final List<double> _decibelHistory = [];
  final List<double> _visualizerBars = List.filled(20, 0.0);

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _rotateController;

  int _recordingSeconds = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _noiseMeter = NoiseMeter();
    _checkPermission();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _noiseSubscription?.cancel();
    _countdownTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.microphone.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  void _startRecording() {
    if (!_hasPermission) {
      _checkPermission();
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _isRecording = true;
      _decibelHistory.clear();
      _maxDecibel = 0;
      _recordingSeconds = 3;
    });

    _noiseSubscription = _noiseMeter!.noise.listen(
      (NoiseReading reading) {
        setState(() {
          _currentDecibel = reading.meanDecibel;
          if (_currentDecibel > _maxDecibel) {
            _maxDecibel = _currentDecibel;
          }
          _decibelHistory.add(_currentDecibel);

          // 비주얼라이저 업데이트
          _visualizerBars.removeAt(0);
          _visualizerBars.add(((_currentDecibel - 30) / 70).clamp(0.0, 1.0));
        });
      },
      onError: (Object error) {
        debugPrint('Noise meter error: $error');
      },
    );

    // 카운트다운 타이머
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingSeconds--;
      });
      if (_recordingSeconds <= 0) {
        timer.cancel();
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    _noiseSubscription?.cancel();
    _countdownTimer?.cancel();

    setState(() {
      _isRecording = false;
    });

    if (_decibelHistory.isEmpty) return;

    HapticFeedback.heavyImpact();

    final avgDecibel =
        _decibelHistory.reduce((a, b) => a + b) / _decibelHistory.length;
    final normalizedAvg = ((avgDecibel - 30) / 70).clamp(0.0, 1.0);
    final normalizedMax = ((_maxDecibel - 30) / 70).clamp(0.0, 1.0);

    final row = (normalizedAvg * gridSize).round().clamp(1, gridSize);
    final col = (normalizedMax * gridSize).round().clamp(1, gridSize);

    CoordinateResultDialog.show(
      context,
      row: row,
      col: col,
      modeName: 'Voice',
      modeColor: modeColor,
      subtitle: 'Avg: ${avgDecibel.toStringAsFixed(1)}dB | Max: ${_maxDecibel.toStringAsFixed(1)}dB',
      onRetry: () {
        setState(() {
          _currentDecibel = 0;
          _maxDecibel = 0;
          _decibelHistory.clear();
          for (int i = 0; i < _visualizerBars.length; i++) {
            _visualizerBars[i] = 0.0;
          }
        });
      },
      onClose: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final normalizedAvg = _decibelHistory.isNotEmpty
        ? ((_decibelHistory.reduce((a, b) => a + b) / _decibelHistory.length - 30) / 70)
            .clamp(0.0, 1.0)
        : 0.0;
    final normalizedMax = ((_maxDecibel - 30) / 70).clamp(0.0, 1.0);

    final currentRow = (normalizedAvg * gridSize).round().clamp(1, gridSize);
    final currentCol = (normalizedMax * gridSize).round().clamp(1, gridSize);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'VOICE',
        emoji: '🔊',
        accentColor: modeColor,
      ),
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: _decibelHistory.isNotEmpty,
        currentRow: _decibelHistory.isNotEmpty ? currentRow : null,
        currentCol: _decibelHistory.isNotEmpty ? currentCol : null,
        child: Column(
          children: [
            const Spacer(),

            // 메인 비주얼라이저
            _buildMainVisualizer(),

            const SizedBox(height: 40),

            // 데시벨 표시
            _buildDecibelDisplay(),

            const Spacer(),

            // 하단 컨트롤
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVisualizer() {
    return SizedBox(
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 회전하는 외부 링
          AnimatedBuilder(
            animation: _rotateController,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateController.value * 2 * pi,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: modeColor.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: CustomPaint(
                    painter: _RingPatternPainter(modeColor),
                  ),
                ),
              );
            },
          ),

          // 비주얼라이저 바
          SizedBox(
            width: 250,
            height: 200,
            child: CustomPaint(
              painter: _VisualizerPainter(
                bars: _visualizerBars,
                color: modeColor,
                isRecording: _isRecording,
              ),
            ),
          ),

          // 중앙 마이크 버튼
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              final scale = _isRecording ? 1.0 + ((_currentDecibel - 30) / 70).clamp(0.0, 0.3) : _pulseAnimation.value;
              return Transform.scale(
                scale: scale,
                child: GestureDetector(
                  onTap: _isRecording ? null : _startRecording,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _isRecording
                            ? [modeColor, modeColor.withValues(alpha: 0.7)]
                            : [modeColor.withValues(alpha: 0.3), modeColor.withValues(alpha: 0.1)],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: modeColor.withValues(alpha: _isRecording ? 0.6 : 0.2),
                          blurRadius: _isRecording ? 40 : 20,
                          spreadRadius: _isRecording ? 10 : 0,
                        ),
                      ],
                      border: Border.all(
                        color: modeColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isRecording ? Icons.mic : Icons.mic_none_rounded,
                          size: _isRecording ? 40 : 36,
                          color: Colors.white,
                        ),
                        if (_isRecording)
                          Text(
                            '$_recordingSeconds',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDecibelDisplay() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: modeColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildDecibelItem('CURRENT', _currentDecibel, true),
          Container(
            width: 1,
            height: 50,
            color: modeColor.withValues(alpha: 0.3),
          ),
          _buildDecibelItem('MAX', _maxDecibel, false),
        ],
      ),
    );
  }

  Widget _buildDecibelItem(String label, double value, bool isPrimary) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                color: isPrimary ? modeColor : Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                'dB',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
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
              // 설명
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoChip(Icons.equalizer_rounded, 'AVG → ROW'),
                  _buildInfoChip(Icons.trending_up_rounded, 'MAX → COL'),
                ],
              ),

              const SizedBox(height: 20),

              // 상태 텍스트
              Text(
                _isRecording
                    ? 'Listening... Make some noise!'
                    : _hasPermission
                        ? 'Tap the microphone to start'
                        : 'Microphone permission required',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),

              if (!_hasPermission) ...[
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: _checkPermission,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: modeColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: modeColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.settings_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'GRANT PERMISSION',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: modeColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPatternPainter extends CustomPainter {
  final Color color;

  _RingPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 점선 패턴
    for (int i = 0; i < 36; i++) {
      final angle = i * pi / 18;
      final start = Offset(
        center.dx + (radius - 5) * cos(angle),
        center.dy + (radius - 5) * sin(angle),
      );
      final end = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _VisualizerPainter extends CustomPainter {
  final List<double> bars;
  final Color color;
  final bool isRecording;

  _VisualizerPainter({
    required this.bars,
    required this.color,
    required this.isRecording,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final barWidth = size.width / bars.length - 4;
    final maxHeight = size.height * 0.7;

    for (int i = 0; i < bars.length; i++) {
      final x = i * (barWidth + 4) + 2;
      final barHeight = max(4.0, bars[i] * maxHeight);
      final y = (size.height - barHeight) / 2;

      // 그라데이션 바
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(2),
      );

      final gradient = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color.withValues(alpha: 0.3),
          color.withValues(alpha: isRecording ? 0.8 : 0.4),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(rect.outerRect)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VisualizerPainter oldDelegate) => true;
}
