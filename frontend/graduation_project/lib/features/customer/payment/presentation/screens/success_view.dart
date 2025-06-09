import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/step_circle.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/step_divider.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/failed_payment_dialog.dart';
import 'package:graduation_project/features/customer/cart/data/models/all_medicines_cart_model.dart';

class SuccessView extends StatelessWidget {
  final List<CartMedicineModel> medicines;
  const SuccessView({super.key, required this.medicines});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff26864E),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('pick up order', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StepCircle(isActive: true, label: 'pay'),
                StepDivider(),
                StepCircle(isActive: true, label: 'Summary'),
                StepDivider(),
                StepCircle(isActive: true, label: 'pick up order'),
              ],
            ),
            const SizedBox(height: 32),
            Image.asset('assets/sucess_order.png', height: 180),
            const SizedBox(height: 24),
            const Text('Payment Success, Yayy!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 12),
            const Text(
              'Your order is now available for pickup at the vending machine in front of you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            // قائمة الأدوية المصروفة
            Expanded(
              child: ListView.builder(
                itemCount: medicines.length,
                itemBuilder: (context, index) {
                  final med = medicines[index];
                  return ListTile(
                    leading: Image.network(med.imagePath, width: 40, height: 40),
                    title: Text(med.medicineName),
                    subtitle: Text('Quantity: ${med.quantity}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            CustomButton(text:" Download Invoice", backgroundcolor: const Color(0xff26864E), width: double.infinity, onPressed: () {
              showFailedPaymentDialog(context);
            }),
            const SizedBox(height: 12),
            CustomButton(text:" Return to HomePage", backgroundcolor: const Color(0xff26864E), width: double.infinity, onPressed: () {}),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.phone, color: Color(0xff26864E)),
              label: const Text('call customer support', style: TextStyle(color: Color(0xff26864E))),
            ),
          ],
        ),
      ),
    );
  }
}


