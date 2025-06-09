import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:graduation_project/features/admin/medicine/data/models/medicine_basic_model.dart';
import 'package:graduation_project/features/admin/medicine/data/repos/medicine_repo.dart';

part 'medicines_state.dart';

class MedicinesCubit extends Cubit<MedicinesState> {
  final MedicineRepo repo;
  MedicinesCubit(this.repo) : super(MedicinesInitial());

  Future<void> fetchAllMedicines() async {
    emit(MedicinesLoading());
    try {
      final medicines = await repo.getAllMedicines();
      emit(MedicinesLoaded(medicines));
    } catch (e) {
      //todo 
      // emit(MedicinesError(e.toString()));
    }
  }
} 