import 'package:flutter/material.dart';

class StepCircle extends StatelessWidget {
  final bool isActive;
  final String label;
   const StepCircle({super.key, required this.isActive, required this.label});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 14,
          backgroundColor:
              isActive ? const Color(0xff26864E) : Colors.grey[300],
          child:
              isActive
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}