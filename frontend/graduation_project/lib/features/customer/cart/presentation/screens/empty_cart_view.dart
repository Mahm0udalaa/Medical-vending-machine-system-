import 'package:flutter/material.dart';
import 'package:graduation_project/core/widgets/custom_view.dart';
import 'package:graduation_project/features/customer/cart/presentation/screens/empty_cart_body.dart';


class EmptyCartView extends StatelessWidget {
  const EmptyCartView({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomView(body: EmptyCartBody());
  }
}
