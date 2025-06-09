import 'package:flutter/material.dart';

class TotalPrice extends StatelessWidget {
  const TotalPrice({
    super.key,
    required this.subtotal,
    required this.discount,
    required this.total,
  });
  final String subtotal, discount, total;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.08 * 255).toInt()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildRow("Subtotal", subtotal, color: Colors.grey[700]!),
          const SizedBox(height: 12),
          _buildRow("Discount", discount, color: Colors.grey[700]!),
          const SizedBox(height: 12),
          Divider(color: Colors.grey[300], thickness: 1),
          const SizedBox(height: 12),
          _buildRow(
            "Total",
            total,
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: Colors.green[700]!,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {Color color = Colors.black,
      FontWeight fontWeight = FontWeight.w600,
      double fontSize = 16}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color),
        ),
        Text(
          value,
          style:
              TextStyle(fontWeight: fontWeight, fontSize: fontSize, color: color),
        ),
      ],
    );
  }
}
