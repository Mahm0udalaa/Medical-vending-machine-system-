import 'package:flutter_bloc/flutter_bloc.dart';
import 'machine_medicine_state.dart';
import '../../data/repos/machine_medicine_repo.dart';

class MachineMedicineCubit extends Cubit<MachineMedicineState> {
  final MachineMedicineRepo repo;
  MachineMedicineCubit(this.repo) : super(MachineMedicineInitial());

  Future<void> fetchMachineMedicines(int machineId) async {
    emit(MachineMedicineLoading());
    try {
      final medicines = await repo.fetchMachineMedicines(machineId);
      if (medicines.isEmpty) {
        emit(MachineMedicineEmpty());
      } else {
        emit(MachineMedicineLoaded(medicines));
      }
    } catch (e) {
      emit(MachineMedicineError(e.toString()));
    }
  }
} 