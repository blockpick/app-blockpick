import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/wish_model.dart';

/// 소원 등록 완료 화면
class WishCreateCompleteScreen extends StatelessWidget {
  final Wish wish;

  const WishCreateCompleteScreen({
    super.key,
    required this.wish,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              // 축하 아이콘
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 50,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                '소원이 등록되었어요!',
                style: AppTextStyles.heading1,
              ),
              const SizedBox(height: 12),
              Text(
                '공감 ${wish.empathyThreshold}개를 모으면\n게임에 참여할 수 있어요',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.gray600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // 안내
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Column(
                  children: [
                    Text(
                      '공감을 빠르게 모으는 방법',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 12),
                    _TipRow(icon: Icons.share, text: '친구에게 공유하기'),
                    SizedBox(height: 8),
                    _TipRow(icon: Icons.chat_bubble_outline, text: 'SNS에 올리기'),
                    SizedBox(height: 8),
                    _TipRow(icon: Icons.favorite, text: '매력적인 한줄평이 핵심!'),
                  ],
                ),
              ),
              const Spacer(flex: 3),
              // 버튼들
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: 공유 기능
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('공유 기능은 추후 구현됩니다')),
                    );
                  },
                  icon: const Icon(Icons.share, size: 18),
                  label: const Text('공유하기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: 내 소원 관리로 이동
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.textBlack,
                    side: const BorderSide(color: AppColors.gray200),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('내 소원 보기'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text(
                  '위시 메인으로',
                  style: TextStyle(color: AppColors.gray600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TipRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _TipRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 13, color: AppColors.gray600),
        ),
      ],
    );
  }
}
