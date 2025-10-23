import 'package:flutter/material.dart';
import '../widgets/signup_form.dart';

/// 회원가입 페이지 (전체 화면)
class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: SignupForm(isDialog: false),
        ),
      ),
    );
  }
}
