import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:graduation_project/features/customer/map/cubit/map_state.dart';
import 'package:graduation_project/features/customer/map/data/models/fetch_marker_model.dart';
import 'package:graduation_project/features/customer/map/data/repos/map_fetch_markers_repo.dart';
import 'package:latlong2/latlong.dart';

class MapCubit extends Cubit<MapState> {
  final MapFetchMarkersRepo repo;
  List<MarkerModel> _cachedMarkers = [];

  MapCubit(this.repo) : super(MapState.initial());

  Future<void> loadMarkers(BuildContext context) async {
    emit(state.copyWith(isLoading: true, errorMessage: ''));
    try {
      if (_cachedMarkers.isEmpty) {
        final List<MarkerModel> markers = await repo.fetchMarkers();
        _cachedMarkers = markers;
      }
      emit(state.copyWith(markers: _cachedMarkers, isLoading: false));
      if (state.userLocation != null) {
        _computeAndSortMachines();
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: e.toString()));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading markers: $e')),
        );
      }
    }
  }

  void setSearchQuery(String query) {
    emit(state.copyWith(searchQuery: query));
    _computeAndSortMachines();
  }

  void _computeAndSortMachines() {
    if (state.userLocation == null) return;
    final Distance distance = const Distance();
    final List<MachineWithDistance> machines = state.markers.map((marker) {
      final dist = distance.as(
        LengthUnit.Kilometer,
        state.userLocation!,
        LatLng(marker.latitude, marker.longitude),
      );
      return MachineWithDistance(marker: marker, distanceKm: dist);
    }).toList();
    machines.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final filtered = machines.where((m) {
      final q = state.searchQuery.toLowerCase();
      return m.marker.location.toLowerCase().contains(q) ||
          m.marker.machineId.toString().contains(q);
    }).toList();
    emit(state.copyWith(sortedMachines: filtered));
  }

  Future<void> centerOnUserLocation(MapController controller, BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.')),
        );
      }
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
      }
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(position.latitude, position.longitude);
      controller.move(userLatLng, state.currentZoom);
      emit(state.copyWith(userLocation: userLatLng));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get user location: $e')),
        );
      }
    }
  }

  Future<void> getUserLocationAndSortMachines(MapController controller, BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location services are disabled.'),backgroundColor: Colors.red,),
        );
      }
      return;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission denied')),
          );
        }
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission permanently denied')),
        );
      }
      return;
    }
    try {
      final position = await Geolocator.getCurrentPosition();
      final userLatLng = LatLng(position.latitude, position.longitude);
      emit(state.copyWith(userLocation: userLatLng));
      _computeAndSortMachines();
      controller.move(userLatLng, state.currentZoom);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to get user location: $e')),
        );
      }
    }
  }

  void focusOnMachine(MapController controller, MachineWithDistance machine) {
    final target = LatLng(machine.marker.latitude, machine.marker.longitude);
    controller.move(target, 16); 
    emit(state.copyWith(selectedMachine: machine));
  }

  void drawRouteAndShowTime(MachineWithDistance machine) {
    
    emit(state.copyWith(
      routeDistanceKm: machine.distanceKm,
      routeTimeMin: machine.distanceKm / 50 * 60, 
      routePolyline: [
        LatLng(machine.marker.latitude, machine.marker.longitude),
        state.userLocation ?? LatLng(machine.marker.latitude, machine.marker.longitude),
      ],
    ));
  }

  void zoomIn(MapController controller) {
    double zoom = state.currentZoom + 1;
    if (zoom > 18) zoom = 18;
    controller.move(controller.camera.center, zoom);
    emit(state.copyWith(currentZoom: zoom));
  }

  void zoomOut(MapController controller) {
    double zoom = state.currentZoom - 1;
    if (zoom < 5) zoom = 5;
    controller.move(controller.camera.center, zoom);
    emit(state.copyWith(currentZoom: zoom));
  }

  void centerOnFirstMarker(MapController controller, List<MarkerModel> markers) {
    if (markers.isEmpty) return;
    final first = markers.first;
    final target = LatLng(first.latitude, first.longitude);
    controller.move(target, 15);
  }

  void setSelectedMachine(MachineWithDistance machine) {
    emit(state.copyWith(selectedMachine: machine));
  }

  void clearSelectedMachineAfterFocus() {
    emit(state.copyWith(selectedMachine: null));
  }
}
