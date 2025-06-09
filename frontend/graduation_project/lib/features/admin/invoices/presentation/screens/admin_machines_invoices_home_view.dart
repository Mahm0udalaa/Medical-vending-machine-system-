import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/admin_home/data/models/machine_model.dart';
import 'package:graduation_project/features/admin/admin_home/data/repos/machine_repo.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/widgets/cutom_machine_cart.dart';
import 'package:graduation_project/features/admin/invoices/presentation/screens/admin_machine_invoices_view.dart';

class AdminMachinesInvoicesHomeView extends StatefulWidget {
  const AdminMachinesInvoicesHomeView({super.key});

  @override
  State<AdminMachinesInvoicesHomeView> createState() => _AdminMachinesInvoicesHomeViewState();
}

class _AdminMachinesInvoicesHomeViewState extends State<AdminMachinesInvoicesHomeView> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoices', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
        centerTitle: true,
        backgroundColor:Color(0xff26864E) ,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
             height: double.infinity,
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: MyColors.backgroundColor,
            ),
          ),
            child: GridView.builder(
                padding: const EdgeInsets.all(24.0),
                itemCount: machines.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 25,
                  crossAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final machine = machines[index];
                  return CutomMachineCart(
                    machineLocationText: machine.location,
                    machineId: machine.machineId.toString(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminMachineInvoicesView(
                            machineId: machine.machineId,
                            machineLocation: machine.location,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
          ),
    );
  }
} 