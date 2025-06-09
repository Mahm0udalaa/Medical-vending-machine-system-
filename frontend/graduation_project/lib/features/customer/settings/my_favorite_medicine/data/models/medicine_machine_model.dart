class MedicineMachineModel {
  final int machineId;
  final String location;

  MedicineMachineModel({required this.machineId, required this.location});

  factory MedicineMachineModel.fromJson(Map<String, dynamic> json) {
    return MedicineMachineModel(
      machineId: json['machineId'],
      location: json['location'],
    );
  }
} 