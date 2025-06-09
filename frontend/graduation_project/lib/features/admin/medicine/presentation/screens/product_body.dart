import 'package:flutter/material.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/presentation/widgets/product_details.dart';

class ProductBody extends StatelessWidget {
  const ProductBody({super.key, this.medicine});
  final MedicineModel? medicine;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xff26864E),
          centerTitle: true,
          elevation: 0,
          title: Text(
            medicine?.medicineName ?? "",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: CustomScrollView(
          slivers: [
        
            ProductDetails(

              medicine: medicine,
              // quantity:medicine?.quantity?? 1,
              imagePath: medicine?.imagePath??"",
              price: medicine?.medicinePrice.toString() ?? "",
              medName: medicine?.medicineName??"",
              medMG: "50 mg",
              medPills: "20 pills",
              description:medicine?.description??""
            ),
          ],
        ),
      ),
    );
  }
}

