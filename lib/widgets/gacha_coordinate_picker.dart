import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme/app_colors.dart';

/// Gacha 스타일 좌표 선택 위젯 (토스 디자인)
class GachaCoordinatePicker extends StatefulWidget {
  /// 경품 이미지 URL
  final String? imageUrl;

  /// 그리드 크기 (기본 1000x1000)
  final int gridSize;

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

  const GachaCoordinatePicker({
    super.key,
    this.imageUrl,
    this.gridSize = 1000,
    required this.onCoordinateSelected,
    this.accentColor = AppColors.darkBlue,
    this.rowSpeed = 2000,
    this.colSpeed = 1800,
    this.eventMode = false,
    this.targetCoordinates = const [],
    this.allowedRange = 10,
    this.showTarget = true,
    this.onEventSuccess,
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

  @override
  void initState() {
    super.initState();
    _currentRowSpeed = widget.rowSpeed;
    _currentColSpeed = widget.colSpeed;

    _verticalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _currentRowSpeed),
    )..repeat(reverse: true);

    _horizontalController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _currentColSpeed),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  /// ROW 속도 변경 (밀리초)
  void setRowSpeed(int speed) {
    _currentRowSpeed = speed;
    final currentValue = _verticalController.value;
    _verticalController.duration = Duration(milliseconds: speed);
    if (_phase == 0) {
      _verticalController.repeat(reverse: true);
      // 현재 위치에서 계속
      _verticalController.value = currentValue;
    }
  }

  /// COL 속도 변경 (밀리초)
  void setColSpeed(int speed) {
    _currentColSpeed = speed;
    final currentValue = _horizontalController.value;
    _horizontalController.duration = Duration(milliseconds: speed);
    if (_phase == 1) {
      _horizontalController.repeat(reverse: true);
      _horizontalController.value = currentValue;
    }
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
      // ROW 고정
      setState(() {
        _fixedVertical = _verticalController.value;
        _phase = 1;
      });
      _verticalController.stop();
      _horizontalController.duration = Duration(milliseconds: _currentColSpeed);
      _horizontalController.repeat(reverse: true);
    } else if (_phase == 1) {
      // COL 고정 → 완료
      setState(() {
        _fixedHorizontal = _horizontalController.value;
        _phase = 2;
      });
      _horizontalController.stop();

      Future.delayed(const Duration(milliseconds: 300), () {
        final row = (_fixedVertical * widget.gridSize).round().clamp(0, widget.gridSize);
        final col = (_fixedHorizontal * widget.gridSize).round().clamp(0, widget.gridSize);

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
    _horizontalController.stop();
    _horizontalController.reset();
    _verticalController.repeat(reverse: true);
  }

  int get currentRow => _phase == 0
      ? (_verticalController.value * widget.gridSize).round().clamp(0, widget.gridSize)
      : (_fixedVertical * widget.gridSize).round().clamp(0, widget.gridSize);

  int? get currentCol => _phase < 1
      ? null
      : _phase == 1
          ? (_horizontalController.value * widget.gridSize).round().clamp(0, widget.gridSize)
          : (_fixedHorizontal * widget.gridSize).round().clamp(0, widget.gridSize);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _verticalController,
        _horizontalController,
        _pulseController,
      ]),
      builder: (context, _) {
        return SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // 단계 인디케이터
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildPhaseIndicator(),
              ),

              const SizedBox(height: 16),

              // 게임 캔버스 (1:1 비율 - 가로 전체 너비 기준)
              LayoutBuilder(
                builder: (context, constraints) {
                  final canvasSize = constraints.maxWidth - 32; // 좌우 마진 16씩
                  return SizedBox(
                    width: constraints.maxWidth,
                    height: canvasSize,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.gray200,
                        width: 2,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
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
                                    Colors.black.withValues(alpha: 0.1),
                                    Colors.black.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // 그리드
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: _TossGridPainter(),
                              );
                            },
                          ),

                          // 크로스헤어
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return CustomPaint(
                                size: Size(constraints.maxWidth, constraints.maxHeight),
                                painter: _TossCrosshairPainter(
                                  phase: _phase,
                                  verticalPos: _phase == 0
                                      ? _verticalController.value
                                      : _fixedVertical,
                                  horizontalPos: _phase >= 1
                                      ? (_phase == 1
                                          ? _horizontalController.value
                                          : _fixedHorizontal)
                                      : 0.5,
                                  accentColor: widget.accentColor,
                                  pulseValue: _pulseController.value,
                                  // 이벤트 모드 관련
                                  showTarget: widget.eventMode && widget.showTarget,
                                  targetCoordinates: widget.targetCoordinates,
                                  allowedRange: widget.allowedRange,
                                  gridSize: widget.gridSize,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

              const SizedBox(height: 16),

              // 하단 컨트롤
              _buildBottomControls(),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
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

  Widget _buildPhaseIndicator() {
    return Row(
      children: [
        Expanded(child: _buildPhaseStep(0, 'ROW 선택', Icons.swap_vert_rounded)),
        _buildConnector(0),
        Expanded(child: _buildPhaseStep(1, 'COL 선택', Icons.swap_horiz_rounded)),
        _buildConnector(1),
        Expanded(child: _buildPhaseStep(2, '완료', Icons.check_rounded)),
      ],
    );
  }

  Widget _buildPhaseStep(int phaseNum, String label, IconData icon) {
    final isActive = _phase == phaseNum;
    final isDone = _phase > phaseNum;

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
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
            size: 20,
            color: (isDone || isActive) ? AppColors.white : AppColors.gray500,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            color: isActive ? widget.accentColor : AppColors.gray500,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int afterPhase) {
    final isDone = _phase > afterPhase;

    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 28),
      color: isDone ? AppColors.green : AppColors.gray200,
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 좌표 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCoordDisplay('ROW', currentRow, _phase >= 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                _buildCoordDisplay('COL', currentCol ?? 0, _phase >= 2),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 버튼
          Row(
            children: [
              // 리셋 버튼
              if (_phase > 0)
                GestureDetector(
                  onTap: reset,
                  child: Container(
                    width: 56,
                    height: 56,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.refresh_rounded,
                      color: AppColors.gray600,
                      size: 24,
                    ),
                  ),
                ),

              // 메인 버튼
              Expanded(
                child: GestureDetector(
                  onTap: _phase < 2 ? _onButtonPressed : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    decoration: BoxDecoration(
                      color: _phase < 2 ? widget.accentColor : AppColors.gray300,
                      borderRadius: BorderRadius.circular(16),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _phase == 0
                              ? Icons.swap_vert_rounded
                              : _phase == 1
                                  ? Icons.swap_horiz_rounded
                                  : Icons.check_rounded,
                          color: AppColors.white,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _phase == 0
                              ? 'ROW 고정'
                              : _phase == 1
                                  ? 'COL 고정'
                                  : '완료',
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 16,
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

  Widget _buildCoordDisplay(String label, int value, bool isLocked) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.gray500,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString().padLeft(4, '0'),
          style: TextStyle(
            color: isLocked ? widget.accentColor : AppColors.gray400,
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

/// 토스 스타일 그리드 페인터
class _TossGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white.withValues(alpha: 0.1)
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
  final int gridSize;

  _TossCrosshairPainter({
    required this.phase,
    required this.verticalPos,
    required this.horizontalPos,
    required this.accentColor,
    required this.pulseValue,
    this.showTarget = false,
    this.targetCoordinates = const [],
    this.allowedRange = 10,
    this.gridSize = 1000,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final y = verticalPos * size.height;
    final x = horizontalPos * size.width;

    // 타겟 좌표들 표시 (이벤트 모드)
    if (showTarget && targetCoordinates.isNotEmpty) {
      for (final target in targetCoordinates) {
        _drawTargetArea(canvas, size, target);
      }
    }

    // ROW 라인 (가로)
    if (phase >= 0) {
      final isMoving = phase == 0;
      final lineColor = isMoving ? AppColors.blue : accentColor;
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

    // COL 라인 (세로)
    if (phase >= 1) {
      final isMoving = phase == 1;
      final lineColor = isMoving ? AppColors.green : accentColor;
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

  /// 타겟 영역 그리기
  void _drawTargetArea(Canvas canvas, Size size, Point<int> target) {
    // 좌표를 화면 위치로 변환
    final targetX = (target.y / gridSize) * size.width;
    final targetY = (target.x / gridSize) * size.height;

    // 허용 범위를 화면 크기로 변환
    final rangeX = (allowedRange / gridSize) * size.width;
    final rangeY = (allowedRange / gridSize) * size.height;

    // 허용 범위 영역 (반투명 사각형)
    final rangePaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.2 + pulseValue * 0.1)
      ..style = PaintingStyle.fill;

    final rangeRect = Rect.fromCenter(
      center: Offset(targetX, targetY),
      width: rangeX * 2,
      height: rangeY * 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rangeRect, const Radius.circular(8)),
      rangePaint,
    );

    // 허용 범위 테두리
    final rangeBorderPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rangeRect, const Radius.circular(8)),
      rangeBorderPaint,
    );

    // 타겟 중심점 (별 모양 효과)
    final targetPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..style = PaintingStyle.fill;

    // 외곽 글로우
    final glowPaint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: 0.3 + pulseValue * 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(targetX, targetY), 16 + pulseValue * 4, glowPaint);

    // 중심 원
    canvas.drawCircle(Offset(targetX, targetY), 8, targetPaint);

    // 십자 마커
    final crossPaint = Paint()
      ..color = const Color(0xFFFFD700)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(targetX - 16, targetY),
      Offset(targetX - 8, targetY),
      crossPaint,
    );
    canvas.drawLine(
      Offset(targetX + 8, targetY),
      Offset(targetX + 16, targetY),
      crossPaint,
    );
    canvas.drawLine(
      Offset(targetX, targetY - 16),
      Offset(targetX, targetY - 8),
      crossPaint,
    );
    canvas.drawLine(
      Offset(targetX, targetY + 8),
      Offset(targetX, targetY + 16),
      crossPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _TossCrosshairPainter oldDelegate) => true;
}
