import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/cubit/cubit/all_machine_medicines_cubit.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/presentation/screens/product_view.dart';

class MedicineCard extends StatelessWidget {
  final MedicineModel? model;
  final VoidCallback? onAdd;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showWarning;
  final bool isAddCard;

  const MedicineCard({
    super.key,
    this.model,
    this.onAdd,
    this.onTap,
    this.onDelete,
    this.showWarning = false,
    this.isAddCard = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          isAddCard || model == null
              ? onAdd
              : () async {
                final newQuantity = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductView(medicine: model!),
                  ),
                );
                if (newQuantity != null) {
                  context
                      .read<AllMachineMedicinesCubit>()
                      .updateMedicineQuantity(model!.medicineId!, newQuantity);
                }
              },
      child: Stack(
        children: [
          Container(
            width: 150,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child:
                isAddCard
                    ? AddNewMedicineWidget()
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),

                        Expanded(
                          child:
                              model?.imagePath != null
                                  ? Image.network(
                                    model!.imagePath!,
                                    height: 80,
                                    width: 100,
                                    fit: BoxFit.cover,
                                  )
                                  : Container(
                                    height: 80,
                                    width: 100,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                  ),
                        ),

                        /// Quantity / Out of Stock
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.topRight,
                          child:
                              model?.quantity != 0
                                  ? Container(
                                    padding: const EdgeInsets.all(7),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                    ),
                                    child: Text(
                                      model?.quantity.toString() ?? '',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )
                                  : const Text(
                                    "Out of stock!",
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontSize: 12,
                                    ),
                                  ),
                        ),

                        /// Price and Slot
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${model?.medicinePrice ?? 0} EGP',
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                               " Slot: ${model?.slot ?? ''}" ,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// Name and ID
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                model?.medicineName ?? '',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            // Expanded(
                            //   child: Text(
                            //     "ID: ${model?.medicineId.toString()}",
                            //     style: const TextStyle(
                            //       fontSize: 12,
                            //       color: Colors.black,
                            //     ),
                            //     overflow: TextOverflow.ellipsis,
                            //     textAlign: TextAlign.left,
                            //   ),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        /// Description
                        Text(
                          model?.description ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
          ),

          /// Delete Button - Only show if not Add Card
          if (!isAddCard)
            Positioned(
              top: 4,
              left: 4,
              child: CircleAvatar(
                backgroundColor: Colors.red,
                radius: 16,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                  onPressed: () {
                    context.read<AllMachineMedicinesCubit>().deleteMedicine(
                      model!.machineId!,
                      model!.medicineId!,
                    );
                  },
                  tooltip: "Delete",
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class AddNewMedicineWidget extends StatelessWidget {
  const AddNewMedicineWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.add_circle, color: Colors.green, size: 40),
        const SizedBox(height: 10),
        Text(
          'Add New Medicine',
          style: TextStyle(
            color: Colors.grey[700],
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
