import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomAppBar extends StatelessWidget {
  const CustomAppBar({super.key, required this.screenTitle});
  final String screenTitle;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromARGB(115, 255, 255, 255),
            ),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(FontAwesomeIcons.chevronLeft, color: Colors.black),
        ),
        SizedBox(width: 24),
        Text(
          screenTitle,
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
