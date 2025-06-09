import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/medicines_cubit.dart';
import 'package:graduation_project/features/admin/medicine/presentation/widgets/medicine_list_item.dart';
import 'package:graduation_project/features/admin/medicine/presentation/widgets/search_bar.dart';

class ExistingMedicineTab extends StatefulWidget {
  final int machineId;
  const ExistingMedicineTab({super.key, required this.machineId});

  @override
  State<ExistingMedicineTab> createState() => _ExistingMedicineTabState();
}

class _ExistingMedicineTabState extends State<ExistingMedicineTab> {
  List medicines = [];
  List filtered = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MedicinesCubit>().fetchAllMedicines();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      filtered = medicines
          .where((med) => med.medicineName
              .toLowerCase()
              .startsWith(_searchController.text.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MedicinesCubit, MedicinesState>(
      listener: (context, state) {
        if (state is MedicinesLoaded) {
          medicines = state.medicines;
          filtered = medicines;
        }
      },
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SearchBarWidget(
                controller: _searchController,
                onChanged: (val) => _onSearchChanged(),
              ),
            ),
            if (state is MedicinesLoading)
              const Expanded(child: Center(child: CircularProgressIndicator())),
            if (state is MedicinesError)
              Expanded(child: Center(child: Text(state.message))),
            if (state is MedicinesLoaded)
              Expanded(
                child: ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final med = filtered[index];
                    return MedicineListItem(
                      medicineName: med.medicineName,
                      medicineId: med.medicineId,
                      stock: med.stock,
                      machineId: widget.machineId,
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
} 