part of 'all_machine_medicines_cubit.dart';

sealed class AllMachineMedicinesState extends Equatable {
  const AllMachineMedicinesState();

  @override
  List<Object> get props => [];
}

final class AllMachineMedicinesInitial extends AllMachineMedicinesState {}

class AllMachineMedicinesLoading extends AllMachineMedicinesState {}

class AllMachineMedicinesLoaded extends AllMachineMedicinesState {
  final List<MedicineModel> medicines;
  const AllMachineMedicinesLoaded(this.medicines);

  @override
  List<Object> get props => [medicines];
}

class AllMachineMedicinesError extends AllMachineMedicinesState {
  final String message;
  const AllMachineMedicinesError(this.message);

  @override
  List<Object> get props => [message];
}

class AllMachineMedicinesNotFound extends AllMachineMedicinesState {
  final int machineId;
  const AllMachineMedicinesNotFound(this.machineId);

  @override
  List<Object> get props => [machineId];
}

class AllMachineMedicinesEmpty extends AllMachineMedicinesState {}
