import 'dart:ui'; // مهم لتفعيل blur

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/networking/dio_factory.dart';
import 'package:graduation_project/features/customer/home/presentation/widgets/customer_product_details.dart';
import 'package:graduation_project/features/customer/settings/my_favorite_medicine/data/models/fav_medicine_model.dart';

import '../../cubit/cubit/medicine_machine_cubit.dart';
import '../../cubit/cubit/medicine_machine_state.dart';
import '../../data/repos/machine_medicine_repo.dart';
import '../../data/repos/medicine_machine_repo.dart';

class FavMedicinecard extends StatelessWidget {
  final FavMedicineModel medicine;
  const FavMedicinecard({super.key, required this.medicine});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Text(
                medicine.medicineName,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Color(0xff26864E),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  (medicine.imagePath != null && medicine.imagePath!.isNotEmpty)
                      ? Image.network(
                          medicine.imagePath!,
                          height: 80,
                          width: 80,
                          fit: BoxFit.cover,
                        )
                      : Image.asset("assets/medicen.png", height: 80, width: 80),
                  Spacer(),
                  Text(
                    "${medicine.medicinePrice} EGP",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  ),
                  Spacer(),

                  const SizedBox(height: 10),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  showFavMedicineMachineDialog(context, medicine.medicineId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xff26864E),
                ),
                child: Text(
                  "Show Machines that have medicines ",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

 void showFavMedicineMachineDialog(BuildContext context, int medicineId) async {
  final dio = await DioFactory.getDio();

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: "Machines Dialog",
    barrierColor: Colors.black.withAlpha((0.3 * 255).toInt()), 
    pageBuilder: (context, animation, secondaryAnimation) {
      final size = MediaQuery.of(context).size;

      return BlocProvider(
        create: (_) => MedicineMachineCubit(MedicineMachineRepo(dio: dio))
          ..fetchMachines(medicineId),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0), 
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                height: size.height * (2 / 3),
                width: size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Machines with this medicine",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff26864E),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: BlocBuilder<MedicineMachineCubit, MedicineMachineState>(
                        builder: (context, state) {
                          if (state is MachineLoading) {
                            return Center(child: CircularProgressIndicator());
                          } else if (state is MachineError) {
                            return Center(child: Text(state.message));
                          } else if (state is MachineEmpty) {
                            return Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.warning, size: 60, color: Colors.redAccent),
                                  SizedBox(height: 16),
                                  Text(
                                    "This medicine is not available at any machine at the time.",
                                    style: TextStyle(fontSize: 16, color: Colors.black54),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          } else if (state is MachineLoaded) {
                            final machines = state.machines;
                            return ListView.separated(
                              itemCount: machines.length,
                              separatorBuilder: (_, __) => Divider(),
                              itemBuilder: (context, index) {
                                final machine = machines[index];
                                return ListTile(
                                  leading: Icon(Icons.medical_services, color: Color(0xff26864E)),
                                  title: Text(" ${machine.location}"),
                                  subtitle: Text("ID: ${machine.machineId}"),
                                  onTap: () async {
                                    final repo = MachineMedicineRepo(dio: dio);
                                    try {
                                      final medicines = await repo.fetchMachineMedicines(machine.machineId);
                                      final selected = medicines.firstWhere(
                                        (m) => m.medicineId == medicine.medicineId,
                                        orElse: () => throw Exception('Medicine not found in this machine'),
                                      );
                                      Navigator.of(context).pop(); // غلق الديالوج
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => CustomerProductDetails(
                                            medicineId: selected.medicineId,
                                            machineId: machine.machineId,
                                            medName: selected.medicineName,
                                            description: selected.description,
                                            price: selected.medicinePrice.toString(),
                                            imagePath: selected.imagePath ?? '',
                                            slot: selected.slot,
                                            quantity: selected.quantity.toString(),
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Medicine not found in this machine.')),
                                      );
                                    }
                                  },
                                );
                              },
                            );
                          }
                          return SizedBox.shrink();
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff26864E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Close",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );

}
}