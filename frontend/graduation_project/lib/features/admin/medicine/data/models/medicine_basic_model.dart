class MedicineBasicModel {
  final int medicineId;
  final String medicineName;
  final int stock;

  MedicineBasicModel({
    required this.medicineId,
    required this.medicineName,
    required this.stock,
  });

  factory MedicineBasicModel.fromJson(Map<String, dynamic> json) {
    return MedicineBasicModel(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      stock: json['stock'] ?? 0,
    );
  }
} 