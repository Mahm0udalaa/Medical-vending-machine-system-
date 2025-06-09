import 'package:flutter/material.dart';

class CategoryAvatar extends StatelessWidget {
  const CategoryAvatar({super.key, required this.image, required this.title});
  final String image;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          backgroundColor: Colors.transparent,
          child: Image.asset(image),
        ),
        Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
