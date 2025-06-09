class MedicineRefillModel {
  final int machineId;
  final int medicineId;
  final int quantity;

  MedicineRefillModel({
    required this.machineId,
    required this.medicineId,
    required this.quantity,
  });

  Map<String, dynamic> toJson() {
    return {
      'machineId': machineId,
      'medicineId': medicineId,
      'quantity': quantity,
    };
  }
}
