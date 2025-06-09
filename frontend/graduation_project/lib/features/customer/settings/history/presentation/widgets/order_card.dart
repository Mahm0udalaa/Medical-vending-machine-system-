import 'package:flutter/material.dart';

class OrderCard extends StatelessWidget {
  const OrderCard(
      {super.key,
      required this.title,
      required this.price,
      required this.image});
  final String title, price, image;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      margin: EdgeInsets.symmetric(horizontal: 32),
      height: MediaQuery.of(context).size.height * 0.15,
      decoration: BoxDecoration(
        border: Border.all(color: Color.fromARGB(172, 27, 94, 55)),
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Row(
        children: [
          SizedBox(width: 10),
          Image.asset(image, height: 50, fit: BoxFit.fill),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: 20),
              Text(
                price,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 16),
            ],
          ),
        ],
      ),
    );
  }
}
