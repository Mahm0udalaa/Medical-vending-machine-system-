import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/admin_home/data/models/machine_model.dart';
import 'package:graduation_project/features/admin/admin_home/data/repos/machine_repo.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/widgets/admin_drawer.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/widgets/cutom_machine_cart.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';
import 'package:graduation_project/features/admin/medicine/presentation/screens/all_machine_medicines_view.dart';

class AdminHomeView extends StatefulWidget {
  const AdminHomeView({super.key});

  @override
  State<AdminHomeView> createState() => _AdminHomeViewState();
}

class _AdminHomeViewState extends State<AdminHomeView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<MachineModel> machines = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchMachines();
  }

  Future<void> fetchMachines() async {
    try {
      final repo = MachinesRepo();
      final data = await repo.getMachines();
      setState(() {
        machines = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        
        key: _scaffoldKey,
        drawer: const AdminDrawer(),
        appBar: AppBar(
          backgroundColor: MyColors.primaryColor,
          centerTitle: true,
          title: const Text(
            "All Machines",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
          ),
         
         
          
        ),
        extendBodyBehindAppBar: true,
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
            padding: const EdgeInsets.all(24.0),
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                      itemCount: machines.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.9,
                            mainAxisSpacing: 25,
                            crossAxisSpacing: 10,
                          ),
                      itemBuilder: (context, index) {
                        final machine = machines[index];
                        return GestureDetector(
                          onTap: () async {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                            final repo = MedicineRepo();
                            try {
                              await repo.getMachineMedicines(machine.machineId);
                              Navigator.of(context, rootNavigator: true).pop();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AllMachineMedicinesView(
                                    machineLocationText: machine.location,
                                    machineId: machine.machineId,
                                  ),
                                ),
                              );
                            } catch (e) {
                              Navigator.of(context, rootNavigator: true).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to load medicines: $e')),
                              );
                            }
                          },
                          child: CutomMachineCart(
                            machineLocationText: machine.location,
                            machineId: machine.machineId.toString(),
                          ),
                        );
                      },
                    ),
          ),
        ),
      ),
    );
  }
}
