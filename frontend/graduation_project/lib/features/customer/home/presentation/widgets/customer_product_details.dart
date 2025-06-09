  import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/customer/cart/data/repos/all_medicines_cart_repo.dart';

import '../../cubit/cart_cubit.dart';
import '../../data/repos/cart_repo.dart';

class CustomerProductDetails extends StatelessWidget {
   CustomerProductDetails({
    super.key,
    this.medicine,
    required this.medName,
    required this.description,
    required this.price,
    required this.imagePath,
    this.slot,
    this.quantity, 
    required  this.medicineId, 
    required this.machineId,
  });
  final int medicineId, machineId;
  final MedicineModel? medicine;
  final String medName, description;
  final String? price;
  final String imagePath;
  final String? slot;
  final String? quantity;
  int addedMedicineQuantity = 0;

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (_) => CartCubit(CartRepo()),
      child: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) async {
          if (state is CartSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Medicine with Name ${medicine?.medicineName} from machine Name ${medicine?.machineLocation} added successfully to cart',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is CartError) {
            if (state.message.contains(
              'Cannot add items from different machines',
            )) {
              await addingFromDifferentMachinedErrorDialog(context, state);
            } else if (state.message.contains('already in the cart')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: const Color(0xff26864E),
              centerTitle: true,
              elevation: 0,
              title: Text(
                medicine?.medicineName ?? "",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: screenHeight / 3,
                      width: double.infinity,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      medName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 22,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            width: 90,
                            child: Material(
                              child: SpinBox(
                                value: addedMedicineQuantity.toDouble(),
                                min: 1,
                                max: 100,
                                textStyle: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,
                                incrementIcon: const Icon(
                                  FontAwesomeIcons.plus,
                                  color: Color.fromARGB(255, 10, 187, 10),
                                ),
                                decrementIcon: const Icon(
                                  FontAwesomeIcons.minus,
                                  color: Color.fromARGB(255, 255, 0, 0),
                                ),
                                onChanged: (value) {
                                  addedMedicineQuantity = value.toInt();
                                },
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8),
                                    ),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            '${price ?? ""} EGP',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Quantity: ${quantity ?? '-'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Expanded(
                          child: Text(
                            "Slot: ${slot ?? '-'}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      "Product details",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xff6C7278),
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomButton(
                      onPressed:
                          state is CartLoading
                              ? null
                              : () {
                                 if (addedMedicineQuantity < 1) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Quantity must be at least 1',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                             
                               
                                context.read<CartCubit>().addToCart(
                                  machineId:machineId,
                                  medicineId: medicineId,
                                  quantity: addedMedicineQuantity,
                                );
                              },
                      text: state is CartLoading ? "Adding..." : "Add To Cart",
                      backgroundcolor: const Color(0xff26864E),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<Object?> addingFromDifferentMachinedErrorDialog(
    BuildContext context,
    CartError state,
  ) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Cart Deletion Dialog",
      barrierColor: Colors.black.withAlpha((0.3 * 255).toInt()),
      pageBuilder: (context, animation, secondaryAnimation) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
          child: Material(
            type: MaterialType.transparency,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              context.read<CartCubit>().emit(CartInitial());
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[200],
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('No'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final repo = AllMedicinesCartRepo();
                              try {
                                final message =
                                    await repo.deleteAllCartMedicines();
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(message),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } catch (e) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(e.toString()),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Delete All Cart'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
