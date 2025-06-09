import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_refill_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_refill_repo.dart';

import 'medicine_refill_state.dart';

class MedicineRefillCubit extends Cubit<MedicineRefillState> {
  final MedicineRefillRepo repo;

  MedicineRefillCubit(this.repo) : super(MedicineRefillInitial());

  Future<void> refillMedicine(MedicineRefillModel model) async {
    emit(MedicineRefillLoading());
    final result = await repo.refillMedicine(model);
    if (result['success'] == true) {
      emit(MedicineRefillSuccess(result['message']));
    } else {
      emit(MedicineRefillFailure(result['message'] ?? 'Failed to update quantity'));
    }
  }
}
