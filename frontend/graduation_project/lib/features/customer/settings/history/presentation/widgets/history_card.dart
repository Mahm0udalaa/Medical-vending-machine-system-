import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.image,
    required this.orderNumber,
    required this.date,
    required this.price,
    required this.numberOfOrders,
    required this.onTap,
  });
  
  final String image, orderNumber, date, price, numberOfOrders;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // صورة الدائرة
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                ),
              ),
      
              const SizedBox(width: 12),
      
              // العمود الذي يحتوي النصوص، مع Expanded لمنع overflow
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "order number : #$orderNumber",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Order date : $date",
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff949D9E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 35,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$price EGP",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                         
                          Text(
                            "number of orders : $numberOfOrders",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      
              // زر السهم
              IconButton(
                icon: const Icon(FontAwesomeIcons.angleRight, color: Color(0xff949D9E)),
                onPressed: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
