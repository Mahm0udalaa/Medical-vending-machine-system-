class CartMedicineModel {
  final int id;
  final int machineId;
  final String ?machineLocation;
  final int medicineId;
  final int quantity;
  final String medicineName;
  final num price;
  final String imagePath;
  final String slot;

  CartMedicineModel({
    required this.id,
    required this.machineId,
    required this.machineLocation,
    required this.medicineId,
    required this.quantity,
    required this.medicineName,
    required this.price,
    required this.imagePath,
    required this.slot,
  });

  factory CartMedicineModel.fromJson(Map<String, dynamic> json) {
    return CartMedicineModel(
      id: json['id'],
      machineId: json['machineId'],
      machineLocation: json['machineLocation'],
      medicineId: json['medicineId'],
      quantity: json['quantity'],
      medicineName: json['medicineName'],
      price: json['price'],
      imagePath: json['imagePath'],
      slot: json['slot'],
    );
  }
}
