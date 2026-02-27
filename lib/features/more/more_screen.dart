import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/mode_card.dart';

/// 10가지 좌표 선택 모드 체험 화면
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  static const List<PickMode> modes = [
    PickMode(
      id: 'gravity',
      name: 'Gravity',
      icon: '📱',
      description: '폰을 기울여서 구슬을 굴려보세요',
      color: AppColors.primaryMain,
    ),
    PickMode(
      id: 'time',
      name: 'Time',
      icon: '⏱️',
      description: '지금 이 순간의 좌표를 잡아보세요',
      color: AppColors.yellow,
    ),
    PickMode(
      id: 'draw',
      name: 'Draw',
      icon: '🎨',
      description: '그림을 그려서 좌표를 만들어보세요',
      color: AppColors.pink,
    ),
    PickMode(
      id: 'wave',
      name: 'Wave',
      icon: '🌊',
      description: '파동이 퍼져나가는 곳이 좌표가 됩니다',
      color: AppColors.mint,
    ),
    PickMode(
      id: 'voice',
      name: 'Voice',
      icon: '🔊',
      description: '소리로 좌표를 결정해보세요',
      color: AppColors.primaryLight,
    ),
    PickMode(
      id: 'farm',
      name: 'Farm',
      icon: '🌱',
      description: '좌표를 심고 키워보세요',
      color: AppColors.mint,
    ),
    PickMode(
      id: 'rpg',
      name: 'RPG',
      icon: '🗺️',
      description: '캐릭터로 이미지를 탐험해보세요',
      color: AppColors.red,
    ),
    PickMode(
      id: 'duo',
      name: 'Duo',
      icon: '👥',
      description: '친구와 함께 좌표를 합쳐보세요',
      color: AppColors.blue,
    ),
    PickMode(
      id: 'fortune',
      name: 'Fortune',
      icon: '🎭',
      description: '운명의 질문에 답하고 좌표를 받으세요',
      color: AppColors.primaryLight,
    ),
    PickMode(
      id: 'predict',
      name: 'Predict',
      icon: '🌀',
      description: '다음 당첨 좌표를 예언해보세요',
      color: AppColors.mint,
    ),
    PickMode(
      id: 'gacha',
      name: 'Gacha',
      icon: '🎮',
      description: '인형뽑기처럼 좌표를 잡아보세요',
      color: AppColors.pink,
    ),
    PickMode(
      id: 'treasure',
      name: 'Treasure',
      icon: '💎',
      description: '숨겨진 보물을 찾아보세요!',
      color: AppColors.yellow,
    ),
    PickMode(
      id: 'unity',
      name: '3D Block',
      icon: '🧊',
      description: '3D 블록 세계에서 보물을 찾아보세요',
      color: AppColors.mint,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.gray100,
      child: CustomScrollView(
        slivers: [
          // 헤더 설명
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '좌표 선택 체험',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '12가지 독창적인 방법으로 좌표를 선택해보세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 모드 그리드
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final mode = modes[index];
                  return ModeCard(
                    mode: mode,
                    onTap: () => _navigateToMode(context, mode),
                  );
                },
                childCount: modes.length,
              ),
            ),
          ),

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  void _navigateToMode(BuildContext context, PickMode mode) {
    context.push('/more/${mode.id}');
  }
}

/// 픽 모드 데이터 모델
class PickMode {
  final String id;
  final String name;
  final String icon;
  final String description;
  final Color color;

  const PickMode({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.color,
  });
}
