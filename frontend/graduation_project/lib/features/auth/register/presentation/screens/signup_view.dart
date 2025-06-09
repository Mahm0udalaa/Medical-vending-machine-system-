import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/auth/register/presentation/widgets/signup_body.dart';


class SignupView extends StatelessWidget {
  const SignupView({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(child: CustomView(body: SignupBody()));
  }
}
