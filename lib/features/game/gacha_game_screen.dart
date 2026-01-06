import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../../providers/game_participation_provider.dart';
import '../../providers/game_join_progress_provider.dart';
import '../../widgets/gacha_coordinate_picker.dart';
import 'widgets/game_join_progress_overlay.dart';
import 'widgets/game_join_result_overlay.dart';

/// Gacha 스타일 게임 화면 (토스 디자인)
class GachaGameScreen extends ConsumerStatefulWidget {
  final String? gameId;

  const GachaGameScreen({super.key, this.gameId});

  @override
  ConsumerState<GachaGameScreen> createState() => _GachaGameScreenState();
}

class _GachaGameScreenState extends ConsumerState<GachaGameScreen> {
  GameRound? _gameRound;
  Game? _game;

  final GlobalKey<GachaCoordinatePickerState> _pickerKey = GlobalKey();
  final _priceFormatter = NumberFormat('#,###');

  @override
  void initState() {
    super.initState();
  }

  void _onCoordinateSelected(int row, int col) {
    _showCoordinateConfirmDialog(row, col);
  }

  void _showCoordinateConfirmDialog(int row, int col) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TossStyleConfirmSheet(
        row: row,
        col: col,
        productName: _gameRound?.title ?? '상품',
        productImage: _gameRound?.imageUrl ?? '',
        price: _gameRound?.currentPrice ?? 0,
        onConfirm: () {
          Navigator.pop(context);
          _joinGame(row, col);
        },
        onRetry: () {
          Navigator.pop(context);
          _pickerKey.currentState?.reset();
        },
      ),
    );
  }

  Future<void> _joinGame(int row, int col) async {
    if (_game == null || _gameRound == null) return;

    final contractAddress = _game!.onchainContractAddr;
    final gameProducts = _game!.gameProducts;

    if (contractAddress == null || contractAddress.isEmpty) {
      _showErrorSnackBar('컨트랙트 주소가 없습니다.');
      _pickerKey.currentState?.reset();
      return;
    }

    if (gameProducts == null || gameProducts.isEmpty) {
      _showErrorSnackBar('게임 상품 정보가 없습니다.');
      _pickerKey.currentState?.reset();
      return;
    }

    final selectedGameProductId = gameProducts.first.id;

    OverlayEntry? progressOverlay;

    try {
      progressOverlay = GameJoinProgressOverlay.show(
        context,
        currentStep: GameJoinStep.walletCheck,
        statusMessage: '게임 참여를 준비하고 있습니다...',
      );

      final result = await ref
          .read(gameParticipationProvider.notifier)
          .joinGame(
            gameId: _game!.id,
            selectedGameProductId: selectedGameProductId,
            row: row,
            col: col,
            contractAddress: contractAddress,
          );

      progressOverlay.remove();
      progressOverlay = null;

      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        if (result.success) {
          GameJoinResultOverlay.showSuccess(
            context,
            entryId: result.entryId,
            txHash: result.txHash,
            onConfirm: () {
              context.go('/');
            },
          );
        } else {
          GameJoinResultOverlay.showError(
            context,
            errorMessage: result.message,
            onRetry: () {
              _pickerKey.currentState?.reset();
            },
          );
        }
      }
    } catch (e) {
      progressOverlay?.remove();
      progressOverlay = null;

      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));

        if (!mounted) return;
        GameJoinResultOverlay.showError(
          context,
          errorMessage: '알 수 없는 오류가 발생했습니다.\n$e',
          onRetry: () {
            _pickerKey.currentState?.reset();
          },
        );
      }
    } finally {
      ref.read(gameJoinProgressNotifierProvider.notifier).reset();
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.gameId == null) {
      return _buildErrorScreen('게임 ID가 없습니다');
    }

    final gameAsync = ref.watch(gameProvider(widget.gameId!));

    return gameAsync.when(
      loading: () => Scaffold(
        backgroundColor: AppColors.gray100,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
          ),
        ),
      ),
      error: (error, stack) => _buildErrorScreen('게임을 불러올 수 없습니다'),
      data: (game) {
        if (game == null) {
          return _buildErrorScreen('게임을 찾을 수 없습니다');
        }
        _game = game;
        final gameRound = game.toGameRound();
        _gameRound = gameRound;
        return _buildGameContent(gameRound);
      },
    );
  }

  Widget _buildErrorScreen(String message) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkBlue),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.red, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.gray700,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameContent(GameRound game) {
    return Scaffold(
      backgroundColor: AppColors.gray100,
      appBar: _buildAppBar(game),
      body: Column(
        children: [
          // 상품 정보 카드
          _buildProductCard(game),

          // Gacha 좌표 선택기
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkBlue.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: GachaCoordinatePicker(
                  key: _pickerKey,
                  imageUrl: game.imageUrl,
                  gridSize: 1000,
                  accentColor: AppColors.darkBlue,
                  rowSpeed: 2500,
                  colSpeed: 2200,
                  onCoordinateSelected: _onCoordinateSelected,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(GameRound game) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(56),
      child: Container(
        color: AppColors.white,
        child: SafeArea(
          bottom: false,
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 22,
                    color: AppColors.darkBlue,
                  ),
                ),
                Expanded(
                  child: Text(
                    game.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // 도움말 버튼
                IconButton(
                  onPressed: () => _showHelpSheet(),
                  icon: Icon(
                    Icons.help_outline_rounded,
                    size: 22,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard(GameRound game) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.darkBlue.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 상품 이미지
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppColors.gray100,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: game.imageUrl.isNotEmpty
                  ? Image.network(
                      game.imageUrl.replaceAll(' ', '%20'),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
          ),

          const SizedBox(width: 16),

          // 상품 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 카테고리 태그
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    game.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blue,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 상품명
                Text(
                  game.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // 그리드 정보
                Text(
                  '${game.actualGridWidth} × ${game.actualGridHeight} 그리드',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.gray500,
                  ),
                ),
              ],
            ),
          ),

          // 참가비
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '참가비',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.gray500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_priceFormatter.format(game.currentPrice)}원',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.gray100,
      child: Icon(
        Icons.card_giftcard_rounded,
        size: 32,
        color: AppColors.gray400,
      ),
    );
  }

  void _showHelpSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 핸들
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.gray300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '게임 방법',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
              ),
            ),
            const SizedBox(height: 20),
            _buildHelpStep(1, 'ROW 선택', '버튼을 눌러 가로줄(ROW)을 고정하세요'),
            const SizedBox(height: 16),
            _buildHelpStep(2, 'COL 선택', '버튼을 눌러 세로줄(COL)을 고정하세요'),
            const SizedBox(height: 16),
            _buildHelpStep(3, '참가 완료', '선택한 좌표로 게임에 참가합니다'),
            const SizedBox(height: 24),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpStep(int step, String title, String description) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.darkBlue.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              '$step',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.darkBlue,
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
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkBlue,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 토스 스타일 확인 바텀시트
class _TossStyleConfirmSheet extends StatelessWidget {
  final int row;
  final int col;
  final String productName;
  final String productImage;
  final int price;
  final VoidCallback onConfirm;
  final VoidCallback onRetry;

  const _TossStyleConfirmSheet({
    required this.row,
    required this.col,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.onConfirm,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final priceFormatter = NumberFormat('#,###');

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // 체크 아이콘
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.green,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),

          // 타이틀
          const Text(
            '좌표 선택 완료',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택한 좌표로 게임에 참가하시겠습니까?',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.gray600,
            ),
          ),

          const SizedBox(height: 24),

          // 좌표 정보 카드
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCoordBox('ROW', row),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '×',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                      color: AppColors.gray400,
                    ),
                  ),
                ),
                _buildCoordBox('COL', col),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 참가비 정보
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.blue.withValues(alpha: 0.2)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '참가비',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.gray600,
                  ),
                ),
                Text(
                  '${priceFormatter.format(price)}원',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkBlue,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 버튼들
          Row(
            children: [
              // 다시하기 버튼
              Expanded(
                child: GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        '다시 선택',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 참가하기 버튼
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: onConfirm,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppColors.darkBlue,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        '참가하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildCoordBox(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.gray500,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toString().padLeft(4, '0'),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.darkBlue,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}
