class MachineModel {
  final int machineId;
  final String location;

  MachineModel({required this.machineId, required this.location});

  factory MachineModel.fromJson(Map<String, dynamic> json) {
    return MachineModel(
      machineId: json['machineId'],
      location: json['location'],
    );
  }
}
