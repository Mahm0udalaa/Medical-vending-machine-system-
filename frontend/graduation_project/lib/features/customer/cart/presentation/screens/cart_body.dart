import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/customer/cart/presentation/widgets/cart_card.dart';
import 'package:graduation_project/features/customer/cart/presentation/widgets/total_container.dart';
import 'package:graduation_project/features/customer/payment/presentation/screens/checkout_view.dart';

import '../../cubits/cubit/all_medicine_cart_cubit.dart';
import '../../data/models/all_medicines_cart_model.dart';
import '../../data/repos/all_medicines_cart_repo.dart';
import 'empty_cart_body.dart';

class CartBody extends StatelessWidget {
  const CartBody({super.key});
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              AllMedicineCartCubit(AllMedicinesCartRepo())
                ..fetchCartMedicines(),
      child: BlocBuilder<AllMedicineCartCubit, AllMedicineCartState>(
        builder: (context, state) {
          if (state is AllMedicineCartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AllMedicineCartError) {
            return Center(child: Text(state.message));
          } else if (state is AllMedicineCartEmpty) {
            return const EmptyCartBody();
          } else if (state is AllMedicineCartLoaded) {
            final List<CartMedicineModel> medicines =
                List<CartMedicineModel>.from(state.medicines);
            final total = medicines.fold<double>(
              0,
              (sum, item) => sum + (item.price * item.quantity),
            );

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // App bar
                        const Padding(
                          padding: EdgeInsets.only(left: 32.0),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Cart",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1B5E37),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Info bar
                        Container(
                          decoration: const BoxDecoration(
                            color: Color(0xffEBF9F1),
                          ),
                          width: double.infinity,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "You have ${medicines.length} items in your cart",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xff1B5E37),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // List of medicines
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: medicines.length,
                          itemBuilder: (context, index) {
                            final med = medicines[index];
                            return CartCard(
                              medicineId: med.medicineId,
                              image: med.imagePath,
                              name: med.medicineName,
                              price: med.price.toInt(),
                              addedMedicineQuantity: med.quantity,
                              quantity: med.quantity,
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Remove all button
                        Padding(
                          padding: const EdgeInsets.only(right: 24.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                final cubit =
                                    context.read<AllMedicineCartCubit>();
                                final message =
                                    await cubit.deleteAllCartMedicines();
                                if (message != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(message),backgroundColor: Colors.green,),
                                    
                                  );
                                }
                              },
                              child: const Text(
                                "Remove All",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 255, 0, 0),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Total price container
                        TotalContainer(price: "$total EGP"),

                        const SizedBox(height: 16),

                        // Checkout button
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => CheckoutView(
                                        medicines: medicines,
                                        totalPrice: total,
                                      ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff26864E),
                              minimumSize: const Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              "Checkout",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
