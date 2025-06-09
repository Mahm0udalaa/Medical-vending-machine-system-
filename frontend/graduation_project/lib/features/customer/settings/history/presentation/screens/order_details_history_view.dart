import 'package:flutter/material.dart';
import 'package:graduation_project/features/customer/settings/history/data/models/history_model.dart';
import 'package:graduation_project/features/customer/settings/history/presentation/screens/order_details_history_body.dart';

class OrderDetailsHistoryView extends StatelessWidget {
  final List<PurchaseItemModel> items;
  const OrderDetailsHistoryView({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return  OrderDetailsHistoryBody(items: items);

  }
}
