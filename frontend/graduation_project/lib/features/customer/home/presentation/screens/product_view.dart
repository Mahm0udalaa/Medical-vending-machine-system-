import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/product_body.dart';


class CustomerProductView extends StatelessWidget {
  const CustomerProductView({super.key,  this.medicine});
  final MedicineModel? medicine;

  @override
  Widget build(BuildContext context) {
    return CustomView(body: CustomerProductBody(medicine:medicine ,));
  }
}
