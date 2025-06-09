import 'package:flutter/material.dart';

class TotalContainer extends StatelessWidget {
  const TotalContainer({super.key, required this.price});
  final String price;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.09,
      decoration: BoxDecoration(color: Color.fromARGB(255, 255, 255, 255)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total Price",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: Color(0xff6C7278),
                ),
              ),
              Text(
                price,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 22),
              ),
            ],
          ),
          // SizedBox(
          //   width: 150,
          //   height: 35,
          //   child: ElevatedButton(
          //     style: ButtonStyle(
          //       shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          //         RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(4.0),
          //         ),
          //       ),
          //       backgroundColor: WidgetStateProperty.all(
          //         Color(0xff1B5E37),
          //       ),
          //     ),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (context) => EmptyCartView(),
          //         ),
          //       );
          //     },
          //     child: Text(
          //       "Checkout",
          //       style: TextStyle(color: Colors.white),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
