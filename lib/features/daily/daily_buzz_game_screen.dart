import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/game_round_model.dart';
import '../wish/widgets/buzz_canvas.dart';
import 'daily_buzz_complete_screen.dart';

/// 데일리 게임 블록선택 화면 — 위시 BuzzGameScreen 완전 복제
class DailyBuzzGameScreen extends StatefulWidget {
  final GameRound game;
  const DailyBuzzGameScreen({super.key, required this.game});

  @override
  State<DailyBuzzGameScreen> createState() => _DailyBuzzGameScreenState();
}

class _DailyBuzzGameScreenState extends State<DailyBuzzGameScreen> {
  @override
  void dispose() {
    _minimapNotifier.dispose();
    super.dispose();
  }

  Set<(int, int)> _selectedBlocks = {};
  bool _isSubmitting = false;
  final _canvasKey = GlobalKey<BuzzCanvasState>();
  final _minimapNotifier = ValueNotifier<int>(0);

  // 최대 선택 개수
  int get _pickMax => 5;

  Widget _buildMinimap() {
    const minimapSize = 100.0;
    return GestureDetector(
      onTapDown: (details) {
        final fractionX = details.localPosition.dx / minimapSize;
        final fractionY = details.localPosition.dy / minimapSize;
        _canvasKey.currentState?.navigateTo(fractionX, fractionY);
      },
      onPanUpdate: (details) {
        final fractionX = details.localPosition.dx / minimapSize;
        final fractionY = details.localPosition.dy / minimapSize;
        if (fractionX >= 0 && fractionX <= 1 && fractionY >= 0 && fractionY <= 1) {
          _canvasKey.currentState?.navigateTo(fractionX, fractionY);
        }
      },
      child: Container(
        width: minimapSize,
        height: minimapSize,
        decoration: BoxDecoration(
          color: const Color(0xCC1B1D21),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: const Color(0xFF3E4149), width: 0.5),
        ),
        child: CustomPaint(
          size: const Size(minimapSize, minimapSize),
          painter: _MinimapPainter(
            canvasState: _canvasKey.currentState,
            gridSize: widget.game.actualGridWidth,
            selectedBlocks: _selectedBlocks,
            backgroundImage: _canvasKey.currentState?.bgImage,
          ),
        ),
      ),
    );
  }

  Widget _buildZoomButton(IconData icon, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xCC2A2D33),
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: const Color(0xFF3E4149), width: 0.5),
        ),
        child: Icon(icon, size: 20, color: const Color(0xFF8B8F96)),
      ),
    );
  }

  void _onSubmit() async {
    if (_selectedBlocks.isEmpty || _isSubmitting) return;
    setState(() => _isSubmitting = true);

    // TODO: 실제 게임 참여 API 연동 (game_participation_provider)
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => DailyBuzzCompleteScreen(
          game: widget.game,
          selectedBlocks: _selectedBlocks,
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    if (price >= 10000) {
      final man = price ~/ 10000;
      final remainder = price % 10000;
      if (remainder == 0) return '$man만';
      return '$man만원';
    }
    return price
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
        );
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = _selectedBlocks.isNotEmpty;
    final gridSize = widget.game.actualGridWidth;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // 1. 상단 바 (위시와 동일)
          Container(
            color: AppColors.white,
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_ios_new,
                        size: 20, color: AppColors.textBlack),
                  ),
                  const Expanded(
                    child: Text(
                      '데일리 복제',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.title1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull),
                      ),
                      child: Text(
                        '${widget.game.currentPrice}P',
                        style: AppTextStyles.caption2.copyWith(
                          color: AppColors.gray600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 상품 정보 카드 (위시와 동일)
          Container(
            color: AppColors.white,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                  child: widget.game.imageUrl.isNotEmpty
                      ? Image.network(
                          widget.game.imageUrl.replaceAll(' ', '%20'),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 56,
                            height: 56,
                            color: AppColors.gray200,
                            child: const Icon(Icons.image_rounded, size: 22, color: AppColors.gray400),
                          ),
                        )
                      : Container(
                          width: 56,
                          height: 56,
                          color: AppColors.gray200,
                          child: const Icon(Icons.image_rounded, size: 22, color: AppColors.gray400),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title3.copyWith(
                            color: AppColors.textBlack),
                      ),
                      if (widget.game.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.game.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.caption1.copyWith(
                              color: AppColors.gray600),
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        '${_formatPrice(widget.game.currentPrice)}P',
                        style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. 캔버스 그리드 영역 (위시와 동일한 BuzzCanvas)
          Expanded(
            child: ClipRect(
              child: Stack(
                children: [
                  // BuzzCanvas 그리드
                  BuzzCanvas(
                    key: _canvasKey,
                    gridSize: gridSize,
                    selectedBlocks: _selectedBlocks,
                    backgroundImageUrl: widget.game.imageUrl.isNotEmpty
                        ? widget.game.imageUrl.replaceAll(' ', '%20')
                        : null,
                    onViewChanged: () => _minimapNotifier.value++,
                    onBlockTap: (x, y) {
                      final coord = (x, y);
                      setState(() {
                        if (_selectedBlocks.contains(coord)) {
                          _selectedBlocks.remove(coord);
                        } else {
                          if (_selectedBlocks.length >= _pickMax) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('최대 $_pickMax개까지 선택할 수 있습니다'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                            return;
                          }
                          _selectedBlocks.add(coord);
                        }
                        _selectedBlocks = Set.from(_selectedBlocks);
                      });
                    },
                  ),
                  // 상단 안내 텍스트
                  Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xCC2A2D33),
                          borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                        ),
                        child: Text(
                          hasSelection
                              ? '${_selectedBlocks.length}/$_pickMax개 선택됨 · 탭하여 추가/해제'
                              : '확대하고 블록을 탭하세요',
                          style: AppTextStyles.caption2.copyWith(
                            color: hasSelection ? AppColors.primaryLight : const Color(0xFF8B8F96),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 미니맵 (좌하단) — ValueListenableBuilder로 캔버스 변경 시만 리빌드
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: ValueListenableBuilder<int>(
                      valueListenable: _minimapNotifier,
                      builder: (_, __, ___) => _buildMinimap(),
                    ),
                  ),
                  // 줌 컨트롤 버튼 (우하단)
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: Column(
                      children: [
                        _buildZoomButton(Icons.add, () => _canvasKey.currentState?.zoomIn()),
                        const SizedBox(height: 8),
                        _buildZoomButton(Icons.remove, () => _canvasKey.currentState?.zoomOut()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. 하단: 선택 칩 + CTA (위시와 동일)
          Container(
            color: AppColors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 선택된 블록 칩 리스트
                    if (hasSelection)
                      SizedBox(
                        height: 36,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedBlocks.length,
                          itemBuilder: (context, index) {
                            final block = _selectedBlocks.elementAt(index);
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: GestureDetector(
                                onTap: () {
                                  _canvasKey.currentState?.navigateTo(
                                    block.$1 / gridSize,
                                    block.$2 / gridSize,
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryBg,
                                    borderRadius: BorderRadius.circular(AppConstants.radius2Xl),
                                    border: Border.all(color: AppColors.primaryMain.withValues(alpha: 0.2)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '(${block.$1}, ${block.$2})',
                                        style: AppTextStyles.caption2.copyWith(
                                          color: AppColors.primaryMain,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _selectedBlocks.remove(block);
                                            _selectedBlocks = Set.from(_selectedBlocks);
                                          });
                                        },
                                        child: Icon(
                                          Icons.close_rounded,
                                          size: 14,
                                          color: AppColors.primaryMain.withValues(alpha: 0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    if (hasSelection) const SizedBox(height: 8),
                    // CTA 버튼
                    GestureDetector(
                      onTap: hasSelection && !_isSubmitting
                          ? _onSubmit
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: double.infinity,
                        height: 50,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: hasSelection
                              ? AppColors.textBlack
                              : AppColors.gray200,
                          borderRadius: BorderRadius.circular(
                              AppConstants.radius2Xl),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.white),
                                ),
                              )
                            : Text(
                                hasSelection
                                    ? '${_selectedBlocks.length}/$_pickMax개 선택 완료'
                                    : '블록을 선택하세요',
                                style: AppTextStyles.button.copyWith(
                                  color: hasSelection
                                      ? AppColors.white
                                      : AppColors.gray400,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 미니맵 페인터 (위시와 동일)
class _MinimapPainter extends CustomPainter {
  final BuzzCanvasState? canvasState;
  final int gridSize;
  final Set<(int, int)> selectedBlocks;
  final ui.Image? backgroundImage;

  _MinimapPainter({
    this.canvasState,
    required this.gridSize,
    this.selectedBlocks = const {},
    this.backgroundImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2D33)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gridPaint);

    if (backgroundImage != null) {
      final img = backgroundImage!;
      final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(img, srcRect, dstRect,
        Paint()..filterQuality = FilterQuality.low..color = const Color(0xBBFFFFFF),
      );
    }

    final borderPaint = Paint()
      ..color = const Color(0xFF3E4149)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), borderPaint);

    if (canvasState == null) return;

    final zoom = canvasState!.currentZoom;
    final pan = canvasState!.currentPan;
    final step = canvasState!.gridStepValue;
    final totalGrid = gridSize * step;

    final ctxSize = canvasState!.context.size;
    if (ctxSize == null) return;

    final vpLeft = (-pan.dx) / (totalGrid * zoom);
    final vpTop = (-pan.dy) / (totalGrid * zoom);
    final vpWidth = ctxSize.width / (totalGrid * zoom);
    final vpHeight = ctxSize.height / (totalGrid * zoom);

    final vpRect = Rect.fromLTWH(
      vpLeft * size.width, vpTop * size.height,
      vpWidth * size.width, vpHeight * size.height,
    );

    canvas.drawRect(vpRect, Paint()..color = AppColors.primaryMain.withValues(alpha: 0.15));
    canvas.drawRect(vpRect, Paint()
      ..color = AppColors.primaryMain.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5,
    );

    for (final block in selectedBlocks) {
      final dotX = (block.$1 / gridSize) * size.width;
      final dotY = (block.$2 / gridSize) * size.height;
      canvas.drawCircle(Offset(dotX, dotY), 2.5, Paint()..color = AppColors.primaryMain);
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) => true;
}
