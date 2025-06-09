import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/category_repo.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';
import 'package:graduation_project/features/customer/cart/presentation/screens/cart_body.dart';
import 'package:graduation_project/features/customer/home/cubit/category_cubit.dart';
import 'package:graduation_project/features/customer/home/cubit/machine_medicines_cubit.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/home_body.dart';
import 'package:graduation_project/features/customer/map/cubit/map_cubit.dart';
import 'package:graduation_project/features/customer/map/data/repos/map_fetch_markers_repo.dart';
import 'package:graduation_project/features/customer/map/presentation/screens/map_body.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  int? selectedMachineId;
  String? selectedMachineLocation;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MachineMedicinesCubit(MedicineRepo())),
        BlocProvider(create: (_) => CategoryCubit(CategoryRepo())),
        BlocProvider(create: (_) => MapCubit(MapFetchMarkersRepo())), 
        //  BlocProvider(
        //    create: (context) => ConfirmOrderCubit(ConfirmOrderRepo(dio: Dio(), storage: const FlutterSecureStorage())),
        //  ) 
        
      ],
      child: SafeArea(
        child: Scaffold(
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: MyColors.backgroundColor[0],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            backgroundColor: Colors.white,
            unselectedItemColor: Colors.black54,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                  icon: Icon(FontAwesomeIcons.house), label: "Home"),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.cartShopping),
                label: "Cart",
              ),
              BottomNavigationBarItem(
                icon: Icon(FontAwesomeIcons.locationDot),
                label: "Map",
              ),
            ],
          ),
          body: Container(
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomCenter,
                colors: MyColors.backgroundColor,
              ),
            ),
            child: Builder(
              builder: (context) {
                if (_selectedIndex == 0) {
                  return HomeBody(
                    machineId: selectedMachineId,
                    machineLocation: selectedMachineLocation,
                  );
                } else if (_selectedIndex == 1) {
                  return CartBody();
                } else {
                  return MapBody(
                    onMachineSelected: (id, location) {
                      setState(() {
                        selectedMachineId = id;
                        selectedMachineLocation = location;
                        _selectedIndex = 0;
                      });
                      context.read<MachineMedicinesCubit>().fetchMachineMedicines(id);
                    },
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
