
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/customer/home/cubit/category_cubit.dart';
import 'package:graduation_project/features/customer/home/cubit/category_state.dart';
import 'package:graduation_project/features/customer/home/cubit/machine_medicines_cubit.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/product_view.dart';
import 'package:graduation_project/features/customer/home/presentation/widgets/custom_card.dart';
import 'package:graduation_project/features/customer/home/presentation/widgets/search_home_view.dart';
import 'package:graduation_project/features/customer/map/data/models/fetch_marker_model.dart';
import 'package:graduation_project/features/customer/map/data/repos/map_fetch_markers_repo.dart';

class HomeBody extends StatefulWidget {
  final int? machineId;
  final String? machineLocation;
  const HomeBody({super.key, this.machineId, this.machineLocation});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  String _searchText = '';
  int? selectedCategoryId;
  bool _locationChecked = false;
  int? _autoSelectedMachineId;
  String? _autoSelectedMachineLocation;
  bool _isFindingNearest = false;

  @override
  void initState() {
    super.initState();
    _handleInitialLocationAndMachine();
    if (widget.machineId != null) {
      context.read<MachineMedicinesCubit>().fetchMachineMedicines(widget.machineId!);
    }
  }

  Future<void> _handleInitialLocationAndMachine() async {
    if (widget.machineId != null) return;
    if (_locationChecked) return;
    _locationChecked = true;
    setState(() {
      _isFindingNearest = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _isFindingNearest = false;
        });
        return;
      }
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _isFindingNearest = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isFindingNearest = false;
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    List<MarkerModel> machines = await fetchAllMachines();
    if (machines.isEmpty) {
      setState(() {
        _isFindingNearest = false;
      });
      return;
    }

    MarkerModel? nearest = _findNearestMachine(position, machines);
    if (nearest != null) {
      setState(() {
        _autoSelectedMachineId = nearest.machineId;
        _autoSelectedMachineLocation = nearest.location;
        _isFindingNearest = false;
      });
      if (mounted) {
        context.read<MachineMedicinesCubit>().fetchMachineMedicines(nearest.machineId);
      }
    } else {
      setState(() {
        _isFindingNearest = false;
      });
    }
  }

  MarkerModel? _findNearestMachine(Position userPos, List<MarkerModel> machines) {
    double minDist = double.infinity;
    MarkerModel? nearest;
    for (var m in machines) {
      double dist = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, m.latitude, m.longitude);
      if (dist < minDist) {
        minDist = dist;
        nearest = m;
      }
    }
    return nearest;
  }

  @override
  void didUpdateWidget(covariant HomeBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.machineId != null && widget.machineId != oldWidget.machineId) {
      context.read<MachineMedicinesCubit>().fetchMachineMedicines(widget.machineId!);
    }
  }

  Future<List<MarkerModel>> fetchAllMachines() async {
    final repo = MapFetchMarkersRepo();
    return await repo.fetchMarkers();
  }

  @override
  Widget build(BuildContext context) {
    context.read<CategoryCubit>().fetchCategories();
    final int? machineIdToShow = widget.machineId ?? _autoSelectedMachineId;
    final String? machineLocationToShow = widget.machineLocation ?? _autoSelectedMachineLocation;

    return BlocBuilder<MachineMedicinesCubit, List<MedicineModel>>(
      builder: (context, medicines) {
        if (machineIdToShow == null) {
          if (_isFindingNearest) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Finding nearest machine...'),
                ],
              ),
            );
          } else {
            return Center(
              child: Text(
                'Unable to access your location. Please select a machine from the map.',
                style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            );
          }
        }

        var filteredMedicines = _searchText.isEmpty
            ? medicines
            : medicines
                .where((m) => (m.medicineName ?? '').toLowerCase().contains(_searchText.toLowerCase()))
                .toList();

        if (selectedCategoryId != null) {
          filteredMedicines = filteredMedicines.where((m) => m.categoryId == selectedCategoryId).toList();
        }

        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SearchHomeView(
                      onChanged: (text) {
                        setState(() {
                          _searchText = text;
                        });
                      },
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined, color: Color(0xff6C7278)),
                          SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {},
                            child: Text(
                              machineLocationToShow != null
                                  ? "Pick up from $machineLocationToShow"
                                  : "Click to choose a machine",
                              style: TextStyle(color: Color(0xff6C7278)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "Shop by category",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                    SizedBox(height: 10),
                    BlocBuilder<CategoryCubit, CategoryState>(
                      builder: (context, state) {
                        if (state is CategoryLoading) {
                          return Center(child: CircularProgressIndicator());
                        } else if (state is CategoryError) {
                          return Center(child: Text("Error fetching categories: ${state.message}"));
                        } else if (state is CategoryLoaded) {
                          final categories = state.categories;
                          if (categories.isEmpty) {
                            return Center(child: Text("No categories found"));
                          }
                          return SizedBox(
                            height: 140,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: categories.length,
                              separatorBuilder: (context, index) => SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedCategoryId = category.categoryId;
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: (category.imagePath != null && category.imagePath!.isNotEmpty)
                                            ? Image.network(
                                                category.imagePath!,
                                                width: 80,
                                                height: 80,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error, stackTrace) => Container(
                                                  width: 80,
                                                  height: 80,
                                                  color: Colors.grey[300],
                                                  child: Icon(Icons.broken_image, color: Colors.red, size: 40),
                                                ),
                                              )
                                            : Container(
                                                width: 80,
                                                height: 80,
                                                color: Colors.grey[300],
                                                child: Icon(Icons.broken_image, color: Colors.red, size: 40),
                                              ),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        category.categoryName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: selectedCategoryId == category.categoryId ? Colors.green : Colors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );
                        } else {
                          return SizedBox();
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "Machine Medicines",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                        Spacer(),
                        TextButton.icon(
                          iconAlignment: IconAlignment.end,
                          icon: Icon(Icons.arrow_forward_ios, color: Color(0xff07AA59)),
                          onPressed: () {
                            setState(() {
                              selectedCategoryId = null;
                            });
                          },
                          label: Text(
                            "  Show all",
                            style: TextStyle(color: Color(0xff07AA59), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    if (medicines.isEmpty)
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.4,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.medical_services_outlined, size: 60, color: Color(0xff07AA59)),
                              const SizedBox(height: 12),
                              Text(
                                "No medicines found",
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[700]),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "in machine at $machineLocationToShow (ID: $machineIdToShow)",
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (selectedCategoryId != null && filteredMedicines.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange, size: 40),
                            SizedBox(height: 8),
                            Text(
                              "No medicines found in this category",
                              style: TextStyle(fontSize: 16, color: Colors.orange),
                            ),
                          ],
                        ),
                      ),
                    if (filteredMedicines.isNotEmpty)
                      GridView.builder(
                        shrinkWrap: true,
                        itemCount: filteredMedicines.length,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.78,
                          mainAxisSpacing: 10,
                        ),
                        itemBuilder: (context, index) => GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerProductView(medicine: filteredMedicines[index]),
                              ),
                            );
                          },
                          child: CustomCard(medicine: filteredMedicines[index]),
                        ),
                      ),
                    if (medicines.isNotEmpty && filteredMedicines.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20),
                          child: Text(
                            "No medicines match your search",
                            style: TextStyle(fontSize: 16, color: Colors.orange),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
