import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/widgets/forgot_password_body.dart';


class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomView(body: ForgotPasswordBody());
  }
}
