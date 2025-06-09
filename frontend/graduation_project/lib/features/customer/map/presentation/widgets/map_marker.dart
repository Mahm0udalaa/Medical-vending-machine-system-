import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/customer/map/data/models/fetch_marker_model.dart';
import 'package:latlong2/latlong.dart';

Widget _buildMarkerWidget({
  required String location,
  required int id,
  required BuildContext context,
  required Function(int, String) onMachineSelected,
}) {
  return GestureDetector(
    onTap: () {
      onMachineSelected(id, location);
    },
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,  
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: MyColors.backgroundColor[0],
            borderRadius: BorderRadius.circular(6),
            boxShadow: const [
              BoxShadow(color: Colors.grey, blurRadius: 4),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                softWrap: true,
              ),
              // Text(
              //   'Id: $id',
              //   style: const TextStyle(
              //     fontSize: 12,
              //     color: Colors.black,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.center,
              //   softWrap: true,
              // ),
            ],
          ),
        ),
        const Icon(
          Icons.location_on,
          color: Colors.blue,
          size: 40,
        ),
      ],
    ),
  );
}

List<Marker> buildMarkers({
  required List<MarkerModel> markersData,
  LatLng? userLocation,
  required BuildContext context,
  required Function(int, String) onMachineSelected,
}) {
  final List<Marker> markers = markersData.map((marker) {
    return Marker(
      width: 140,  
      height: 100, 
      point: LatLng(marker.latitude, marker.longitude),
      child: _buildMarkerWidget(
        location: marker.location,
        id: marker.machineId,
        context: context,
        onMachineSelected: onMachineSelected,
      ),
    );
  }).toList();

  if (userLocation != null) {
    markers.add(
      Marker(
        width: 50.0,
        height: 50.0,
        point: userLocation,
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(6),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 4),
                ],
              ),
              child: const Text(
                'You',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Icon(
              Icons.my_location,
              color: Colors.green,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  return markers;
}
