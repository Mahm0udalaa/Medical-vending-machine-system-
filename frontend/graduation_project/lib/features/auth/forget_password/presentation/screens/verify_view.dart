import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/auth/forget_password/cubit/verify_code_cubit.dart';
import 'package:graduation_project/features/auth/forget_password/data/repos/forgot_password_repo.dart';
import '../widgets/verify_body.dart';
import 'package:dio/dio.dart';

class VerifyView extends StatelessWidget {
  final String email;

  const VerifyView({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyCodeCubit(ForgotPasswordRepo(dio: Dio())),
      child: Material(
        child: SafeArea(  // يحمي من تجاوز المحتوى لـ notch أو status bar
          child: VerifyBody(email: email),
        ),
      ),
    );
  }
}
