import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 튜토리얼 버튼 위젯 (새로운 디자인)
class TutorialButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const TutorialButtonWidget({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: InkWell(
        onTap: onTap ?? () {
          _showTutorialModal(context);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFEFF6FF), Color(0xFFF9F5FF)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.blue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              // 아이콘
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradientBlue,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.blue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  LucideIcons.bookOpen,
                  color: AppColors.white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '단 하나의 선택이 행운으로!',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.darkBlue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '블록픽 참가하는 방법',
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.navy,
                      ),
                    ),
                  ],
                ),
              ),

              // 화살표
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.blue,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 튜토리얼 모달 표시
  void _showTutorialModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TutorialModal(),
    );
  }
}

/// 튜토리얼 모달
class TutorialModal extends StatelessWidget {
  const TutorialModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // 핸들
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 헤더
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BlockPick Tutorial',
                  style: AppTextStyles.large.copyWith(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.navy,
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTutorialSection(
                    title: '1. 게임 선택하기',
                    description: '원하는 상품이 있는 게임을 선택하세요.',
                    icon: LucideIcons.grid,
                    iconColor: AppColors.blue,
                  ),
                  const SizedBox(height: 20),
                  _buildTutorialSection(
                    title: '2. 블록 선택하기',
                    description: '그리드에서 원하는 블록을 선택하세요. 각 블록은 고유한 위치를 가지고 있습니다.',
                    icon: LucideIcons.mousePointerClick,
                    iconColor: AppColors.purple,
                  ),
                  const SizedBox(height: 20),
                  _buildTutorialSection(
                    title: '3. 게임 참가하기',
                    description: '선택한 블록으로 게임에 참가합니다. 참가비를 지불하고 당첨을 기다리세요!',
                    icon: LucideIcons.trophy,
                    iconColor: AppColors.yellow,
                  ),
                  const SizedBox(height: 20),
                  _buildTutorialSection(
                    title: '4. 당첨 확인하기',
                    description: '게임이 종료되면 결과를 확인할 수 있습니다. 당첨되면 상품을 받게 됩니다!',
                    icon: LucideIcons.gift,
                    iconColor: AppColors.pink,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blueWhite,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          LucideIcons.info,
                          color: AppColors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '게임이 취소되면 참가비가 100% 환불됩니다.',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.blue,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  '시작하기',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorialSection({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.darkBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppTextStyles.body.copyWith(
                  color: AppColors.navy,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
