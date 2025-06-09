import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/login/presentation/screens/login_view.dart';

class AlreadyHaveAnAccount extends StatelessWidget {
  const AlreadyHaveAnAccount({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account?",
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
              MaterialPageRoute(builder: (context) => LoginView()),//todo:: replace
            );
          },
          child: Text(
            "Log In",
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
