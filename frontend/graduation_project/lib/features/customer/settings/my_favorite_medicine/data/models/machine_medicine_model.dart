class MachineMedicineModel {
  final int machineId;
  final String machineLocation;
  final int medicineId;
  final String medicineName;
  final String description;
  final String? imagePath;
  final int categoryId;
  final int quantity;
  final num price;
  final num medicinePrice;
  final String slot;

  MachineMedicineModel({
    required this.machineId,
    required this.machineLocation,
    required this.medicineId,
    required this.medicineName,
    required this.description,
    this.imagePath,
    required this.categoryId,
    required this.quantity,
    required this.price,
    required this.medicinePrice,
    required this.slot,
  });

  factory MachineMedicineModel.fromJson(Map<String, dynamic> json) {
    return MachineMedicineModel(
      machineId: json['machineId'],
      machineLocation: json['machineLocation'],
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      description: json['description'],
      imagePath: json['imagePath'],
      categoryId: json['categoryId'],
      quantity: json['quantity'],
      price: json['price'],
      medicinePrice: json['medicinePrice'],
      slot: json['slot'],
    );
  }
} 