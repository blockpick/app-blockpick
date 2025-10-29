import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/game_model.dart';
import '../../models/game_round_model.dart';
import '../../providers/game_provider.dart';
import '../grid/game_grid_widget.dart';
import '../../models/block_model.dart';
import 'package:lucide_icons/lucide_icons.dart';

/// 게임 상세 화면
class GameDetailScreen extends ConsumerStatefulWidget {
  final String gameId;

  const GameDetailScreen({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends ConsumerState<GameDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final gameAsync = ref.watch(gameProvider(widget.gameId));

    return gameAsync.when(
      data: (game) {
        debugPrint('📊 GameDetailScreen.build():');
        debugPrint('   - game: ${game?.id}');
        debugPrint('   - game != null: ${game != null}');

        if (game == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Game Not Found'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    LucideIcons.alertCircle,
                    size: 64,
                    color: AppColors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Game not found',
                    style: AppTextStyles.large.copyWith(
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          );
        }

        final gameRound = game.toGameRound();

        debugPrint('🎯 GameDetailScreen - gameRound 생성 완료:');
        debugPrint('   - gameRound.id: ${gameRound.id}');
        debugPrint('   - gameRound.imageUrl: ${gameRound.imageUrl}');
        debugPrint('   - gameRound.imageUrl.isEmpty: ${gameRound.imageUrl.isEmpty}');

        return Scaffold(
          backgroundColor: AppColors.deepWhite,
          appBar: AppBar(
            title: Text(gameRound.title),
            backgroundColor: AppColors.white,
            actions: [
              IconButton(
                icon: const Icon(LucideIcons.share2),
                onPressed: () {
                  // TODO: 공유 기능
                },
              ),
            ],
          ),
          body: Stack(
            children: [
              // 배경 (Vibe의 경우 이미지 표시)
              if (gameRound.type == GameType.vibe && gameRound.vibeImageUrl != null)
                Positioned.fill(
                  child: gameRound.vibeImageUrl!.isEmpty
                      ? Container(color: AppColors.blueWhite)
                      : Image.network(
                          gameRound.vibeImageUrl!.replaceAll(' ', '%20'),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(color: AppColors.blueWhite);
                          },
                        ),
                ),

              // 게임 그리드
              Builder(
                builder: (context) {
                  final imageUrl = gameRound.imageUrl.isEmpty ? null : gameRound.imageUrl;
                  debugPrint('🎮 GameGrid 빌드:');
                  debugPrint('   - gameRound.imageUrl: ${gameRound.imageUrl}');
                  debugPrint('   - backgroundImagePath: $imageUrl');
                  debugPrint('   - gridWidth: ${gameRound.gridWidth}');
                  debugPrint('   - gridHeight: ${gameRound.gridHeight}');
                  return GameGridWidget(
                    gameId: widget.gameId,
                    gridWidth: gameRound.gridWidth ?? 10,
                    gridHeight: gameRound.gridHeight ?? 10,
                    backgroundImagePath: imageUrl,
                    onBlockTap: (block) {
                      debugPrint('Block tapped: ${block.row}, ${block.col}');
                    },
                  );
                },
              ),

              // 상단 정보 패널
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: _buildInfoPanel(gameRound),
              ),

              // 하단 참가 버튼
              Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: _buildParticipateButton(),
              ),
            ],
          ),
        );
      },
      loading: () => Scaffold(
        appBar: AppBar(
          title: const Text('Loading...'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.blue),
          ),
        ),
      ),
      error: (error, stack) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                LucideIcons.alertCircle,
                size: 64,
                color: AppColors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading game',
                style: AppTextStyles.large.copyWith(
                  color: AppColors.darkBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.medium,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(gameProvider(widget.gameId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 정보 패널
  Widget _buildInfoPanel(GameRound game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.buleGray),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getTypeColor(game.type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getTypeText(game.type),
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(LucideIcons.clock, size: 16, color: AppColors.red),
              const SizedBox(width: 4),
              Text(
                game.timeLeft,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            game.title,
            style: AppTextStyles.medium.copyWith(
              color: AppColors.darkBlue,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            LucideIcons.users,
            'Participants',
            '${game.participants} / ${game.maxParticipants}',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            LucideIcons.trophy,
            'Winners',
            '${game.winners}명',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            LucideIcons.coins,
            'Entry Fee',
            '₩${_formatNumber(game.currentPrice)}',
          ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.blue),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.medium),
        ),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 참가 버튼
  Widget _buildParticipateButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientBluePurplePink,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // TODO: 참가 로직
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('게임 참가 기능은 곧 추가됩니다!'),
                backgroundColor: AppColors.green,
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  LucideIcons.zap,
                  size: 24,
                  color: AppColors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  'Participate Now',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 타입 색상
  Color _getTypeColor(GameType type) {
    switch (type) {
      case GameType.daily:
        return AppColors.pink;
      case GameType.select:
        return AppColors.purple;
      case GameType.vibe:
        return AppColors.blue;
    }
  }

  /// 타입 텍스트
  String _getTypeText(GameType type) {
    switch (type) {
      case GameType.daily:
        return 'DAILY';
      case GameType.select:
        return 'SELECT';
      case GameType.vibe:
        return 'VIBE';
    }
  }

  /// 숫자 포맷팅
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
