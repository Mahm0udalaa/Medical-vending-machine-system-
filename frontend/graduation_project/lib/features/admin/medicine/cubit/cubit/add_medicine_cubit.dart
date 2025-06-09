import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/data/models/new_medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_basic_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';

part 'add_medicine_state.dart';

class AddMedicineCubit extends Cubit<AddMedicineState> {
  final MedicineRepo repo;
  AddMedicineCubit(this.repo) : super(AddMedicineInitial());

  Future<void> addMedicine(NewMedicineModel model) async {
    emit(AddMedicineLoading());
    try {
      final newMedicine = await repo.addNewMedicine(model);
      emit(AddMedicineSuccess(newMedicine));
    } catch (e) {
      emit(AddMedicineError(e.toString()));
    }
  }
} 