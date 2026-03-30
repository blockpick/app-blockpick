import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// 캐시 충전 화면
class ChargeScreen extends ConsumerStatefulWidget {
  const ChargeScreen({super.key});

  @override
  ConsumerState<ChargeScreen> createState() => _ChargeScreenState();
}

class _ChargeScreenState extends ConsumerState<ChargeScreen> {
  int? _selectedAmount;
  bool _isLoading = false;

  final List<int> _amounts = [5000, 10000, 30000, 50000, 100000, 300000];

  Future<void> _processCharge() async {
    if (_selectedAmount == null) return;

    setState(() => _isLoading = true);

    try {
      // TODO: 결제 프로세스 연동
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_formatNumber(_selectedAmount!)}원이 충전되었습니다'),
            backgroundColor: AppColors.green500,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('충전 실패: $e'),
            backgroundColor: AppColors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.gray100,
        appBar: AppBar(
          title: Text(
            '캐시 충전',
            style: AppTextStyles.title1.copyWith(color: AppColors.darkBlue),
          ),
          backgroundColor: AppColors.gray100,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // 충전 금액 선택
                  Text(
                    '충전할 금액을 선택하세요',
                    style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.2,
                    ),
                    itemCount: _amounts.length,
                    itemBuilder: (context, index) {
                      final amount = _amounts[index];
                      final isSelected = _selectedAmount == amount;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedAmount = amount),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.blue : AppColors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppColors.blue : AppColors.gray200,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${_formatNumber(amount)}원',
                              style: AppTextStyles.title2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 24),

                  // 안내 사항
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.blue.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '충전 안내',
                          style: AppTextStyles.caption2.copyWith(color: AppColors.blue),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '• 충전된 캐시는 게임 참여 및 쇼핑에 사용할 수 있습니다.\n• 충전 취소는 24시간 이내에만 가능합니다.\n• 자세한 내용은 이용약관을 참고해주세요.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray600,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 결제 버튼
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedAmount != null && !_isLoading
                        ? _processCharge
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkBlue,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: AppColors.gray300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : Text(
                            _selectedAmount != null
                                ? '${_formatNumber(_selectedAmount!)}원 충전하기'
                                : '금액을 선택하세요',
                            style: AppTextStyles.title2,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
