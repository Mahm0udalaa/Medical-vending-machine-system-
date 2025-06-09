import 'package:flutter_bloc/flutter_bloc.dart';
import 'medicine_machine_state.dart';
import '../../data/repos/medicine_machine_repo.dart';

class MedicineMachineCubit extends Cubit<MedicineMachineState> {
  final MedicineMachineRepo repo;
  MedicineMachineCubit(this.repo) : super(MachineInitial());

  Future<void> fetchMachines(int medicineId) async {
    emit(MachineLoading());
    try {
      final machines = await repo.fetchMachinesByMedicine(medicineId);
      if (machines.isEmpty) {
        emit(MachineEmpty());
      } else {
        emit(MachineLoaded(machines));
      }
    } catch (e) {
      emit(MachineError(e.toString()));
    }
  }
} 