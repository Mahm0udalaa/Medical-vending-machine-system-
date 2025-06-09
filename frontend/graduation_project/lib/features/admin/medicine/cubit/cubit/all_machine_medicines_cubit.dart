import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';

part 'all_machine_medicines_state.dart';

class AllMachineMedicinesCubit extends Cubit<AllMachineMedicinesState> {
  final MedicineRepo repo;
  AllMachineMedicinesCubit(this.repo) : super(AllMachineMedicinesInitial());

  Future<void> fetchMedicines(int machineId) async {
    emit(AllMachineMedicinesLoading());
    try {
      final medicines = await repo.getMachineMedicines(machineId);
      if (medicines.isEmpty) {
        emit(AllMachineMedicinesEmpty());
      } else {
        emit(AllMachineMedicinesLoaded(medicines));
      }
    } catch (e) {
      final errorMessage = e.toString();
      emit(AllMachineMedicinesError(errorMessage));
    }
  }

  void updateMedicineQuantity(int medicineId, int newQuantity) {
    if (state is AllMachineMedicinesLoaded) {
      final loadedState = state as AllMachineMedicinesLoaded;
      final updatedList = loadedState.medicines.map((med) {
        if (med.medicineId == medicineId) {
          return MedicineModel(
            machineId: med.machineId,
            machineLocation: med.machineLocation,
            medicineId: med.medicineId,
            medicineName: med.medicineName,
            description: med.description,
            imagePath: med.imagePath,
            categoryId: med.categoryId,
            quantity: newQuantity,
            price: med.price,
            medicinePrice: med.medicinePrice,
            slot: med.slot,
          );
        }
        return med;
      }).toList();
      emit(AllMachineMedicinesLoaded(updatedList));
    }
  }

  Future<void> deleteMedicine(int machineId, int medicineId) async {
    if (state is AllMachineMedicinesLoaded) {
      try {
        await repo.deleteMedicine(machineId, medicineId);
        final loadedState = state as AllMachineMedicinesLoaded;
        final updatedList = loadedState.medicines.where((med) => med.medicineId != medicineId).toList();
        emit(AllMachineMedicinesLoaded(updatedList));
      } catch (e) {
        // يمكنك إظهار رسالة خطأ هنا
      }
    }
  }
}
