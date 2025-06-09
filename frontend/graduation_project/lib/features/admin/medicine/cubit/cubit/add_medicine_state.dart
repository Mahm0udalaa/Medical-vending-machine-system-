part of 'add_medicine_cubit.dart';

abstract class AddMedicineState {}

class AddMedicineInitial extends AddMedicineState {}
class AddMedicineLoading extends AddMedicineState {}
class AddMedicineSuccess extends AddMedicineState {
  final MedicineBasicModel medicine;
  AddMedicineSuccess(this.medicine);
}
class AddMedicineError extends AddMedicineState {
  final String message;
  AddMedicineError(this.message);
} 