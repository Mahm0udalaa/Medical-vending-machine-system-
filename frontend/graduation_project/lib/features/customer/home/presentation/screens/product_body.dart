import 'package:flutter/material.dart';
import 'package:graduation_project/features/customer/home/presentation/widgets/customer_product_details.dart';

import '../../../../admin/medicine/data/models/medicine_model.dart';


class CustomerProductBody extends StatelessWidget {
  const CustomerProductBody({super.key, this.medicine});
  final MedicineModel? medicine;

  @override
  Widget build(BuildContext context) {
    // ببساطة أعد CustomerProductDetails مباشرةً، لأنه سيحتوي الآن على Scaffold الخاص به
    return CustomerProductDetails(
      medicine: medicine,
      machineId: medicine?.machineId ?? 0,
      medicineId: medicine?.medicineId ?? 0,
      imagePath: medicine?.imagePath ?? "",
      price: medicine?.medicinePrice?.toString() ?? "",
      medName: medicine?.medicineName ?? "",
      slot: medicine?.slot ?? "",
      quantity: medicine?.quantity.toString() ?? "",
      description: medicine?.description ?? "",
    );
  }
}