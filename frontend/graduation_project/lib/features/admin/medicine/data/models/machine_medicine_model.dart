class MachineMedicineModel {
  final int machineId;
  final int medicineId;
  final int quantity;
  final String slot;

  MachineMedicineModel({
    required this.machineId,
    required this.medicineId,
    required this.quantity,
    required this.slot,
  });

  Map<String, dynamic> toJson() {
    return {
      'machineId': machineId,
      'medicineId': medicineId,
      'quantity': quantity,
      'slot': slot,
    };
  }
} 