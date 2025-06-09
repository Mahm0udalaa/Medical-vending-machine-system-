import 'package:equatable/equatable.dart';
import '../../data/models/medicine_machine_model.dart';

abstract class MedicineMachineState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MachineInitial extends MedicineMachineState {}
class MachineLoading extends MedicineMachineState {}
class MachineLoaded extends MedicineMachineState {
  final List<MedicineMachineModel> machines;
  MachineLoaded(this.machines);
  @override
  List<Object?> get props => [machines];
}
class MachineEmpty extends MedicineMachineState {}
class MachineError extends MedicineMachineState {
  final String message;
  MachineError(this.message);
  @override
  List<Object?> get props => [message];
} 