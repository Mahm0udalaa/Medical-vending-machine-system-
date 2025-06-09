class MedicineModel {
  int? machineId;
  String? machineLocation;
  int? medicineId;
  String? medicineName;
  String? description;
  String? imagePath;
  int? categoryId;
  int? quantity;
  int? price;
  double? medicinePrice;
  String? slot;

  MedicineModel(
      {this.machineId,
      this.machineLocation,
      this.medicineId,
      this.medicineName,
      this.description,
      this.imagePath,
      this.categoryId,
      this.quantity,
      this.price,
      this.medicinePrice,
      this.slot});

  MedicineModel.fromJson(Map<String, dynamic> json) {
    machineId = json['machineId'];
    machineLocation = json['machineLocation'];
    medicineId = json['medicineId'];
    medicineName = json['medicineName'];
    description = json['description'];
    imagePath = json['imagePath'];
    categoryId = json['categoryId'];
    quantity = json['quantity'];
    price = json['price'];
    medicinePrice = json['medicinePrice'];
    slot = json['slot'];
  }


}
