import 'package:equatable/equatable.dart';
import '../../data/models/machine_medicine_model.dart';

abstract class MachineMedicineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MachineMedicineInitial extends MachineMedicineState {}
class MachineMedicineLoading extends MachineMedicineState {}
class MachineMedicineLoaded extends MachineMedicineState {
  final List<MachineMedicineModel> medicines;
  MachineMedicineLoaded(this.medicines);
  @override
  List<Object?> get props => [medicines];
}
class MachineMedicineEmpty extends MachineMedicineState {}
class MachineMedicineError extends MachineMedicineState {
  final String message;
  MachineMedicineError(this.message);
  @override
  List<Object?> get props => [message];
} 