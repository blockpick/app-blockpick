import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/wish_model.dart';
import 'buzz_complete_screen.dart';
import 'widgets/buzz_canvas.dart';

/// 소문내기 게임 화면 — 10x10 그리드에서 블록 하나 선택
class BuzzGameScreen extends StatefulWidget {
  final Wish wish;
  const BuzzGameScreen({super.key, required this.wish});

  @override
  State<BuzzGameScreen> createState() => _BuzzGameScreenState();
}

class _BuzzGameScreenState extends State<BuzzGameScreen> {
  Set<(int, int)> _selectedBlocks = {};
  bool _isSubmitting = false;
  final _canvasKey = GlobalKey<BuzzCanvasState>();

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
            gridSize: 1000,
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

    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BuzzCompleteScreen(
          wish: widget.wish,
          gridX: _selectedBlocks.first.$1,
          gridY: _selectedBlocks.first.$2,
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
    final isFree = widget.wish.isBusinessWish;
    final hasSelection = _selectedBlocks.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.gray100,
      body: Column(
        children: [
          // 1. 상단 바
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
                      '소문내기',
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
                        color: isFree
                            ? AppColors.primaryBg
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull),
                      ),
                      child: Text(
                        isFree ? '무료' : '10원',
                        style: AppTextStyles.caption2.copyWith(
                          color: isFree
                              ? AppColors.primaryMain
                              : AppColors.gray600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. 상품 정보 카드
          Container(
            color: AppColors.white,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(AppConstants.radiusMd),
                  child: Image.network(
                    widget.wish.productImageUrl,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 56,
                      height: 56,
                      color: AppColors.gray200,
                      child: Center(
                        child: Text(
                          widget.wish.category.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.wish.oneLiner,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.title3.copyWith(
                            color: AppColors.textBlack),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.wish.productName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption1.copyWith(
                            color: AppColors.gray600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${_formatPrice(widget.wish.productPrice)}원',
                        style: AppTextStyles.title2.copyWith(
                            fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 3. 캔버스 그리드 영역 (1000x1000, 줌/팬 지원)
          Expanded(
            child: ClipRect(
              child: Stack(
                children: [
                  // 캔버스 그리드
                  BuzzCanvas(
                    key: _canvasKey,
                    gridSize: 1000,
                    selectedBlocks: _selectedBlocks,
                    backgroundImageUrl: widget.wish.productImageUrl,
                    onBlockTap: (x, y) {
                      final coord = (x, y);
                      setState(() {
                        if (_selectedBlocks.contains(coord)) {
                          _selectedBlocks.remove(coord);
                        } else {
                          _selectedBlocks.add(coord);
                        }
                        // 새 Set으로 교체하여 repaint 트리거
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
                              ? '${_selectedBlocks.length}개 선택됨 · 탭하여 추가/해제'
                              : '확대하고 블록을 탭하세요',
                          style: AppTextStyles.caption2.copyWith(
                            color: hasSelection ? AppColors.primaryLight : const Color(0xFF8B8F96),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // 미니맵 (좌하단)
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: _buildMinimap(),
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

          // 4. 하단 CTA
          Container(
            color: AppColors.white,
            child: SafeArea(
              top: false,
              child: Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: GestureDetector(
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
                            hasSelection ? '선택 완료' : '블록을 선택하세요',
                            style: AppTextStyles.button.copyWith(
                              color: hasSelection
                                  ? AppColors.white
                                  : AppColors.gray400,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 미니맵 페인터
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
    // 배경 그리드 표시
    final gridPaint = Paint()
      ..color = const Color(0xFF2A2D33)
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), gridPaint);

    // 배경 이미지
    if (backgroundImage != null) {
      final img = backgroundImage!;
      final srcRect = Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble());
      final dstRect = Rect.fromLTWH(0, 0, size.width, size.height);
      canvas.drawImageRect(
        img,
        srcRect,
        dstRect,
        Paint()
          ..filterQuality = FilterQuality.low
          ..color = const Color(0xBBFFFFFF), // 약간 어둡게
      );
    }

    // 그리드 경계 표시
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

    // 뷰포트 영역 계산
    final ctxSize = canvasState!.context.size;
    if (ctxSize == null) return;

    final vpLeft = (-pan.dx) / (totalGrid * zoom);
    final vpTop = (-pan.dy) / (totalGrid * zoom);
    final vpWidth = ctxSize.width / (totalGrid * zoom);
    final vpHeight = ctxSize.height / (totalGrid * zoom);

    // 뷰포트 사각형
    final vpRect = Rect.fromLTWH(
      vpLeft * size.width,
      vpTop * size.height,
      vpWidth * size.width,
      vpHeight * size.height,
    );

    // 뷰포트 표시
    final vpFill = Paint()
      ..color = AppColors.primaryMain.withValues(alpha: 0.15);
    final vpBorder = Paint()
      ..color = AppColors.primaryMain.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawRect(vpRect, vpFill);
    canvas.drawRect(vpRect, vpBorder);

    // 선택된 블록들 표시
    for (final block in selectedBlocks) {
      final dotX = (block.$1 / gridSize) * size.width;
      final dotY = (block.$2 / gridSize) * size.height;
      canvas.drawCircle(
        Offset(dotX, dotY),
        2.5,
        Paint()..color = AppColors.primaryMain,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MinimapPainter old) => true;
}
