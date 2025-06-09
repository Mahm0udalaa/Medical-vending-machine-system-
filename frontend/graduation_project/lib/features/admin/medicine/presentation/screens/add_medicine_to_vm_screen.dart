import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/add_machine_medicine_cubit.dart';
import 'package:graduation_project/features/admin/medicine/data/models/machine_medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/machine_medicine_repo.dart';

class AddMedicineToVmScreen extends StatefulWidget {
  final int machineId;
  final int medicineId;
  final String medicineName;
  final int stock;
  const AddMedicineToVmScreen({
    super.key,
    required this.machineId,
    required this.medicineId,
    required this.medicineName,
    required this.stock,
  });

  @override
  State<AddMedicineToVmScreen> createState() => _AddMedicineToVmScreenState();
}

class _AddMedicineToVmScreenState extends State<AddMedicineToVmScreen> {
  String? _selectedSlot;
  int? _selectedQuantity;
  final List<String> _slots = ['1', '2', '3', '4', '5', '6'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AddMachineMedicineCubit(MachineMedicineRepo()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Add ${widget.medicineName} to VM ${widget.machineId}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff26864E),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: BlocConsumer<AddMachineMedicineCubit, AddMachineMedicineState>(
          listener: (context, state) {
            if (state is AddMachineMedicineSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.green,
                  content: Text(state.message),
                ),
              );
              Navigator.pop(context, true);
            } else if (state is AddMachineMedicineError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Medicine: ${widget.medicineName} (ID: ${widget.medicineId})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text('Current Stock: ${widget.stock}'),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<int>(
                    value: _selectedQuantity,
                    items: List.generate(
                      6,
                      (index) => DropdownMenuItem(
                        value: index + 1,
                        child: Text('${index + 1}'),
                      ),
                    ),
                    onChanged: (val) => setState(() => _selectedQuantity = val),
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),
                  DropdownButtonFormField<String>(
                    value: _selectedSlot,
                    items:
                        _slots
                            .map(
                              (slot) => DropdownMenuItem(
                                value: slot,
                                child: Text(slot),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => _selectedSlot = val),
                    decoration: const InputDecoration(
                      labelText: 'Slot',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          state is AddMachineMedicineLoading
                              ? null
                              : () {
                             
                                final model = MachineMedicineModel(
                                  machineId: widget.machineId,
                                  medicineId: widget.medicineId,
                                  quantity:_selectedQuantity!,
                                  slot: _selectedSlot!,
                                );
                                context
                                    .read<AddMachineMedicineCubit>()
                                    .addMedicineToMachine(model);
                              },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff26864E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          state is AddMachineMedicineLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Add to Machine',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
