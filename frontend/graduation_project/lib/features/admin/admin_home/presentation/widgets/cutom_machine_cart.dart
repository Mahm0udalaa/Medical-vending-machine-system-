import 'package:flutter/material.dart';

class CutomMachineCart extends StatelessWidget {
  final String machineLocationText;
  final String machineId;
  final VoidCallback? onTap;

  const CutomMachineCart({
    super.key,
    required this.machineLocationText,
    required this.machineId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 300, // ارتفاع ثابت للكارد
        child: Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الصورة تاخد 2/3
                Flexible(
                  flex: 2,
                  child: Image.asset(
                    "assets/image 1.png",
                    fit: BoxFit.cover,
                    width: double.infinity,
                  ),
                ),

                const SizedBox(height: 8),

                // الكلام ياخد 1/3 مع SingleChildScrollView
                Flexible(
                  flex: 1,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          machineLocationText,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        // Text(
                        //   "ID: $machineId",
                        //   style: const TextStyle(fontWeight: FontWeight.bold),
                        // ),

                        
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
