import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/domain/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/constants/app_constants.dart';

/// SC-011-09, SC-011-10: 회원 탈퇴 화면
class WithdrawalScreen extends ConsumerStatefulWidget {
  const WithdrawalScreen({super.key});

  @override
  ConsumerState<WithdrawalScreen> createState() => _WithdrawalScreenState();
}

class _WithdrawalScreenState extends ConsumerState<WithdrawalScreen> {
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isValid = false;
  String? _passwordError;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  void _validatePassword(String value) {
    setState(() {
      if (value.isEmpty) {
        _passwordError = null;
        _isValid = false;
      } else {
        _passwordError = null;
        _isValid = value.isNotEmpty;
      }
    });
  }

  Future<void> _handleWithdrawal() async {
    if (!_isValid) return;

    final password = _passwordController.text.trim();

    try {
      await ref.read(authProvider.notifier).withdrawUser(
        password: password,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              '회원 탈퇴가 정상적으로 완료되었습니다.\n더 좋은 서비스로 다시 만나요!',
            ),
            backgroundColor: AppColors.darkBlue,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
            ),
            duration: Duration(seconds: 3),
          ),
        );
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _passwordError = '비밀번호를 다시 확인해 주세요.';
          _isValid = false;
        });
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
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          foregroundColor: AppColors.darkBlue,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),

                    // 타이틀
                    Text(
                      '회원 탈퇴 전,\n아래 사항을 반드시 확인해 주세요.',
                      style: AppTextStyles.heading2.copyWith(color: AppColors.darkBlue, height: 1.3),
                    ),
                    const SizedBox(height: 32),

                    // 안내 항목들
                    _buildInfoSection(
                      title: '포인트 및 캐시 확인',
                      description:
                          '회원 탈퇴를 하시면 다양한 블록픽의 이벤트, 쇼핑 혜택을 받을 수 없어요.',
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      title: '데이터 삭제',
                      description:
                          '작성한 리뷰, 이벤트 응모 및 당첨 내역 등 모든 활동 기록이 영구 삭제됩니다.',
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      title: '혜택 종료',
                      description:
                          '탈퇴 즉시 블록픽의 이벤트 혜택과 맞춤형 쇼핑 소식을 받으실 수 없습니다.',
                    ),
                    const SizedBox(height: 24),
                    _buildInfoSection(
                      title: '개인정보 보호',
                      description: '회원님의 정보는 탈퇴 즉시 안전하게 파기됩니다.',
                    ),

                    const SizedBox(height: 32),
                    const Divider(color: AppColors.gray200, height: 1),
                    SizedBox(height: 32),

                    // 비밀번호 입력 섹션
                    Text(
                      '비밀번호 입력 후 탈퇴됩니다.',
                      style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordInput(),

                    SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // 탈퇴하기 버튼 (하단 고정)
            _buildWithdrawButton(),
          ],
        ),
      ),
    );
  }

  /// 안내 항목
  Widget _buildInfoSection({
    required String title,
    required String description,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.title2.copyWith(color: AppColors.darkBlue),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// 비밀번호 입력 필드
  Widget _buildPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          onChanged: _validatePassword,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: '비밀번호를 입력해 주세요.',
            hintStyle: TextStyle(
              color: AppColors.gray400,
              fontSize: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(color: AppColors.gray200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(
                color:
                    _passwordError != null ? AppColors.red : AppColors.gray200,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              borderSide: BorderSide(
                color:
                    _passwordError != null ? AppColors.red : AppColors.darkBlue,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 유효성 체크 아이콘
                if (_passwordController.text.isNotEmpty)
                  Icon(
                    Icons.check,
                    size: 20,
                    color: _isValid ? AppColors.green500 : AppColors.gray400,
                  ),
                // 비밀번호 보기/숨기기 토글
                IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: AppColors.gray500,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
        if (_passwordError != null) ...[
          const SizedBox(height: 8),
          Text(
            _passwordError!,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.red,
            ),
          ),
        ],
      ],
    );
  }

  /// 탈퇴하기 버튼
  Widget _buildWithdrawButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isValid ? _handleWithdrawal : null,
            style: ElevatedButton.styleFrom(
              foregroundColor: AppColors.white,
              disabledBackgroundColor: AppColors.gray300,
              disabledForegroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              ),
              elevation: 0,
            ),
            child: const Text(
              '탈퇴하기',
              style: AppTextStyles.title2,
            ),
          ),
        ),
      ),
    );
  }
}
