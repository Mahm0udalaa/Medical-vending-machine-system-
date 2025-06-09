import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/features/auth/login/presentation/screens/login_view.dart';

class Popupsuccess extends StatelessWidget {
  const Popupsuccess({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      elevation: 50,
      shadowColor: CupertinoColors.inactiveGray,
      backgroundColor: Colors.white,
      shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(4)),
      content: GestureDetector(
        onTap: () {
          Navigator.of(context).pop(); // يغلق الـ dialog
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginView()),
          );
        },
        child: Image.asset("assets/pop.png"),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
              (route) => false,
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
