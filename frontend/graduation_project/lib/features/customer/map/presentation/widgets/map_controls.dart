import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:graduation_project/features/customer/map/cubit/map_cubit.dart';
import 'package:graduation_project/features/customer/map/data/models/fetch_marker_model.dart';

class MapControls extends StatelessWidget {
  final MapController mapController;
  final MapCubit cubit;
  final List<MarkerModel> markersData;

  const MapControls({
    super.key,
    required this.mapController,
    required this.cubit,
    required this.markersData,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 10,
      child: Column(
        children: [
          FloatingActionButton(
            heroTag: "zoomIn",
            mini: true,
            onPressed: () => cubit.zoomIn(mapController),
            child: const Icon(Icons.zoom_in),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "zoomOut",
            mini: true,
            onPressed: () => cubit.zoomOut(mapController),
            child: const Icon(Icons.zoom_out),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "centerMap",
            mini: true,
            onPressed: () => cubit.centerOnFirstMarker(mapController, markersData),
            child: const Icon(Icons.center_focus_strong),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: "userLocation",
            mini: true,
            onPressed: () => cubit.getUserLocationAndSortMachines(mapController, context),
            backgroundColor: Colors.green,
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }
}
