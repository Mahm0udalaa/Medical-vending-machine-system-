import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:graduation_project/features/customer/map/cubit/map_cubit.dart';
import 'package:graduation_project/features/customer/map/cubit/map_state.dart';
import 'package:graduation_project/features/customer/map/data/repos/map_fetch_markers_repo.dart';
import 'package:graduation_project/features/customer/map/presentation/widgets/map_marker.dart';
import 'package:latlong2/latlong.dart';

class MapBody extends StatelessWidget {
  final MapController _mapController = MapController();
  final Function(int, String)? onMachineSelected;

  MapBody({super.key, this.onMachineSelected});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MapCubit(MapFetchMarkersRepo())..loadMarkers(context),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          final mapCubit = context.read<MapCubit>();

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: LatLng(29.9792, 30.9505),
                  initialZoom: 13.0,
                  minZoom: 5,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.yourapp',
                  ),
                  MarkerLayer(
                    markers: buildMarkers(
                      markersData: state.markers,
                      userLocation: state.userLocation,
                      context: context,
                      onMachineSelected:
                          onMachineSelected ?? (int _, String __) {},
                    ),
                  ),
                ],
              ),

              Positioned(
                top: 32,
                right: 16,
                child: FloatingActionButton(
                  heroTag: "Get All",
                  mini: true,
                  onPressed: () async {
                    await mapCubit.getUserLocationAndSortMachines(
                      _mapController,
                      context,
                    );
                    if (!context.mounted) return;
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (modalContext) {
                        return BlocProvider.value(
                          value: mapCubit,
                          child: DraggableScrollableSheet(
                            initialChildSize: 0.66,
                            minChildSize: 0.4,
                            maxChildSize: 0.9,
                            builder: (context, scrollController) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(24),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 10,
                                      offset: Offset(0, -2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 6,
                                      margin: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[300],
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: TextField(
                                        decoration: InputDecoration(
                                          hintText:
                                              "Search machines by Name or ID",
                                          prefixIcon: Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            borderSide: BorderSide.none,
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[100],
                                          contentPadding: EdgeInsets.symmetric(
                                            vertical: 0,
                                            horizontal: 16,
                                          ),
                                        ),
                                        onChanged:
                                            (q) => mapCubit.setSearchQuery(q),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Expanded(
                                      child: BlocBuilder<MapCubit, MapState>(
                                        builder: (context, state) {
                                          if (state.sortedMachines.isEmpty) {
                                            return const Center(
                                              child: Text(
                                                "there are no machines found",
                                              ),
                                            );
                                          }
                                          return ListView.builder(
                                            controller: scrollController,
                                            itemCount:
                                                state.sortedMachines.length,
                                            itemBuilder: (context, index) {
                                              final machine =
                                                  state.sortedMachines[index];
                                              final isSelected =
                                                  state
                                                      .selectedMachine
                                                      ?.marker
                                                      .machineId ==
                                                  machine.marker.machineId;
                                              return Card(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 6,
                                                    ),
                                                color:
                                                    isSelected
                                                        ? Colors.green[50]
                                                        : null,
                                                child: ListTile(
                                                  title: Text(
                                                    machine.marker.location,
                                                  ),
                                                  subtitle: Text(
                                                    '${machine.distanceKm.toStringAsFixed(2)} KM',
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  trailing: Text(
                                                    'ID: ${machine.marker.machineId}',
                                                  ),
                                                  onTap: () {
                                                    mapCubit.setSelectedMachine(
                                                      machine,
                                                    );
                                                    Navigator.of(context).pop();
                                                  },
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    
                                  ],
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                    if (mapCubit.state.selectedMachine != null) {
                      mapCubit.focusOnMachine(
                        _mapController,
                        mapCubit.state.selectedMachine!,
                      );
                    }
                  },
                  child: const Icon(Icons.list),
                ),
              ),

              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton(
                        heroTag: "zoom_in",
                        mini: true,
                        onPressed: () => mapCubit.zoomIn(_mapController),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "zoom_out",
                        mini: true,
                        onPressed: () => mapCubit.zoomOut(_mapController),
                        child: const Icon(Icons.remove),
                      ),
                      const SizedBox(height: 16),
                      FloatingActionButton(
                        heroTag: "center_machine",
                        mini: true,
                        onPressed: () {
                          mapCubit.centerOnFirstMarker(
                            _mapController,
                            state.markers,
                          );
                        },
                        child: const Icon(Icons.location_searching),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton(
                        heroTag: "center_user",
                        mini: true,
                        onPressed: () {
                          mapCubit.centerOnUserLocation(
                            _mapController,
                            context,
                          );
                        },
                        child: const Icon(Icons.my_location),
                      ),
                    ],
                  ),
                ),
              ),

              if (state.isLoading)
                const Center(child: CircularProgressIndicator()),

              if (state.errorMessage.isNotEmpty)
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha((0.9 * 255).toInt()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
