part of 'all_medicine_cart_cubit.dart';

sealed class AllMedicineCartState extends Equatable {
  const AllMedicineCartState();

  @override
  List<Object> get props => [];
}

final class AllMedicineCartInitial extends AllMedicineCartState {}

final class AllMedicineCartLoading extends AllMedicineCartState {}

final class AllMedicineCartLoaded extends AllMedicineCartState {
  final List<dynamic> medicines;
  const AllMedicineCartLoaded(this.medicines);
  @override
  List<Object> get props => [medicines];
}

final class AllMedicineCartEmpty extends AllMedicineCartState {}

final class AllMedicineCartError extends AllMedicineCartState {
  final String message;
  const AllMedicineCartError(this.message);
  @override
  List<Object> get props => [message];
}
