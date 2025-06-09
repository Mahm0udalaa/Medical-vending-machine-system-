part of 'confirm_order_cubit.dart';

abstract class ConfirmOrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ConfirmOrderInitial extends ConfirmOrderState {}
class ConfirmOrderLoading extends ConfirmOrderState {}
class ConfirmOrderMotorSuccess extends ConfirmOrderState {
  final String message;
  ConfirmOrderMotorSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class ConfirmOrderMotorError extends ConfirmOrderState {
  final String message;
  ConfirmOrderMotorError(this.message);
  @override
  List<Object?> get props => [message];
}
class ConfirmOrderSuccess extends ConfirmOrderState {
  final String message;
  ConfirmOrderSuccess(this.message);
  @override
  List<Object?> get props => [message];
}
class ConfirmOrderError extends ConfirmOrderState {
  final String message;
  ConfirmOrderError(this.message);
  @override
  List<Object?> get props => [message];
}
