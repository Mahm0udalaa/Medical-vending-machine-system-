import 'package:graduation_project/features/customer/map/data/models/fetch_marker_model.dart';
import 'package:latlong2/latlong.dart';

class MachineWithDistance {
  final MarkerModel marker;
  final double distanceKm;

  MachineWithDistance({
    required this.marker,
    required this.distanceKm,
  });
}

class MapState {
  final double currentZoom;
  final LatLng? userLocation;
  final List<MarkerModel> markers;
  final bool isLoading;
  final String errorMessage;
  final List<MachineWithDistance> sortedMachines;
  final String searchQuery;
  final List<LatLng> routePolyline;
  final double? routeDistanceKm;
  final double? routeTimeMin;
  final MachineWithDistance? selectedMachine;

  const MapState({
    required this.currentZoom,
    required this.userLocation,
    required this.markers,
    required this.isLoading,
    required this.errorMessage,
    required this.sortedMachines,
    required this.searchQuery,
    this.routePolyline = const [],
    this.routeDistanceKm,
    this.routeTimeMin,
    this.selectedMachine,
  });

  factory MapState.initial() {
    return MapState(
      currentZoom: 13.0,
      userLocation: null,
      markers: [],
      isLoading: false,
      errorMessage: '',
      sortedMachines: [],
      searchQuery: '',
      routePolyline: const [],
      routeDistanceKm: null,
      routeTimeMin: null,
      selectedMachine: null,
    );
  }

  MapState copyWith({
    double? currentZoom,
    LatLng? userLocation,
    List<MarkerModel>? markers,
    bool? isLoading,
    String? errorMessage,
    List<MachineWithDistance>? sortedMachines,
    String? searchQuery,
    List<LatLng>? routePolyline = const [],
    double? routeDistanceKm,
    double? routeTimeMin,
    MachineWithDistance? selectedMachine,
  }) {
    return MapState(
      currentZoom: currentZoom ?? this.currentZoom,
      userLocation: userLocation ?? this.userLocation,
      markers: markers ?? this.markers,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sortedMachines: sortedMachines ?? this.sortedMachines,
      searchQuery: searchQuery ?? this.searchQuery,
      routePolyline: routePolyline ?? this.routePolyline,
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      routeTimeMin: routeTimeMin ?? this.routeTimeMin,
      selectedMachine: selectedMachine ?? this.selectedMachine,
    );
  }
}
