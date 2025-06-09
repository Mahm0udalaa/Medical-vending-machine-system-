import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/screens/admin_home_view.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/add_medicine_cubit.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/medicines_cubit.dart';
import 'package:graduation_project/features/admin/medicine/data/models/category_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/category_repo.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';
import 'package:graduation_project/features/admin/medicine/presentation/widgets/add_new_medicine_tab.dart';
import 'package:graduation_project/features/admin/medicine/presentation/widgets/existing_medicine_tab.dart';

class AddNewOrExistedMedicineScreen extends StatefulWidget {
  final int machineId;
  const AddNewOrExistedMedicineScreen({super.key, required this.machineId});

  @override
  State<AddNewOrExistedMedicineScreen> createState() => _AddNewOrExistedMedicineScreenState();
}

class _AddNewOrExistedMedicineScreenState extends State<AddNewOrExistedMedicineScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MedicinesCubit(MedicineRepo())),
        BlocProvider(create: (_) => AddMedicineCubit(MedicineRepo())),
      ],
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'Add Medicine',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xff26864E),
          bottom: TabBar(
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            controller: _tabController,
            tabs: const [Tab(text: 'Choose Existing'), Tab(text: 'Add New')],
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () =>   Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AdminHomeView(),
                                ),
                                (route) => false,
                              )
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
          child: FutureBuilder<List<CategoryModel>>(
            future: CategoryRepo().fetchCategories(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error loading categories'));
              }
              final categories = snapshot.data ?? [];
              return TabBarView(
                controller: _tabController,
                children: [
                  ExistingMedicineTab(machineId: widget.machineId),
                  AddNewMedicineTab(categories: categories),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
