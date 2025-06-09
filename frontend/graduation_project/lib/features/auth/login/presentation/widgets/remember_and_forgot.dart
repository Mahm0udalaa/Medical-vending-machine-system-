import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/forget_password/presentation/screens/forgot_password_view.dart';

class RememberAndForgot extends StatelessWidget {
  const RememberAndForgot({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Spacer(),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ForgotPasswordView()),
            );
          },
          child: Text(
            "Forgot Password ?",
            style: TextStyle(
              color: Color(0xff07AA59),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
