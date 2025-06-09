import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/data/models/machine_medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/machine_medicine_repo.dart';

part 'add_machine_medicine_state.dart';

class AddMachineMedicineCubit extends Cubit<AddMachineMedicineState> {
  final MachineMedicineRepo repo;
  AddMachineMedicineCubit(this.repo) : super(AddMachineMedicineInitial());

  Future<void> addMedicineToMachine(MachineMedicineModel model) async {
    emit(AddMachineMedicineLoading());
    final result = await repo.addMedicineToMachine(model);
    if (result['success'] == true) {
      emit(AddMachineMedicineSuccess(result['message']));
    } else {
      emit(AddMachineMedicineError(result['message']));
    }
  }
} 