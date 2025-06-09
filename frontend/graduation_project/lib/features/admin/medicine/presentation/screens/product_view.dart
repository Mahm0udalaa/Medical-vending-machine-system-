import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/medicine_refill_cubit.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_refill_repo.dart';
import 'package:graduation_project/features/admin/medicine/presentation/screens/product_body.dart';

class ProductView extends StatelessWidget {
  const ProductView({super.key, this.medicine});
  final MedicineModel? medicine;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MedicineRefillCubit(MedicineRefillRepo()),
      child: CustomView(
        body: ProductBody(medicine: medicine),
      ),
    );
  }
}
