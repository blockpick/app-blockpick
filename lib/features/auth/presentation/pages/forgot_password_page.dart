import 'package:flutter/material.dart';
import '../widgets/forgot_password_form.dart';

/// 비밀번호 찾기 페이지 (전체 화면)
class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: ForgotPasswordForm(isDialog: false),
        ),
      ),
    );
  }
}
