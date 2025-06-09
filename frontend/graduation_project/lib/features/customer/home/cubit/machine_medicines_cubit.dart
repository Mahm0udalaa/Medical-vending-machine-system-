import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';

class MachineMedicinesCubit extends Cubit<List<MedicineModel>> {
  final MedicineRepo repo;
  MachineMedicinesCubit(this.repo) : super([]);

  Future<void> fetchMachineMedicines(int machineId) async {
    try {
      final medicines = await repo.getMachineMedicines(machineId);
      emit(medicines);
    } catch (e) {
      emit([]);
    }
  }

  void clear() => emit([]);
} 