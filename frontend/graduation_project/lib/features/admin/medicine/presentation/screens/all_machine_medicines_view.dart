import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/all_machine_medicines_cubit.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';
import 'package:graduation_project/features/admin/medicine/presentation/screens/add_new_or_exist.dart';
import 'package:graduation_project/features/admin/medicine/presentation/screens/product_view.dart';
import 'package:graduation_project/features/admin/medicine/presentation/widgets/medicine_card.dart';

class AllMachineMedicinesView extends StatelessWidget {
  final String machineLocationText;
  final int machineId;

  const AllMachineMedicinesView({
    super.key,
    required this.machineLocationText,
    required this.machineId,
  });

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AllMachineMedicinesCubit(MedicineRepo())..fetchMedicines(machineId),
      child: BlocListener<AllMachineMedicinesCubit, AllMachineMedicinesState>(
        listener: (context, state) {
          if (state is AllMachineMedicinesNotFound) {
            _showSnackBar(
              context,
              'No medicines found in machine with ID ${state.machineId}',
            );
          } else if (state is AllMachineMedicinesError) {
            _showSnackBar(context, 'Error: ${state.message}');
          }
        },
        child: BlocBuilder<AllMachineMedicinesCubit, AllMachineMedicinesState>(
          builder: (context, state) {
            if (state is AllMachineMedicinesLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is AllMachineMedicinesEmpty) {
              return SafeArea(
                child: Scaffold(
                  appBar: AppBar(
                    backgroundColor: Color(0xff26864E),
                    centerTitle: true,
                    elevation: 0,
                    title: Text(
                      machineLocationText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    leading: IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  body: Container(
                    height: double.infinity,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomCenter,
                        colors: MyColors.backgroundColor,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        itemCount: 1,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemBuilder: (context, index) {
                          return MedicineCard(
                            isAddCard: true,
                            onAdd: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewOrExistedMedicineScreen(machineId: machineId),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            }

            List<MedicineModel> medicines = [];
            if (state is AllMachineMedicinesLoaded) {
              medicines = state.medicines;
            }

            return SafeArea(
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: Color(0xff26864E),
                  centerTitle: true,
                  elevation: 0,
                  title: Text(
                    machineLocationText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                body: Container(
                  height: double.infinity,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomCenter,
                      colors: MyColors.backgroundColor,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: GridView.builder(
                      itemCount: medicines.isEmpty ? 1 : medicines.length + 1,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.8,
                      ),
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return MedicineCard(
                            isAddCard: true,
                            onAdd: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddNewOrExistedMedicineScreen(machineId: machineId),
                                ),
                              );
                            },
                          );
                        } else {
                          final medicine = medicines[index - 1];
                          return MedicineCard(
                            model: medicine,
                            onTap: () {
                              /// Navigate to ProductView
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductView(
                                    medicine: medicine,
                                  ),
                                ),
                              );
                            },
                            showWarning: medicine.quantity == 0,
                            onDelete: () {
                              _showSnackBar(context, 'Medicine deleted');
                            },
                          );
                        }
                      },
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
