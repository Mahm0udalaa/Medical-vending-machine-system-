import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/core/widgets/custom_text_field.dart';

class AddMedicinePage extends StatefulWidget {
  const AddMedicinePage({super.key});

  @override
  AddMedicinePageState createState() => AddMedicinePageState();
}

class AddMedicinePageState extends State<AddMedicinePage> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _oldPriceController = TextEditingController();
  final _discountController = TextEditingController();

  void _saveMedicine() {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Medicine added successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: MyColors.backgroundColor[0],
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Add New Medicine',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors: MyColors.backgroundColor,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 100.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // اسم الدواء
                CustomTextField(
                  hintText: "Medicine Name",
                  isPassword: false,
                  controller: _nameController,
                ),
                const SizedBox(height: 15),

                // السعر الحالي
                CustomTextField(
                  hintText: "Price",
                  isPassword: false,
                  controller: _priceController,
                ),
                const SizedBox(height: 15),

                // السعر القديم
                CustomTextField(
                  hintText: "Old Price",
                  isPassword: false,
                  controller: _oldPriceController,
                ),
                const SizedBox(height: 15),

                // نسبة الخصم
                CustomTextField(
                  hintText: "Discount %",
                  isPassword: false,
                  controller: _discountController,
                ),
                const SizedBox(height: 30),

                // زر حفظ البيانات
                ElevatedButton(
                  onPressed: _saveMedicine,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: MyColors.backgroundColor[0],
                  ),
                  child: const Text("Add Medicine",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
