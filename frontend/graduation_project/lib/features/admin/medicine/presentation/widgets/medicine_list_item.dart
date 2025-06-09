import 'package:flutter/material.dart';
import 'package:graduation_project/features/admin/medicine/presentation/screens/add_medicine_to_vm_screen.dart';

class MedicineListItem extends StatelessWidget {
  final String medicineName;
  final int medicineId;
  final int stock;
  final int machineId;
   const MedicineListItem({super.key, required this.medicineName, required this.medicineId, required this.stock, required this.machineId});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        medicineName,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
      ),
      subtitle: Text('ID: $medicineId | Stock: $stock'),
      onTap: () {
      
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddMedicineToVmScreen(
              machineId: machineId ,
              medicineId: medicineId,
              medicineName: medicineName,
              stock: stock,
            ),
          ),
        );
            },
    );
  }
}
