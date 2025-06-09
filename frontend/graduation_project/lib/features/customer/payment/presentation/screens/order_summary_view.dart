import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/features/customer/cart/data/models/all_medicines_cart_model.dart';
import 'package:graduation_project/features/customer/payment/cubit/cubit/confirm_order_cubit.dart';
import 'package:graduation_project/features/customer/payment/presentation/screens/success_view.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/step_circle.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/step_divider.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/failed_payment_dialog.dart';

class OrderSummaryView extends StatefulWidget {
  final List<CartMedicineModel> medicines;
  final double discount;
  final double totalPrice;
  final String? cardSuffix;
  const OrderSummaryView({
    super.key,
    required this.medicines,
    required this.totalPrice,
    this.cardSuffix,
    this.discount = 0,
  });

  @override
  State<OrderSummaryView> createState() => _OrderSummaryViewState();
}

class _OrderSummaryViewState extends State<OrderSummaryView> {
  @override
  Widget build(BuildContext context) {
    final machineLocation =
        widget.medicines.isNotEmpty
            ? widget.medicines.first.machineLocation
            : '';
    return BlocConsumer<ConfirmOrderCubit, ConfirmOrderState>(
      listener: (context, state) async {
        if (state is ConfirmOrderMotorError) {
          showFailedPaymentDialog(context);
        } else if (state is ConfirmOrderSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => SuccessView(medicines: widget.medicines),
            ),
          );
        } else if (state is ConfirmOrderError) {
          showFailedPaymentDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xff26864E),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Order Summary',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StepCircle(isActive: true, label: 'pay'),
                    StepDivider(),
                    StepCircle(isActive: true, label: 'Summary'),
                    StepDivider(),
                    StepCircle(isActive: false, label: 'pick up order'),
                  ],
                ),
                const SizedBox(height: 32),
                const Text(
                  'Order Summary',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                _SummaryRow(
                  label: 'Subtotal',
                  value: '${widget.totalPrice.toStringAsFixed(2)} EGP',
                ),
                _SummaryRow(
                  label: 'discount',
                  value: '${widget.discount.toStringAsFixed(2)} EGP',
                ),
                _SummaryRow(
                  label: 'total',
                  value:
                      '${(widget.totalPrice - widget.discount).toStringAsFixed(2)} EGP',
                  isBold: true,
                ),

                const SizedBox(height: 24),
                const Text(
                  'Please confirm your order',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _PaymentMethodCard(cardSuffix: widget.cardSuffix),
                const SizedBox(height: 16),
                _LocationCard(location: machineLocation ?? ''),
                const Spacer(),
                if (state is ConfirmOrderLoading)
                  const Center(child: CircularProgressIndicator()),
                if (state is! ConfirmOrderLoading)
                  CustomButton(
                    text: "Confirm Order",
                    width: double.infinity,
                    backgroundcolor: const Color(0xff26864E),
                    onPressed:
                        state is ConfirmOrderLoading
                            ? null
                            : () {
                              context
                                  .read<ConfirmOrderCubit>()
                                  .confirmOrderWithDispense(widget.medicines);
                            },
                  ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  final String? cardSuffix;
  const _PaymentMethodCard({this.cardSuffix});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Image.asset('assets/visa_image.png', width: 40),
        title: Text('**** **** **** ${cardSuffix ?? '****'}'),
        subtitle: const Text('Payment Method'),
        trailing: TextButton(
          onPressed: () {},
          child: const Text('edit', style: TextStyle(color: Color(0xff26864E))),
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String location;
  const _LocationCard({required this.location});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Color(0xff26864E)),
        title: const Text('vending machine location'),
        subtitle: Text(location),
        trailing: TextButton(
          onPressed: () {},
          child: const Text('edit', style: TextStyle(color: Color(0xff26864E))),
        ),
      ),
    );
  }
}
