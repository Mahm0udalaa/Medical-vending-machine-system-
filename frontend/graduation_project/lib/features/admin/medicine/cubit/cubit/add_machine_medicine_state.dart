part of 'add_machine_medicine_cubit.dart';

abstract class AddMachineMedicineState {}

class AddMachineMedicineInitial extends AddMachineMedicineState {}
class AddMachineMedicineLoading extends AddMachineMedicineState {}
class AddMachineMedicineSuccess extends AddMachineMedicineState {
  final String message;
  AddMachineMedicineSuccess(this.message);
}
class AddMachineMedicineError extends AddMachineMedicineState {
  final String message;
  AddMachineMedicineError(this.message);
} 