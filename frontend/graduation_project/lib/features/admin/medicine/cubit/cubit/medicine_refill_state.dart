abstract class MedicineRefillState {}

class MedicineRefillInitial extends MedicineRefillState {}

class MedicineRefillLoading extends MedicineRefillState {}

class MedicineRefillSuccess extends MedicineRefillState {
  final String message;
  MedicineRefillSuccess(this.message);
}

class MedicineRefillFailure extends MedicineRefillState {
  final String error;

  MedicineRefillFailure(this.error);
}
