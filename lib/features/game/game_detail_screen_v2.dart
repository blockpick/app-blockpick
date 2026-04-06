import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../data/mock_game_data.dart';
import '../../models/game_round_model.dart';
import '../../models/block_model.dart';
import '../../providers/grid_state_provider.dart';
import '../grid/game_grid_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/constants/app_constants.dart';

/// 게임 상세 화면 V2 (제품 이미지 배경 + 우측 패널)
class GameDetailScreenV2 extends ConsumerStatefulWidget {
  final String gameId;

  const GameDetailScreenV2({
    super.key,
    required this.gameId,
  });

  @override
  ConsumerState<GameDetailScreenV2> createState() => _GameDetailScreenV2State();
}

class _GameDetailScreenV2State extends ConsumerState<GameDetailScreenV2> {
  GameRound? _game;
  bool _loading = true;
  final List<BlockModel> _selectedBlocks = [];

  @override
  void initState() {
    super.initState();
    _loadGame();
  }

  Future<void> _loadGame() async {
    setState(() {
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 500));

    final game = MockGameData.getGameById(widget.gameId);

    setState(() {
      _game = game;
      _loading = false;
    });
  }

  void _handleBlockTap(BlockModel block) {
    setState(() {
      final index = _selectedBlocks.indexWhere((b) => b.id == block.id);
      if (index >= 0) {
        // 이미 선택된 블록이면 제거
        _selectedBlocks.removeAt(index);
      } else {
        // 새 블록 추가
        _selectedBlocks.add(block);
      }
    });
  }

  void _handleRemoveBlock(BlockModel block) {
    setState(() {
      _selectedBlocks.removeWhere((b) => b.id == block.id);
    });
  }

  void _handleClearAll() {
    setState(() {
      _selectedBlocks.clear();
    });
    // GridConfig를 사용하는 경우에만 호출
    // ref.read(gridStateProvider(...).notifier).clearBlocks();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('불러오는 중...')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_game == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게임을 찾을 수 없습니다')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.alertCircle, size: 64, color: AppColors.red),
              const SizedBox(height: 16),
              Text('게임을 찾을 수 없습니다', style: AppTextStyles.heading1),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('돌아가기'),
              ),
            ],
          ),
        ),
      );
    }

    final gridSize = _game!.gridSize ?? 10000;
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text(_game!.title),
        backgroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.share2),
            onPressed: () {},
          ),
        ],
      ),
      body: isMobile ? _buildMobileLayout(gridSize) : _buildDesktopLayout(gridSize),
    );
  }

  /// 모바일 레이아웃
  Widget _buildMobileLayout(int gridSize) {
    return Stack(
      children: [
        // 게임 그리드
        Container(
          color: AppColors.deepWhite,
          child: GameGridWidget(
            gameId: widget.gameId,
            gridWidth: gridSize,
            gridHeight: gridSize,
            backgroundImagePath: _game!.imageUrl,
            onBlockTap: _handleBlockTap,
          ),
        ),

        // 하단 선택된 블록 정보
        if (_selectedBlocks.isNotEmpty)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildMobileBottomSheet(),
          ),
      ],
    );
  }

  /// 데스크톱 레이아웃
  Widget _buildDesktopLayout(int gridSize) {
    return Row(
      children: [
        // 좌측: 게임 그리드
        Expanded(
          flex: 7,
          child: Container(
            color: AppColors.deepWhite,
            child: GameGridWidget(
              gameId: widget.gameId,
            gridWidth: gridSize,
            gridHeight: gridSize,
              backgroundImagePath: _game!.imageUrl,
              onBlockTap: _handleBlockTap,
            ),
          ),
        ),

        // 우측: 정보 패널
        Container(
          width: 380,
          decoration: const BoxDecoration(
            color: AppColors.white,
            border: Border(
              left: BorderSide(color: AppColors.buleGray),
            ),
          ),
          child: _buildRightPanel(),
        ),
      ],
    );
  }

  /// 우측 패널 (제품 정보 + 선택된 블록)
  Widget _buildRightPanel() {
    return Column(
      children: [
        // 제품 정보
        _buildProductInfo(),

        Divider(height: 1),

        // 선택된 블록 리스트
        Expanded(
          child: _buildSelectedBlocksList(),
        ),

        // 하단 확인 버튼
        _buildConfirmButton(),
      ],
    );
  }

  /// 제품 정보
  Widget _buildProductInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제품명
          Row(
            children: [
              Expanded(
                child: Text(
                  _game!.title,
                  style: AppTextStyles.heading1.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(LucideIcons.info, size: 20),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(LucideIcons.externalLink, size: 20),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 브랜드 정보
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.blueWhite,
                child: Icon(LucideIcons.package, size: 20, color: AppColors.blue),
              ),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brand: APPLE',
                    style: AppTextStyles.body4.copyWith(
                      color: AppColors.medium,
                    ),
                  ),
                  Text(
                    'Value: \$${(_game!.originalPrice / 1000).toStringAsFixed(2)}',
                    style: AppTextStyles.body3.copyWith(
                      color: AppColors.darkBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 추가 정보
          _buildInfoRow('Quantity', '1'),
          const SizedBox(height: 8),
          _buildInfoRow('Shipping From', 'Korea'),
          const SizedBox(height: 8),
          _buildInfoRow('Shipping To', 'Korea'),

          const SizedBox(height: 16),

          // 게임 상태 버튼
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(LucideIcons.barChart, size: 16),
                  label: const Text('Game status'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: Icon(LucideIcons.award, size: 16),
                  label: Text('Prize info'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 정보 행
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body4.copyWith(color: AppColors.medium),
        ),
        Text(
          value,
          style: AppTextStyles.body4.copyWith(
            color: AppColors.darkBlue,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  /// 선택된 블록 리스트
  Widget _buildSelectedBlocksList() {
    if (_selectedBlocks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.mousePointerClick,
              size: 48,
              color: AppColors.buleGray,
            ),
            SizedBox(height: 16),
            Text(
              'Select blocks on the grid',
              style: AppTextStyles.body3.copyWith(color: AppColors.medium),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedBlocks.length} Blocks selected',
                style: AppTextStyles.button.copyWith(color: AppColors.blue),
              ),
              TextButton(
                onPressed: _handleClearAll,
                child: const Text('CLEAR'),
              ),
            ],
          ),
        ),

        // 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _selectedBlocks.length,
            separatorBuilder: (context, index) => Divider(height: 1),
            itemBuilder: (context, index) {
              final block = _selectedBlocks[index];
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(vertical: 4),
                title: Text(
                  '${block.row} Row, ${block.col} Column',
                  style: AppTextStyles.body3.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(LucideIcons.x, size: 18),
                  onPressed: () => _handleRemoveBlock(block),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// 확인 버튼
  Widget _buildConfirmButton() {
    final isDisabled = _selectedBlocks.isEmpty;
    final totalCost = _game!.currentPrice * _selectedBlocks.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(color: AppColors.buleGray),
        ),
      ),
      child: Column(
        children: [
          // 총 비용
          if (!isDisabled)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Cost',
                    style: AppTextStyles.body3.copyWith(color: AppColors.medium),
                  ),
                  Text(
                    '₩${_formatNumber(totalCost)}',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.blue,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          // 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDisabled ? null : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Confirmed ${_selectedBlocks.length} blocks!'),
                    backgroundColor: AppColors.green500,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isDisabled ? AppColors.buleGray : AppColors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                ),
              ),
              child: Text(
                isDisabled
                    ? 'Select blocks to continue'
                    : 'Confirm Picks (₩${_formatNumber(_game!.currentPrice)}/pick)',
                style: AppTextStyles.button.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 모바일 하단 시트
  Widget _buildMobileBottomSheet() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusBottomSheet)),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.buleGray,
              borderRadius: BorderRadius.circular(AppConstants.radiusSm),
            ),
          ),

          // 선택된 블록 수
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedBlocks.length} Blocks selected',
                  style: AppTextStyles.button.copyWith(color: AppColors.blue),
                ),
                TextButton(
                  onPressed: _handleClearAll,
                  child: const Text('CLEAR'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: _buildConfirmButton(),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}K';
    }
    return number.toString();
  }
}
