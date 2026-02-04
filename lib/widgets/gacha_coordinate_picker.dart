import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

/// Gacha 스타일 좌표 선택 위젯 (토스 디자인)
class GachaCoordinatePicker extends StatefulWidget {
  /// 경품 이미지 URL
  final String? imageUrl;

  /// 그리드 가로 크기 (COL)
  final int gridWidth;

  /// 그리드 세로 크기 (ROW)
  final int gridHeight;

  /// 좌표 선택 완료 콜백
  final Function(int row, int col) onCoordinateSelected;

  /// 악센트 컬러
  final Color accentColor;

  /// ROW 축 이동 속도 (밀리초)
  final int rowSpeed;

  /// COL 축 이동 속도 (밀리초)
  final int colSpeed;

  /// 이벤트 모드 활성화
  final bool eventMode;

  /// 타겟 좌표 리스트 (이벤트 모드)
  final List<Point<int>> targetCoordinates;

  /// 허용 범위 (이벤트 모드)
  final int allowedRange;

  /// 타겟 좌표 표시 여부
  final bool showTarget;

  /// 이벤트 성공 콜백
  final VoidCallback? onEventSuccess;

  /// 가이드선 표시 여부
  final bool showGuideLine;

  /// 가이드선 X 좌표 (COL)
  final int? guideX;

  /// 가이드선 Y 좌표 (ROW)
  final int? guideY;

  /// 전체 화면 모드 (플로팅 UI 사용)
  final bool fullScreenMode;

  const GachaCoordinatePicker({
    super.key,
    this.imageUrl,
    this.gridWidth = 10000,
    this.gridHeight = 10000,
    required this.onCoordinateSelected,
    this.accentColor = AppColors.darkBlue,
    this.rowSpeed = 2000,
    this.colSpeed = 1800,
    this.eventMode = false,
    this.targetCoordinates = const [],
    this.allowedRange = 10,
    this.showTarget = true,
    this.onEventSuccess,
    this.showGuideLine = false,
    this.guideX,
    this.guideY,
    this.fullScreenMode = false,
  });

  @override
  GachaCoordinatePickerState createState() => GachaCoordinatePickerState();
}

class GachaCoordinatePickerState extends State<GachaCoordinatePicker>
    with TickerProviderStateMixin {
  late AnimationController _verticalController;
  late AnimationController _horizontalController;
  late AnimationController _pulseController;

  // 0: ROW 이동 중, 1: COL 이동 중, 2: 완료
  int _phase = 0;
  double _fixedVertical = 0.5;
  double _fixedHorizontal = 0.5;

  // 현재 속도 (동적 변경 가능)
  late int _currentRowSpeed;
  late int _currentColSpeed;

  // 캔버스 최대 크기 (태블릿/웹에서 너무 커지는 것 방지)
  static const double _maxCanvasSize = 600.0;

  @override
  void initState() {
    super.initState();
    _currentRowSpeed = widget.rowSpeed;
    _currentColSpeed = widget.colSpeed;

    _verticalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _currentRowSpeed),
    );

    _horizontalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _currentColSpeed),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  /// ROW 속도 변경 (밀리초)
  void setRowSpeed(int speed) {
    _currentRowSpeed = speed;
    _verticalController.duration = Duration(milliseconds: speed);
    if (_phase == 1) {
      _verticalController.repeat(reverse: true);
    }
  }

  /// COL 속도 변경 (밀리초)
  void setColSpeed(int speed) {
    _currentColSpeed = speed;
    _horizontalController.duration = Duration(milliseconds: speed);
    if (_phase == 0) {
      _horizontalController.repeat(reverse: true);
    }
  }

  /// 애니메이션 값을 COL 좌표로 변환
  int _valueToCol(double value) {
    return (value * widget.gridWidth).round().clamp(0, widget.gridWidth);
  }

  /// 애니메이션 값을 ROW 좌표로 변환
  int _valueToRow(double value) {
    return (value * widget.gridHeight).round().clamp(0, widget.gridHeight);
  }

  /// 이벤트 성공 여부 체크 (하나라도 맞으면 성공)
  bool _checkEventSuccess(int row, int col) {
    if (!widget.eventMode || widget.targetCoordinates.isEmpty) return false;

    for (final target in widget.targetCoordinates) {
      final rowDiff = (row - target.x).abs();
      final colDiff = (col - target.y).abs();

      if (rowDiff <= widget.allowedRange && colDiff <= widget.allowedRange) {
        return true;
      }
    }
    return false;
  }

  @override
  void dispose() {
    _verticalController.dispose();
    _horizontalController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onButtonPressed() {
    HapticFeedback.mediumImpact();

    if (_phase == 0) {
      // X (COL) 고정
      setState(() {
        _fixedHorizontal = _horizontalController.value;
        _phase = 1;
      });
      _horizontalController.stop();
      _verticalController.duration = Duration(milliseconds: _currentRowSpeed);
      _verticalController.repeat(reverse: true);
    } else if (_phase == 1) {
      // Y (ROW) 고정 → 완료
      setState(() {
        _fixedVertical = _verticalController.value;
        _phase = 2;
      });
      _verticalController.stop();

      Future.delayed(const Duration(milliseconds: 300), () {
        final row = _valueToRow(_fixedVertical);
        final col = _valueToCol(_fixedHorizontal);

        // 이벤트 모드에서 성공 체크
        if (widget.eventMode && _checkEventSuccess(row, col)) {
          widget.onEventSuccess?.call();
        }

        widget.onCoordinateSelected(row, col);
      });
    }
  }

  void reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _phase = 0;
      _fixedVertical = 0.5;
      _fixedHorizontal = 0.5;
    });
    _verticalController.stop();
    _verticalController.reset();
    _horizontalController.repeat(reverse: true);
  }

  int get currentCol => _phase == 0
      ? _valueToCol(_horizontalController.value)
      : _valueToCol(_fixedHorizontal);

  int? get currentRow => _phase < 1
      ? null
      : _phase == 1
          ? _valueToRow(_verticalController.value)
          : _valueToRow(_fixedVertical);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _verticalController,
        _horizontalController,
        _pulseController,
      ]),
      builder: (context, _) {
        // 전체 화면 모드: 플로팅 UI
        if (widget.fullScreenMode) {
          return _buildFullScreenLayout();
        }
        // 기본 모드: 스크롤 가능한 레이아웃
        return _buildDefaultLayout();
      },
    );
  }

  /// 기본 레이아웃
  Widget _buildDefaultLayout() {
    return Column(
      children: [
        // 게임 캔버스 (1:1 비율, 최대 크기 제한)
        Expanded(
          child: Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final canvasSize = min(
                  min(constraints.maxWidth, constraints.maxHeight),
                  _maxCanvasSize,
                );
                return SizedBox(
                  width: canvasSize,
                  height: canvasSize,
                  child: _buildGameCanvas(),
                );
              },
            ),
          ),
        ),

        // 하단 컨트롤
        _buildBottomControls(),
      ],
    );
  }

  /// 전체 화면 레이아웃 (플로팅 UI)
  Widget _buildFullScreenLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 가로/세로 중 작은 쪽 기준 1:1 캔버스 + 최대 크기 제한
        final canvasSize = min(min(constraints.maxWidth, constraints.maxHeight), _maxCanvasSize);

        return Stack(
          children: [
            // 중앙: 1:1 비율 게임 캔버스
            Center(
              child: SizedBox(
                width: canvasSize,
                height: canvasSize,
                child: _buildGameCanvas(),
              ),
            ),

            // 상단: 단계 인디케이터 (플로팅)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: _buildFloatingPhaseIndicator(),
            ),

            // 하단: 좌표 표시 + 버튼 (플로팅)
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: _buildFloatingBottomControls(),
            ),
          ],
        );
      },
    );
  }

  /// 기본 하단 컨트롤
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 좌표 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // X (COL)
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'X (COL)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        currentCol.toString().padLeft(4, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _phase >= 1
                              ? widget.accentColor
                              : AppColors.darkBlue,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                // 구분선
                Container(
                  width: 1,
                  height: 28,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  color: AppColors.gray300,
                ),
                // Y (ROW)
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Y (ROW)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        (currentRow ?? 0).toString().padLeft(4, '0'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _phase >= 2
                              ? widget.accentColor
                              : AppColors.gray400,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 액션 버튼
          GestureDetector(
            onTap: _phase < 2 ? _onButtonPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: _phase < 2 ? widget.accentColor : AppColors.gray300,
                borderRadius: BorderRadius.circular(14),
                boxShadow: _phase < 2
                    ? [
                        BoxShadow(
                          color: widget.accentColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _phase == 0
                      ? 'X (COL) 좌표 선택'
                      : _phase == 1
                          ? 'Y (ROW) 좌표 선택'
                          : '선택 완료',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 초기화 링크
          GestureDetector(
            onTap: _phase > 0 ? reset : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    size: 14,
                    color: _phase > 0 ? AppColors.gray500 : Colors.transparent,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '초기화',
                    style: TextStyle(
                      fontSize: 13,
                      color: _phase > 0 ? AppColors.gray500 : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 게임 캔버스 (1:1 비율)
  Widget _buildGameCanvas() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(0),
      child: Stack(
        children: [
          // 경품 이미지
          Positioned.fill(
            child: _buildProductImage(),
          ),

          // 오버레이
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.35),
                  ],
                ),
              ),
            ),
          ),

          // 그리드
          Positioned.fill(
            child: CustomPaint(
              painter: _TossGridPainter(),
            ),
          ),

          // 크로스헤어
          Positioned.fill(
            child: CustomPaint(
              painter: _TossCrosshairPainter(
                phase: _phase,
                horizontalPos: _phase == 0
                    ? _horizontalController.value
                    : _fixedHorizontal,
                verticalPos: _phase >= 1
                    ? (_phase == 1
                        ? _verticalController.value
                        : _fixedVertical)
                    : 0.5,
                accentColor: widget.accentColor,
                pulseValue: _pulseController.value,
                // 이벤트 모드 관련
                showTarget: widget.eventMode && widget.showTarget,
                targetCoordinates: widget.targetCoordinates,
                allowedRange: widget.allowedRange,
                gridWidth: widget.gridWidth,
                gridHeight: widget.gridHeight,
                // 가이드선 관련
                showGuideLine: widget.showGuideLine,
                guideX: widget.guideX,
                guideY: widget.guideY,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 플로팅 단계 인디케이터
  Widget _buildFloatingPhaseIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildCompactPhaseStep(0, 'X(COL)', Icons.swap_horiz_rounded)),
          _buildCompactConnector(0),
          Expanded(child: _buildCompactPhaseStep(1, 'Y(ROW)', Icons.swap_vert_rounded)),
          _buildCompactConnector(1),
          Expanded(child: _buildCompactPhaseStep(2, '완료', Icons.check_rounded)),
        ],
      ),
    );
  }

  /// 컴팩트 단계 스텝
  Widget _buildCompactPhaseStep(int phaseNum, String label, IconData icon) {
    final isActive = _phase == phaseNum;
    final isDone = _phase > phaseNum;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isDone
                ? AppColors.green
                : isActive
                    ? widget.accentColor
                    : AppColors.gray200,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isDone ? Icons.check_rounded : icon,
            size: 16,
            color: (isDone || isActive) ? AppColors.white : AppColors.gray500,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? widget.accentColor : AppColors.gray500,
          ),
        ),
      ],
    );
  }

  /// 컴팩트 연결선
  Widget _buildCompactConnector(int afterPhase) {
    final isDone = _phase > afterPhase;

    return Container(
      width: 20,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: isDone ? AppColors.green : AppColors.gray200,
    );
  }

  /// 플로팅 하단 컨트롤
  Widget _buildFloatingBottomControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 좌표 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildCompactCoordDisplay('X(COL)', currentCol, _phase >= 1),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '×',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: AppColors.gray400,
                  ),
                ),
              ),
              _buildCompactCoordDisplay('Y(ROW)', currentRow ?? 0, _phase >= 2),
            ],
          ),

          const SizedBox(height: 12),

          // 버튼
          Row(
            children: [
              // 리셋 버튼
              if (_phase > 0)
                GestureDetector(
                  onTap: reset,
                  child: Container(
                    width: 48,
                    height: 48,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.gray600,
                      size: 22,
                    ),
                  ),
                ),

              // 메인 버튼
              Expanded(
                child: GestureDetector(
                  onTap: _phase < 2 ? _onButtonPressed : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _phase < 2 ? widget.accentColor : AppColors.gray300,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: _phase < 2
                          ? [
                              BoxShadow(
                                color: widget.accentColor.withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        _phase == 0
                            ? 'X (COL) 좌표 선택'
                            : _phase == 1
                                ? 'Y (ROW) 좌표 선택'
                                : '선택 완료',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  /// 컴팩트 좌표 표시
  Widget _buildCompactCoordDisplay(String label, int value, bool isLocked) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value.toString().padLeft(4, '0'),
          style: TextStyle(
            color: isLocked ? widget.accentColor : AppColors.gray400,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildProductImage() {
    final url = widget.imageUrl;

    if (url == null || url.isEmpty) {
      return _buildPlaceholder();
    }

    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url.replaceAll(' ', '%20'),
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    return Image.asset(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.gray400,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: Center(
        child: Icon(
          Icons.card_giftcard_rounded,
          size: 64,
          color: AppColors.gray300,
        ),
      ),
    );
  }
}

/// 토스 스타일 그리드 페인터
class _TossGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.2)
      ..strokeWidth = 1;

    // 10x10 그리드
    for (int i = 1; i < 10; i++) {
      final x = size.width * i / 10;
      final y = size.height * i / 10;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 토스 스타일 크로스헤어 페인터
class _TossCrosshairPainter extends CustomPainter {
  final int phase;
  final double verticalPos;
  final double horizontalPos;
  final Color accentColor;
  final double pulseValue;
  // 이벤트 모드 관련
  final bool showTarget;
  final List<Point<int>> targetCoordinates;
  final int allowedRange;
  final int gridWidth;
  final int gridHeight;
  // 가이드선 관련
  final bool showGuideLine;
  final int? guideX;
  final int? guideY;

  _TossCrosshairPainter({
    required this.phase,
    required this.verticalPos,
    required this.horizontalPos,
    required this.accentColor,
    required this.pulseValue,
    this.showTarget = false,
    this.targetCoordinates = const [],
    this.allowedRange = 10,
    this.gridWidth = 10000,
    this.gridHeight = 10000,
    this.showGuideLine = false,
    this.guideX,
    this.guideY,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = verticalPos * size.height;
    final x = horizontalPos * size.width;

    // 가이드선 표시
    if (showGuideLine) {
      _drawGuideLine(canvas, size);
    }

    // 타겟 좌표들 표시 (이벤트 모드)
    if (showTarget && targetCoordinates.isNotEmpty) {
      for (final target in targetCoordinates) {
        _drawTargetArea(canvas, size, target);
      }
    }

    // COL 라인 (세로) - Phase 0부터 표시
    if (phase >= 0) {
      final isMoving = phase == 0;
      final lineColor = isMoving ? AppColors.blue : accentColor;
      final alpha = isMoving ? 0.6 + pulseValue * 0.4 : 1.0;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.2 * alpha)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), glowPaint);

      // 메인 라인
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: alpha)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);

      // 상하 마커
      _drawMarker(canvas, Offset(x, 16), lineColor, isMoving);
      _drawMarker(canvas, Offset(x, size.height - 16), lineColor, isMoving);
    }

    // ROW 라인 (가로) - Phase 1부터 표시
    if (phase >= 1) {
      final isMoving = phase == 1;
      final lineColor = isMoving ? AppColors.green : accentColor;
      final alpha = isMoving ? 0.6 + pulseValue * 0.4 : 1.0;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = lineColor.withValues(alpha: 0.2 * alpha)
        ..strokeWidth = 8
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), glowPaint);

      // 메인 라인
      final linePaint = Paint()
        ..color = lineColor.withValues(alpha: alpha)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);

      // 좌우 마커
      _drawMarker(canvas, Offset(16, y), lineColor, isMoving);
      _drawMarker(canvas, Offset(size.width - 16, y), lineColor, isMoving);
    }

    // 교차점
    if (phase >= 1) {
      final crossPoint = Offset(x, y);

      // 외곽 원
      final outerPaint = Paint()
        ..color = accentColor.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(crossPoint, 24, outerPaint);

      // 중간 원
      final middlePaint = Paint()
        ..color = accentColor.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(crossPoint, 16, middlePaint);

      // 중심점
      final centerPaint = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(crossPoint, 6, centerPaint);

      // 중심점 테두리
      final centerBorderPaint = Paint()
        ..color = accentColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(crossPoint, 6, centerBorderPaint);
    }
  }

  void _drawMarker(Canvas canvas, Offset position, Color color, bool animate) {
    final size = animate ? 6 + pulseValue * 2 : 8.0;

    // 배경
    final bgPaint = Paint()
      ..color = AppColors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(position, size, bgPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(position, size, borderPaint);
  }

  /// 타겟 영역 그리기 (반짝이는 보석 스타일)
  void _drawTargetArea(Canvas canvas, Size size, Point<int> target) {
    // 좌표를 화면 위치로 변환 (col → X축, row → Y축)
    final targetX = (target.y / gridWidth) * size.width;
    final targetY = (target.x / gridHeight) * size.height;
    final center = Offset(targetX, targetY);

    // 허용 범위를 화면 크기로 변환
    final rangeX = (allowedRange / gridWidth) * size.width;
    final rangeY = (allowedRange / gridHeight) * size.height;

    // 색상 정의
    const primaryColor = Color(0xFFFF6B9D); // 핑크
    const secondaryColor = Color(0xFFFF9E4F); // 오렌지
    const sparkleColor = Color(0xFFFFFFFF); // 화이트

    // 1. 허용 범위 영역 (그라데이션 원형)
    final rangeRect = Rect.fromCenter(
      center: center,
      width: rangeX * 2,
      height: rangeY * 2,
    );

    final rangePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          primaryColor.withValues(alpha: 0.3 + pulseValue * 0.15),
          primaryColor.withValues(alpha: 0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.7, 1.0],
      ).createShader(rangeRect);
    canvas.drawOval(rangeRect, rangePaint);

    // 2. 회전하는 외곽 링
    canvas.save();
    canvas.translate(targetX, targetY);
    canvas.rotate(pulseValue * pi * 2); // 360도 회전

    final ringRadius = rangeX * 0.8;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..shader = SweepGradient(
        colors: [
          primaryColor.withValues(alpha: 0.8),
          secondaryColor.withValues(alpha: 0.4),
          Colors.transparent,
          primaryColor.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 0.3, 0.6, 1.0],
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: ringRadius));
    canvas.drawCircle(Offset.zero, ringRadius, ringPaint);
    canvas.restore();

    // 3. 바깥쪽 글로우
    final outerGlowPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.2 + pulseValue * 0.1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);
    canvas.drawCircle(center, 20 + pulseValue * 8, outerGlowPaint);

    // 4. 중간 글로우
    final midGlowPaint = Paint()
      ..color = secondaryColor.withValues(alpha: 0.4 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, 12 + pulseValue * 4, midGlowPaint);

    // 5. 다이아몬드 모양 중심
    final diamondPath = Path();
    final diamondSize = 10 + pulseValue * 2;
    diamondPath.moveTo(targetX, targetY - diamondSize); // 위
    diamondPath.lineTo(targetX + diamondSize * 0.7, targetY); // 오른쪽
    diamondPath.lineTo(targetX, targetY + diamondSize * 0.6); // 아래
    diamondPath.lineTo(targetX - diamondSize * 0.7, targetY); // 왼쪽
    diamondPath.close();

    // 다이아몬드 그라데이션
    final diamondPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          sparkleColor,
          primaryColor,
          secondaryColor,
        ],
      ).createShader(Rect.fromCenter(center: center, width: diamondSize * 2, height: diamondSize * 2));
    canvas.drawPath(diamondPath, diamondPaint);

    // 다이아몬드 테두리
    final diamondBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = sparkleColor.withValues(alpha: 0.8);
    canvas.drawPath(diamondPath, diamondBorderPaint);

    // 6. 반짝이 효과 (4개 별)
    _drawSparkle(canvas, Offset(targetX - 18, targetY - 12), 4 + pulseValue * 2, sparkleColor, 1.0 - pulseValue * 0.3);
    _drawSparkle(canvas, Offset(targetX + 16, targetY - 8), 3 + pulseValue * 1.5, sparkleColor, 0.7 + pulseValue * 0.3);
    _drawSparkle(canvas, Offset(targetX + 12, targetY + 14), 3.5 + pulseValue * 1.8, sparkleColor, 0.8 - pulseValue * 0.2);
    _drawSparkle(canvas, Offset(targetX - 14, targetY + 10), 2.5 + pulseValue * 1.2, sparkleColor, 0.6 + pulseValue * 0.4);
  }

  /// 반짝이(별) 그리기
  void _drawSparkle(Canvas canvas, Offset position, double size, Color color, double alpha) {
    final paint = Paint()
      ..color = color.withValues(alpha: alpha.clamp(0.0, 1.0))
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    // 가로 선
    canvas.drawLine(
      Offset(position.dx - size, position.dy),
      Offset(position.dx + size, position.dy),
      paint,
    );
    // 세로 선
    canvas.drawLine(
      Offset(position.dx, position.dy - size),
      Offset(position.dx, position.dy + size),
      paint,
    );
    // 대각선 (작게)
    final diagSize = size * 0.5;
    canvas.drawLine(
      Offset(position.dx - diagSize, position.dy - diagSize),
      Offset(position.dx + diagSize, position.dy + diagSize),
      paint..strokeWidth = 1,
    );
    canvas.drawLine(
      Offset(position.dx + diagSize, position.dy - diagSize),
      Offset(position.dx - diagSize, position.dy + diagSize),
      paint,
    );
  }

  /// 가이드선 그리기
  void _drawGuideLine(Canvas canvas, Size size) {
    const guideColor = Color(0xFFFFD700); // 골드 색상

    // 가로 가이드선 (Y 좌표 - ROW)
    if (guideY != null) {
      final guideYPos = (guideY! / gridHeight) * size.height;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = guideColor.withValues(alpha: 0.3 + pulseValue * 0.2)
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(Offset(0, guideYPos), Offset(size.width, guideYPos), glowPaint);

      // 점선 효과
      final dashPaint = Paint()
        ..color = guideColor.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      const dashWidth = 8.0;
      const dashSpace = 6.0;
      double startX = 0;
      while (startX < size.width) {
        canvas.drawLine(
          Offset(startX, guideYPos),
          Offset((startX + dashWidth).clamp(0, size.width), guideYPos),
          dashPaint,
        );
        startX += dashWidth + dashSpace;
      }
    }

    // 세로 가이드선 (X 좌표 - COL)
    if (guideX != null) {
      final guideXPos = (guideX! / gridWidth) * size.width;

      // 글로우 효과
      final glowPaint = Paint()
        ..color = guideColor.withValues(alpha: 0.3 + pulseValue * 0.2)
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawLine(Offset(guideXPos, 0), Offset(guideXPos, size.height), glowPaint);

      // 점선 효과
      final dashPaint = Paint()
        ..color = guideColor.withValues(alpha: 0.8)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      const dashWidth = 8.0;
      const dashSpace = 6.0;
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(guideXPos, startY),
          Offset(guideXPos, (startY + dashWidth).clamp(0, size.height)),
          dashPaint,
        );
        startY += dashWidth + dashSpace;
      }
    }

    // 교차점 표시 (둘 다 있을 때)
    if (guideX != null && guideY != null) {
      final guideXPos = (guideX! / gridWidth) * size.width;
      final guideYPos = (guideY! / gridHeight) * size.height;
      final crossPoint = Offset(guideXPos, guideYPos);

      // 외곽 글로우
      final outerGlowPaint = Paint()
        ..color = guideColor.withValues(alpha: 0.4 + pulseValue * 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(crossPoint, 16 + pulseValue * 4, outerGlowPaint);

      // 외곽 원
      final outerPaint = Paint()
        ..color = guideColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(crossPoint, 14, outerPaint);

      // 테두리
      final borderPaint = Paint()
        ..color = guideColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawCircle(crossPoint, 14, borderPaint);

      // 중심점
      final centerPaint = Paint()
        ..color = AppColors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(crossPoint, 5, centerPaint);

      // 중심점 테두리
      final centerBorderPaint = Paint()
        ..color = guideColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(crossPoint, 5, centerBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TossCrosshairPainter oldDelegate) => true;
}
