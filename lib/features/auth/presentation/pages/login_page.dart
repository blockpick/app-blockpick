import 'package:flutter/material.dart';
import '../widgets/login_form.dart';

/// 로그인 페이지 (전체 화면)
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: LoginForm(isDialog: false),
        ),
      ),
    );
  }
}
