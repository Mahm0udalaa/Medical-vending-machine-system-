import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/customer/cart/presentation/screens/cart_body.dart';

class CartView extends StatelessWidget {
  const CartView({super.key, MedicineModel? medicine, required int quantity});

  @override
  Widget build(BuildContext context) {
    return CustomView(body: CartBody());
  }
}
