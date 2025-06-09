import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/register/presentation/screens/signup_view.dart';

class DontHaveAccount extends StatelessWidget {
  const DontHaveAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Don’t have an account?",
          style: TextStyle(
            color: Color(0xff6C7278),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SignupView()),
            );
          },
          child: Text(
            " Sign Up",
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
