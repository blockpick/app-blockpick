import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_model.dart';
import '../../../models/game_round_model.dart';

/// Unity 3D 블록 게임 선택 화면
/// 서버에서 받은 게임 목록에서 선택하면 Unity 3D로 플레이
class UnityGameSelectScreen extends ConsumerWidget {
  const UnityGameSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // gamesProvider 사용 (activeGamesProvider가 빈 배열 반환하는 이슈)
    final gamesAsync = ref.watch(gamesProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '3D Block Pick',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // 헤더 설명
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '게임을 선택하세요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '선택한 게임의 이미지가 3D 블록으로 변환됩니다.\n줌아웃하면 이미지 전체가 보여요!',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // 게임 리스트
          Expanded(
            child: gamesAsync.when(
              data: (games) {
                // Game -> GameRound 변환
                final gameRounds = games.map((g) => g.toGameRound()).toList();
                return _buildGameList(context, gameRounds);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: Colors.amber),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red[300], size: 48),
                    const SizedBox(height: 16),
                    Text(
                      '게임을 불러올 수 없습니다',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.invalidate(gamesProvider),
                      child: const Text('다시 시도'),
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

  Widget _buildGameList(BuildContext context, List<GameRound> games) {
    if (games.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sports_esports_outlined, color: Colors.grey[600], size: 64),
            const SizedBox(height: 16),
            Text(
              '진행 중인 게임이 없습니다',
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
            ),
            const SizedBox(height: 24),
            // 데모 게임 버튼
            ElevatedButton.icon(
              onPressed: () => _launchDemoGame(context),
              icon: const Icon(Icons.play_arrow),
              label: const Text('데모 게임 시작'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: games.length,
      itemBuilder: (context, index) {
        final game = games[index];
        return _buildGameCard(context, game);
      },
    );
  }

  Widget _buildGameCard(BuildContext context, GameRound game) {
    return GestureDetector(
      onTap: () => _navigateToUnity(context, game),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!,
              Colors.grey[850]!,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[800]!, width: 1),
        ),
        child: Row(
          children: [
            // 이미지
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: SizedBox(
                width: 120,
                height: 120,
                child: game.imageUrl.isNotEmpty
                    ? Image.network(
                        game.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stack) =>
                            _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),

            // 정보
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.grid_4x4, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${game.gridWidth ?? 100} x ${game.gridHeight ?? 100}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.people, size: 14, color: Colors.grey[500]),
                        const SizedBox(width: 4),
                        Text(
                          '${game.participants}/${game.maxParticipants}',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '3D로 플레이',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Colors.grey[600]),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[800],
      child: Center(
        child: Icon(Icons.image, color: Colors.grey[600], size: 32),
      ),
    );
  }

  void _navigateToUnity(BuildContext context, GameRound game) {
    context.push('/more/unity/play', extra: {
      'gameId': game.id,
      'gridRows': game.gridHeight ?? 100,
      'gridCols': game.gridWidth ?? 100,
      'imageUrl': game.imageUrl,
      'title': game.title,
    });
  }

  void _launchDemoGame(BuildContext context) {
    // 테스트용 데모 게임 - 샘플 이미지 URL 사용
    context.push('/more/unity/play', extra: {
      'gameId': 'demo_game_001',
      'gridRows': 50,
      'gridCols': 50,
      'imageUrl': 'https://picsum.photos/200/200', // 랜덤 이미지
      'title': '데모 게임',
    });
  }
}
