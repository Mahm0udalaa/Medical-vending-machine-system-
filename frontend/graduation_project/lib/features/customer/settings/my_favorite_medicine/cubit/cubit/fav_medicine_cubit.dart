  import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/repos/fav_medicine_repo.dart';


part 'fav_medicine_state.dart';

class FavMedicineCubit extends Cubit<FavMedicineState> {
  final FavMedicineRepo repo;
  FavMedicineCubit(this.repo) : super(FavMedicineInitial());

  Future<void> fetchFavMedicines() async {
    emit(FavMedicineLoading());
    try {
      final favs = await repo.fetchFavMedicines();
      if (favs.isEmpty) {
        emit(FavMedicineEmpty());
      } else {
        emit(FavMedicineLoaded(favs));
      }
    } catch (e) {
      emit(FavMedicineError(e.toString()));
    }
  }
}
