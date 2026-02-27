import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/auth/domain/providers/auth_provider.dart';

/// SC-004: 로그인 화면
///
/// - SC-004-01: 로그인 화면 (이메일/비밀번호 입력)
/// - SC-004-02: 로그인 기능 (이메일/SNS 로그인)
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  String? _emailError;
  String? _passwordError;
  bool _isLoading = false;
  bool _obscurePassword = true;
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

    // 로그인 시도
    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).signIn(email, password);

      if (!mounted) return;

      // 로그인 성공 - 홈으로 이동
      context.go('/');
    } catch (e) {
      _loginAttempts++;

      if (_loginAttempts >= 5) {
        // 5회 이상 실패
        _showAccountLockedDialog();
      } else {
        setState(() {
          _passwordError = '비밀번호를 다시 확인해 주세요 ($_loginAttempts/5).';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAccountLockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '비밀번호 5회 실패로 보안을 위해\n계정이 잠겼어요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.darkBlue,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '비밀번호 찾기를 이용해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/find-password');
            },
            child: const Text(
              '비밀번호찾기',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNotMemberDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Blockpick 회원 계정이 아니에요.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '다른 계정으로 로그인 하거나\n회원가입을 해주세요.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.gray600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: AppColors.gray600),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/signup');
            },
            child: const Text(
              '회원가입 하기',
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    // TODO: 실제 소셜 로그인 구현
    // 최초 로그인인 경우 회원가입 유도 다이얼로그 표시
    _showNotMemberDialog();
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
            '로그인 하기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.darkBlue,
            ),
          ),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),

                      // 이메일 입력 필드
                      _buildTextField(
                        label: '이메일',
                        hint: '이메일을 입력해 주세요.',
                        controller: _emailController,
                        focusNode: _emailFocusNode,
                        errorText: _emailError,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() => _emailError = null),
                        onEditingComplete: () => _passwordFocusNode.requestFocus(),
                      ),
                      const SizedBox(height: 20),

                      // 비밀번호 입력 필드
                      _buildTextField(
                        label: '비밀번호',
                        hint: '비밀번호를 입력해 주세요.',
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        errorText: _passwordError,
                        obscureText: _obscurePassword,
                        onChanged: (_) => setState(() => _passwordError = null),
                        onEditingComplete: _handleLogin,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: AppColors.gray500,
                            size: 22,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 회원가입 / 이메일 찾기 / 비밀번호 찾기
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTextButton('회원가입', () => context.push('/signup')),
                          _buildDivider(),
                          _buildTextButton('이메일 찾기', () => context.push('/find-email')),
                          _buildDivider(),
                          _buildTextButton('비밀번호 찾기', () => context.push('/find-password')),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // 로그인 버튼
                      SizedBox(
                        width: double.infinity,
                        height: 56,
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
                                    strokeWidth: 2,
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
                      const SizedBox(height: 32),

                      // 또는 구분선
                      Row(
                        children: [
                          Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              '또는',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.gray500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.gray300, thickness: 1)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 구글 로그인
                      _buildSocialButton(
                        icon: _buildGoogleIcon(),
                        text: '구글 계정으로 로그인',
                        backgroundColor: AppColors.white,
                        textColor: AppColors.darkBlue,
                        borderColor: AppColors.gray300,
                        onTap: () => _handleSocialLogin('google'),
                      ),
                      const SizedBox(height: 12),

                      // 애플 로그인
                      _buildSocialButton(
                        icon: const Icon(Icons.apple, color: AppColors.white, size: 22),
                        text: '애플 계정으로 로그인',
                        backgroundColor: AppColors.black,
                        textColor: AppColors.white,
                        onTap: () => _handleSocialLogin('apple'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    String? errorText,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    void Function(String)? onChanged,
    VoidCallback? onEditingComplete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.darkBlue,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.darkBlue,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 16,
              color: AppColors.gray400,
            ),
            errorText: errorText,
            errorStyle: TextStyle(
              fontSize: 12,
              color: AppColors.red,
            ),
            filled: true,
            fillColor: AppColors.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.blue, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.red, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Widget _buildTextButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.gray600,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '|',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.gray300,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required Widget icon,
    required String text,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: borderColor != null ? Border.all(color: borderColor) : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 12),
              Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

/// 구글 로고 페인터
class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 간단한 G 로고
    paint.color = const Color(0xFF4285F4);
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    paint.color = AppColors.white;
    final rect = Rect.fromLTWH(
      size.width * 0.45,
      size.height * 0.35,
      size.width * 0.35,
      size.height * 0.3,
    );
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
