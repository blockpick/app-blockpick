import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../models/game_round_model.dart';
import '../../models/block_model.dart';
import '../../data/mock_game_data.dart';
import '../../components/cards/my_pick_card.dart';

/// My Pick 화면 (참여한 게임 이력)
class MyPickScreen extends ConsumerStatefulWidget {
  const MyPickScreen({super.key});

  @override
  ConsumerState<MyPickScreen> createState() => _MyPickScreenState();
}

class _MyPickScreenState extends ConsumerState<MyPickScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // 탭 바
          Container(
              color: AppColors.white,
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                indicatorColor: AppColors.blue,
                indicatorWeight: 3,
                labelColor: AppColors.blue,
                unselectedLabelColor: AppColors.medium,
                labelStyle: AppTextStyles.button.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: AppTextStyles.button,
                tabs: const [
                  Tab(text: 'ALL'),
                  Tab(text: 'DAILY'),
                  Tab(text: 'SELECT'),
                  Tab(text: 'VIBE'),
                ],
              ),
            ),
          // 탭 뷰
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGameList(null), // ALL
                _buildGameList(GameType.daily),
                _buildGameList(GameType.select),
                _buildGameList(GameType.vibe),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 게임 리스트 빌드
  Widget _buildGameList(GameType? filter) {
    // Mock 데이터로 게임 목록 생성
    final allGames = [
      ...MockGameData.dailyGames,
      ...MockGameData.selectGames,
      ...MockGameData.vibeGames,
    ];

    // 필터링
    final filteredGames = filter == null
        ? allGames
        : allGames.where((game) => game.type == filter).toList();

    if (filteredGames.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredGames.length,
      itemBuilder: (context, index) {
        final game = filteredGames[index];
        final myPicks = _getMockPicks(game);

        return MyPickCard(
          game: game,
          myPicks: myPicks,
          onTap: () {
            _showGameDetails(context, game, myPicks);
          },
        );
      },
    );
  }

  /// 빈 상태 표시
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 80,
            color: AppColors.medium.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No picks yet',
            style: AppTextStyles.large.copyWith(
              color: AppColors.medium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start playing to see your picks here',
            style: AppTextStyles.body.copyWith(
              color: AppColors.medium,
            ),
          ),
        ],
      ),
    );
  }

  /// Mock 픽 데이터 생성
  List<BlockModel> _getMockPicks(GameRound game) {
    // 게임에 따라 다른 수의 픽 생성
    final pickCount = game.requiredPicks + (game.id.hashCode % 10);

    return List.generate(
      pickCount,
      (index) => BlockModel.fromPosition(
        (index * 123 % game.actualGridHeight) + 1,
        (index * 456 % game.actualGridWidth) + 1,
        state: BlockState.selected,
      ),
    );
  }

  /// 게임 상세 정보 바텀시트
  void _showGameDetails(BuildContext context, GameRound game, List<BlockModel> myPicks) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppConstants.radiusXl),
          ),
        ),
        child: Column(
          children: [
            // 핸들
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.medium.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // 상품 이미지
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  image: DecorationImage(
                    image: AssetImage(game.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),

            // 게임 정보
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: AppTextStyles.xlarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      game.description,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.medium,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 내 픽 리스트
                    Text(
                      'My Picks (${myPicks.length})',
                      style: AppTextStyles.large.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: myPicks.map((block) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                            border: Border.all(color: AppColors.blue.withOpacity(0.3)),
                          ),
                          child: Text(
                            'X${block.col}-Y${block.row}',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // 그리드로 보기 버튼
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: 게임 화면으로 이동
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Opening game: ${game.title}'),
                              backgroundColor: AppColors.blue,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.blue,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          ),
                        ),
                        child: Text(
                          'View on Grid',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
