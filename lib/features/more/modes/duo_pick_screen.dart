import 'dart:math';
import 'dart:ui';
import '../../../../core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/coordinate_result_dialog.dart';
import '../widgets/game_canvas.dart';

/// Duo Pick - 친구와 좌표 합체
class DuoPickScreen extends StatefulWidget {
  const DuoPickScreen({super.key});

  @override
  State<DuoPickScreen> createState() => _DuoPickScreenState();
}

class _DuoPickScreenState extends State<DuoPickScreen>
    with TickerProviderStateMixin {
  static const Color modeColor = AppColors.blue;
  static const Color friendColor = AppColors.primaryLight;
  static const int gridSize = 1000;

  final _myRowController = TextEditingController();
  final _myColController = TextEditingController();
  final _friendRowController = TextEditingController();
  final _friendColController = TextEditingController();

  int? _myRow;
  int? _myCol;
  int? _friendRow;
  int? _friendCol;

  String _combineMethod = 'average';

  final _random = Random();

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _orbitController;
  late Animation<double> _orbitAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _orbitAnimation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      CurvedAnimation(parent: _orbitController, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _myRowController.dispose();
    _myColController.dispose();
    _friendRowController.dispose();
    _friendColController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    super.dispose();
  }

  void _generateMyCoordinate() {
    HapticFeedback.mediumImpact();
    final row = _random.nextInt(gridSize) + 1;
    final col = _random.nextInt(gridSize) + 1;

    setState(() {
      _myRow = row;
      _myCol = col;
      _myRowController.text = row.toString();
      _myColController.text = col.toString();
    });
  }

  void _generateFriendCoordinate() {
    HapticFeedback.mediumImpact();
    final row = _random.nextInt(gridSize) + 1;
    final col = _random.nextInt(gridSize) + 1;

    setState(() {
      _friendRow = row;
      _friendCol = col;
      _friendRowController.text = row.toString();
      _friendColController.text = col.toString();
    });
  }

  void _combineCoordinates() {
    if (_myRow == null ||
        _myCol == null ||
        _friendRow == null ||
        _friendCol == null) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Enter both coordinates first!'),
          backgroundColor: modeColor,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    HapticFeedback.heavyImpact();

    int finalRow, finalCol;

    switch (_combineMethod) {
      case 'xor':
        finalRow = (_myRow! ^ _friendRow!).clamp(1, gridSize);
        finalCol = (_myCol! ^ _friendCol!).clamp(1, gridSize);
        break;
      case 'add':
        finalRow = ((_myRow! + _friendRow!) % gridSize).clamp(1, gridSize);
        finalCol = ((_myCol! + _friendCol!) % gridSize).clamp(1, gridSize);
        break;
      case 'average':
      default:
        finalRow = ((_myRow! + _friendRow!) ~/ 2).clamp(1, gridSize);
        finalCol = ((_myCol! + _friendCol!) ~/ 2).clamp(1, gridSize);
    }

    CoordinateResultDialog.show(
      context,
      row: finalRow,
      col: finalCol,
      modeName: 'Duo',
      modeColor: modeColor,
      subtitle: 'Combined using $_combineMethod',
      onRetry: _resetAll,
      onClose: () => Navigator.of(context).pop(),
    );
  }

  void _resetAll() {
    HapticFeedback.mediumImpact();
    setState(() {
      _myRow = null;
      _myCol = null;
      _friendRow = null;
      _friendCol = null;
      _myRowController.clear();
      _myColController.clear();
      _friendRowController.clear();
      _friendColController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasMyCoord = _myRow != null && _myCol != null;
    final hasFriendCoord = _friendRow != null && _friendCol != null;

    // 미리보기 좌표 계산
    int? previewRow, previewCol;
    if (hasMyCoord && hasFriendCoord) {
      switch (_combineMethod) {
        case 'xor':
          previewRow = (_myRow! ^ _friendRow!).clamp(1, gridSize);
          previewCol = (_myCol! ^ _friendCol!).clamp(1, gridSize);
          break;
        case 'add':
          previewRow = ((_myRow! + _friendRow!) % gridSize).clamp(1, gridSize);
          previewCol = ((_myCol! + _friendCol!) % gridSize).clamp(1, gridSize);
          break;
        case 'average':
        default:
          previewRow = ((_myRow! + _friendRow!) ~/ 2).clamp(1, gridSize);
          previewCol = ((_myCol! + _friendCol!) ~/ 2).clamp(1, gridSize);
      }
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: GameAppBar(
        title: 'DUO',
        emoji: '👥',
        accentColor: modeColor,
      ),
      body: GameCanvas(
        accentColor: modeColor,
        showCoordinate: previewRow != null && previewCol != null,
        currentRow: previewRow,
        currentCol: previewCol,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            16,
            100,
            16,
            MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            children: [
              // 합체 비주얼라이저
              _buildCombineVisualizer(hasMyCoord, hasFriendCoord),

              const SizedBox(height: 24),

              // 내 좌표 카드
              _buildCoordinateCard(
                title: 'MY COORDINATE',
                emoji: '🙋',
                color: modeColor,
                rowController: _myRowController,
                colController: _myColController,
                onRowChanged: (v) => setState(() => _myRow = int.tryParse(v)),
                onColChanged: (v) => setState(() => _myCol = int.tryParse(v)),
                onRandom: _generateMyCoordinate,
                hasValue: hasMyCoord,
              ),

              const SizedBox(height: 16),

              // 친구 좌표 카드
              _buildCoordinateCard(
                title: 'FRIEND COORDINATE',
                emoji: '👤',
                color: friendColor,
                rowController: _friendRowController,
                colController: _friendColController,
                onRowChanged: (v) =>
                    setState(() => _friendRow = int.tryParse(v)),
                onColChanged: (v) =>
                    setState(() => _friendCol = int.tryParse(v)),
                onRandom: _generateFriendCoordinate,
                hasValue: hasFriendCoord,
              ),

              const SizedBox(height: 24),

              // 합체 방식 선택
              _buildMethodSelector(),

              const SizedBox(height: 24),

              // 합체 버튼
              _buildCombineButton(hasMyCoord && hasFriendCoord),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombineVisualizer(bool hasMyCoord, bool hasFriendCoord) {
    return AnimatedBuilder(
      animation: Listenable.merge([_pulseAnimation, _orbitAnimation]),
      builder: (context, _) {
        return Container(
          height: 120,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                modeColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.1),
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 궤도
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),

              // 내 좌표 (왼쪽)
              Transform.translate(
                offset: Offset(
                  -40 + (hasMyCoord ? cos(_orbitAnimation.value) * 10 : 0),
                  hasMyCoord ? sin(_orbitAnimation.value) * 10 : 0,
                ),
                child: _buildOrbitDot(
                  color: modeColor,
                  emoji: '🙋',
                  active: hasMyCoord,
                  scale: _pulseAnimation.value,
                ),
              ),

              // 친구 좌표 (오른쪽)
              Transform.translate(
                offset: Offset(
                  40 +
                      (hasFriendCoord
                          ? cos(_orbitAnimation.value + pi) * 10
                          : 0),
                  hasFriendCoord ? sin(_orbitAnimation.value + pi) * 10 : 0,
                ),
                child: _buildOrbitDot(
                  color: friendColor,
                  emoji: '👤',
                  active: hasFriendCoord,
                  scale: _pulseAnimation.value,
                ),
              ),

              // 중앙 합체 아이콘
              if (hasMyCoord && hasFriendCoord)
                Container(
                  width: 50 * _pulseAnimation.value,
                  height: 50 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        modeColor.withValues(alpha: 0.8),
                        friendColor.withValues(alpha: 0.8),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: modeColor.withValues(alpha: 0.5),
                        blurRadius: 20 * _pulseAnimation.value,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('💫', style: TextStyle(fontSize: 24)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrbitDot({
    required Color color,
    required String emoji,
    required bool active,
    required double scale,
  }) {
    return Container(
      width: 40 * (active ? scale : 0.8),
      height: 40 * (active ? scale : 0.8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
        border: Border.all(
          color: active ? color : Colors.white.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 15,
                ),
              ]
            : null,
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(
            fontSize: active ? 18 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCoordinateCard({
    required String title,
    required String emoji,
    required Color color,
    required TextEditingController rowController,
    required TextEditingController colController,
    required Function(String) onRowChanged,
    required Function(String) onColChanged,
    required VoidCallback onRandom,
    required bool hasValue,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: hasValue ? 0.2 : 0.1),
                color.withValues(alpha: hasValue ? 0.1 : 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: color.withValues(alpha: hasValue ? 0.4 : 0.2),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(emoji, style: const TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        if (hasValue)
                          Text(
                            '(${rowController.text}, ${colController.text})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 랜덤 버튼
                  GestureDetector(
                    onTap: onRandom,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎲', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'RANDOM',
                            style: TextStyle(
                              color: color,
                              fontSize: 11,
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

              const SizedBox(height: 16),

              // 입력 필드들
              Row(
                children: [
                  Expanded(
                    child: _buildInputField(
                      label: 'ROW',
                      controller: rowController,
                      onChanged: onRowChanged,
                      color: color,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInputField(
                      label: 'COL',
                      controller: colController,
                      onChanged: onColChanged,
                      color: color,
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

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: onChanged,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: '1-1000',
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.2),
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: color, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'COMBINE METHOD',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMethodChip('average', 'AVG', '➗'),
              const SizedBox(width: 10),
              _buildMethodChip('xor', 'XOR', '⊕'),
              const SizedBox(width: 10),
              _buildMethodChip('add', 'ADD', '➕'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodChip(String value, String label, String emoji) {
    final isSelected = _combineMethod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          setState(() => _combineMethod = value);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      modeColor,
                      friendColor,
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: modeColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombineButton(bool canCombine) {
    return GestureDetector(
      onTap: canCombine ? _combineCoordinates : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: canCombine
              ? LinearGradient(
                  colors: [
                    modeColor,
                    friendColor,
                  ],
                )
              : null,
          color: canCombine ? null : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: canCombine
              ? [
                  BoxShadow(
                    color: modeColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('💫', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(
              'COMBINE COORDINATES',
              style: TextStyle(
                color: canCombine
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.3),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
