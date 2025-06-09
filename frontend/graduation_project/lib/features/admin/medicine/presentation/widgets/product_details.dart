import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:graduation_project/core/widgets/custem_button.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/screens/admin_home_view.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/medicine_refill_state.dart';

import '../../cubit/cubit/medicine_refill_cubit.dart';
import '../../data/models/medicine_model.dart';
import '../../data/models/medicine_refill_model.dart';
import '../../data/repos/medicine_refill_repo.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({
    super.key,
    required this.medicine,
    required this.medName,
    required this.medMG,
    required this.medPills,
    required this.description,
    required this.price,
    required this.imagePath,
  });

  final MedicineModel? medicine;
  final String medName, medMG, medPills, description;
  final String? price;
  final String imagePath;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  late int updatedQuantity;

  @override
  void initState() {
    super.initState();
    updatedQuantity = widget.medicine?.quantity ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return BlocProvider(
      create: (_) => MedicineRefillCubit(MedicineRefillRepo()),
      child: BlocListener<MedicineRefillCubit, MedicineRefillState>(
        listener: (context, state) {
          if (state is MedicineRefillSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Quantity of Medicine with name ${widget.medName} has been updated to $updatedQuantity',
                ),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => AdminHomeView()),
                (route) => false,
              );
            });
          } else if (state is MedicineRefillFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        child: SliverToBoxAdapter(
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
                      widget.imagePath,
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
                  widget.medName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 22,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.medMG,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    color: Color(0xff6C7278),
                  ),
                ),
                const SizedBox(height: 12),
                Text(widget.medPills),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        width:
                            90, 
                        child: SpinBox(
                          value: updatedQuantity.toDouble(),
                          min: 1,
                          max: 6,
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
                            updatedQuantity = value.toInt();
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(horizontal: 2),
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
                    const Spacer(),
                    Expanded(
                      child: Text(
                        '${widget.price ?? ""} EGP',
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
                const Text(
                  "Product details",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.description,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xff6C7278),
                  ),
                ),
                const SizedBox(height: 32),
                BlocBuilder<MedicineRefillCubit, MedicineRefillState>(
                  builder: (context, state) {
                    return CustomButton(
                      onPressed:
                          state is MedicineRefillLoading
                              ? null
                              : () {
                                if (widget.medicine?.machineId == null ||
                                    widget.medicine?.medicineId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Invalid machine or medicine id',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                context
                                    .read<MedicineRefillCubit>()
                                    .refillMedicine(
                                      MedicineRefillModel(
                                        machineId: widget.medicine!.machineId!,
                                        medicineId:
                                            widget.medicine!.medicineId!,
                                        quantity: updatedQuantity,
                                      ),
                                    );
                              },
                      text:
                          state is MedicineRefillLoading
                              ? 'Refilling...'
                              : 'ReFill',
                      backgroundcolor: const Color(0xff26864E),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
