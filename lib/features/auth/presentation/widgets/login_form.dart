import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// 재사용 가능한 로그인 폼 위젯
/// 페이지와 다이얼로그에서 모두 사용 가능
class LoginForm extends ConsumerStatefulWidget {
  /// 다이얼로그 모드 여부 (true: 다이얼로그, false: 페이지)
  final bool isDialog;

  const LoginForm({
    super.key,
    this.isDialog = false,
  });

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _emailError;
  String? _passwordError;
  int _loginAttempts = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> _handleLogin() async {
    // 유효성 검사 초기화
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // 이메일 검증
    if (email.isEmpty) {
      setState(() => _emailError = '이메일을 입력해 주세요.');
      return;
    }
    if (!_isValidEmail(email)) {
      setState(() => _emailError = '이메일 형식이 올바르지 않습니다.');
      return;
    }

    // 비밀번호 검증
    if (password.isEmpty) {
      setState(() => _passwordError = '비밀번호를 입력해주세요.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signIn(email, password);

      if (!mounted) return;

      // signIn은 AsyncValue.guard를 사용하므로 throw하지 않음
      // state를 직접 확인
      final authState = ref.read(authProvider);
      if (authState.hasValue && authState.value?.isAuthenticated == true) {
        // 로그인 성공
        if (widget.isDialog) {
          Navigator.of(context).pop();
        } else {
          context.go('/');
        }
      } else {
        // 로그인 실패
        _loginAttempts++;
        if (_loginAttempts >= 5) {
          setState(() {
            _passwordError = '비밀번호 5회 실패. 비밀번호 찾기를 이용해주세요.';
          });
        } else {
          setState(() {
            _passwordError = '비밀번호를 다시 확인해 주세요 ($_loginAttempts/5)';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        _loginAttempts++;
        setState(() {
          _passwordError = '로그인 중 오류가 발생했습니다.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleClose() {
    if (widget.isDialog) {
      Navigator.of(context).pop();
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: widget.isDialog ? MainAxisSize.min : MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '로그인',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
            ),
            IconButton(
              onPressed: _handleClose,
              icon: const Icon(Icons.close),
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 이메일 입력
        const Text(
          '이메일',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _emailController,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() => _emailError = null),
          onEditingComplete: () => _passwordFocusNode.requestFocus(),
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: '이메일을 입력해 주세요.',
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        if (_emailError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _emailError!,
              style: TextStyle(fontSize: 13, color: AppColors.red),
            ),
          ),
        const SizedBox(height: 16),

        // 비밀번호 입력
        const Text(
          '비밀번호',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onChanged: (_) => setState(() => _passwordError = null),
          onEditingComplete: _handleLogin,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: '비밀번호를 입력해 주세요.',
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.gray400,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _isPasswordVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                color: AppColors.gray500,
                size: 22,
              ),
              onPressed: () {
                setState(() {
                  _isPasswordVisible = !_isPasswordVisible;
                });
              },
            ),
          ),
        ),
        if (_passwordError != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              _passwordError!,
              style: TextStyle(fontSize: 13, color: AppColors.red),
            ),
          ),
        const SizedBox(height: 24),

        // 로그인 버튼
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleLogin,
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
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    ),
                  )
                : const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 20),

        // 회원가입 | 비밀번호 찾기
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                if (widget.isDialog) {
                  Navigator.of(context).pop();
                }
                Future.microtask(() {
                  if (mounted) {
                    context.push('/auth/signup-select');
                  }
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '회원가입',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ),
            Text(
              '|',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray300,
              ),
            ),
            TextButton(
              onPressed: () {
                if (widget.isDialog) {
                  Navigator.of(context).pop();
                }
                Future.microtask(() {
                  if (mounted) {
                    context.push('/find-password');
                  }
                });
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                '비밀번호 찾기',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.gray500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
