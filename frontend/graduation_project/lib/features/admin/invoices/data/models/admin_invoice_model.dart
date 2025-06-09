class AdminInvoiceModel {
  final int purchaseId;
  final String purchaseDate;
  final double totalPrice; // تم تعديلها
  final int machineId;
  final int customerId;
  final List<AdminInvoiceItemModel> items;

  AdminInvoiceModel({
    required this.purchaseId,
    required this.purchaseDate,
    required this.totalPrice,
    required this.machineId,
    required this.customerId,
    required this.items,
  });

  factory AdminInvoiceModel.fromJson(Map<String, dynamic> json) {
    return AdminInvoiceModel(
      purchaseId: json['purchaseId'],
      purchaseDate: json['purchaseDate'],
      totalPrice: (json['totalPrice'] as num).toDouble(), // safe cast
      machineId: json['machineId'],
      customerId: json['customerId'],
      items: (json['items'] as List)
          .map((e) => AdminInvoiceItemModel.fromJson(e))
          .toList(),
    );
  }
}

class AdminInvoiceItemModel {
  final int medicineId;
  final String medicineName;
  final int quantity;
  final double pricePerUnit; 
  final double totalPriceUnit; 
  final String imagePath;

  AdminInvoiceItemModel({
    required this.medicineId,
    required this.medicineName,
    required this.quantity,
    required this.pricePerUnit,
    required this.totalPriceUnit,
    required this.imagePath,
  });

  factory AdminInvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return AdminInvoiceItemModel(
      medicineId: json['medicineId'],
      medicineName: json['medicineName'],
      quantity: json['quantity'],
      pricePerUnit: (json['pricePerUnit'] as num).toDouble(),
      totalPriceUnit: (json['totalPriceUnit'] as num).toDouble(),
      imagePath: json['imagePath'] ?? '',
    );
  }
}
