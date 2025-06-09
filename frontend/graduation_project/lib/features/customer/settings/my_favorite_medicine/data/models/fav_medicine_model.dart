class FavMedicineModel {
  final int medicineId;
  final String medicineName;
  final num medicinePrice;
  final String addedDate;
  final String? imagePath;

  FavMedicineModel({
    required this.medicineId,
    required this.medicineName,
    required this.medicinePrice,
    required this.addedDate,
    this.imagePath,
  });

  factory FavMedicineModel.fromJson(Map<String, dynamic> json) {
    return FavMedicineModel(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      medicinePrice: json['medicinePrice'],
      addedDate: json['addedDate'],
      imagePath: json['imagePath'],
    );
  }
}
