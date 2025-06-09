import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';

import '../../cubits/cubit/all_medicine_cart_cubit.dart';

class CartCard extends StatelessWidget {
  const CartCard({
    super.key,
    this.medicineId,
    required this.addedMedicineQuantity,
    required this.image,
    required this.name,
    required this.price,
    this.medicine,
    required this.quantity,
  });

  final String image, name;
  final int addedMedicineQuantity, quantity , price;
  final int? medicineId;
  final MedicineModel? medicine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      height: MediaQuery.of(context).size.height * 0.13,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(50),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Image.network(image, height: 50, width: 50, fit: BoxFit.cover),
          const SizedBox(width: 10),

          // Expanded column for name and price
          Expanded(
            flex: 2,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  ' Total Price: ${price*quantity}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 95, 105, 99),
                  ),
                ),
              ],
            ),
          ),

          // SpinBox with fixed width
          SizedBox(
            width: 90,
            child: SpinBox(
              iconSize: 18,
              incrementIcon: const Icon(
                FontAwesomeIcons.plus,
                color: Color.fromARGB(255, 10, 187, 10),
                size: 12,
              ),
              decrementIcon: const Icon(
                FontAwesomeIcons.minus,
                color: Color.fromARGB(255, 255, 0, 0),
                size: 12,
              ),
              min: 1,
              textStyle: const TextStyle(color: Colors.black, fontSize: 16),
              max: 6,
              value: quantity.toDouble(),
              onChanged: (value) {
                final cubit = context.read<AllMedicineCartCubit>();
                cubit.updateCartMedicineQuantity(medicineId!, value.toInt());
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              ),
            ),
          ),

          // Delete button
          IconButton(
            onPressed: () {
              final cubit = context.read<AllMedicineCartCubit>();
              cubit.deleteCartMedicine(medicineId!);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Medicine removed from cart'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            icon: const Icon(Icons.delete, color: Color.fromARGB(255, 180, 32, 32)),
          ),
        ],
      ),
    );
  }
}
