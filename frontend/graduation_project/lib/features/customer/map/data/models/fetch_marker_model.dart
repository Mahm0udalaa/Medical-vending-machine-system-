class MarkerModel {
  final int machineId;
  final String location;
  final double latitude;
  final double longitude;

  MarkerModel({
    required this.machineId,
    required this.location,
    required this.latitude,
    required this.longitude,
  });

  factory MarkerModel.fromJson(Map<String, dynamic> json) {
    return MarkerModel(
      machineId: json['machineId'],
      location: json['location'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }
}
