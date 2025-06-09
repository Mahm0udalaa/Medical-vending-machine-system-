import 'dart:io';

class NewMedicineModel {
  final String medicineName;
  final int medicinePrice;
  final int stock;
  final String expirationDate;
  final String description;
  final int categoryId;
  final File? imageFile;

  NewMedicineModel({
    required this.medicineName,
    required this.medicinePrice,
    required this.stock,
    required this.expirationDate,
    required this.description,
    required this.categoryId,
    this.imageFile,
  });

  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'medicinePrice': medicinePrice,
      'stock': stock,
      'expirationDate': expirationDate,
      'description': description,
      'categoryId': categoryId,
    };
  }
} 