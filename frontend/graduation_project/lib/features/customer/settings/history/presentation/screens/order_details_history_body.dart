import 'package:flutter/material.dart';
import 'package:graduation_project/core/constants/my_colors.dart';
import 'package:graduation_project/features/customer/settings/history/data/models/history_model.dart';
import 'package:graduation_project/features/customer/settings/history/presentation/widgets/total_price.dart';

class OrderDetailsHistoryBody extends StatelessWidget {
  final List<PurchaseItemModel> items;
  const OrderDetailsHistoryBody({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    int subtotal = items.fold(0, (sum, item) => sum + item.totalPriceUnit);
    int discount = 0; 
    int total = subtotal - discount;
    return Scaffold(
      appBar: AppBar(
            title: const Text("Order Details",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            backgroundColor: Color(0xff1B5E37),
            centerTitle: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
      body: Container(
        width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomCenter,
              colors: MyColors.backgroundColor,
            ),
          ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Container(
                      decoration: const BoxDecoration(color: Color(0xffEBF9F1)),
                      width: double.infinity,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "you have ${items.length} items in your order",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: Color(0xff1B5E37),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    ...items.map((item) => _OrderItemCard(item: item)),
                    TotalPrice(subtotal: subtotal.toString(), discount: discount.toString(), total: total.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _OrderItemCard extends StatelessWidget {
  final PurchaseItemModel item;
  const _OrderItemCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color.fromARGB(172, 27, 94, 55)),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withAlpha((0.12 * 255).toInt()),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              "assets/medicen.png",
              height: 60,
              width: 60,
              fit: BoxFit.cover,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B5E37),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
               
                const SizedBox(height: 6),
                Text(
                  "Quantity: ${item.quantity}",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  "Price per unit: ${item.pricePerUnit} EGP",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  "Total: ${item.totalPriceUnit} EGP",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
