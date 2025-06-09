part of 'fav_medicine_cubit.dart';

sealed class FavMedicineState extends Equatable {
  const FavMedicineState();

  @override
  List<Object> get props => [];
}

final class FavMedicineInitial extends FavMedicineState {}

final class FavMedicineLoading extends FavMedicineState {}

final class FavMedicineLoaded extends FavMedicineState {
  final List<dynamic> favMedicines;
  const FavMedicineLoaded(this.favMedicines);

  @override
  List<Object> get props => [favMedicines];
}

final class FavMedicineEmpty extends FavMedicineState {}

final class FavMedicineError extends FavMedicineState {
  final String message;
  const FavMedicineError(this.message);

  @override
  List<Object> get props => [message];
}
