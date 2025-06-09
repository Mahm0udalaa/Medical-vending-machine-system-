import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/features/customer/cart/data/models/all_medicines_cart_model.dart';
import 'package:graduation_project/features/customer/payment/cubit/cubit/confirm_order_cubit.dart';
import 'package:graduation_project/features/customer/payment/data/repos/confirm_order_repo.dart';
import 'package:graduation_project/features/customer/payment/presentation/screens/order_summary_view.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/step_circle.dart';
import 'package:graduation_project/features/customer/payment/presentation/widgets/step_divider.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class CheckoutView extends StatefulWidget {
  final List<CartMedicineModel> medicines;
  final double totalPrice;

  const CheckoutView({
    super.key,
    required this.medicines,
    required this.totalPrice,
  });

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final _formKey = GlobalKey<FormState>();
  final _cardholderController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _expirationDateController = TextEditingController();

  final _expiryFormatter = MaskTextInputFormatter(
    mask: '##/##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _cardholderController.dispose();
    _cardNumberController.dispose();
    _cvvController.dispose();
    _expirationDateController.dispose();
    super.dispose();
  }

  bool _isValidExpiryDate(String value) {
    if (!_expiryFormatter.isFill()) return false;
    final parts = value.split('/');
    final month = int.tryParse(parts[0]);
    final year = int.tryParse('20${parts[1]}');
    if (month == null || year == null) return false;
    if (month < 1 || month > 12) return false;
    final now = DateTime.now();
    final lastDayOfMonth = DateTime(year, month + 1, 0);
    return lastDayOfMonth.isAfter(now);
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _cardholderController.clear();
    _cardNumberController.clear();
    _cvvController.clear();
    _expirationDateController.clear();
    setState(() {}); // refresh UI
  }

  String? _getCardNumberSuffix() {
    final text = _cardNumberController.text;
    if (text.length >= 4) {
      return text.substring(text.length - 4);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    const greenColor = Color(0xff26864E);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: greenColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'checkout  payment',
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StepCircle(isActive: true, label: 'pay'),
                      StepDivider(),
                      StepCircle(isActive: false, label: 'Summary'),
                      StepDivider(),
                      StepCircle(isActive: false, label: 'pick up order'),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Choose your preferred payment method:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _PaymentIcon(asset: 'assets/visa_image.png'),
                      _PaymentIcon(asset: 'assets/master_card.png'),
                      _PaymentIcon(asset: 'assets/paypal_image.png'),
                      _PaymentIcon(asset: 'assets/apple_pay.png'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _cardholderController,
                    decoration: _inputDecoration('Cardholder Name'),
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'Please enter the cardholder name'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: _inputDecoration('Card Number'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter card number';
                      }
                      if (value.length != 16) {
                        return 'Card number must be 16 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _cvvController,
                          decoration: _inputDecoration('CVV'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter CVV';
                            }
                            if (value.length != 3) {
                              return 'CVV must be 3 digits';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _expirationDateController,
                          decoration: _inputDecoration('Expiration Date'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [_expiryFormatter],
                          autovalidateMode: AutovalidateMode.onUserInteraction,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Enter expiration date';
                            }
                            if (!_isValidExpiryDate(value)) {
                              return 'Invalid or expired date (MM/YY)';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: true,
                        activeColor: greenColor,
                        onChanged: (_) {},
                      ),
                      const Text('Save card information'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: 'Confirm & Continue',
                    width: double.infinity,
                    backgroundcolor: greenColor,
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final cardSuffix = _getCardNumberSuffix();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BlocProvider(
                                  create:
                                      (_) => ConfirmOrderCubit(
                                        ConfirmOrderRepo(
                                          dio: Dio(),
                                          storage: const FlutterSecureStorage(),
                                        ),
                                      ),
                                  child: OrderSummaryView(
                                    medicines: widget.medicines,
                                    totalPrice: widget.totalPrice,
                                    cardSuffix: cardSuffix,
                                  ),
                                ),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SizedBox(
                      width: 200,
                      child: CustomButton(
                        text: 'Reset Form',
                        width: double.infinity,
                        backgroundcolor: greenColor,
                        onPressed: _resetForm,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    const borderColor = Color(0xff26864E);
    return InputDecoration(
      labelText: label,
      isDense: true,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }
}

class _PaymentIcon extends StatelessWidget {
  final String asset;
  const _PaymentIcon({required this.asset});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(asset, width: 40, height: 28),
    );
  }
}
