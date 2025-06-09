import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/home_view.dart';

void showFailedPaymentDialog(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Failed Payment Dialog",
    barrierColor: Colors.black.withAlpha((0.3 * 255).toInt()),
    pageBuilder: (context, animation, secondaryAnimation) {
      final size = MediaQuery.of(context).size;
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Material(
          type: MaterialType.transparency,
          child: Center(
            child: Container(
              width: size.width * 0.85,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/failed_order_image.png', height: 120),
                  const SizedBox(height: 24),
                  const Text(
                    'Oops! Order Failed',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Something went tembly wrong.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 32),
                  CustomButton(text: "Please Try Again", backgroundcolor: const Color(0xff26864E), width: double.infinity, onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  }),
                  const SizedBox(height: 12),
                  CustomButton(text: "Back to home", backgroundcolor: const Color(0xff26864E), width: double.infinity, onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const HomeView()), (route) => false); 
                  }),
          
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
