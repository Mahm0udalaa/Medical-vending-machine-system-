part of 'forgot_password_cubit.dart';

abstract class ForgotPasswordState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordSuccess extends ForgotPasswordState {
  final String email;
  final String message;

  ForgotPasswordSuccess(this.email, this.message);

  @override
  List<Object?> get props => [email, message];
}

class ForgotPasswordFailure extends ForgotPasswordState {
  final String error;

  ForgotPasswordFailure(this.error);

  @override
  List<Object?> get props => [error];
}
