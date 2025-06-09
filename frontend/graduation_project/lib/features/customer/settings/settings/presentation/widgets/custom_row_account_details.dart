import 'package:flutter/material.dart';

class CustomRowaccountDetails extends StatefulWidget {
  const CustomRowaccountDetails({super.key, required this.text});
  final String text;

  @override
  State<CustomRowaccountDetails> createState() =>
      _CustomRowaccountDetailsState();
}

class _CustomRowaccountDetailsState extends State<CustomRowaccountDetails> {
  bool isSwitched = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xff000000),
          ),
        ),
        Spacer(),
        Switch(
          value: isSwitched,
          onChanged: (value) {
            setState(() {
              isSwitched = value;
            });
          },
          activeColor: Color(0xff1B5E37),
        ),
      ],
    );
  }
}
