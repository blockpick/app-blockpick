import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/data/repositories/auth_repository.dart';

/// SC-006-03: 이메일 찾기 결과 화면
class FindEmailResultScreen extends ConsumerStatefulWidget {
  final String? phone;
  final String? phoneE164;

  const FindEmailResultScreen({
    super.key,
    this.phone,
    this.phoneE164,
  });

  @override
  ConsumerState<FindEmailResultScreen> createState() => _FindEmailResultScreenState();
}

class _FindEmailResultScreenState extends ConsumerState<FindEmailResultScreen> {
  bool _isLoading = true;
  String? _email;
  String? _errorMessage;
  bool _notFound = false;

  @override
  void initState() {
    super.initState();
    _fetchEmail();
  }

  Future<void> _fetchEmail() async {
    if (widget.phoneE164 == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '전화번호 정보가 없습니다.';
      });
      return;
    }

    try {
      final authRepo = await ref.read(authRepositoryProvider.future);
      final result = await authRepo.findEmail(phoneNumber: widget.phoneE164!);

      if (!mounted) return;

      if (result.success && result.email != null) {
        setState(() {
          _isLoading = false;
          _email = result.email;
        });
      } else {
        setState(() {
          _isLoading = false;
          _notFound = true;
          _errorMessage = result.message ?? '해당 번호로 가입된 계정이 없습니다.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = '이메일 조회 중 오류가 발생했습니다.';
      });
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
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.darkBlue),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            '이메일 찾기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
                ),
              )
            : _notFound
                ? _buildNotFoundView()
                : _errorMessage != null
                    ? _buildErrorView()
                    : _buildResultView(),
      ),
    );
  }

  Widget _buildResultView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          // 안내 문구
          const Text(
            '입력하신 휴대폰 번호로\n가입된 계정을 찾았어요!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          // 계정 정보 카드
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('이메일', _email ?? '-'),
                const SizedBox(height: 16),
                _buildInfoRow('휴대폰', widget.phone ?? '-'),
              ],
            ),
          ),

          const Spacer(),

          // 비밀번호 찾기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => context.push('/find-password'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkBlue,
                side: BorderSide(color: AppColors.gray300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '비밀번호 찾기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 로그인 하기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.go('/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '로그인 하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildNotFoundView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),

          const Text(
            '해당 번호로 가입된\n계정이 없어요',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.darkBlue,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '다른 번호로 다시 시도하거나\n새로 회원가입을 해주세요.',
            style: TextStyle(
              fontSize: 15,
              color: AppColors.gray600,
              height: 1.4,
            ),
          ),

          const Spacer(),

          // 다시 찾기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.darkBlue,
                side: BorderSide(color: AppColors.gray300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '다시 찾기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 회원가입 하기 버튼
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => context.push('/signup'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkBlue,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '회원가입 하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppColors.gray400,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? '오류가 발생했습니다.',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkBlue,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('돌아가기'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.gray500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
        ),
      ],
    );
  }
}
