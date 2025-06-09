class PurchaseHistoryModel {
  final int purchaseId;
  final DateTime purchaseDate;
  final int totalPrice;
  final int machineId;
  final List<PurchaseItemModel> items;

  PurchaseHistoryModel({
    required this.purchaseId,
    required this.purchaseDate,
    required this.totalPrice,
    required this.machineId,
    required this.items,
  });

  factory PurchaseHistoryModel.fromJson(Map<String, dynamic> json) {
    return PurchaseHistoryModel(
      purchaseId: (json['purchaseId'] as num).toInt(),
      purchaseDate: DateTime.parse(json['purchaseDate']),
      totalPrice: (json['totalPrice'] as num).toInt(),
      machineId: (json['machineId'] as num).toInt(),
      items: (json['items'] as List)
          .map((item) => PurchaseItemModel.fromJson(item))
          .toList(),
    );
  }
}

class PurchaseItemModel {
  final int medicineId;
  final String medicineName;
  final int quantity;
  final int pricePerUnit;
  final int totalPriceUnit;

  PurchaseItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPriceUnit,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      medicineId: (json['medicineId'] as num).toInt(),
      medicineName: json['medicineName'],
      quantity: (json['quantity'] as num).toInt(),
      pricePerUnit: (json['pricePerUnit'] as num).toInt(),
      totalPriceUnit: (json['totalPriceUnit'] as num).toInt(),
    );
  }
}
