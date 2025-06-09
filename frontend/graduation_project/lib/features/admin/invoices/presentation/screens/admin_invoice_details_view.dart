import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/admin/invoices/data/models/admin_invoice_model.dart';

class AdminInvoiceDetailsView extends StatelessWidget {
  final AdminInvoiceModel invoice;
  const AdminInvoiceDetailsView({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        title: const Text(
          'Order Details',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        backgroundColor: MyColors.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomCenter,
            colors:
                MyColors
                    .backgroundColor, 
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.white,
                child: Text(
                  'you have ${invoice.items.length} items in your order',
                  style: const TextStyle(color:MyColors.primaryColor, fontSize: 16),
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true, 
              physics: const NeverScrollableScrollPhysics(), 
              padding: const EdgeInsets.all(16.0),
              itemCount: invoice.items.length,
              itemBuilder: (context, index) {
                final item = invoice.items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        if (item.imagePath.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              item.imagePath,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) => Container(
                                width: 70,
                                height: 70,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              color: Colors.grey[200],
                            ),
                            child: const Icon(
                              Icons.medication,
                              color: Colors.grey,
                            ),
                          ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.medicineName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text('ID: ${item.medicineId}'),
                              Text('Quantity: ${item.quantity}'),
                              Text(
                                'Price per unit: ${item.pricePerUnit} EGP',
                              ),
                              Text('Total: ${item.totalPriceUnit} EGP'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            // الـ Card الخاصة بالمجموع تم نقلها مباشرة بعد الـ ListView
            Padding(
              padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Subtotal',
                                style: TextStyle(fontSize: 16),
                              ),
                              Text('${invoice.totalPrice}'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Discount', style: TextStyle(fontSize: 16)),
                              Text('0'),
                            ],
                          ),
                          const Divider(height: 24, thickness: 1),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.primaryColor,
                                ),
                              ),
                              Text(
                                '${invoice.totalPrice} EGP',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: MyColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}